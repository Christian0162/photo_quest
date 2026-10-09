import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../../config/constant/app_spacing.dart';

/// A labelled text field for the account screens. Keeps its own controller
/// (seeded from [initialValue]) and reports edits through [onChanged]; the
/// owning view model holds the real value. Errors appear under the field and
/// are read out by screen readers with the field.
///
/// Pass [onToggleObscured] to get a show/hide eye for password fields.
class MdAuthTextField extends StatefulWidget {
  const MdAuthTextField({
    super.key,
    required this.label,
    required this.onChanged,
    this.initialValue = '',
    this.errorText,
    this.helperText,
    this.obscured = false,
    this.onToggleObscured,
    this.keyboardType,
    this.autofillHints,
    this.textInputAction,
    this.onSubmitted,
    this.inputFormatters,
    this.textAlign = TextAlign.start,
    this.style,
    this.enabled = true,
    this.autofocus = false,
  });

  final String label;
  final ValueChanged<String> onChanged;
  final String initialValue;
  final String? errorText;
  final String? helperText;

  final bool obscured;
  final VoidCallback? onToggleObscured;
  final TextInputType? keyboardType;
  final Iterable<String>? autofillHints;
  final TextInputAction? textInputAction;
  final VoidCallback? onSubmitted;
  final List<TextInputFormatter>? inputFormatters;
  final TextAlign textAlign;
  final TextStyle? style;
  final bool enabled;
  final bool autofocus;

  @override
  State<MdAuthTextField> createState() => _MdAuthTextFieldState();
}

class _MdAuthTextFieldState extends State<MdAuthTextField> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.initialValue,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final toggle = widget.onToggleObscured;

    return TextField(
      controller: _controller,
      enabled: widget.enabled,
      autofocus: widget.autofocus,
      obscureText: widget.obscured,
      enableSuggestions: !widget.obscured,
      autocorrect: false,
      keyboardType: widget.keyboardType,
      autofillHints: widget.autofillHints,
      textInputAction: widget.textInputAction,
      inputFormatters: widget.inputFormatters,
      textAlign: widget.textAlign,
      style: widget.style,
      onChanged: widget.onChanged,
      onSubmitted: widget.onSubmitted == null
          ? null
          : (_) => widget.onSubmitted!(),
      decoration: InputDecoration(
        labelText: widget.label,
        errorText: widget.errorText,
        helperText: widget.helperText,
        helperMaxLines: 2,
        errorMaxLines: 2,
        suffixIcon: toggle == null
            ? null
            : Padding(
                padding: const EdgeInsets.only(right: AppSpacing.xs),
                child: IconButton(
                  tooltip: widget.obscured ? 'Show password' : 'Hide password',
                  icon: Icon(
                    widget.obscured
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                  ),
                  onPressed: toggle,
                ),
              ),
      ),
    );
  }
}
