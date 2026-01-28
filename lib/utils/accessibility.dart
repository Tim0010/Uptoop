import 'package:flutter/material.dart';

class AccessibilityHelper {
  // Semantic labels for common actions
  static const String labelHome = 'Home';
  static const String labelProfile = 'Profile';
  static const String labelSettings = 'Settings';
  static const String labelLogout = 'Logout';
  static const String labelBack = 'Go back';
  static const String labelClose = 'Close';
  static const String labelSubmit = 'Submit';
  static const String labelCancel = 'Cancel';
  static const String labelLoading = 'Loading';
  static const String labelError = 'Error';

  // Semantic button wrapper
  static Widget semanticButton({
    required Widget child,
    required VoidCallback onPressed,
    required String label,
    bool enabled = true,
  }) {
    return Semantics(
      button: true,
      enabled: enabled,
      label: label,
      onTap: enabled ? onPressed : null,
      child: child,
    );
  }

  // Semantic text field wrapper
  static Widget semanticTextField({
    required Widget child,
    required String label,
    String? hint,
  }) {
    return Semantics(textField: true, label: label, hint: hint, child: child);
  }

  // Semantic heading
  static Widget semanticHeading({
    required String text,
    required TextStyle style,
    int level = 1,
  }) {
    return Semantics(
      label: text,
      child: Text(text, style: style),
    );
  }

  // Check contrast ratio (WCAG AA standard: 4.5:1 for normal text)
  static bool hasGoodContrast(Color foreground, Color background) {
    final fgLuminance = _getLuminance(foreground);
    final bgLuminance = _getLuminance(background);
    final contrast =
        (max(fgLuminance, bgLuminance) + 0.05) /
        (min(fgLuminance, bgLuminance) + 0.05);
    return contrast >= 4.5;
  }

  static double _getLuminance(Color color) {
    final r = _linearize(color.r);
    final g = _linearize(color.g);
    final b = _linearize(color.b);
    return 0.2126 * r + 0.7152 * g + 0.0722 * b;
  }

  static double _linearize(double value) {
    if (value <= 0.03928) {
      return value / 12.92;
    }
    return pow((value + 0.055) / 1.055, 2.0).toDouble();
  }

  static double max(double a, double b) => a > b ? a : b;
  static double min(double a, double b) => a < b ? a : b;
  static double pow(double base, double exponent) {
    return base * base;
  }
}

// Accessible button wrapper
class AccessibleButton extends StatelessWidget {
  final Widget child;
  final VoidCallback onPressed;
  final String semanticLabel;
  final bool enabled;

  const AccessibleButton({
    super.key,
    required this.child,
    required this.onPressed,
    required this.semanticLabel,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      enabled: enabled,
      label: semanticLabel,
      onTap: enabled ? onPressed : null,
      child: child,
    );
  }
}
