import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppSpacing {
  static const double none = 0.0;
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
  static const double xxxl = 64.0;

  static const EdgeInsets paddingXs = EdgeInsets.all(xs);
  static const EdgeInsets paddingSm = EdgeInsets.all(sm);
  static const EdgeInsets paddingMd = EdgeInsets.all(md);
  static const EdgeInsets paddingLg = EdgeInsets.all(lg);
  static const EdgeInsets paddingXl = EdgeInsets.all(xl);

  static const EdgeInsets horizontalXs = EdgeInsets.symmetric(horizontal: xs);
  static const EdgeInsets horizontalSm = EdgeInsets.symmetric(horizontal: sm);
  static const EdgeInsets horizontalMd = EdgeInsets.symmetric(horizontal: md);
  static const EdgeInsets horizontalLg = EdgeInsets.symmetric(horizontal: lg);
  static const EdgeInsets horizontalXl = EdgeInsets.symmetric(horizontal: xl);

  static const EdgeInsets verticalXs = EdgeInsets.symmetric(vertical: xs);
  static const EdgeInsets verticalSm = EdgeInsets.symmetric(vertical: sm);
  static const EdgeInsets verticalMd = EdgeInsets.symmetric(vertical: md);
  static const EdgeInsets verticalLg = EdgeInsets.symmetric(vertical: lg);
  static const EdgeInsets verticalXl = EdgeInsets.symmetric(vertical: xl);
}

class AppRadius {
  static const double none = 0.0;
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 10.0;
  static const double lg = 12.0;
  static const double xl = 14.0;
  static const double xxl = 16.0;
  static const double full = 9999.0;
}

extension TextStyleContext on BuildContext {
  TextTheme get textStyles => Theme.of(this).textTheme;
}

extension TextStyleExtensions on TextStyle {
  TextStyle get bold => copyWith(fontWeight: FontWeight.bold);
  TextStyle get semiBold => copyWith(fontWeight: FontWeight.w600);
  TextStyle get medium => copyWith(fontWeight: FontWeight.w500);
  TextStyle get normal => copyWith(fontWeight: FontWeight.w400);
  TextStyle get light => copyWith(fontWeight: FontWeight.w300);
  TextStyle withColor(Color color) => copyWith(color: color);
  TextStyle withSize(double size) => copyWith(fontSize: size);
}

class LightModeColors {
  static const primary = Color(0xFF7C9CB4);
  static const onPrimary = Color(0xFFFFFFFF);
  static const primaryContainer = Color(0xFFD8E8F5);
  static const onPrimaryContainer = Color(0xFF0D2030);
  static const secondary = Color(0xFFC4836A);
  static const onSecondary = Color(0xFFFFFFFF);
  static const secondaryContainer = Color(0xFFF5DCD0);
  static const onSecondaryContainer = Color(0xFF2C1A10);
  static const tertiary = Color(0xFF4A6741);
  static const onTertiary = Color(0xFFFFFFFF);
  static const error = Color(0xFFBA1A1A);
  static const onError = Color(0xFFFFFFFF);
  static const errorContainer = Color(0xFFFFDAD6);
  static const onErrorContainer = Color(0xFF410002);
  static const background = Color(0xFFFFFFFF);
  static const onBackground = Color(0xFF1A1A1A);
  static const secondaryBackground = Color(0xFFF5F5F5);
  static const surface = Color(0xFFFFFFFF);
  static const onSurface = Color(0xFF1A1A1A);
  static const surfaceVariant = Color(0xFFF0F0F0);
  static const onSurfaceVariant = Color(0xFF484848);
  static const primaryText = Color(0xFF1A1A1A);
  static const secondaryText = Color(0xFF484848);
  static const outline = Color(0xFF909090);
  static const divider = Color(0xFFE0E0E0);
  static const transparent = Color(0x00000000);
  static const shadow = Color(0xFF000000);
  static const scrim = Color(0xFF000000);
  static const inverseSurface = Color(0xFF2C2C2C);
  static const inverseOnSurface = Color(0xFFF5F5F5);
  static const inversePrimary = Color(0xFFA8C8E0);
}

class DarkModeColors {
  static const primary = Color(0xFFA8C8E0);
  static const onPrimary = Color(0xFF203848);
  static const primaryContainer = Color(0xFF385060);
  static const onPrimaryContainer = Color(0xFFD8E8F5);
  static const secondary = Color(0xFFE0A890);
  static const onSecondary = Color(0xFF3D2820);
  static const secondaryContainer = Color(0xFF584038);
  static const onSecondaryContainer = Color(0xFFF5DCD0);
  static const tertiary = Color(0xFF90C080);
  static const onTertiary = Color(0xFF1A3010);
  static const error = Color(0xFFFFB4AB);
  static const onError = Color(0xFF690005);
  static const errorContainer = Color(0xFF93000A);
  static const onErrorContainer = Color(0xFFFFDAD6);
  static const background = Color(0xFF1A1A1A);
  static const onBackground = Color(0xFFE8E8E8);
  static const secondaryBackground = Color(0xFF242424);
  static const surface = Color(0xFF1A1A1A);
  static const onSurface = Color(0xFFE8E8E8);
  static const surfaceVariant = Color(0xFF404040);
  static const onSurfaceVariant = Color(0xFFC8C8C8);
  static const primaryText = Color(0xFFE8E8E8);
  static const secondaryText = Color(0xFFA8A8A8);
  static const outline = Color(0xFF707070);
  static const divider = Color(0xFF404040);
  static const transparent = Color(0x00000000);
  static const shadow = Color(0xFF000000);
  static const scrim = Color(0xFF000000);
  static const inverseSurface = Color(0xFFE8E8E8);
  static const inverseOnSurface = Color(0xFF2C2C2C);
  static const inversePrimary = Color(0xFF7C9CB4);
}

class FontSizes {
  static const double displayLarge = 57.0;
  static const double displayMedium = 45.0;
  static const double displaySmall = 36.0;
  static const double headlineLarge = 32.0;
  static const double headlineMedium = 28.0;
  static const double headlineSmall = 24.0;
  static const double titleLarge = 22.0;
  static const double titleMedium = 16.0;
  static const double titleSmall = 14.0;
  static const double labelLarge = 14.0;
  static const double labelMedium = 12.0;
  static const double labelSmall = 11.0;
  static const double bodyLarge = 16.0;
  static const double bodyMedium = 14.0;
  static const double bodySmall = 12.0;
}

ThemeData get lightTheme => ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.light(
    primary: LightModeColors.primary,
    onPrimary: LightModeColors.onPrimary,
    primaryContainer: LightModeColors.primaryContainer,
    onPrimaryContainer: LightModeColors.onPrimaryContainer,
    secondary: LightModeColors.secondary,
    onSecondary: LightModeColors.onSecondary,
    tertiary: LightModeColors.tertiary,
    onTertiary: LightModeColors.onTertiary,
    error: LightModeColors.error,
    onError: LightModeColors.onError,
    errorContainer: LightModeColors.errorContainer,
    onErrorContainer: LightModeColors.onErrorContainer,
    surface: LightModeColors.surface,
    onSurface: LightModeColors.onSurface,
    surfaceContainerHighest: LightModeColors.surfaceVariant,
    onSurfaceVariant: LightModeColors.onSurfaceVariant,
    outline: LightModeColors.outline,
    shadow: LightModeColors.shadow,
    inversePrimary: LightModeColors.inversePrimary,
    inverseSurface: LightModeColors.inverseSurface,
    onInverseSurface: LightModeColors.inverseOnSurface,
  ),
  brightness: Brightness.light,
  scaffoldBackgroundColor: LightModeColors.background,
  dividerColor: LightModeColors.divider,
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.transparent,
    foregroundColor: LightModeColors.onSurface,
    elevation: 0,
    scrolledUnderElevation: 0,
  ),
  cardTheme: CardThemeData(
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
      side: const BorderSide(
        color: LightModeColors.divider,
        width: 1,
      ),
    ),
  ),
  textTheme: _buildTextTheme(Brightness.light),
);

ThemeData get darkTheme => ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.dark(
    primary: DarkModeColors.primary,
    onPrimary: DarkModeColors.onPrimary,
    primaryContainer: DarkModeColors.primaryContainer,
    onPrimaryContainer: DarkModeColors.onPrimaryContainer,
    secondary: DarkModeColors.secondary,
    onSecondary: DarkModeColors.onSecondary,
    tertiary: DarkModeColors.tertiary,
    onTertiary: DarkModeColors.onTertiary,
    error: DarkModeColors.error,
    onError: DarkModeColors.onError,
    errorContainer: DarkModeColors.errorContainer,
    onErrorContainer: DarkModeColors.onErrorContainer,
    surface: DarkModeColors.surface,
    onSurface: DarkModeColors.onSurface,
    surfaceContainerHighest: DarkModeColors.surfaceVariant,
    onSurfaceVariant: DarkModeColors.onSurfaceVariant,
    outline: DarkModeColors.outline,
    shadow: DarkModeColors.shadow,
    inversePrimary: DarkModeColors.inversePrimary,
    inverseSurface: DarkModeColors.inverseSurface,
    onInverseSurface: DarkModeColors.inverseOnSurface,
  ),
  brightness: Brightness.dark,
  scaffoldBackgroundColor: DarkModeColors.background,
  dividerColor: DarkModeColors.divider,
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.transparent,
    foregroundColor: DarkModeColors.onSurface,
    elevation: 0,
    scrolledUnderElevation: 0,
  ),
  cardTheme: CardThemeData(
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
      side: const BorderSide(
        color: DarkModeColors.divider,
        width: 1,
      ),
    ),
  ),
  textTheme: _buildTextTheme(Brightness.dark),
);

TextTheme _buildTextTheme(Brightness brightness) {
  final textColor = brightness == Brightness.light 
      ? LightModeColors.primaryText 
      : DarkModeColors.primaryText;
      
  return TextTheme(
    displayLarge: GoogleFonts.inter(
      fontSize: FontSizes.displayLarge,
      fontWeight: FontWeight.w400,
      height: 1.12,
      color: textColor,
    ),
    displayMedium: GoogleFonts.inter(
      fontSize: FontSizes.displayMedium,
      fontWeight: FontWeight.w400,
      height: 1.16,
      color: textColor,
    ),
    displaySmall: GoogleFonts.inter(
      fontSize: FontSizes.displaySmall,
      fontWeight: FontWeight.w400,
      height: 1.22,
      color: textColor,
    ),
    headlineLarge: GoogleFonts.inter(
      fontSize: FontSizes.headlineLarge,
      fontWeight: FontWeight.w400,
      height: 1.25,
      color: textColor,
    ),
    headlineMedium: GoogleFonts.inter(
      fontSize: FontSizes.headlineMedium,
      fontWeight: FontWeight.w400,
      height: 1.29,
      color: textColor,
    ),
    headlineSmall: GoogleFonts.inter(
      fontSize: FontSizes.headlineSmall,
      fontWeight: FontWeight.w400,
      height: 1.33,
      color: textColor,
    ),
    titleLarge: GoogleFonts.inter(
      fontSize: FontSizes.titleLarge,
      fontWeight: FontWeight.w400,
      height: 1.27,
      color: textColor,
    ),
    titleMedium: GoogleFonts.inter(
      fontSize: FontSizes.titleMedium,
      fontWeight: FontWeight.w500,
      height: 1.5,
      color: textColor,
    ),
    titleSmall: GoogleFonts.inter(
      fontSize: FontSizes.titleSmall,
      fontWeight: FontWeight.w500,
      height: 1.43,
      color: textColor,
    ),
    labelLarge: GoogleFonts.inter(
      fontSize: FontSizes.labelLarge,
      fontWeight: FontWeight.w500,
      height: 1.43,
      color: textColor,
    ),
    labelMedium: GoogleFonts.inter(
      fontSize: FontSizes.labelMedium,
      fontWeight: FontWeight.w500,
      height: 1.33,
      color: textColor,
    ),
    labelSmall: GoogleFonts.inter(
      fontSize: FontSizes.labelSmall,
      fontWeight: FontWeight.w500,
      height: 1.45,
      color: textColor,
    ),
    bodyLarge: GoogleFonts.inter(
      fontSize: FontSizes.bodyLarge,
      fontWeight: FontWeight.w400,
      height: 1.5,
      color: textColor,
    ),
    bodyMedium: GoogleFonts.inter(
      fontSize: FontSizes.bodyMedium,
      fontWeight: FontWeight.w400,
      height: 1.43,
      color: textColor,
    ),
    bodySmall: GoogleFonts.inter(
      fontSize: FontSizes.bodySmall,
      fontWeight: FontWeight.w400,
      height: 1.33,
      color: textColor,
    ),
  );
}
