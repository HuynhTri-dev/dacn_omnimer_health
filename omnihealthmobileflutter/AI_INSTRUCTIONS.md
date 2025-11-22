# PROJECT CONTEXT: OmniHealth Mobile (Flutter)

## 1. ARCHITECTURE & TECH STACK (MANDATORY COMPLIANCE)

- **Framework:** Flutter (Dart).
- **Architecture:** CLEAN ARCHITECTURE (Strict Separation of Concerns).
- **Dependency Injection:** Uses `injection_container.dart` for all dependencies.
- **Networking:** Dio/Http configuration must be handled in `lib/core/api`.
- **Local Storage:** Services (e.g., SecureStorageService / SharedPreferencesService) must be used from `lib/services`.

## 2. LAYERS & DEPENDENCY RULES (INVIOLABLE CONSTRAINTS)

The Agent MUST strictly follow the one-way dependency flow: `Presentation` -> `Domain` <- `Data`

### A. Domain Layer (`lib/domain`) - PURE DART

- **Contents:** Entities, UseCases, Repository Interfaces (Abstracts).
- **Rules:**

  - **Entities:** MUST extend **`Equatable`** (from `package:equatable/equatable.dart`).
  - **Entities:** MUST override the **`props`** getter to include all fields. This ensures value equality, not reference equality.

- **Forbidden Rules:**
    - MUST NOT import `flutter/material.dart` or `flutter/cupertino.dart`.
    - MUST NOT contain JSON serialization/deserialization logic.
    - MUST NOT depend on the Data Layer.

### B. Data Layer (`lib/data`)

- **Contents:** Models, Datasources (Remote/Local), Repository Implementations.
- **Rules:**
    - **Models:** These are DTOs (Data Transfer Objects).
      - MUST include `fromJson` / `toJson` methods for serialization.
      - MUST include a mapping method: **`toEntity()`** to convert the Model into a Domain Entity.
      - MUST NOT extend (inherit from) Entities from the Domain.
    - **Repositories:** MUST implement interfaces from `domain/abstracts`.
    - **Data Flow:** Repository Implementations MUST convert all received Models into Domain Entities before returning the result.

### C. Presentation Layer (`lib/presentation`)

- **Contents:** Screens, Widgets (Common), State Management (e.g., BLoC, Provider, Riverpod).
- **Rules:**
    - ONLY calls `UseCase`s. MUST NOT directly call any Repository or Datasource.
    - Full screen logic must reside in `screen/`. Reusable, generic widgets must be placed in `common/`.

## 3. FILE STRUCTURE & ORGANIZATION

All new files must be placed in the following dedicated locations:

```text
lib/
├── core/           # Shared (api client, constants, theme, routing, utils)
├── domain/         # Business Logic
│   ├── entities/   # Core Business Objects (The What)
│   ├── usecases/   # Specific Business Actions (The How)
│   └── abstracts/  # Repository Contracts (Interfaces)
├── data/           # Data Implementation
│   ├── datasources/# API calls / DB access
│   ├── models/     # DTOs (Data Models)
│   └── repositories/# Concrete Repository Implementations
├── presentation/   # UI
│   ├── screen/     # Full screens
│   └── common/     # Reusable Widgets
├── services/       # System/3rd Party Services (e.g., Secure Storage)
└── injection_container.dart # Dependency Injection Setup
```

## 4. CODING & QUALITY STANDARDS

File Naming: MUST use snake_case (e.g., user_profile_screen.dart).

Class Naming: MUST use PascalCase (e.g., UserProfileScreen, AuthRepositoryImpl).

Testing: Unit Tests (using Vitest or flutter_test) MUST be written for all new UseCases and Repository implementations.

Commits: All commit messages MUST follow Conventional Commits standards (e.g., feat: Add user login feature).

Imports: Imports MUST be sorted and unused imports MUST be removed.

## 5. AGENT COMMUNICATION (ZERO FRICTION MODE)

Output Focus: Your output must be the code files (Artifacts) and the Execution Plan.

MINIMAL EXPLANATION: You MUST NOT provide conversational introductions, summaries, or explanations of the code unless explicitly asked for (e.g., "Explain the architecture").

NO EXTRA FILES: Do NOT create standalone explanation files (like README.md or EXPLANATION.md) unless the user specifically requests them. Your focus is implementation and verification.
