import 'package:flutter/material.dart';
import 'package:fruitesdashboard/core/utils/app_colors.dart';

class CustomTextFormField extends StatelessWidget {
  final String hintText;
  final IconData? prefixIcon;
  final bool obscureText;
  final String? errorText;
  final TextInputType keyboardType;
  final Function(String?)? onSaved;
  final Function(String)? onChanged;
  final VoidCallback? toggleObscure;
  final TextEditingController? controller;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;

  const CustomTextFormField({
    super.key,
    required this.hintText,
    this.prefixIcon,
    this.obscureText = false,
    this.errorText,
    TextInputType? textInputType,
    this.onSaved,
    this.onChanged,
    this.toggleObscure,
    this.controller,
    this.suffixIcon,
    this.validator,
  }) : keyboardType = textInputType ?? TextInputType.text;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          onSaved: onSaved,
          onChanged: onChanged,
          validator:
              validator ??
              (value) {
                if (value == null || value.isEmpty) {
                  return 'هذا الحقل مطلوب';
                }
                return null;
              },
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFFF9FAFA),
            hintText: hintText,
            prefixIcon: prefixIcon != null
                ? Icon(prefixIcon, color: AppColors.primary)
                : null,
            suffixIcon:
                suffixIcon ??
                (toggleObscure != null
                    ? GestureDetector(
                        onTap: toggleObscure,
                        child: Icon(
                          obscureText ? Icons.visibility_off : Icons.visibility,
                          color: Colors.grey,
                        ),
                      )
                    : null),
            border: buildBorder(),
            enabledBorder: buildBorder(),
            focusedBorder: buildBorder(AppColors.primary),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  OutlineInputBorder buildBorder([Color? color]) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: color ?? const Color(0xFFE6E9EA), width: 1),
    );
  }
}
