import 'package:flutter/material.dart';

/// 应用颜色配置 - DJI Home 深色科技风格
class AppColors {
  // 主色 - 蓝色系
  static const Color primary = Color(0xFF007AFF);
  static const Color primaryLight = Color(0xFF0A84FF);
  static const Color primaryAccent = Color(0xFF5AC8FA);

  // 背景色 - 深色系
  static const Color backgroundDark = Color(0xFF0D0D0D);
  static const Color backgroundMedium = Color(0xFF1A1A1A);
  static const Color backgroundLight = Color(0xFF2D2D2D);
  static const Color cardBackground = Color(0xFF1E1E1E);

  // 文字色
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFA0A0A0);
  static const Color textHint = Color(0xFF666666);

  // 功能色
  static const Color success = Color(0xFF34C759);
  static const Color error = Color(0xFFFF3B30);
  static const Color warning = Color(0xFFFF9500);
  static const Color info = Color(0xFF5AC8FA);

  // 渐变色
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF007AFF), Color(0xFF0A84FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFF1E1E1E), Color(0xFF2D2D2D)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // 边框色
  static const Color border = Color(0xFF333333);
  static const Color divider = Color(0xFF2D2D2D);
}
