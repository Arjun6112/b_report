// lib/core/theme.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor:
        const Color(0xFFFAFBFC), // Slightly off-white for medical feel
    primaryColor: const Color(0xFF1B365D), // Medical blue

    // Define the color scheme with medical-appropriate colors
    colorScheme: const ColorScheme.light(
      primary: Color(0xFF1B365D), // Professional medical blue
      secondary: Color(0xFF2563EB), // Lighter blue accent
      tertiary: Color(0xFF059669), // Medical green for positive indicators
      surface: Color(0xFFFFFFFF), // Pure white for cards/surfaces
      background: Color(0xFFFAFBFC), // Subtle background
      onPrimary: Color(0xFFFFFFFF), // White text on primary
      onSurface: Color(0xFF1F2937), // Dark text on surfaces
      onBackground: Color(0xFF1F2937), // Dark text on background
      error: Color(0xFFDC2626), // Medical red for errors
      onError: Color(0xFFFFFFFF),
      outline: Color(0xFFE5E7EB), // Subtle borders
    ),

    // Define the TextTheme using medical-appropriate fonts
    textTheme: GoogleFonts.sourceSerif4TextTheme(
      ThemeData.light().textTheme,
    ).copyWith(
      // Headlines use Playfair Display for elegance and trust
      displayLarge: GoogleFonts.playfairDisplay(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        color: const Color(0xFF1F2937),
        letterSpacing: -0.5,
      ),
      displayMedium: GoogleFonts.playfairDisplay(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        color: const Color(0xFF1F2937),
        letterSpacing: -0.3,
      ),
      displaySmall: GoogleFonts.playfairDisplay(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: const Color(0xFF1F2937),
        letterSpacing: -0.2,
      ),

      // Headlines for sections
      headlineLarge: GoogleFonts.inter(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: const Color(0xFF1F2937),
        letterSpacing: -0.2,
      ),
      headlineMedium: GoogleFonts.inter(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: const Color(0xFF1F2937),
        letterSpacing: -0.1,
      ),
      headlineSmall: GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: const Color(0xFF1F2937),
      ),

      // Titles for cards and components
      titleLarge: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: const Color(0xFF1F2937),
        letterSpacing: 0.1,
      ),
      titleMedium: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: const Color(0xFF1F2937),
        letterSpacing: 0.1,
      ),
      titleSmall: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: const Color(0xFF374151),
        letterSpacing: 0.1,
      ),

      // Body text uses Source Serif 4 for readability
      bodyLarge: GoogleFonts.sourceSerif4(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: const Color(0xFF374151),
        height: 1.6,
      ),
      bodyMedium: GoogleFonts.sourceSerif4(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: const Color(0xFF4B5563),
        height: 1.5,
      ),
      bodySmall: GoogleFonts.sourceSerif4(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: const Color(0xFF6B7280),
        height: 1.4,
      ),

      // Labels for buttons and UI elements use Inter
      labelLarge: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: const Color(0xFFFFFFFF),
        letterSpacing: 0.5,
      ),
      labelMedium: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: const Color(0xFF374151),
        letterSpacing: 0.3,
      ),
      labelSmall: GoogleFonts.inter(
        fontSize: 10,
        fontWeight: FontWeight.w500,
        color: const Color(0xFF6B7280),
        letterSpacing: 0.3,
      ),
    ),

    // Define component themes with medical app styling
    appBarTheme: AppBarTheme(
      backgroundColor: const Color(0xFFFFFFFF),
      elevation: 0,
      scrolledUnderElevation: 1,
      surfaceTintColor: Colors.transparent,
      shadowColor: const Color(0xFF000000).withOpacity(0.05),
      iconTheme: const IconThemeData(color: Color(0xFF1B365D)),
      titleTextStyle: GoogleFonts.inter(
        color: const Color(0xFF1F2937),
        fontSize: 20,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.1,
      ),
      centerTitle: false,
    ),

    // Card theme for medical data presentation
    cardTheme: CardThemeData(
      elevation: 0,
      color: const Color(0xFFFFFFFF),
      surfaceTintColor: Colors.transparent,
      shadowColor: const Color(0xFF000000).withOpacity(0.04),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
        side: const BorderSide(color: Color(0xFFE5E7EB), width: 1),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    ),

    // Button themes for medical app
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF1B365D),
        foregroundColor: const Color(0xFFFFFFFF),
        elevation: 0,
        shadowColor: const Color(0xFF1B365D).withOpacity(0.3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        textStyle: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.3,
        ),
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: const Color(0xFF1B365D),
        side: const BorderSide(color: Color(0xFF1B365D), width: 1.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        textStyle: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.3,
        ),
      ),
    ),

    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: const Color(0xFF1B365D),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        textStyle: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.2,
        ),
      ),
    ),

    // Input decoration theme for forms
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFFF9FAFB),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF1B365D), width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFDC2626)),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      hintStyle: GoogleFonts.inter(
        color: const Color(0xFF9CA3AF),
        fontSize: 14,
      ),
      labelStyle: GoogleFonts.inter(
        color: const Color(0xFF374151),
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
    ),

    // Bottom sheet theme
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: Color(0xFFFFFFFF),
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
      ),
    ),

    // Tab bar theme
    tabBarTheme: TabBarThemeData(
      labelColor: const Color(0xFFFFFFFF),
      unselectedLabelColor: const Color(0xFF6B7280),
      labelStyle: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
      unselectedLabelStyle: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      indicator: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: const Color(0xFF1B365D),
      ),
    ),

    // Divider theme
    dividerTheme: const DividerThemeData(
      color: Color(0xFFE5E7EB),
      thickness: 1,
      space: 1,
    ),

    // Icon theme
    iconTheme: const IconThemeData(
      color: Color(0xFF6B7280),
      size: 24,
    ),

    // Chip theme for tags and status indicators
    chipTheme: ChipThemeData(
      backgroundColor: const Color(0xFFF3F4F6),
      labelStyle: GoogleFonts.inter(
        color: const Color(0xFF374151),
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
      side: const BorderSide(color: Color(0xFFE5E7EB)),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    ),
  );
}
