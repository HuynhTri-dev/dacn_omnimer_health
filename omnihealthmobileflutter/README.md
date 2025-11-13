# OmniHealth Mobile Flutter App

## Project Structure

```
lib/
├── core/                   # Core functionality and configurations
│   ├── api/               # API related code
│   │   ├── api_client.dart        # HTTP client implementation
│   │   ├── api_exception.dart     # Custom exceptions
│   │   ├── api_response.dart      # Standardized API response wrapper
│   │   ├── app_config.dart        # App configuration
│   │   └── endpoints.dart         # API endpoints definitions
│   ├── constants/         # Application constants
│   └── theme/            # App theming and styling
├── data/                  # Data layer (repositories, data sources)
├── domain/               # Business logic and domain models
├── presentation/         # UI layer (screens, widgets)
├── services/             # Application services
├── utils/               # Utility functions and helpers
│   ├── filter_util.dart    # Filtering utilities
│   ├── logger.dart         # Logging functionality
│   ├── query_builder.dart  # Query building helpers
│   └── sort_util.dart      # Sorting utilities
├── firebase_options.dart  # Firebase configuration
└── main.dart             # Application entry point
```

## Coding Guidelines

### 1. API Integration

The app uses a standardized API integration approach with the following components:

#### API Client (`core/api/api_client.dart`)

- Uses Dio for HTTP requests
- Supports all standard HTTP methods (GET, POST, PUT, PATCH, DELETE)
- Includes file upload functionality
- Handles response parsing and error handling

Example usage:

```dart
final apiClient = ApiClient();

// GET request
final response = await apiClient.get<UserModel>(
  '/users',
  parser: (json) => UserModel.fromJson(json),
);

// POST request with data
final response = await apiClient.post<ResponseType>(
  '/endpoint',
  data: {'key': 'value'},
  parser: (json) => ResponseType.fromJson(json),
);
```

#### API Response Format

All API responses are wrapped in `ApiResponse<T>` class with the following structure:

```dart
class ApiResponse<T> {
  final bool success;
  final T? data;
  final String message;
  final dynamic error;
}
```

#### Error Handling

The app implements a comprehensive error handling system:

```dart
try {
  final response = await apiClient.get('/endpoint');
  // Handle success
} on UnauthorizedException {
  // Handle 401 unauthorized
} on BadRequestException {
  // Handle 400 bad request
} on NetworkException {
  // Handle network issues
} on ServerException {
  // Handle server errors
}
```

### 2. Project Layer Guidelines

#### Core Layer (`/core`)

- Contains fundamental application code
- Should be independent of other layers
- Houses configurations, constants, and base classes

#### Data Layer (`/data`)

- Implements repositories
- Handles data sources (local storage, API)
- Contains data models and mapping logic

#### Domain Layer (`/domain`)

- Contains business logic
- Defines entity models
- Houses use cases/interactors

#### Presentation Layer (`/presentation`)

- Contains all UI components
- Implements screens and widgets
- Handles state management

#### Services Layer (`/services`)

- Implements standalone services
- Handles background tasks
- Manages third-party integrations

### 3. Best Practices

1. **File Naming**

   - Use snake_case for file names
   - Add type suffixes: `user_repository.dart`, `home_screen.dart`

2. **Class Naming**

   - Use PascalCase for class names
   - Add clear suffixes: `UserRepository`, `HomeScreen`

3. **Code Organization**

   - Group related files in appropriate directories
   - Keep files focused and single-responsibility
   - Use exports in index files for cleaner imports

4. **Error Handling**

   - Use custom exceptions for different error cases
   - Handle errors at appropriate levels
   - Provide user-friendly error messages

5. **State Management**

   - Use appropriate state management solution for different cases
   - Keep business logic separate from UI
   - Follow unidirectional data flow

6. **Testing**
   - Write tests for business logic
   - Mock dependencies in tests
   - Use test helpers and fixtures

### 4. Utility Functions

The `/utils` directory contains several helpful utilities:

- **filter_util.dart**: Helpers for filtering data
- **logger.dart**: Structured logging functionality
- **query_builder.dart**: SQL/NoSQL query building helpers
- **sort_util.dart**: Data sorting utilities

### 5. Configuration

1. **Environment Configuration**

   - Use `app_config.dart` for environment-specific settings
   - Configure API endpoints in `endpoints.dart`
   - Manage Firebase settings in `firebase_options.dart`

2. **Theme Configuration**
   - Define app themes in `core/theme`
   - Use consistent colors and styles
   - Support light/dark modes

## Getting Started

1. Clone the repository
2. Install dependencies:
   ```bash
   flutter pub get
   ```
3. Run the app:
   ```bash
   flutter run
   ```

## Contributing

1. Follow the project structure
2. Maintain coding guidelines
3. Write tests for new features
4. Update documentation as needed

## Additional Resources

- [Flutter Documentation](https://docs.flutter.dev/)
- [Dart Documentation](https://dart.dev/guides)
- [Material Design](https://material.io/design)
