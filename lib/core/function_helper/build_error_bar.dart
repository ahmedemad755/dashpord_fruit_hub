import 'package:flutter/material.dart';

void buildBar(
  BuildContext context,
  String message, {
  TextStyle? style, // style اختياري
  Color backgroundColor = Colors.red, // كمان تقدر تخلي اللون الافتراضي أحمر
}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        message,
        style: style ?? const TextStyle(color: Colors.white), // لو مبعتش style
      ),
      duration: const Duration(seconds: 2),
      backgroundColor: backgroundColor,
    ),
  );
}
