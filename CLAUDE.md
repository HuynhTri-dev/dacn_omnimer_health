# PROJECT CONTEXT: OmniMer Health Ecosystem

## 1. OVERVIEW

This repository contains a multi-platform health ecosystem consisting of:

1.  **Mobile App:** Flutter (Clean Architecture)
2.  **Backend Server:** Node.js/Express (TypeScript, DDD)
3.  **AI Server:** Python/FastAPI (PyTorch, Scikit-learn)
4.  **Admin Portal:** React (Vite, TypeScript)

---

## 2. MOBILE APP (`omnihealthmobileflutter`)

### Architecture & Tech Stack

- **Framework:** Flutter (Dart)
- **Architecture:** Clean Architecture (Presentation -> Domain <- Data)
- **State Management:** BLoC (`flutter_bloc`)
- **Dependency Injection:** `get_it` (configured in `injection_container.dart`)
- **UI:** `flutter_screenutil` for responsiveness.

### Layer Rules

- **Domain (`lib/domain`):**
  - Pure Dart.
  - Entities must extend `Equatable`.
  - UseCases are callable classes executing specific business actions.
  - Repository Interfaces (Abstracts) define contracts.
- **Data (`lib/data`):**
  - Models are DTOs with `fromJson`/`toJson`.
  - Models must implement `toEntity()` to map to Domain Entities.
  - Repositories implement Domain interfaces.
- **Presentation (`lib/presentation`):**
  - BLoCs handle business logic and state changes.
  - Screens reside in `screen/`, reusable widgets in `common/`.
  - **Strict Rule:** Presentation layer talks ONLY to Domain UseCases, NEVER to Repositories directly.

### Naming Conventions

- **Files:** `snake_case.dart`
- **Classes:** `PascalCase`
- **Variables/Functions:** `camelCase`

---

## 3. BACKEND SERVER (`omnimer_health_server`)

### Architecture & Tech Stack

- **Framework:** Node.js with Express & TypeScript.
- **Database:** MongoDB (Mongoose).
- **Structure:** Domain-Driven Design (DDD).
  - `src/domain/controllers`: Handle HTTP requests/responses.
  - `src/domain/services`: Business logic.
  - `src/domain/repositories`: Database interactions.
  - `src/domain/models`: Mongoose schemas & interfaces.
  - `src/domain/routes`: Express routers.

### Key Patterns

- **Response:** Use helpers `sendSuccess`, `sendCreated`, `sendError` from `utils/ResponseHelper`.
- **Error Handling:** Global error handler middleware. Use `HttpError` class.
- **Dependency Injection:** Manual injection pattern (Controller -> Service -> Repository).
- **Authentication:** JWT middleware (`verifyAccessToken`).

---

## 4. AI SERVER (`3T-FIT/ai_server`)

### Architecture & Tech Stack

- **Framework:** FastAPI (Python).
- **ML Libraries:** PyTorch, Pandas, Scikit-learn, NumPy.
- **Structure:**
  - `app/`: API endpoints (`main.py`), inference logic (`recommend.py`), schemas.
  - `artifacts_unified/`: Training scripts (`src/`), saved models.

### Coding Style

- **Type Hinting:** Mandatory for function arguments and return types.
- **Data Handling:** Use Pandas DataFrames for tabular data processing.
- **Model Loading:** Load artifacts (models, scalers) efficiently.

---

## 5. ADMIN PORTAL (`adminpage`)

### Architecture & Tech Stack

- **Framework:** React (Vite, TypeScript).
- **Styling:** TailwindCSS.
- **State:** React Hooks.

---

## 6. GENERAL WORKFLOW & RULES

- **Commits:** Conventional Commits (e.g., `feat: add login`, `fix: resolve crash`).
- **Paths:** Always use absolute paths when referencing files in tools.
- **Agent Behavior:**
  - Focus on implementation and verification.
  - Do not provide conversational filler unless asked.
  - Strictly follow the architecture of the specific sub-project being modified.
