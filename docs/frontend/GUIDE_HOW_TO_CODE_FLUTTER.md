Dưới đây là bản dịch tiếng Việt đầy đủ và chi tiết của tài liệu hướng dẫn, được biên soạn lại để phù hợp với đội ngũ phát triển dự án OmniHealth của bạn.

---

# HƯỚNG DẪN LẬP TRÌNH FLUTTER - DỰ ÁN OMNIHEALTH

## Mục Lục

1.  [Tổng Quan Quy Trình Phát Triển](https://www.google.com/search?q=%23t%E1%BB%95ng-quan-quy-tr%C3%ACnh-ph%C3%A1t-tri%E1%BB%83n)
2.  [Bước 1: Phân Tích Thiết Kế Figma](https://www.google.com/search?q=%23b%C6%B0%E1%BB%9Bc-1-ph%C3%A2n-t%C3%ADch-thi%E1%BA%BFt-k%E1%BA%BF-figma)
3.  [Bước 2: Tạo Domain Layer (Tầng Nghiệp Vụ)](https://www.google.com/search?q=%23b%C6%B0%E1%BB%9Bc-2-t%E1%BA%A1o-domain-layer-t%E1%BA%A7ng-nghi%E1%BB%87p-v%E1%BB%A5)
4.  [Bước 3: Phân Tích & Test API](https://www.google.com/search?q=%23b%C6%B0%E1%BB%9Bc-3-ph%C3%A2n-t%C3%ADch--test-api)
5.  [Bước 4: Tạo Data Layer (Tầng Dữ Liệu)](https://www.google.com/search?q=%23b%C6%B0%E1%BB%9Bc-4-t%E1%BA%A1o-data-layer-t%E1%BA%A7ng-d%E1%BB%AF-li%E1%BB%87u)
6.  [Bước 5: Thiết Lập Dependency Injection](https://www.google.com/search?q=%23b%C6%B0%E1%BB%9Bc-5-thi%E1%BA%BFt-l%E1%BA%ADp-dependency-injection)
7.  [Bước 6: Quản Lý Trạng Thái (BLoC/Cubit)](https://www.google.com/search?q=%23b%C6%B0%E1%BB%9Bc-6-qu%E1%BA%A3n-l%C3%BD-tr%E1%BA%A1ng-th%C3%A1i-bloccubit)
8.  [Bước 7: Xây Dựng UI/UX](https://www.google.com/search?q=%23b%C6%B0%E1%BB%9Bc-7-x%C3%A2y-d%E1%BB%B1ng-uiux)
9.  [Các Nguyên Tắc & Thực Hành Tốt Nhất](https://www.google.com/search?q=%23c%C3%A1c-nguy%C3%AAn-t%E1%BA%AFc--th%E1%BB%B1c-h%C3%A0nh-t%E1%BB%91t-nh%E1%BA%A5t)

---

## Tổng Quan Quy Trình Phát Triển

Hướng dẫn này tuân thủ nghiêm ngặt mô hình **Clean Architecture** cho việc phát triển Flutter trong dự án OmniHealth. Luôn tuân theo các bước sau theo đúng thứ tự:

1.  **Phân tích Figma** → Hiểu rõ các sự kiện (events) và trạng thái (states) của UI.
2.  **Domain Layer** → Tạo các Entities (Thực thể) và Abstracts (Lớp trừu tượng).
3.  **Phân tích API** → Test các endpoints bằng Postman để hiểu dữ liệu.
4.  **Data Layer** → Tạo Models, Datasources, và Repositories.
5.  **Dependency Injection** → Đăng ký các dependencies mới.
6.  **State Management** → Triển khai BLoC hoặc Cubit.
7.  **UI/UX Layer** → Xây dựng màn hình (Screens) và Widgets.

---

## Bước 1: Phân Tích Thiết Kế Figma

Trước khi viết bất kỳ dòng code nào, hãy phân tích thiết kế trên Figma để hiểu:

### Xác định Sự kiện Người dùng (User Events)

- Người dùng có thể thực hiện hành động gì? (chạm, nhập liệu, cuộn).
- Điều gì kích hoạt thay đổi dữ liệu? (gửi form, bấm nút).
- Luồng điều hướng như thế nào? (chuyển màn hình).

### Xác định Trạng thái Ứng dụng (Application States)

- **Loading:** Đang tải (vòng xoay, thanh tiến trình).
- **Success:** Thành công (hiển thị dữ liệu, thông báo xác nhận).
- **Error:** Lỗi (thông báo lỗi, nút thử lại).
- **Empty:** Trống (không có dữ liệu, trạng thái ban đầu).

### Ví dụ Phân tích

```text
Màn hình: Hồ sơ người dùng (User Profile)
Sự kiện (Events):
- Chạm nút chỉnh sửa hồ sơ
- Gửi form lưu thay đổi
- Tải lên ảnh đại diện

Trạng thái (States):
- Loading: Khi đang lấy hoặc cập nhật dữ liệu hồ sơ.
- Success: Hiển thị thông tin người dùng.
- Error: Hiện thông báo lỗi khi cập nhật thất bại.
- Editing: Form đang ở chế độ chỉnh sửa.
```

---

## Bước 2: Tạo Domain Layer (Tầng Nghiệp Vụ)

### 2.1 Tạo Entities (Thực thể)

**Vị trí:** `lib/domain/entities/`

**Quy tắc:**

- **BẮT BUỘC** kế thừa `Equatable`.
- **BẮT BUỘC** override getter `props` với tất cả các trường.
- Là các class Dart thuần túy (không import thư viện Flutter như material, widgets...).
- Chỉ chứa logic nghiệp vụ cốt lõi.

<!-- end list -->

```dart
// lib/domain/entities/user_profile.dart
import 'package:equatable/equatable.dart';

class UserProfile extends Equatable {
  final String id;
  final String name;
  final String email;
  final String? avatar;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserProfile({
    required this.id,
    required this.name,
    required this.email,
    this.avatar,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [id, name, email, avatar, createdAt, updatedAt];

  // Hàm copyWith giúp tạo bản sao mới khi cần thay đổi 1 vài trường
  UserProfile copyWith({
    String? id,
    String? name,
    String? email,
    String? avatar,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      avatar: avatar ?? this.avatar,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
```

### 2.2 Tạo Repository Abstracts

**Vị trí:** `lib/domain/abstracts/`

**Quy tắc:**

- Định nghĩa tất cả các thao tác dữ liệu dưới dạng hàm trừu tượng (`abstract methods`).
- Mỗi Entity hoặc tính năng nên có một Abstract Repository riêng.
- Các hàm phải trả về/sử dụng **Entities**, không dùng Models.

<!-- end list -->

```dart
// lib/domain/abstracts/user_profile_repository.dart
import 'package:dacn_omnimer_health/domain/entities/user_profile.dart';

abstract class UserProfileRepository {
  Future<UserProfile> getUserProfile(String userId);
  Future<UserProfile> updateUserProfile(UserProfile profile);
  Future<String> uploadProfilePicture(String userId, String filePath);
  Future<void> deleteUserProfile(String userId);
}
```

### 2.3 Tạo Use Cases

**Vị trí:** `lib/domain/usecases/`

**Quy tắc:**

- Mỗi hành động nghiệp vụ cụ thể là một Use Case riêng biệt.
- Mỗi hàm trong Abstract Repository sẽ tương ứng với một Use Case.
- Phải có tính tái sử dụng và dễ dàng kiểm thử (testable).

<!-- end list -->

```dart
// lib/domain/usecases/get_user_profile.dart
import 'package:dacn_omnimer_health/domain/abstracts/user_profile_repository.dart';
import 'package:dacn_omnimer_health/domain/entities/user_profile.dart';

class GetUserProfileUseCase {
  final UserProfileRepository _repository;

  GetUserProfileUseCase(this._repository);

  Future<UserProfile> call(String userId) async {
    return await _repository.getUserProfile(userId);
  }
}

// lib/domain/usecases/update_user_profile.dart
class UpdateUserProfileUseCase {
  final UserProfileRepository _repository;

  UpdateUserProfileUseCase(this._repository);

  Future<UserProfile> call(UserProfile profile) async {
    return await _repository.updateUserProfile(profile);
  }
}
```

---

## Bước 3: Phân Tích & Test API

### 3.1 Kiểm tra Endpoints có sẵn

**Vị trí:** `lib/core/api/endpoints.dart`

Xem xét file này để biết:

- Các đường dẫn API (routes) hiện có.
- Các tham số bắt buộc.
- Phương thức HTTP (GET, POST, PUT, DELETE).
- Yêu cầu về xác thực (Authentication/Token).

<!-- end list -->

```dart
// lib/core/api/endpoints.dart (Ví dụ)
class ApiEndpoints {
  static const String baseUrl = 'https://api.omnihealth.com';

  // Các endpoints cho User Profile
  static const String userProfile = '/user/profile';
  static const String updateProfile = '/user/profile';
  static const String uploadAvatar = '/user/profile/avatar';
}
```

### 3.2 Test bằng Postman

Trước khi code, hãy test endpoints trong Postman để hiểu:

#### Định dạng Request/Response

```json
// GET /user/profile/{userId}
// Headers: Authorization: Bearer {token}

// Ví dụ Response trả về:
{
  "success": true,
  "data": {
    "id": "user123",
    "name": "Nguyen Van A",
    "email": "nguyen@example.com",
    "avatar": "https://example.com/avatar.jpg",
    "createdAt": "2024-01-01T00:00:00Z",
    "updatedAt": "2024-01-01T00:00:00Z"
  }
}
```

#### Phân tích Dữ liệu Vào/Ra

- **Input:** API cần gửi lên dữ liệu gì? (Body, Params).
- **Output:** API trả về cấu trúc JSON như thế nào?
- **Xử lý lỗi:** Các mã lỗi có thể xảy ra (400, 401, 404, 500).

---

## Bước 4: Tạo Data Layer (Tầng Dữ Liệu)

### 4.1 Tạo Models

**Vị trí:** `lib/data/models/`

**Quy tắc:**

- Là DTOs (Data Transfer Objects) dùng để giao tiếp với API.
- **BẮT BUỘC** có hàm `fromJson` và `toJson`.
- **BẮT BUỘC** có hàm `toEntity()` để chuyển đổi sang Domain Entity.
- **KHÔNG** kế thừa từ Entities (để tách biệt hoàn toàn hai tầng).

<!-- end list -->

```dart
// lib/data/models/user_profile_model.dart
import 'package:dacn_omnimer_health/domain/entities/user_profile.dart';

class UserProfileModel {
  // ... Khai báo biến (giống Entity nhưng có thể nullable tùy response API) ...

  UserProfileModel({ ... });

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      id: json['id'] as String,
      name: json['name'] as String,
      // ... parse các trường khác ...
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      // ...
    };
  }

  // Hàm quan trọng để chuyển đổi sang Entity
  UserProfile toEntity() {
    return UserProfile(
      id: id,
      name: name,
      email: email,
      avatar: avatar,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
```

### 4.2 Tạo Data Sources

**Vị trí:** `lib/data/datasources/`

#### Remote Data Source (Xử lý gọi API trực tiếp)

```dart
// lib/data/datasources/user_profile_remote_datasource.dart
import 'package:dacn_omnimer_health/core/api/dio_client.dart';

abstract class UserProfileRemoteDataSource {
  Future<UserProfileModel> getUserProfile(String userId);
  // ... các hàm khác
}

class UserProfileRemoteDataSourceImpl implements UserProfileRemoteDataSource {
  final DioClient _dioClient;

  UserProfileRemoteDataSourceImpl(this._dioClient);

  @override
  Future<UserProfileModel> getUserProfile(String userId) async {
    final response = await _dioClient.get('${ApiEndpoints.userProfile}/$userId');
    // Lấy data từ response và parse thành Model
    return UserProfileModel.fromJson(response.data['data']);
  }
  // ... implement các hàm khác
}
```

### 4.3 Triển khai Repositories (Impl)

**Vị trí:** `lib/data/repositories/`

**Quy tắc:**

- **BẮT BUỘC** implements các interface từ `domain/abstracts`.
- Gọi Datasource để lấy Model, sau đó chuyển đổi (`toEntity`) trước khi trả về.
- Xử lý mọi logic chuyển đổi dữ liệu tại đây.

<!-- end list -->

```dart
// lib/data/repositories/user_profile_repository_impl.dart
class UserProfileRepositoryImpl implements UserProfileRepository {
  final UserProfileRemoteDataSource _remoteDataSource;

  UserProfileRepositoryImpl(this._remoteDataSource);

  @override
  Future<UserProfile> getUserProfile(String userId) async {
    // Lấy Model từ Datasource
    final model = await _remoteDataSource.getUserProfile(userId);
    // Chuyển đổi thành Entity để trả về cho Domain layer
    return model.toEntity();
  }

  // ... implement các hàm khác
}
```

---

## Bước 5: Thiết Lập Dependency Injection

**Vị trí:** `lib/injection_container.dart`

Đăng ký tất cả các class mới tạo vào container (Service Locator):

```dart
// lib/injection_container.dart
final GetIt sl = GetIt.instance;

Future<void> init() async {
  // --- Data Sources ---
  sl.registerLazySingleton<UserProfileRemoteDataSource>(
    () => UserProfileRemoteDataSourceImpl(sl()), // Tiêm DioClient vào
  );

  // --- Repositories ---
  sl.registerLazySingleton<UserProfileRepository>(
    () => UserProfileRepositoryImpl(sl()), // Tiêm DataSource vào
  );

  // --- Use Cases ---
  sl.registerLazySingleton<GetUserProfileUseCase>(
    () => GetUserProfileUseCase(sl()), // Tiêm Repository vào
  );
  // ... đăng ký các use case khác
}
```

---

## Bước 6: Quản Lý Trạng Thái (BLoC/Cubit)

**Vị trí:** `lib/presentation/bloc/` hoặc `lib/presentation/cubit/`

### 6.1 Định nghĩa Events và States

**Quyết định độ phức tạp:**

- Dùng **Cubit** cho logic đơn giản.
- Dùng **BLoC** cho logic nghiệp vụ phức tạp, nhiều loại sự kiện đầu vào.

**Events (Sự kiện):**

```dart
// user_profile_event.dart
abstract class UserProfileEvent extends Equatable { ... }

class GetUserProfileEvent extends UserProfileEvent {
  final String userId;
  // ...
}
```

**States (Trạng thái):**

```dart
// user_profile_state.dart
abstract class UserProfileState extends Equatable { ... }

class UserProfileInitial extends UserProfileState {}
class UserProfileLoading extends UserProfileState {} // Đang tải
class UserProfileLoaded extends UserProfileState {   // Tải xong, có dữ liệu
  final UserProfile userProfile;
  const UserProfileLoaded(this.userProfile);
  // ...
}
class UserProfileError extends UserProfileState {    // Lỗi
  final String message;
  // ...
}
```

### 6.2 Triển khai BLoC

```dart
// user_profile_bloc.dart
class UserProfileBloc extends Bloc<UserProfileEvent, UserProfileState> {
  final GetUserProfileUseCase _getUserProfileUseCase;

  UserProfileBloc({
    required GetUserProfileUseCase getUserProfileUseCase,
  })  : _getUserProfileUseCase = getUserProfileUseCase,
        super(UserProfileInitial()) {

    // Đăng ký xử lý sự kiện
    on<GetUserProfileEvent>(_onGetUserProfile);
  }

  Future<void> _onGetUserProfile(
    GetUserProfileEvent event,
    Emitter<UserProfileState> emit,
  ) async {
    emit(UserProfileLoading()); // Bắn state Loading
    try {
      final userProfile = await _getUserProfileUseCase(event.userId);
      emit(UserProfileLoaded(userProfile)); // Bắn state Loaded kèm data
    } catch (e) {
      emit(UserProfileError(e.toString())); // Bắn state Error
    }
  }
}
```

---

## Bước 7: Xây Dựng UI/UX

### 7.1 Cấu Trúc Màn Hình (Screen)

**Vị trí:** `lib/presentation/screen/`

```dart
// lib/presentation/screen/user_profile_screen.dart
class UserProfileScreen extends StatelessWidget {
  // ...
  @override
  Widget build(BuildContext context) {
    // Cung cấp BLoC cho màn hình này
    return BlocProvider(
      create: (context) => sl<UserProfileBloc>()..add(GetUserProfileEvent(userId)),
      child: UserProfileView(),
    );
  }
}

class UserProfileView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Hồ sơ')),
      // Lắng nghe sự thay đổi State
      body: BlocBuilder<UserProfileBloc, UserProfileState>(
        builder: (context, state) {
          if (state is UserProfileLoading) {
            return Center(child: CircularProgressIndicator());
          } else if (state is UserProfileLoaded) {
            return _buildLoadedState(context, state); // Hàm tách riêng để code gọn
          } else if (state is UserProfileError) {
            return Center(child: Text('Lỗi: ${state.message}'));
          }
          return SizedBox.shrink();
        },
      ),
    );
  }
  // ... Các hàm _build private
}
```

### 7.2 Widgets Tái Sử Dụng

**Vị trí:** `lib/presentation/common/`
Luôn tách nhỏ code thành các widget con nếu có thể tái sử dụng (Ví dụ: `ProfileAvatarWidget`, `ProfileInfoWidget`).

### 7.3 Xử lý Form và Validate

Sử dụng class Validation có sẵn tại `lib/core/validation`.

```dart
TextFormField(
  controller: _emailController,
  validator: Validation.email, // Sử dụng hàm validate chung
  decoration: InputDecoration(labelText: 'Email'),
),
```

### 7.4 Xử lý Query/Lọc

Sử dụng tiện ích Query tại `lib/utils/query_util` để tạo chuỗi query params cho API (sort, filter, search).

---

## Các Nguyên Tắc & Thực Hành Tốt Nhất

### Tổ Chức Code

1.  **Tách nhỏ Widget:** Không viết tất cả trong một file màn hình. Các widget dùng chung để ở `lib/presentation/common/`.
2.  **Sử dụng Theme:** Luôn dùng `Theme.of(context)` (màu sắc, font chữ) được định nghĩa ở `lib/core/theme`. Không hardcode màu sắc.
3.  **Tuân thủ Clean Architecture:**
    - Domain layer KHÔNG import bất cứ thứ gì của Flutter/UI/Data layer.
    - Data layer xử lý việc parse JSON.
    - Presentation layer chỉ lo việc hiển thị.

### Validation (Kiểm tra dữ liệu)

Sử dụng các hàm static trong `lib/core/validation/validation.dart`:

- `Validation.name(value)`
- `Validation.email(value)`
- `Validation.password(value)`

### Xử lý Lỗi

Luôn hiển thị thông báo lỗi thân thiện với người dùng, tránh hiển thị lỗi kỹ thuật thô (Raw Exception).

### Quy Tắc Đặt Tên

- Tên file: `snake_case` (ví dụ: `user_profile_screen.dart`)
- Tên class: `PascalCase` (ví dụ: `UserProfileScreen`)

---

## Danh Sách Kiểm Tra Nhanh (Checklist)

Trước khi hoàn thành một tính năng (Feature), hãy kiểm tra:

- [ ] Đã phân tích kỹ thiết kế Figma (Events/States).
- [ ] Tất cả Entities đã `extend Equatable`.
- [ ] Đã tạo Repository Abstracts trong Domain.
- [ ] Đã tạo đầy đủ Use Cases.
- [ ] Đã test API endpoints bằng Postman.
- [ ] Models đã có hàm `toEntity()`, `fromJson()`, `toJson()`.
- [ ] Đã implement Data Sources và Repositories.
- [ ] Đã đăng ký dependencies trong `injection_container.dart`.
- [ ] BLoC/Cubit đã xử lý đủ các trạng thái (Loading, Loaded, Error).
- [ ] UI sử dụng Theme từ `core/theme`.
- [ ] Các Form input đã dùng Validation từ `core/validation`.
- [ ] Logic lọc/tìm kiếm đã dùng `query_util`.
- [ ] Code tuân thủ đúng quy tắc Clean Architecture.

**Hãy làm theo hướng dẫn này một cách nhất quán để đảm bảo code của dự án OmniHealth dễ bảo trì và mở rộng\!**
