# Fix lỗi 404 - API Data Sharing

## Mô tả lỗi

```
I/flutter ( 4884): │ ⛔ [PATCH] http://10.0.2.2:8000/api/v1/user/data-sharing
I/flutter ( 4884): │ ⛔ Status: 404
I/flutter ( 4884): │ ⛔ Message: Cannot PATCH /api/v1/user/data-sharing
```

## Nguyên nhân

Backend route `/api/v1/user/data-sharing` đã được định nghĩa đúng nhưng có thể:

1. Backend chưa được khởi động lại sau khi thêm route
2. Có lỗi trong quá trình khởi động backend
3. Route chưa được đăng ký đúng cách

## Kiểm tra

### 1. Kiểm tra Backend đang chạy

```bash
# Kiểm tra xem backend có đang chạy trên port 8000 không
netstat -ano | findstr :8000
```

### 2. Kiểm tra log backend

Xem terminal đang chạy backend để kiểm tra:

- Có lỗi nào khi khởi động không?
- Route có được đăng ký không?
- Server có lắng nghe trên port 8000 không?

### 3. Kiểm tra code

#### Backend Route (✅ ĐÃ ĐÚNG)

File: `omnimer_health_server/src/domain/routes/user.route.ts`

```typescript
// Dòng 49
router.patch("/data-sharing", verifyAccessToken, controller.toggleDataSharing);
```

#### Route Mount (✅ ĐÃ ĐÚNG)

File: `omnimer_health_server/src/domain/routes/index.ts`

```typescript
// Dòng 33
app.use("/api/v1/user", userRoute);
```

#### Controller (✅ ĐÃ ĐÚNG)

File: `omnimer_health_server/src/domain/controllers/Profile/User.controller.ts`

```typescript
// Dòng 77-97
toggleDataSharing = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const user = req.user as DecodePayload;
    const userId = user?.id?.toString();
    if (!userId) return sendUnauthorized(res);

    const updated = await this.userService.toggleDataSharing(userId);

    return sendSuccess(
      res,
      updated,
      "Cập nhật trạng thái chia sẻ dữ liệu thành công"
    );
  } catch (err) {
    next(err);
  }
};
```

#### Frontend (✅ ĐÃ ĐÚNG)

File: `omnihealthmobileflutter/lib/core/api/endpoints.dart`

```dart
// Dòng 33
static const String toggleDataSharing = "/v1/user/data-sharing";
```

File: `omnihealthmobileflutter/lib/data/datasources/auth_datasource.dart`

```dart
// Dòng 256-268
@override
Future<ApiResponse<UserModel>> toggleDataSharing() async {
  try {
    final response = await apiClient.patch<UserModel>(
      Endpoints.toggleDataSharing,
      parser: (json) => UserModel.fromJson(json as Map<String, dynamic>),
    );
    return response;
  } catch (e) {
    return ApiResponse<UserModel>.error(
      "Toggle data sharing failed: ${e.toString()}",
    );
  }
}
```

## Giải pháp

### Bước 1: Khởi động lại Backend

```bash
cd omnimer_health_server
npm run dev
```

### Bước 2: Kiểm tra Backend đã khởi động thành công

Xem log trong terminal, đảm bảo thấy:

```
✅ All services initialized.
Server is running on port 8000
```

### Bước 3: Test API bằng Postman hoặc curl

```bash
# Lấy access token trước (từ login)
# Sau đó test endpoint:
curl -X PATCH http://localhost:8000/api/v1/user/data-sharing \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN" \
  -H "Content-Type: application/json"
```

### Bước 4: Kiểm tra Service Layer

Đảm bảo method `toggleDataSharing` tồn tại trong `UserService`:

File: `omnimer_health_server/src/domain/services/Profile/User.service.ts`

Nếu chưa có, cần thêm method:

```typescript
async toggleDataSharing(userId: string) {
  const user = await this.userRepository.findById(userId);
  if (!user) {
    throw new Error("User not found");
  }

  // Toggle the data sharing status
  user.isDataSharingAccepted = !user.isDataSharingAccepted;

  // If enabled, sync to GraphDB
  if (user.isDataSharingAccepted) {
    // TODO: Sync data to GraphDB
  } else {
    // If disabled, remove from GraphDB
    // TODO: Remove data from GraphDB
  }

  await user.save();
  return user;
}
```

### Bước 5: Restart Flutter App

Sau khi backend đã chạy ổn định:

```bash
# Stop app hiện tại
# Sau đó chạy lại
flutter run
```

## Checklist

- [ ] Backend đang chạy trên port 8000
- [ ] Không có lỗi trong log backend
- [ ] Route `/api/v1/user/data-sharing` được đăng ký
- [ ] Controller method `toggleDataSharing` tồn tại
- [ ] Service method `toggleDataSharing` tồn tại
- [ ] Test API bằng Postman/curl thành công
- [ ] Flutter app có thể gọi API thành công

## Lưu ý

- Endpoint này yêu cầu authentication (Bearer token)
- Đảm bảo user đã login và có valid access token
- Kiểm tra middleware `verifyAccessToken` hoạt động đúng
