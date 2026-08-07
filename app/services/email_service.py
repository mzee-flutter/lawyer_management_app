import os
import resend
from dotenv import load_dotenv

load_dotenv()

resend.api_key = os.getenv("RESEND_API_KEY")

# During Resend onboarding, before you verify your own domain, you can only
# send from "onboarding@resend.dev" and only to your own verified account
# email. Once you verify a domain (e.g. rightcase.app) in the Resend
# dashboard, switch RESEND_FROM_EMAIL to something like
# "RightCase <noreply@rightcase.app>".
FROM_EMAIL = os.getenv("RESEND_FROM_EMAIL", "RightCase <onboarding@resend.dev>")


def send_otp_email(to_email: str, otp: str, expiry_minutes: int) -> None:
    """
    Sends the password reset OTP. Raises on failure -- the caller decides
    whether to surface that failure, since the user is actively waiting
    for this code.
    """
    resend.Emails.send({
        "from": FROM_EMAIL,
        "to": [to_email],
        "subject": "Your RightCase password reset code",
        "html": f"""
            <div style="font-family: Arial, sans-serif; max-width: 480px; margin: 0 auto; padding: 24px;">
                <h2 style="color:#1A2744; margin-bottom: 8px;">Reset your password</h2>
                <p style="color:#333;">Use the code below to reset your RightCase password. This code expires in {expiry_minutes} minutes.</p>
                <p style="font-size:32px; font-weight:bold; letter-spacing:8px; color:#C8952A; margin: 24px 0;">{otp}</p>
                <p style="color:#666; font-size: 13px;">If you didn't request this, you can safely ignore this email -- your password will not be changed.</p>
            </div>
        """,
    })


def send_password_changed_email(to_email: str) -> None:
    """
    Best-effort security notification. Failure here should never block the
    password change itself, so callers should swallow exceptions from this.
    """
    resend.Emails.send({
        "from": FROM_EMAIL,
        "to": [to_email],
        "subject": "Your RightCase password was changed",
        "html": """
            <div style="font-family: Arial, sans-serif; max-width: 480px; margin: 0 auto; padding: 24px;">
                <h2 style="color:#1A2744; margin-bottom: 8px;">Password changed</h2>
                <p style="color:#333;">Your RightCase account password was just changed. You've been logged out on all other devices as a security precaution.</p>
                <p style="color:#666; font-size: 13px;">If this wasn't you, please contact support immediately.</p>
            </div>
        """,
    })


def send_account_deleted_email(to_email: str) -> None:
    """
    Best-effort. The user row is already gone from the DB by the time this
    fires -- this is purely a courtesy confirmation, never a condition for
    the deletion itself.
    """
    resend.Emails.send({
        "from": FROM_EMAIL,
        "to": [to_email],
        "subject": "Your RightCase account has been deleted",
        "html": """
            <div style="font-family: Arial, sans-serif; max-width: 480px; margin: 0 auto; padding: 24px;">
                <h2 style="color:#1A2744; margin-bottom: 8px;">Account deleted</h2>
                <p style="color:#333;">Your RightCase account and all associated data have been permanently deleted, as requested.</p>
                <p style="color:#666; font-size: 13px;">If you didn't request this, please contact support immediately.</p>
            </div>
        """,
    })