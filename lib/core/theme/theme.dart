import 'package:flutter/material.dart';
import 'package:repair_shop/core/theme/app_pallate.dart';

class AppTheme {
  // Resuable method to create a border for input fields
  static _border({Color color = AppPallete.borderColor}) => OutlineInputBorder(
    borderSide: BorderSide(color: color, width: 2.0),
    borderRadius: BorderRadius.circular(10.0),
  );

  // Light theme mode
  static final darkThemeMode = ThemeData.dark().copyWith(
    scaffoldBackgroundColor: AppPallete.backgroundColor,

    appBarTheme: AppBarTheme(backgroundColor: AppPallete.backgroundColor),

    chipTheme: ChipThemeData(
      color: WidgetStatePropertyAll(AppPallete.backgroundColor),
      side: BorderSide.none,
    ),

    inputDecorationTheme: InputDecorationTheme(
      contentPadding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
      border: _border(),
      enabledBorder: _border(),
      focusedBorder: _border(color: AppPallete.gradient2),
      errorBorder: _border(color: AppPallete.errorColor),
    ),

    dropdownMenuTheme: DropdownMenuThemeData(
      menuStyle: MenuStyle(
        backgroundColor: WidgetStatePropertyAll(AppPallete.backgroundColor),
        surfaceTintColor: WidgetStatePropertyAll(AppPallete.backgroundColor),
      ),
    ),
  );
}
