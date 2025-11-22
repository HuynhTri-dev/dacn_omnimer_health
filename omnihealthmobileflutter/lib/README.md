# Project Structure Documentation

## Directory Structure

```
lib/
├── core/                   # Core functionality and base implementations
│   ├── api/               # API related implementations
│   │   ├── api_client.dart        # HTTP client using Dio
│   │   ├── api_exception.dart     # Custom API exceptions
│   │   ├── api_response.dart      # Standard API response wrapper
│   │   ├── app_config.dart        # Environment configuration
│   │   └── endpoints.dart         # API endpoint definitions
│   ├── constants/         # App-wide constants
│   └── theme/            # App theming and styling
├── data/                  # Data layer implementation
│   ├── datasources/      # Data providers implementation
│   │   └── auth_datasource.dart   # Authentication API calls
│   ├── models/           # API data models
│   │   └── user_model.dart        # User data model for API
│   └── repositories/     # Repository implementations
│       └── auth_repository_impl.dart  # Auth repository implementation
├── domain/               # Business logic layer
│   ├── abstracts/        # Abstract definitions
│   │   └── auth_repository.dart   # Auth repository interface
│   ├── entities/         # Business entities
│   │   └── user_entity.dart       # User domain entity
│   └── usecase/         # Business use case
│       └── login_usecase.dart       # Login Use Case (Đăng ký chức năng trong login use case)
├── presentation/         # UI Layer
│   ├── screens/         # App screens/pages
│   └── widgets/         # Reusable widgets
├── services/             # Service implementations
│   ├── firebase_auth_service.dart  # Firebase authentication
│   └── firebase_auth_failure.dart  # Firebase error handling
└── utils/               # Utility functions
    ├── filter_util.dart    # Data filtering utilities
    ├── logger.dart         # Logging utility
    ├── query_builder.dart  # Query building helper
    └── sort_util.dart      # Sorting utilities
```

## Layer Explanations

### 1. Core Layer (`/core`)

Core functionality that is used throughout the application.

- **api/**: Contains all API related implementations
  - `api_client.dart`: Centralized HTTP client using Dio
  - `api_response.dart`: Standard response format for all API calls
  - `api_exception.dart`: Custom exceptions for API errors
  - `endpoints.dart`: API endpoint definitions
  - `app_config.dart`: Environment-specific configurations

### 2. Data Layer (`/data`)

Handles data operations and transformations.

- **datasources/**: Implementation of data providers

  - Handles direct API calls
  - Implements caching if needed
  - Example: `auth_datasource.dart` handles authentication API calls

- **models/**: Data models for API communication

  - Implements `fromJson`/`toJson` for serialization
  - Includes conversion methods to/from domain entities
  - Example: `user_model.dart` represents API user data structure

- **repositories/**: Implementation of domain repositories
  - Converts between models and entities
  - Handles data source selection (cache vs API)
  - Example: `auth_repository_impl.dart` implements `AuthRepository`

### 3. Domain Layer (`/domain`)

Contains business logic and rules.

- **abstracts/**: Interfaces/abstract classes

  - Defines contracts for repositories
  - Example: `auth_repository.dart` defines authentication operations

- **entities/**: Business objects
  - Pure data classes used in business logic
  - Independent of API structure
  - Example: `user_entity.dart` represents user in the application

### 4. Presentation Layer (`/presentation`)

Contains all UI components.

- **screens/**: Full page components

  - One file per screen
  - Handles screen-level state management

- **widgets/**: Reusable UI components
  - Shared widgets used across screens
  - Custom UI components

### 5. Services (`/services`)

Implements external service integrations.

- `firebase_auth_service.dart`: Firebase Authentication implementation
- `firebase_auth_failure.dart`: Firebase error handling

### 6. Utils (`/utils`)

Helper functions and utilities.

- `logger.dart`: Logging utility
- `filter_util.dart`: Data filtering helpers
- `sort_util.dart`: Sorting functionality
- `query_builder.dart`: Query construction helpers

## Data Flow Example

Using Authentication as an example:

1. **UI Layer** (`presentation/`) calls `AuthRepository.login()`

2. **Repository** (`data/repositories/auth_repository_impl.dart`):

   - Converts `LoginEntity` to `LoginRequestModel`
   - Calls `AuthDataSource.login()`
   - Converts `UserModel` response back to `UserEntity`

3. **DataSource** (`data/datasources/auth_datasource.dart`):
   - Makes API call using `ApiClient`
   - Handles Firebase authentication
   - Returns `UserModel`

## Best Practices

1. **Layer Independence**

   - Domain layer should not depend on data layer
   - Entities should not know about models
   - Use abstractions (interfaces) for dependencies

2. **Error Handling**

   - Use custom exceptions for different error cases
   - Transform API errors to domain-specific errors
   - Handle errors at appropriate levels

3. **Testing**

   - Each layer can be tested independently
   - Use dependency injection for better testability
   - Mock dependencies in tests

4. **Code Organization**
   - Keep files focused and single-responsibility
   - Use clear naming conventions
   - Group related functionality together
