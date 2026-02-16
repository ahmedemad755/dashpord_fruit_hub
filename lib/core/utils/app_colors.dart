import 'package:flutter/material.dart';

abstract class AppColors {
  // الأزرق الداكن الأساسي (من الخلفية)
  static const Color primaryColor = Color(0xFF0B3A57);

  // الأزرق السماوي الفاتح (التدرج العلوي)
  static const Color lightPrimaryColor = Color(0xFF4FA3D1);

  // الأصفر الذهبي (لون العنوان في اللوجو)
  static const Color secondaryColor = Color(0xFFFFC238);

  // ذهبي فاتح للتدرجات
  static const Color lightSecondaryColor = Color(0xFFFFD982);

  // رمادي غامق محايد (أفضل من السابق)
  static const Color darkgrey600 = Color(0xFF4A4A4A);

  // لون الخطأ (مناسب للثيم الجديد)
  static const Color errorColor = Color(0xFFE53935);

  // أزرق داكن جدًا (بديل مناسب للـ darkBlue)
  static const Color darkBlue = Color(0xFF082636);

  // ==================== Primary Gradient Colors ====================
  /// Light Turquoise - Top of primary gradient
  static const Color primaryLight = Color(0xFFB1E5F6);

  /// Medium Turquoise - Middle of primary gradient
  static const Color primaryMid = Color(0xFF67B0E6);

  /// Deep Blue - Bottom of primary gradient
  static const Color primaryDark = Color(0xFF4A90D9);

  // ==================== Auth & Navigation Colors ====================
  /// Primary brand color - used in buttons, icons, navigation
  static const Color primary = Color(0xFF007BBB);

  /// Active background for navigation items
  static const Color activeBg = Color(0xFFE6FBFF);

  /// Border color for navigation
  static const Color borderColor = Color(0xFFDDEFF3);

  // ==================== Accent Color Schemes ====================
  /// Page 1 Accent: Bright Cyan
  static const Color accentCyan1 = Color(0xFF00D4FF);

  /// Page 1 Accent: Deep Blue
  static const Color accentDeepBlue1 = Color(0xFF0084FF);

  /// Page 2 Accent: Cyan
  static const Color accentCyan2 = Color(0xFF00C6FF);

  /// Page 2 Accent: Sky Blue
  static const Color accentSkyBlue = Color(0xFF00A8E8);

  /// Page 3 Accent: Light Cyan
  static const Color accentLightCyan = Color(0xFF00E5FF);

  /// Page 3 Accent: Blue
  static const Color accentBlue = Color(0xFF0090FF);

  // ==================== Neutral Colors ====================
  /// White color
  static const Color white = Color(0xFFFFFFFF);

  /// Black color
  static const Color black = Color(0xFF000000);

  /// Transparent color
  static const Color transparent = Color(0x00000000);

  /// Light gray for disabled states
  static const Color lightGray = Color(0xFFF5F5F5);

  /// Medium gray for borders
  static const Color mediumGray = Color(0xFFE0E0E0);

  /// Dark gray for text
  static const Color darkGray = Color(0xFF424242);

  // ==================== Error & Status Colors ====================
  /// Error/Red color for validation errors
  static const Color error = Color(0xFFFF0000);

  /// Red color
  static const Color red = Color(0xFFFF0000);

  /// Success/Green color
  static const Color success = Color(0xFF4CAF50);
  // تدرج أخضر متداخل
  static const LinearGradient successGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color.fromARGB(255, 96, 252, 117), // أخضر فاتح قليلاً (Light Green)
      Color.fromARGB(255, 62, 168, 67), // أخضر أغمق (Darker Green)
    ],
  );

  /// Warning/Orange color
  static const Color warning = Color(0xFFFFA500);

  // ==================== Gradients ====================
  /// Primary gradient for backgrounds (Light Turquoise → Deep Blue)
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      AppColors.primaryLight,
      AppColors.primaryMid,
      AppColors.primaryDark,
    ],
    stops: [0.0, 0.5, 1.0],
  );

  /// Accent gradient for Page 1 (Bright Cyan → Deep Blue)
  static const LinearGradient accentGradient1 = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.accentCyan1, AppColors.accentDeepBlue1],
  );

  /// Accent gradient for Page 2 (Cyan → Sky Blue)
  static const LinearGradient accentGradient2 = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.accentCyan2, AppColors.accentSkyBlue],
  );

  /// Accent gradient for Page 3 (Light Cyan → Blue)
  static const LinearGradient accentGradient3 = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.accentLightCyan, AppColors.accentBlue],
  );

  // ==================== Helper Methods ====================
  /// Get accent gradient by page index (1, 2, 3)
  static LinearGradient getAccentGradientByPage(int pageIndex) {
    switch (pageIndex) {
      case 1:
        return accentGradient1;
      case 2:
        return accentGradient2;
      case 3:
        return accentGradient3;
      default:
        return accentGradient1;
    }
  }

  /// Get accent colors (color1, color2) by page index
  static (Color, Color) getAccentColorsByPage(int pageIndex) {
    switch (pageIndex) {
      case 1:
        return (accentCyan1, accentDeepBlue1);
      case 2:
        return (accentCyan2, accentSkyBlue);
      case 3:
        return (accentLightCyan, accentBlue);
      default:
        return (accentCyan1, accentDeepBlue1);
    }
  }
}

class ColorsManager {
  static const Color mainBlue = Color(0xFF247CFF);
  static const Color lightBlue = Color(0xFFF4F8FF);
  static const Color darkBlue = Color(0xFF242424);
  static const Color gray = Color(0xFF757575);
  static const Color lightGray = Color(0xFFC2C2C2);
  static const Color lighterGray = Color(0xFFEDEDED);
  static const Color moreLightGray = Color(0xFFFDFDFF);
  static const Color moreLighterGray = Color(0xFFF5F5F5);
  static const Color moreLightewhite = Color(0xFFF4F8FF);
  static const Color darktexttitel = Color(0xff212121);
}
