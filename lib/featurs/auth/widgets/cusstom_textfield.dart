// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:fruitesdashboard/core/utils/app_colors.dart';

// ----------------- Reusable TextField Widget -----------------
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
    TextInputType? keyboardType,
    this.onSaved,
    this.onChanged,
    this.toggleObscure,
    this.controller,
    this.suffixIcon,
    this.validator,
    // Old parameter names for backward compatibility
    TextInputType? textInputType,
  }) : keyboardType = textInputType ?? keyboardType ?? TextInputType.text;

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
          validator: validator,
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.lightGray,
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
                          color: AppColors.darkGray,
                        ),
                      )
                    : null),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: errorText != null
                    ? AppColors.error
                    : AppColors.mediumGray,
                width: errorText != null ? 2 : 1,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: errorText != null
                    ? AppColors.error
                    : AppColors.mediumGray,
                width: errorText != null ? 2 : 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
        ),
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              errorText!,
              style: const TextStyle(color: AppColors.error, fontSize: 12),
            ),
          )
        else
          const SizedBox(height: 12),
      ],
    );
  }
}
