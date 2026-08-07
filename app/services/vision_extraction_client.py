"""
Thin, swappable wrapper around whichever vision LLM does the actual OCR +
field extraction. Everything else in the scan pipeline talks to
`extract_hearing_fields()` only — never to the Gemini SDK/REST shape
directly — so switching providers, or models, when Google eventually
deprecates the current one, means editing this one file, nothing downstream.

Setup required:
  1. pip install httpx  (if not already installed)
  2. Set GEMINI_API_KEY in your .env — get a free key from
     https://aistudio.google.com/apikey
  3. (Optional) Set GEMINI_VISION_MODEL to override the default model if
     "gemini-2.5-flash" gets deprecated — check https://ai.google.dev/gemini-api/docs/models
     for the current recommended Flash-tier model at that time.
"""
import os
import base64
import json
import httpx

GEMINI_API_KEY = os.getenv("GEMINI_API_KEY")
GEMINI_MODEL = os.getenv("GEMINI_VISION_MODEL", "gemini-3.5-flash-lite")
GEMINI_URL = (
    f"https://generativelanguage.googleapis.com/v1beta/models/{GEMINI_MODEL}:generateContent"
)

_EXTRACTION_PROMPT = """You are analyzing a photograph of a Pakistani court document \
(an order sheet or next-hearing notice). Extract ONLY these fields: case number, \
case title (party names, e.g. "X vs Y"), court name, judge name, next hearing date, \
next hearing time.

Rules:
- If a field is not clearly present or is illegible, set it to null. Never guess or \
fabricate a value.
- Normalize hearing_date to YYYY-MM-DD. If the year is missing or ambiguous, use your \
best judgement based on context, but if you can't be reasonably confident, set it null \
instead of guessing.
- hearing_time uses 24-hour "HH:MM". Pakistani cause lists/order sheets very often state \
a date only, with no specific time — if no time is clearly written on the document, set \
hearing_time to null. Do not invent a default time.
- confidence is your own honest assessment of how reliable this extraction is overall: \
"high" if the document is clear and all key fields were legible, "medium" if some fields \
were unclear, "low" if the document was blurry, heavily handwritten, or mostly illegible.
"""

_RESPONSE_SCHEMA = {
    "type": "OBJECT",
    "properties": {
        "case_number": {"type": "STRING", "nullable": True},
        "case_title": {"type": "STRING", "nullable": True},
        "court_name": {"type": "STRING", "nullable": True},
        "judge_name": {"type": "STRING", "nullable": True},
        "hearing_date": {"type": "STRING", "nullable": True},
        "hearing_time": {"type": "STRING", "nullable": True},
        "confidence": {"type": "STRING", "enum": ["high", "medium", "low"]},
    },
    "required": ["confidence"],
}


class VisionExtractionError(Exception):
    """Raised when the vision API call fails or returns something we can't parse."""


async def extract_hearing_fields(image_bytes: bytes, mime_type: str = "image/jpeg") -> dict:
    """
    Sends the scanned image to the vision model and returns a dict with keys:
    case_number, case_title, court_name, judge_name, hearing_date, hearing_time,
    confidence, raw_model_text.

    Raises VisionExtractionError on any failure — the caller (ScanService)
    decides how to surface that to the lawyer; it should never bubble up as
    a raw 500 with an unhelpful message.
    """
    if not GEMINI_API_KEY:
        raise VisionExtractionError("GEMINI_API_KEY is not configured on the server.")

    payload = {
        "contents": [{
            "parts": [
                {"text": _EXTRACTION_PROMPT},
                {"inline_data": {"mime_type": mime_type, "data": base64.b64encode(image_bytes).decode()}},
            ]
        }],
        "generationConfig": {
            "responseMimeType": "application/json",
            "responseSchema": _RESPONSE_SCHEMA,
        },
    }

    try:
        async with httpx.AsyncClient(timeout=30.0) as client:
            response = await client.post(
                GEMINI_URL,
                headers={"x-goog-api-key": GEMINI_API_KEY, "Content-Type": "application/json"},
                json=payload,
            )
    except httpx.RequestError as e:
        raise VisionExtractionError(f"Could not reach the vision API: {e}") from e

    if response.status_code != 200:
        raise VisionExtractionError(
            f"Vision API returned {response.status_code}: {response.text[:300]}"
        )

    try:
        body = response.json()
        raw_text = body["candidates"][0]["content"]["parts"][0]["text"]
        parsed = json.loads(raw_text)
    except (KeyError, IndexError, json.JSONDecodeError) as e:
        raise VisionExtractionError(f"Unexpected response shape from vision API: {e}") from e

    return {
        "case_number": parsed.get("case_number"),
        "case_title": parsed.get("case_title"),
        "court_name": parsed.get("court_name"),
        "judge_name": parsed.get("judge_name"),
        "hearing_date": parsed.get("hearing_date"),
        "hearing_time": parsed.get("hearing_time"),
        "confidence": parsed.get("confidence", "low"),
        "raw_model_text": raw_text,
    }