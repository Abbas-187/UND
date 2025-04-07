import 'package:flutter/material.dart';
import 'app_colors.dart';

// Extension for success, warning, and information components
@immutable
class StatusColors extends ThemeExtension<StatusColors> {
  final Color success;
  final Color warning;
  final Color information;
  final Color onSuccess;
  final Color onWarning;
  final Color onInformation;

  const StatusColors({
    required this.success,
    required this.warning,
    required this.information,
    required this.onSuccess,
    required this.onWarning,
    required this.onInformation,
  });

  // Light theme values
  static const light = StatusColors(
    success: AppColors.lightSuccess,
    warning: AppColors.lightWarning,
    information: AppColors.lightInformation,
    onSuccess: Colors.white,
    onWarning: Colors.white,
    onInformation: Colors.white,
  );

  // Dark theme values
  static const dark = StatusColors(
    success: AppColors.darkSuccess,
    warning: AppColors.darkWarning,
    information: AppColors.darkInformation,
    onSuccess: Colors.black,
    onWarning: Colors.black,
    onInformation: Colors.white,
  );

  @override
  ThemeExtension<StatusColors> copyWith({
    Color? success,
    Color? warning,
    Color? information,
    Color? onSuccess,
    Color? onWarning,
    Color? onInformation,
  }) {
    return StatusColors(
      success: success ?? this.success,
      warning: warning ?? this.warning,
      information: information ?? this.information,
      onSuccess: onSuccess ?? this.onSuccess,
      onWarning: onWarning ?? this.onWarning,
      onInformation: onInformation ?? this.onInformation,
    );
  }

  @override
  ThemeExtension<StatusColors> lerp(
      ThemeExtension<StatusColors>? other, double t) {
    if (other is! StatusColors) {
      return this;
    }

    return StatusColors(
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      information: Color.lerp(information, other.information, t)!,
      onSuccess: Color.lerp(onSuccess, other.onSuccess, t)!,
      onWarning: Color.lerp(onWarning, other.onWarning, t)!,
      onInformation: Color.lerp(onInformation, other.onInformation, t)!,
    );
  }
}

// Extension for custom button styling
@immutable
class CustomButtonStyles extends ThemeExtension<CustomButtonStyles> {
  final ButtonStyle successButton;
  final ButtonStyle warningButton;
  final ButtonStyle infoButton;

  const CustomButtonStyles({
    required this.successButton,
    required this.warningButton,
    required this.infoButton,
  });

  // Light theme values
  static CustomButtonStyles light = CustomButtonStyles(
    successButton: ElevatedButton.styleFrom(
      backgroundColor: AppColors.lightSuccess,
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    ),
    warningButton: ElevatedButton.styleFrom(
      backgroundColor: AppColors.lightWarning,
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    ),
    infoButton: ElevatedButton.styleFrom(
      backgroundColor: AppColors.lightInformation,
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    ),
  );

  // Dark theme values
  static CustomButtonStyles dark = CustomButtonStyles(
    successButton: ElevatedButton.styleFrom(
      backgroundColor: AppColors.darkSuccess,
      foregroundColor: Colors.black,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    ),
    warningButton: ElevatedButton.styleFrom(
      backgroundColor: AppColors.darkWarning,
      foregroundColor: Colors.black,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    ),
    infoButton: ElevatedButton.styleFrom(
      backgroundColor: AppColors.darkInformation,
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    ),
  );

  @override
  ThemeExtension<CustomButtonStyles> copyWith({
    ButtonStyle? successButton,
    ButtonStyle? warningButton,
    ButtonStyle? infoButton,
  }) {
    return CustomButtonStyles(
      successButton: successButton ?? this.successButton,
      warningButton: warningButton ?? this.warningButton,
      infoButton: infoButton ?? this.infoButton,
    );
  }

  @override
  ThemeExtension<CustomButtonStyles> lerp(
      ThemeExtension<CustomButtonStyles>? other, double t) {
    if (other is! CustomButtonStyles) {
      return this;
    }
    // Note: ButtonStyle doesn't support lerp directly, so we return this
    return this;
  }
}
