import 'package:flutter/material.dart';

/// App-styled text field; [obscure] adds a show/hide toggle.
class CustomTextField extends StatefulWidget {
  const CustomTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.hint,
    this.icon,
    this.keyboardType = TextInputType.text,
    this.obscure = false,
    this.validator,
    this.maxLines = 1,
    this.onChanged,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData? icon;
  final TextInputType keyboardType;
  final bool obscure;
  final String? Function(String?)? validator;
  final int maxLines;
  final ValueChanged<String>? onChanged;

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool _visible = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: widget.controller,
          keyboardType: widget.keyboardType,
          onChanged: widget.onChanged,
          maxLines: widget.maxLines,
          obscureText: widget.obscure && !_visible,
          validator: widget.validator,
          decoration: InputDecoration(
            hintText: widget.hint,
            prefixIcon: widget.icon == null || widget.maxLines > 1
                ? null
                : Icon(widget.icon, size: 20, color: const Color(0xFF9CA3AF)),
            suffixIcon: widget.obscure
                ? IconButton(
                    icon: Icon(
                      _visible ? Icons.visibility_off : Icons.visibility,
                      size: 20,
                      color: const Color(0xFF9CA3AF),
                    ),
                    onPressed: () => setState(() => _visible = !_visible),
                  )
                : null,
          ),
        ),
      ],
    );
  }
}
