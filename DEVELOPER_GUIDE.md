# Developer Guide - Frontend Utilities

## Quick Reference for Using New Utilities

### 1. Error Handling
```dart
import 'package:uptop_careers/utils/error_handler.dart';

try {
  // Your async operation
  await someAsyncFunction();
} catch (e) {
  ErrorHandler.showErrorSnackBar(
    context,
    ErrorHandler.getErrorMessage(e),
    onRetry: () => someAsyncFunction(),
  );
}
```

### 2. Form Validation
```dart
import 'package:uptop_careers/utils/validators.dart';

TextFormField(
  validator: AppValidators.validateEmail,
  // or
  validator: AppValidators.validatePassword,
  validator: AppValidators.validatePhoneNumber,
  validator: AppValidators.validateName,
  validator: AppValidators.validateOTP,
)
```

### 3. Page Transitions
```dart
import 'package:uptop_careers/utils/animations.dart';

Navigator.of(context).push(
  AppAnimations.slideTransition(NextScreen()),
  // or
  AppAnimations.fadeTransition(NextScreen()),
  AppAnimations.scaleTransition(NextScreen()),
);
```

### 4. Responsive Design
```dart
import 'package:uptop_careers/utils/responsive.dart';
import 'package:uptop_careers/widgets/responsive_container.dart';

// Check screen size
if (ResponsiveHelper.isMobile(context)) {
  // Mobile layout
}

// Get responsive values
final padding = ResponsiveHelper.getResponsivePadding(context);
final fontSize = ResponsiveHelper.getResponsiveFontSize(context);
final columns = ResponsiveHelper.getResponsiveGridColumns(context);

// Use responsive widgets
ResponsiveContainer(
  child: Text('Responsive content'),
)

ResponsiveGrid(
  children: [/* items */],
)

ResponsiveText('Text', mobileSize: 14, tabletSize: 16)
```

### 5. Accessibility
```dart
import 'package:uptop_careers/utils/accessibility.dart';

AccessibleButton(
  onPressed: () {},
  semanticLabel: 'Submit button',
  child: Text('Submit'),
)

// Check contrast
bool hasGoodContrast = AccessibilityHelper.hasGoodContrast(
  Colors.white,
  Colors.blue,
);
```

### 6. Loading States
```dart
import 'package:uptop_careers/widgets/skeleton_loader.dart';

// Show skeleton while loading
if (isLoading) {
  SkeletonLoader(
    width: 300,
    height: 200,
  );
} else {
  // Your content
}

// Or use SkeletonCard
SkeletonCard()
```

## Best Practices

1. **Always use mounted check** before setState in async operations
2. **Use ErrorHandler** for consistent error messages
3. **Use AppValidators** for all form fields
4. **Use AppAnimations** for all navigation
5. **Use ResponsiveHelper** for adaptive layouts
6. **Use AccessibleButton** for interactive elements

## File Locations
- Utilities: `lib/utils/`
- Widgets: `lib/widgets/`
- Screens: `lib/screens/`
- Config: `lib/config/`
- Providers: `lib/providers/`

## Testing
Run `flutter analyze` to check for issues
Run `flutter test` to run unit tests

