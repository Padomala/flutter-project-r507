import 'package:flutter/material.dart';

// Enum pour définir le type de champ
enum EnumFieldType { text, email, password, number }

class CustomTextField extends StatelessWidget {
  final String label;
  final String hintText;
  final IconData? icon;
  final EnumFieldType fieldType;
  final TextEditingController? controller;
  final bool obscureText;
  final bool enabled;
  final VoidCallback? onEditPressed;

  const CustomTextField({
    super.key,
    required this.label,
    this.hintText = '',
    this.icon,
    this.fieldType = EnumFieldType.text,
    this.controller,
    this.obscureText = false,
    this.enabled = true,
    this.onEditPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label du champ
        Padding(
          padding: const EdgeInsets.only(left: 8.0, bottom: 4.0),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),
        // Zone de texte avec icône et style
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: controller,
            obscureText: obscureText,
            enabled: enabled,
            keyboardType: _getKeyboardType(fieldType),
            decoration: InputDecoration(
              hintText: hintText,
              prefixIcon: icon != null ? Icon(icon, color: Colors.blue) : null,
              suffixIcon: onEditPressed != null
                  ? IconButton(
                      icon: const Icon(
                        Icons.edit,
                        size: 20,
                        color: Colors.blue,
                      ),
                      onPressed: onEditPressed,
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Détermine le type de clavier en fonction du FieldType
  TextInputType _getKeyboardType(EnumFieldType type) {
    switch (type) {
      case EnumFieldType.email:
        return TextInputType.emailAddress;
      case EnumFieldType.number:
        return TextInputType.number;
      case EnumFieldType.password:
        return TextInputType.visiblePassword;
      default:
        return TextInputType.text;
    }
  }
}
