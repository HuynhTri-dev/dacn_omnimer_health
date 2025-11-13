# Hướng dẫn sử dụng Flutter Theme

## 1. Cấu trúc thư mục

```
lib/
├── theme/
│   ├── app_colors.dart
│   ├── app_typography.dart
│   ├── app_spacing.dart
│   ├── app_radius.dart
│   └── app_theme.dart
```

## 2. Cài đặt fonts (pubspec.yaml)

```yaml
flutter:
  fonts:
    - family: Orbitron
      fonts:
        - asset: assets/fonts/Orbitron-Regular.ttf
          weight: 400
        - asset: assets/fonts/Orbitron-Bold.ttf
          weight: 700

    - family: Montserrat
      fonts:
        - asset: assets/fonts/Montserrat-Regular.ttf
          weight: 400
        - asset: assets/fonts/Montserrat-Bold.ttf
          weight: 700
        - asset: assets/fonts/Montserrat-Italic.ttf
          style: italic
```

## 3. Setup trong main.dart

```dart
import 'package:flutter/material.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My App',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system, // hoặc ThemeMode.light, ThemeMode.dark
      home: HomeScreen(),
    );
  }
}
```

## 4. Sử dụng màu sắc

```dart
// Sử dụng trực tiếp
Container(
  color: AppColors.primary,
  child: Text(
    'Hello',
    style: TextStyle(color: AppColors.white),
  ),
)

// Hoặc từ theme
Container(
  color: Theme.of(context).primaryColor,
  child: Text(
    'Hello',
    style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
  ),
)
```

## 5. Sử dụng Typography

```dart
// Cách 1: Sử dụng trực tiếp
Text(
  'Heading',
  style: AppTypography.h1,
)

// Cách 2: Với custom màu
Text(
  'Heading',
  style: AppTypography.headingBoldStyle(
    fontSize: AppTypography.fontSize2Xl,
    color: AppColors.primary,
  ),
)

// Cách 3: Từ Theme
Text(
  'Heading',
  style: Theme.of(context).textTheme.displayLarge,
)
```

## 6. Sử dụng Spacing

```dart
// Padding
Padding(
  padding: AppSpacing.paddingMd,
  child: Text('Content'),
)

// Hoặc custom
Padding(
  padding: AppSpacing.symmetric(
    horizontal: AppSpacing.lg,
    vertical: AppSpacing.md,
  ),
  child: Text('Content'),
)

// SizedBox spacing
Column(
  children: [
    Text('First'),
    SizedBox(height: AppSpacing.md),
    Text('Second'),
  ],
)
```

## 7. Sử dụng Border Radius

```dart
// Container với border radius
Container(
  decoration: BoxDecoration(
    color: AppColors.primary,
    borderRadius: AppRadius.radiusMd,
  ),
  child: Text('Content'),
)

// Card với custom radius
Card(
  shape: RoundedRectangleBorder(
    borderRadius: AppRadius.radiusLg,
  ),
  child: Text('Content'),
)

// Custom radius cho từng góc
Container(
  decoration: BoxDecoration(
    color: AppColors.surface,
    borderRadius: AppRadius.only(
      topLeft: AppRadius.lg,
      topRight: AppRadius.lg,
    ),
  ),
)
```

## 8. Buttons với Theme

```dart
// Elevated Button (tự động dùng theme)
ElevatedButton(
  onPressed: () {},
  child: Text('Primary Button'),
)

// Outlined Button
OutlinedButton(
  onPressed: () {},
  child: Text('Secondary Button'),
)

// Text Button
TextButton(
  onPressed: () {},
  child: Text('Text Button'),
)

// Custom button với màu danger
ElevatedButton(
  onPressed: () {},
  style: ElevatedButton.styleFrom(
    backgroundColor: AppColors.danger,
  ),
  child: Text('Delete'),
)
```

## 9. Input Fields

```dart
// TextField tự động dùng theme
TextField(
  decoration: InputDecoration(
    labelText: 'Email',
    hintText: 'Enter your email',
  ),
)

// Custom TextField
TextField(
  decoration: InputDecoration(
    labelText: 'Password',
    prefixIcon: Icon(Icons.lock),
    suffixIcon: Icon(Icons.visibility),
    errorText: 'Invalid password',
  ),
)
```

## 10. Difficulty Level Colors

```dart
// Sử dụng màu độ khó
Container(
  padding: AppSpacing.paddingSm,
  decoration: BoxDecoration(
    color: AppColors.easy, // hoặc medium, hard, veryHard
    borderRadius: AppRadius.radiusSm,
  ),
  child: Text('Easy'),
)
```

## 11. Shadow và Overlay

```dart
// Shadow
Container(
  decoration: BoxDecoration(
    color: AppColors.white,
    borderRadius: AppRadius.radiusMd,
    boxShadow: [
      BoxShadow(
        color: AppColors.shadow,
        blurRadius: 8,
        offset: Offset(0, 2),
      ),
    ],
  ),
)

// Overlay (cho modal, dialog)
Container(
  color: AppColors.overlay,
  child: Center(
    child: Card(
      child: Padding(
        padding: AppSpacing.paddingLg,
        child: Text('Modal Content'),
      ),
    ),
  ),
)
```

## 12. Responsive Layout với Spacing

```dart
class ResponsiveLayout extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 600;

    return Padding(
      padding: isSmallScreen
        ? AppSpacing.paddingMd
        : AppSpacing.paddingXl,
      child: Column(
        children: [
          // Content
        ],
      ),
    );
  }
}
```

## Tips

- **Import một lần**: Tạo file `theme/theme.dart` để export tất cả:

  ```dart
  export 'app_colors.dart';
  export 'app_typography.dart';
  export 'app_spacing.dart';
  export 'app_radius.dart';
  export 'app_theme.dart';
  ```

- **Sử dụng const**: Luôn dùng `const` khi có thể để tối ưu performance

  ```dart
  const Text('Hello', style: AppTypography.h1)
  ```

- **Extension methods**: Có thể tạo extension để code ngắn gọn hơn
  ```dart
  extension ThemeExtension on BuildContext {
    AppColors get colors => AppColors();
    TextTheme get textTheme => Theme.of(this).textTheme;
  }
  ```
