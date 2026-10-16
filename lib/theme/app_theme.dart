import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const Color coffee = Color(0xFF6F4E37);
  static const Color espresso = Color(0xFF3E2C22);
  static const Color caramel = Color(0xFFC68642);
  static const Color amber = Color(0xFFD9A05B);
  static const Color cream = Color(0xFFFBF6EE);
  static const Color foam = Color(0xFFFFFFFF);
  static const Color milk = Color(0xFFF1E7D8);
  static const Color latte = Color(0xFFE7D9C4);

  static const Color darkCream = Color(0xFF14100E);
  static const Color darkFoam = Color(0xFF1E1713);
  static const Color darkMilk = Color(0xFF2C211B);
  static const Color darkLatte = Color(0xFF3E2F26);
  static const Color darkTextPrimary = Color(0xFFF5EDE4);
  static const Color darkTextSecondary = Color(0xFFBCAAA4);
  static const Color darkCaramel = Color(0xFFE59C58);
  static const Color darkCoffee = Color(0xFFD4976A);

  static const Color success = Color(0xFF3E7C4F);
  static const Color darkSuccess = Color(0xFF57A76D);
  static const Color warning = Color(0xFFC77B2A);
  static const Color error = Color(0xFFB4432F);
}

extension AppThemeContext on BuildContext {
  bool get isDark => Theme.of(this).brightness == Brightness.dark;

  Color get textPrimary =>
      isDark ? AppColors.darkTextPrimary : AppColors.espresso;
  Color get textSecondary =>
      isDark ? AppColors.darkTextSecondary : AppColors.coffee;
  Color get bgCream => isDark ? AppColors.darkCream : AppColors.cream;
  Color get cardFoam => isDark ? AppColors.darkFoam : AppColors.foam;
  Color get containerMilk => isDark ? AppColors.darkMilk : AppColors.milk;
  Color get borderLatte => isDark ? AppColors.darkLatte : AppColors.latte;
  Color get accentCaramel => isDark ? AppColors.darkCaramel : AppColors.caramel;
  Color get accentCoffee => isDark ? AppColors.darkCoffee : AppColors.coffee;
  Color get statusSuccess => isDark ? AppColors.darkSuccess : AppColors.success;
}

class AppTheme {
  AppTheme._();

  static ThemeData light() {
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.coffee,
      brightness: Brightness.light,
      primary: AppColors.coffee,
      secondary: AppColors.caramel,
      surface: AppColors.foam,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: scheme.copyWith(
        primary: AppColors.coffee,
        onPrimary: Colors.white,
        primaryContainer: AppColors.milk,
        onPrimaryContainer: AppColors.espresso,
        secondary: AppColors.caramel,
        onSecondary: Colors.white,
        secondaryContainer: const Color(0xFFF0DCC2),
        onSecondaryContainer: AppColors.espresso,
        tertiary: AppColors.amber,
        surface: AppColors.foam,
        onSurface: AppColors.espresso,
        surfaceContainerHighest: AppColors.milk,
        outline: AppColors.latte,
      ),
      scaffoldBackgroundColor: AppColors.cream,
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: _CoffeePageTransitionsBuilder(),
          TargetPlatform.iOS: _CoffeePageTransitionsBuilder(),
          TargetPlatform.macOS: _CoffeePageTransitionsBuilder(),
          TargetPlatform.windows: _CoffeePageTransitionsBuilder(),
          TargetPlatform.linux: _CoffeePageTransitionsBuilder(),
          TargetPlatform.fuchsia: _CoffeePageTransitionsBuilder(),
        },
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.cream,
        foregroundColor: AppColors.espresso,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: AppColors.espresso,
          fontSize: 22,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.3,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.foam,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.latte, width: 0.8),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.foam,
        indicatorColor: AppColors.milk,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => TextStyle(
            fontSize: 12,
            fontWeight: states.contains(WidgetState.selected)
                ? FontWeight.w700
                : FontWeight.w500,
            color: states.contains(WidgetState.selected)
                ? AppColors.espresso
                : AppColors.coffee,
          ),
        ),
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            color: states.contains(WidgetState.selected)
                ? AppColors.coffee
                : AppColors.coffee.withValues(alpha: 0.55),
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.coffee,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.foam,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.latte),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.latte),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.caramel, width: 2),
        ),
        labelStyle: const TextStyle(color: AppColors.coffee),
        hintStyle: TextStyle(color: AppColors.coffee.withValues(alpha: 0.5)),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.latte,
        thickness: 0.8,
        space: 1,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.espresso,
        contentTextStyle: const TextStyle(color: Colors.white),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }

  static ThemeData dark() {
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.darkCaramel,
      brightness: Brightness.dark,
      primary: AppColors.darkCaramel,
      secondary: AppColors.darkCoffee,
      surface: AppColors.darkFoam,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: scheme.copyWith(
        primary: AppColors.darkCaramel,
        onPrimary: Colors.black,
        primaryContainer: AppColors.darkMilk,
        onPrimaryContainer: AppColors.darkTextPrimary,
        secondary: AppColors.darkCoffee,
        onSecondary: Colors.black,
        secondaryContainer: AppColors.darkMilk,
        onSecondaryContainer: AppColors.darkTextPrimary,
        tertiary: AppColors.amber,
        surface: AppColors.darkFoam,
        onSurface: AppColors.darkTextPrimary,
        surfaceContainerHighest: AppColors.darkMilk,
        outline: AppColors.darkLatte,
      ),
      scaffoldBackgroundColor: AppColors.darkCream,
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: _CoffeePageTransitionsBuilder(),
          TargetPlatform.iOS: _CoffeePageTransitionsBuilder(),
          TargetPlatform.macOS: _CoffeePageTransitionsBuilder(),
          TargetPlatform.windows: _CoffeePageTransitionsBuilder(),
          TargetPlatform.linux: _CoffeePageTransitionsBuilder(),
          TargetPlatform.fuchsia: _CoffeePageTransitionsBuilder(),
        },
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.darkCream,
        foregroundColor: AppColors.darkTextPrimary,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: AppColors.darkTextPrimary,
          fontSize: 22,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.3,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.darkFoam,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.darkLatte, width: 0.8),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.darkFoam,
        indicatorColor: AppColors.darkMilk,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => TextStyle(
            fontSize: 12,
            fontWeight: states.contains(WidgetState.selected)
                ? FontWeight.w700
                : FontWeight.w500,
            color: states.contains(WidgetState.selected)
                ? AppColors.darkTextPrimary
                : AppColors.darkTextSecondary,
          ),
        ),
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            color: states.contains(WidgetState.selected)
                ? AppColors.darkCaramel
                : AppColors.darkTextSecondary.withValues(alpha: 0.6),
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.darkCaramel,
          foregroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkFoam,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.darkLatte),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.darkLatte),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.darkCaramel, width: 2),
        ),
        labelStyle: const TextStyle(color: AppColors.darkTextSecondary),
        hintStyle: TextStyle(
          color: AppColors.darkTextSecondary.withValues(alpha: 0.5),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.darkLatte,
        thickness: 0.8,
        space: 1,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.darkFoam,
        contentTextStyle: const TextStyle(color: AppColors.darkTextPrimary),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: AppColors.darkLatte),
        ),
      ),
    );
  }
}

class _CoffeePageTransitionsBuilder extends PageTransitionsBuilder {
  const _CoffeePageTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    if (MediaQuery.disableAnimationsOf(context)) return child;

    final motion = CurvedAnimation(
      parent: animation,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );

    return FadeTransition(
      opacity: motion,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.035),
          end: Offset.zero,
        ).animate(motion),
        child: child,
      ),
    );
  }
}
