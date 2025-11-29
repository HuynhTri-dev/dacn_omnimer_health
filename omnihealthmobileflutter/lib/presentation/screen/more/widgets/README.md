# Profile Management Features

## Overview

This directory contains the profile management screens for the OmniMer Health application. These screens allow users to manage their account information, security settings, and authentication methods.

## Screens

### 1. Verify Account Screen (`verify_account_screen.dart`)

**Purpose**: Manage email verification and authentication methods

**Features**:

- **Email Verification**:

  - Display verification status
  - Send verification email
  - Visual indicator for verified/unverified status

- **Change Email**:

  - Update email address
  - Send verification to new email

- **Two-Factor Authentication**:

  - Enable/disable 2FA
  - Toggle switch for easy activation

- **Authentication Methods**:
  - Biometric Authentication (fingerprint/face ID)
  - SMS Authentication
  - Authenticator App (Google Authenticator, etc.)

**Navigation**: Accessible from More Screen → Profile → Verify Account

---

### 2. Info Account Screen (`info_account_screen.dart`)

**Purpose**: Update basic user information based on the User model

**User Model Fields** (from `omnimer_health_server/src/domain/models/Profile/User.model.ts`):

- `fullname`: string (required)
- `email`: string (read-only, change via Verify Account)
- `birthday`: Date (optional)
- `gender`: GenderEnum (Male, Female, Other)
- `imageUrl`: string (optional)

**Features**:

- **Profile Image**:

  - Display current profile picture
  - Upload new profile picture
  - Camera icon overlay for easy access

- **Full Name**:

  - Text input with validation
  - Required field

- **Email**:

  - Display only (read-only)
  - Info button to redirect to Verify Account for email changes

- **Birthday**:

  - Date picker interface
  - Optional field
  - Format: DD/MM/YYYY

- **Gender**:

  - Dropdown selection
  - Options: Male, Female, Other
  - Default: Other

- **Save Changes**:
  - Form validation
  - Success/error feedback
  - Auto-save on successful update

**Navigation**: Accessible from More Screen → Profile → Info Account

---

### 3. Change Password Screen (`change_password_screen.dart`)

**Purpose**: Update user password with security validation

**Features**:

- **Current Password**:

  - Secure input field
  - Toggle visibility
  - Required validation

- **New Password**:

  - Secure input field
  - Toggle visibility
  - Strength indicator (Weak, Fair, Good, Strong)
  - Real-time validation
  - Must be different from current password

- **Confirm Password**:

  - Secure input field
  - Toggle visibility
  - Match validation with new password

- **Password Strength Indicator**:

  - Visual progress bar
  - Color-coded (Red → Yellow → Blue → Green)
  - Text label (Weak, Fair, Good, Strong)
  - Real-time feedback

- **Password Requirements**:

  - Minimum 8 characters
  - Uppercase letter (A-Z)
  - Lowercase letter (a-z)
  - Number (0-9)
  - Special character (!@#$%^&\*)

- **Security Info Card**:

  - Tips for creating strong passwords
  - Visual reminder

- **Forgot Password**:
  - Link to password reset flow
  - Sends reset link to email

**Navigation**: Accessible from More Screen → Profile → Change Password

---

## Dropdown Menu Implementation

### Account Section Widget (`account_section.dart`)

The `AccountSection` widget has been enhanced with an animated dropdown menu:

**Features**:

- **Expandable Profile Menu**:

  - Tap to expand/collapse
  - Smooth animation (300ms)
  - Rotation animation for dropdown arrow

- **Dropdown Items**:

  1. Verify Account
  2. Info Account
  3. Change Password

- **Visual Design**:
  - Left border indicator
  - Icon + title + subtitle layout
  - Arrow indicator for navigation
  - Indented from parent menu item

**Animation Details**:

- Uses `AnimationController` with `SingleTickerProviderStateMixin`
- `SizeTransition` for smooth expand/collapse
- `RotationTransition` for arrow rotation (0° → 180°)
- `CurvedAnimation` with `Curves.easeInOut`

---

## User Flow

```
More Screen
  └── Profile (tap to expand)
      ├── Verify Account → VerifyAccountScreen
      │   ├── Email Verification
      │   ├── Change Email
      │   ├── Two-Factor Authentication
      │   └── Authentication Methods
      │
      ├── Info Account → InfoAccountScreen
      │   ├── Profile Image
      │   ├── Full Name
      │   ├── Email (read-only)
      │   ├── Birthday
      │   ├── Gender
      │   └── Save Changes
      │
      └── Change Password → ChangePasswordScreen
          ├── Current Password
          ├── New Password (with strength indicator)
          ├── Confirm Password
          └── Password Requirements
```

---

## TODO: Backend Integration

### API Endpoints Needed

1. **Verify Account**:

   - `POST /api/auth/send-verification-email`
   - `POST /api/auth/change-email`
   - `POST /api/auth/enable-2fa`
   - `POST /api/auth/disable-2fa`
   - `POST /api/auth/setup-biometric`
   - `POST /api/auth/setup-sms`
   - `POST /api/auth/setup-authenticator`

2. **Info Account**:

   - `GET /api/user/profile` - Get current user data
   - `PUT /api/user/profile` - Update user information
   - `POST /api/user/upload-image` - Upload profile image

3. **Change Password**:
   - `POST /api/auth/change-password`
   - `POST /api/auth/forgot-password`

### Data Models

**Update User Request**:

```typescript
{
  fullname?: string;
  birthday?: Date;
  gender?: 'Male' | 'Female' | 'Other';
  imageUrl?: string;
}
```

**Change Password Request**:

```typescript
{
  currentPassword: string;
  newPassword: string;
}
```

---

## Design Patterns Used

1. **StatefulWidget**: For managing dropdown state and animations
2. **Form Validation**: Using `GlobalKey<FormState>` for form validation
3. **Animation Controller**: For smooth UI transitions
4. **Material Design**: Following Material Design guidelines
5. **Responsive Design**: Using `flutter_screenutil` for responsive sizing

---

## Dependencies

- `flutter/material.dart` - Material Design widgets
- `flutter_screenutil` - Responsive sizing
- Custom theme files:
  - `app_colors.dart`
  - `app_spacing.dart`
  - `app_typography.dart`
  - `app_radius.dart`

---

## Notes

- All screens include placeholder implementations with TODO comments for backend integration
- Success/error feedback is provided via SnackBars
- All forms include proper validation
- Animations are smooth and follow Material Design guidelines
- The design is consistent with the existing app theme
