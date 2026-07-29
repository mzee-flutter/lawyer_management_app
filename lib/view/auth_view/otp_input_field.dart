import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:right_case/resources/system_design/rc_theme.dart';

class OtpInputField extends StatefulWidget {
  final void Function(String otp) onCompleted;
  final bool hasError;

  const OtpInputField({
    super.key,
    required this.onCompleted,
    this.hasError = false,
  });

  @override
  State<OtpInputField> createState() => OtpInputFieldState();
}

// Public (no leading underscore) so a parent screen can hold a
// GlobalKey<OtpInputFieldState> and call .clear() after a failed attempt.
class OtpInputFieldState extends State<OtpInputField> {
  static const int _length = 6;
  late final List<TextEditingController> _controllers;
  late final List<FocusNode> _focusNodes;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(_length, (_) => TextEditingController());
    _focusNodes = List.generate(_length, (_) => FocusNode());
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  void _onChanged(int index, String value) {
    if (value.isNotEmpty && index < _length - 1) {
      _focusNodes[index + 1].requestFocus();
    }
    _checkCompletion();
  }

  void _checkCompletion() {
    final otp = _controllers.map((c) => c.text).join();
    if (otp.length == _length) {
      FocusScope.of(context).unfocus();
      widget.onCompleted(otp);
    }
  }

  /// Clears all boxes and refocuses the first one. Call this from the
  /// parent screen after a failed verification attempt.
  void clear() {
    for (final c in _controllers) {
      c.clear();
    }
    _focusNodes[0].requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(_length, (index) {
            return SizedBox(
              width: 46.w,
              height: 56.h,
              child: Focus(
                onKeyEvent: (node, event) {
                  if (event is KeyDownEvent &&
                      event.logicalKey == LogicalKeyboardKey.backspace &&
                      _controllers[index].text.isEmpty &&
                      index > 0) {
                    _focusNodes[index - 1].requestFocus();
                  }
                  return KeyEventResult.ignored;
                },
                child: TextField(
                  controller: _controllers[index],
                  focusNode: _focusNodes[index],
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.number,
                  maxLength: 1,
                  style: TextStyle(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.w600,
                    color: RC.navy,
                  ),
                  decoration: InputDecoration(
                    counterText: '',
                    filled: true,
                    fillColor: RC.surface,
                    contentPadding: EdgeInsets.zero,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.r),
                      borderSide: BorderSide(
                        color: widget.hasError
                            ? RC.danger
                            : RC.navy.withValues(alpha: 0.25),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.r),
                      borderSide: BorderSide(
                        color: widget.hasError
                            ? RC.danger
                            : RC.navy.withValues(alpha: 0.25),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.r),
                      borderSide: BorderSide(
                        color: widget.hasError ? RC.danger : RC.gold,
                        width: 2.w,
                      ),
                    ),
                  ),
                  onChanged: (value) => _onChanged(index, value),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}
