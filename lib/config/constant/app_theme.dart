import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_spacing.dart';
import 'app_typography.dart';

/// Material 3 as the foundation, Photo Quest as the identity. Every stock
/// component used by the app is themed here so screens never restyle them
/// ad hoc. See CLAUDE.md §27-30, design system §5.
abstract final class AppTheme {
  static const _colorScheme = ColorScheme(
    brightness: Brightness.light,
    primary: AppColors.warmCoral,
    onPrimary: AppColors.onCoral,
    primaryContainer: AppColors.softPeach,
    onPrimaryContainer: AppColors.textPrimary,
    secondary: AppColors.filmYellow,
    onSecondary: AppColors.textPrimary,
    tertiary: AppColors.softGreen,
    onTertiary: AppColors.textPrimary,
    error: AppColors.error,
    onError: AppColors.paper,
    errorContainer: AppColors.errorSurface,
    onErrorContainer: AppColors.error,
    surface: AppColors.background,
    onSurface: AppColors.textPrimary,
    onSurfaceVariant: AppColors.textMuted,
    surfaceContainerLowest: AppColors.paper,
    surfaceContainerLow: AppColors.paper,
    surfaceContainer: AppColors.paper,
    surfaceContainerHigh: AppColors.sunken,
    surfaceContainerHighest: AppColors.sunken,
    outline: AppColors.textMuted,
    outlineVariant: AppColors.line,
    inverseSurface: AppColors.warmCharcoal,
    onInverseSurface: AppColors.warmCream,
    inversePrimary: AppColors.warmCoral,
    shadow: AppColors.shadow,
    scrim: AppColors.cameraScrim,
    surfaceTint: Colors.transparent,
  );

  static final _shape = RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(AppRadius.lg),
  );

  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      colorScheme: _colorScheme,
      scaffoldBackgroundColor: AppColors.background,
      fontFamily: AppTypography.bodyFamily,
      splashFactory: InkSparkle.splashFactory,
      textTheme: const TextTheme(
        displaySmall: AppTypography.display,
        headlineLarge: AppTypography.heading1,
        headlineMedium: AppTypography.heading2,
        headlineSmall: AppTypography.heading3,
        titleLarge: AppTypography.heading3,
        titleMedium: AppTypography.label,
        bodyLarge: AppTypography.body,
        bodyMedium: AppTypography.body,
        bodySmall: AppTypography.bodyMuted,
        labelLarge: AppTypography.button,
        labelMedium: AppTypography.label,
        labelSmall: AppTypography.caption,
      ),
      iconTheme: const IconThemeData(
        color: AppColors.textPrimary,
        size: AppIconSizes.lg,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: AppTypography.heading3,
      ),
      filledButtonTheme: FilledButtonThemeData(style: _filledStyle),
      elevatedButtonTheme: ElevatedButtonThemeData(style: _filledStyle),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textPrimary,
          textStyle: AppTypography.button,
          minimumSize: const Size(AppTouch.minTarget, AppTouch.buttonHeight),
          side: const BorderSide(color: AppColors.line, width: 1.5),
          shape: _shape,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.coralInk,
          textStyle: AppTypography.label,
          minimumSize: const Size(AppTouch.minTarget, AppTouch.minTarget),
          shape: _shape,
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: AppColors.textPrimary,
          minimumSize: const Size(AppTouch.minTarget, AppTouch.minTarget),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.paper,
        hintStyle: AppTypography.body.copyWith(color: AppColors.textMuted),
        labelStyle: AppTypography.bodyMuted,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        border: _inputBorder(AppColors.line),
        enabledBorder: _inputBorder(AppColors.line),
        focusedBorder: _inputBorder(AppColors.coralInk, width: 2),
        errorBorder: _inputBorder(AppColors.error),
        focusedErrorBorder: _inputBorder(AppColors.error, width: 2),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.paper,
        selectedColor: AppColors.softPeach,
        disabledColor: AppColors.sunken,
        checkmarkColor: AppColors.textPrimary,
        // Raw coral icons are too light on paper (non-text 3:1).
        iconTheme: const IconThemeData(
          color: AppColors.textPrimary,
          size: AppIconSizes.sm,
        ),
        labelStyle: AppTypography.label,
        side: const BorderSide(color: AppColors.line),
        shape: const StadiumBorder(),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xs,
          vertical: AppSpacing.xs,
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
        showDragHandle: true,
        dragHandleColor: AppColors.line,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppRadius.xl),
          ),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: AppTypography.heading2,
        contentTextStyle: AppTypography.body.copyWith(
          color: AppColors.textMuted,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.xl),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.warmCharcoal,
        contentTextStyle: AppTypography.body.copyWith(
          color: AppColors.warmCream,
        ),
        actionTextColor: AppColors.filmYellow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.warmCoral,
        linearTrackColor: AppColors.softPeach,
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.line,
        thickness: 1,
        space: 1,
      ),
      listTileTheme: const ListTileThemeData(
        minVerticalPadding: AppSpacing.ms,
        titleTextStyle: AppTypography.body,
        subtitleTextStyle: AppTypography.bodyMuted,
        iconColor: AppColors.textPrimary,
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: AppColors.warmCharcoal,
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        textStyle: AppTypography.caption.copyWith(color: AppColors.warmCream),
      ),
    );
  }

  static final _filledStyle = FilledButton.styleFrom(
    backgroundColor: AppColors.warmCoral,
    foregroundColor: AppColors.onCoral,
    disabledBackgroundColor: AppColors.sunken,
    disabledForegroundColor: AppColors.textMuted,
    textStyle: AppTypography.button,
    minimumSize: const Size(AppTouch.minTarget, AppTouch.buttonHeight),
    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
    elevation: 0,
    shape: _shape,
  );

  static OutlineInputBorder _inputBorder(Color color, {double width = 1.5}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.md),
      borderSide: BorderSide(color: color, width: width),
    );
  }
}
