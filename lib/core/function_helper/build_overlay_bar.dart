import 'package:flutter/material.dart';

void showOverlayToast(
  BuildContext context,
  String message, {
  Color color = Colors.green,
}) {
  const duration = Duration(seconds: 1);
  final overlay = Overlay.of(context);

  // 1. تعريف الـ OverlayEntry
  late OverlayEntry overlayEntry;

  overlayEntry = OverlayEntry(
    builder: (context) {
      // 🚀 الحل: استخدام Positioned و Center لوضع الإشعار
      return Positioned(
        top:
            MediaQuery.of(context).size.height *
            0.45, // يضعها تقريباً في المنتصف
        left: 20,
        right: 20,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
            decoration: BoxDecoration(
              color: color.withOpacity(0.9),
              borderRadius: BorderRadius.circular(8),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      );
    },
  );

  // 2. إظهار الـ Overlay
  overlay.insert(overlayEntry);

  // 3. إخفاء الـ Overlay تلقائياً
  Future.delayed(duration, () {
    // التأكد من أن الـ Overlay لا يزال موجوداً قبل إزالته
    try {
      overlayEntry.remove();
    } catch (e) {
      // قد يتم إزالته مسبقاً إذا تم التنقل بسرعة
    }
  });
}

// تحديث دالتك المساعدة
void showBar(BuildContext context, String message, {Color color = Colors.red}) {
  showOverlayToast(context, message, color: color);
}
