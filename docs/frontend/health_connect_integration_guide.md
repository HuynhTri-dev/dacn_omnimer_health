# Hướng dẫn sử dụng Health Connect trong Health Data Section

## Tổng quan

Đã tích hợp thành công **Health Connect** vào màn hình More > Health Data Section sử dụng hai components:

1. **HealthConnectSetupWidget** - Widget nhỏ gọn để nhúng vào các màn hình khác
2. **HealthConnectScreen** - Màn hình chi tiết đầy đủ với tất cả tính năng

## Kiến trúc

### 1. HealthConnectSetupWidget

**File:** `health_connect_setup_widget.dart`

**Mục đích:**

- Widget nhỏ gọn để hiển thị trạng thái Health Connect
- Được thiết kế để nhúng vào các màn hình khác (không có Scaffold)
- Tự động quản lý BLoC instance riêng

**Tính năng:**

- ✅ Tự động kiểm tra trạng thái Health Connect
- ✅ Hiển thị status badges (Available, Not Installed, Permissions Denied, etc.)
- ✅ Action buttons động dựa trên trạng thái
- ✅ Callback để navigate đến màn hình chi tiết

**Props:**

```dart
HealthConnectSetupWidget({
  VoidCallback? onNavigateToHealthConnect, // Callback khi tap vào widget hoặc "Open Health Connect"
})
```

**Các trạng thái hiển thị:**

| Trạng thái                                             | Badge                                        | Action Button               |
| ------------------------------------------------------ | -------------------------------------------- | --------------------------- |
| `HealthConnectLoading`                                 | Loading spinner                              | "Loading..." (disabled)     |
| `HealthConnectAvailable` (installed + has permissions) | ✅ Green "Health Connect is ready"           | "Open Health Connect"       |
| `HealthConnectAvailable` (installed + no permissions)  | ⚠️ Orange "Permissions required"             | "Request Permissions"       |
| `HealthConnectAvailable` (not installed)               | ⚠️ Orange "Health Connect not installed"     | "Install Health Connect"    |
| `HealthConnectUnavailable`                             | ❌ Red "Health Connect not available"        | "Open Health Connect"       |
| `HealthConnectPermissionsDenied`                       | ❌ Red "Permissions denied"                  | "Request Permissions" (red) |
| `HealthConnectPermissionsGranted`                      | ✅ Green "Connected and permissions granted" | "Manage Settings"           |

### 2. HealthConnectScreen

**File:** `health_connect_screen.dart`

**Mục đích:**

- Màn hình đầy đủ với AppBar và tất cả tính năng Health Connect
- Hiển thị thông tin chi tiết về health data
- Quản lý permissions, sync data, etc.

**Tính năng:**

- ✅ Header với logo và mô tả Health Connect
- ✅ Availability section (kiểm tra cài đặt và permissions)
- ✅ Health Data section (hiển thị steps, heart rate, calories, etc.)
- ✅ Actions section (Request Permissions, Sync to Backend, Refresh Data)
- ✅ Error handling với SnackBar
- ✅ Loading states với skeleton loading

**Sections:**

1. **Header Section**

   - Logo Health Connect
   - Tiêu đề và mô tả

2. **Availability Section**

   - Trạng thái cài đặt
   - Trạng thái permissions
   - Action buttons nếu cần

3. **Health Data Section**

   - Today's health data (steps, distance, calories, heart rate)
   - Sync info

4. **Actions Section**
   - Request Permissions (nếu chưa có)
   - Load Health Data
   - Refresh Health Data
   - Sync to Backend

## Cách sử dụng trong Health Data Section

### Trước đây (SAI ❌)

```dart
// SAI: Navigate đến HealthConnectSetupWidget
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => const HealthConnectSetupWidget(), // Widget không có Scaffold!
  ),
);
```

### Bây giờ (ĐÚNG ✅)

**File:** `health_data_section.dart`

```dart
// 1. Import cả hai components
import 'package:omnihealthmobileflutter/presentation/screen/health_connect/health_connect_screen.dart';
import 'package:omnihealthmobileflutter/presentation/screen/health_connect/health_connect_setup_widget.dart';

// 2. Trong dropdown menu, nhúng HealthConnectSetupWidget trực tiếp
Column(
  children: [
    // Apple Health
    _buildDropdownItem(...),

    // Health Connect - Nhúng widget trực tiếp
    Padding(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      child: HealthConnectSetupWidget(
        // Callback để navigate đến màn hình chi tiết
        onNavigateToHealthConnect: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const HealthConnectScreen(),
            ),
          );
        },
      ),
    ),

    // Samsung Health
    _buildDropdownItem(...),
  ],
)
```

## Flow hoạt động

```
User taps "Health Data Center"
  ↓
Dropdown expands
  ↓
HealthConnectSetupWidget được render
  ↓
Widget tự động tạo BLoC instance và check availability
  ↓
Hiển thị status badge và action button phù hợp
  ↓
User có thể:
  1. Tap vào header → Navigate to HealthConnectScreen
  2. Tap action button → Request permissions / Install / etc.
  3. Nếu đã connected → Tap "Manage Settings" → Navigate to HealthConnectScreen
```

## BLoC Management

### HealthConnectSetupWidget

- Tự động tạo BLoC instance riêng qua `BlocProvider`
- Sử dụng `sl.get<HealthConnectBloc>()` từ dependency injection
- BLoC được dispose tự động khi widget bị remove

```dart
BlocProvider(
  create: (context) => sl.get<HealthConnectBloc>(),
  child: BlocConsumer<HealthConnectBloc, HealthConnectState>(...),
)
```

### HealthConnectScreen

- Sử dụng BLoC từ context (cần được provide từ parent)
- Hoặc có thể wrap trong BlocProvider nếu cần

```dart
// Trong initState
context.read<HealthConnectBloc>().add(CheckHealthConnectAvailability());
```

## Events và States

### Events (HealthConnectBloc)

- `CheckHealthConnectAvailability()` - Kiểm tra Health Connect có sẵn không
- `RequestHealthPermissions()` - Yêu cầu permissions
- `GetTodayHealthData()` - Lấy health data hôm nay
- `SyncHealthDataToBackend()` - Sync data lên backend

### States

- `HealthConnectInitial` - Trạng thái ban đầu
- `HealthConnectLoading` - Đang loading
- `HealthConnectAvailable` - Health Connect có sẵn (có thông tin về installed và permissions)
- `HealthConnectUnavailable` - Health Connect không có sẵn
- `HealthConnectPermissionsGranted` - Permissions đã được cấp
- `HealthConnectPermissionsDenied` - Permissions bị từ chối
- `HealthDataLoaded` - Health data đã được load
- `HealthDataSyncSuccess` - Sync thành công
- `HealthConnectError` - Có lỗi xảy ra

## UI Components

### Status Badges

Các badge hiển thị trạng thái với màu sắc phù hợp:

- 🟢 Green: Success, Connected, Ready
- 🟠 Orange: Warning, Permissions Required, Not Installed
- 🔴 Red: Error, Denied, Unavailable

### Action Buttons

Sử dụng `ButtonPrimary` với các variants:

- `ButtonVariant.primarySolid` - Default (blue)
- `ButtonVariant.primaryOutline` - Outline style
- `ButtonVariant.dangerSolid` - Red (cho permissions denied)

### Loading States

- `SkeletonLoading` cho status section
- `CircularProgressIndicator` cho health data
- Button loading state với spinner

## Best Practices

### 1. Không navigate đến HealthConnectSetupWidget

```dart
// ❌ SAI
Navigator.push(context, MaterialPageRoute(
  builder: (context) => HealthConnectSetupWidget(),
));

// ✅ ĐÚNG - Nhúng trực tiếp
child: HealthConnectSetupWidget(
  onNavigateToHealthConnect: () => Navigator.push(...),
)
```

### 2. Luôn provide callback cho navigation

```dart
HealthConnectSetupWidget(
  onNavigateToHealthConnect: () {
    // Navigate to detail screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const HealthConnectScreen(),
      ),
    );
  },
)
```

### 3. BLoC instance management

- HealthConnectSetupWidget tự quản lý BLoC
- Không cần provide BLoC từ parent
- Widget sẽ tự dispose BLoC khi unmount

### 4. Error handling

- Lắng nghe `HealthConnectError` state
- Hiển thị SnackBar với thông báo lỗi
- Sử dụng theme colors cho consistency

## Styling

### Theme Integration

Tất cả components đều sử dụng `Theme.of(context)`:

- `colorScheme.primary` - Primary color
- `colorScheme.surface` - Surface color
- `colorScheme.error` - Error color
- `colorScheme.outline` - Border color
- `textTheme.bodyMedium`, `bodySmall` - Text styles

### Spacing

Sử dụng `AppSpacing`:

- `AppSpacing.xs` - Extra small
- `AppSpacing.sm` - Small
- `AppSpacing.md` - Medium
- `AppSpacing.lg` - Large
- `AppSpacing.xl` - Extra large

### Typography

Sử dụng `AppTypography`:

- `AppTypography.h1` - Heading 1
- `AppTypography.h3` - Heading 3
- `AppTypography.h4` - Heading 4
- `AppTypography.bodyLarge` - Body large
- `AppTypography.bodyMedium` - Body medium
- `AppTypography.bodySmall` - Body small

## Testing

### Test HealthConnectSetupWidget

```dart
testWidgets('should show correct status badge', (tester) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: HealthConnectSetupWidget(
          onNavigateToHealthConnect: () {},
        ),
      ),
    ),
  );

  // Verify status badge is displayed
  expect(find.text('Checking Health Connect...'), findsOneWidget);
});
```

### Test Navigation

```dart
testWidgets('should navigate to detail screen', (tester) async {
  bool navigated = false;

  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: HealthConnectSetupWidget(
          onNavigateToHealthConnect: () {
            navigated = true;
          },
        ),
      ),
    ),
  );

  // Tap on header
  await tester.tap(find.byType(InkWell).first);
  expect(navigated, true);
});
```

## Troubleshooting

### Widget không hiển thị

- Kiểm tra `injection_container.dart` đã register `HealthConnectBloc` chưa
- Verify assets path cho logo Health Connect

### BLoC không hoạt động

- Kiểm tra dependency injection setup
- Verify `sl.get<HealthConnectBloc>()` có thể resolve được

### Navigation không hoạt động

- Đảm bảo đã provide `onNavigateToHealthConnect` callback
- Kiểm tra context có valid không

### Status không update

- Kiểm tra BLoC events có được dispatch không
- Verify states có được emit đúng không
- Check BlocConsumer listener và builder

## Kết luận

Việc tích hợp Health Connect vào Health Data Section đã hoàn thành với:

✅ **HealthConnectSetupWidget** - Widget nhỏ gọn, tự quản lý state, dễ nhúng  
✅ **HealthConnectScreen** - Màn hình chi tiết đầy đủ tính năng  
✅ **Proper navigation flow** - Setup widget → Detail screen  
✅ **BLoC management** - Tự động quản lý lifecycle  
✅ **Theme integration** - Consistent với app theme  
✅ **Error handling** - Proper error states và messages

Giờ đây user có thể:

1. Xem trạng thái Health Connect ngay trong More screen
2. Tap để xem chi tiết và quản lý permissions
3. Sync health data với backend
4. Xem health metrics (steps, heart rate, etc.)
