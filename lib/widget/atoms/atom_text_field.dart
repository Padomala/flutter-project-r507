import 'package:flutter/material.dart';
import '../../app_colors.dart';

// Enum pour définir le type de champ
enum EnumFieldType { text, email, password, number }

class CustomTextField extends StatefulWidget {
  final String label;
  final String hintText;
  final IconData? icon;
  final EnumFieldType fieldType;
  final TextEditingController? controller;
  final bool enabled;

  const CustomTextField({
    super.key,
    required this.label,
    this.hintText = '',
    this.icon,
    this.fieldType = EnumFieldType.text,
    this.controller,
    this.enabled = true,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool _obscurePassword = true; // état interne pour afficher/masquer

  @override
  Widget build(BuildContext context) {
    final isPassword = widget.fieldType == EnumFieldType.password;

    return Padding(
      padding: const EdgeInsets.only(top: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label
          Padding(
            padding: const EdgeInsets.only(left: 8.0, bottom: 4.0),
            child: Text(
              widget.label,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),

          // champ de texte
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(12),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              controller: widget.controller,
              enabled: widget.enabled,
              obscureText: isPassword ? _obscurePassword : false,
              keyboardType: _getKeyboardType(widget.fieldType),
              decoration: InputDecoration(
                hintText: widget.hintText,
                hintStyle: const TextStyle(fontSize: 14, color: AppColors.gray),
                prefixIcon: widget.icon != null
                    ? Icon(widget.icon, color: Colors.blue)
                    : null,
                suffixIcon: isPassword
                    ? IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: AppColors.gray,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
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
      ),
    );
  }

  // détermine le type de clavier
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
