# Code Review & Fix Plan

## Overview

This document outlines the logic, UI/UX, and performance issues identified in the `omnihealthmobileflutter` codebase, along with a plan to address them.

## 1. Critical Logic & State Management Issues

### 1.1. State Loss on Tab Switch (HomeScreen)

- **Fix**:
  - Refactor `CustomTextField` to use `TextFormField` so it can be wrapped in a `Form`.
  - Use `GlobalKey<FormState>` in `LoginForm` to trigger `validate()` on all fields before submission.

## 2. Performance Issues

### 2.1. Inefficient List Rendering

- **Location**:
  - `lib/presentation/screen/workout/workout_home/workout_home_screen.dart`
  - `lib/presentation/screen/report/report_screen.dart`
- **Issue**: Using `ListView.separated` with `shrinkWrap: true` and `NeverScrollableScrollPhysics` inside a `SingleChildScrollView`.
- **Impact**: This forces the `ListView` to calculate the height of all its children immediately, rendering them all at once. This negates the lazy-loading benefit of `ListView` and causes jank with long lists.
- **Fix**:
  - If the entire page needs to scroll, use `CustomScrollView` with `SliverList` (or `SliverChildBuilderDelegate`) instead of nesting scrollables.
  - Alternatively, if the list is the main content, remove `SingleChildScrollView` and let `ListView` handle the scrolling (remove `shrinkWrap` and `physics`).

## 3. UI/UX Improvements

### 3.1. Hardcoded Styles

- **Location**: `lib/presentation/screen/home_screen.dart`
- **Issue**: `CurvedNavigationBar` uses hardcoded opacity for shadows (`theme.shadowColor.withOpacity(0.15)`).
- **Fix**: Define these variations in the `ThemeData` or `AppTheme` to ensure consistency and easier dark mode adjustments.

### 3.2. Error Handling

- **Location**: `lib/data/repositories/auth_repository_impl.dart`
- **Issue**: Returns generic error strings (`"Đăng ký thất bại: ${e.toString()}"`).
- **Fix**: Map exceptions to user-friendly messages (e.g., "Network error", "Invalid credentials") in the Repository or a shared ErrorHandler before passing to the UI.

## Implementation Plan

1.  **Refactor HomeScreen**: Implement `IndexedStack` to preserve tab state.
2.  **Fix Form Validation**: Convert `CustomTextField` to use `TextFormField` and implement `Form` validation in `LoginForm`.
3.  **Optimize Lists**: Refactor `WorkoutHomeScreen` and `ReportScreen` to use `CustomScrollView` + `Slivers` for better performance.
4.  **Polish UI/UX**: Standardize error messages and theme usage.

## 4. Privacy & LOD Module Issues

### 4.1. Hardcoded Strings & Localization

- **Location**: `lib/presentation/screen/privacy_lod/privacy_lod_screen.dart`, `lib/presentation/screen/privacy_lod/policy_viewer_screen.dart`
- **Issue**: Extensive use of hardcoded strings ("Privacy & Data", "Legal Documents", "Your Data is Protected", etc.).
- **Fix**: Extract all strings to a localization file (`l10n` or `strings.dart`) to support multiple languages.

### 4.2. Scroll Detection Logic

- **Location**: `lib/presentation/screen/privacy_lod/policy_viewer_screen.dart`
- **Issue**: `_onScroll` logic relies on `maxScrollExtent`. If the content is shorter than the screen, `maxScrollExtent` might be 0, preventing the "scrolled to end" state from triggering.
- **Fix**: Check if content fits the screen in `_loadMarkdownContent` or `build` and set `_hasScrolledToEnd` to true immediately if so.

## 5. Health Profile Form Issues

### 5.1. "God Widget" & Mixed State Management

- **Location**: `lib/presentation/screen/health_profile/health_profile_form/personal_profile_form_page.dart`
- **Issue**: The widget manages a massive amount of local state (dozens of controllers, boolean flags, lists) alongside `BlocConsumer`. This makes it hard to test and maintain.
- **Fix**: Move form state and logic into the `HealthProfileFormBloc` or a dedicated `FormCubit`. Use `Form` and `TextFormField` for validation.

### 5.2. Manual Validation

- **Location**: `lib/presentation/screen/health_profile/health_profile_form/personal_profile_form_page.dart`
- **Issue**: Validation is done manually in `_handleSubmit` (e.g., checking `controller.text.isEmpty`).
- **Fix**: Wrap inputs in a `Form` widget and use `TextFormField` with `validator` callbacks for standard, inline validation errors.

### 5.3. Hardcoded Mock Data

- **Location**: `lib/presentation/screen/health_profile/health_profile_form/personal_profile_form_page.dart`
- **Issue**: Health status options (e.g., "Diabetes", "Hypertension") are hardcoded lists.
- **Fix**: Move these options to a Repository or Configuration file to allow for dynamic updates and localization.
