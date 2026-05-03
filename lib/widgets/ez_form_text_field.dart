import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ez_queue/widgets/ez_input_field.dart';
import 'package:ez_queue/utils/theme_helpers.dart';

/// A reusable form text field that shows validation errors **below** the
/// input container (EZInputField) instead of inside the InputDecoration.
///
/// Wraps [EZInputField] + [TextFormField] and automatically:
/// - tracks [currentLength] for the inline character counter,
/// - captures the validator result and renders it as a separate [Text],
/// - switches the [EZInputField] border to the theme error colour on error.
class EZFormTextField extends StatefulWidget {
  final TextEditingController? controller;
  final String? hintText;
  final String? labelText;
  final Widget? prefixIcon;
  final Widget? extraSuffix;
  final EdgeInsetsGeometry? contentPadding;
  final int? maxLength;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final TextCapitalization? textCapitalization;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;
  final AutovalidateMode? autovalidateMode;
  final int? maxLines;
  final void Function(String)? onChanged;
  final void Function(String)? onFieldSubmitted;
  final FocusNode? focusNode;

  const EZFormTextField({
    super.key,
    this.controller,
    this.hintText,
    this.labelText,
    this.prefixIcon,
    this.extraSuffix,
    this.contentPadding,
    this.maxLength,
    this.keyboardType,
    this.textInputAction,
    this.textCapitalization,
    this.inputFormatters,
    this.validator,
    this.autovalidateMode,
    this.maxLines,
    this.onChanged,
    this.onFieldSubmitted,
    this.focusNode,
  });

  @override
  State<EZFormTextField> createState() => _EZFormTextFieldState();
}

class _EZFormTextFieldState extends State<EZFormTextField> {
  String? _errorText;
  int _currentLength = 0;

  @override
  void initState() {
    super.initState();
    _currentLength = widget.controller?.text.length ?? 0;
    widget.controller?.addListener(_onTextChange);
  }

  @override
  void didUpdateWidget(covariant EZFormTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?.removeListener(_onTextChange);
      widget.controller?.addListener(_onTextChange);
      _currentLength = widget.controller?.text.length ?? 0;
    }
  }

  void _onTextChange() {
    if (!mounted) return;
    final len = widget.controller?.text.length ?? 0;
    if (len != _currentLength) {
      setState(() => _currentLength = len);
    }
  }

  @override
  void dispose() {
    widget.controller?.removeListener(_onTextChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final errorColor = Theme.of(context).colorScheme.error;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        EZInputField(
          borderColor: _errorText != null ? errorColor : null,
          child: TextFormField(
            controller: widget.controller,
            focusNode: widget.focusNode,
            decoration: ThemeHelpers.textInputDecoration(
              hintText: widget.hintText,
              labelText: widget.labelText,
              prefixIcon: widget.prefixIcon,
              extraSuffix: widget.extraSuffix,
              contentPadding: widget.contentPadding,
              maxLength: widget.maxLength,
              currentLength: _currentLength,
            ),
            keyboardType: widget.keyboardType,
            textInputAction: widget.textInputAction,
            textCapitalization:
                widget.textCapitalization ?? TextCapitalization.none,
            inputFormatters: widget.inputFormatters,
            maxLength: widget.maxLength,
            maxLines: widget.maxLines,
            onChanged: widget.onChanged,
            onFieldSubmitted: widget.onFieldSubmitted,
            autovalidateMode: widget.autovalidateMode,
            validator: (value) {
              final error = widget.validator?.call(value);
              // Schedule state update after the current build frame
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted && _errorText != error) {
                  setState(() => _errorText = error);
                }
              });
              return error;
            },
          ),
        ),
        // CHANGED: render error message below the input container
        if (_errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: 4, left: 12),
            child: Text(
              _errorText!,
              style: TextStyle(
                color: errorColor,
                fontFamily: 'Roboto',
                fontSize: 12,
              ),
            ),
          ),
      ],
    );
  }
}
