# OmniMer Health – Mobile User Setup Guide

## 1. Giới thiệu

Tài liệu này hướng dẫn chi tiết cách **setup môi trường và chạy dự án React Native CLI** cho thư mục `mobile_user` thuộc dự án **OmniMer Health**.  
Mục tiêu: đảm bảo mọi thành viên trong nhóm có thể **build và chạy ứng dụng thành công** trên Android.

---

## 2. Cài đặt thư viện

Trong thư mục `mobile_user`, chạy lệnh:

```bash
npm install
```

Lệnh này sẽ tải toàn bộ dependencies được định nghĩa trong file `package.json`.

---

## 3. Cấu hình môi trường (Environment Setup)

### 3.1. Cài đặt Node.js và npm

- Node.js phiên bản khuyến nghị: **v18.x hoặc v20.x**
- Kiểm tra bằng lệnh:
  ```bash
  node -v
  npm -v
  ```

### 3.2. Cài đặt Java JDK

React Native cần JDK 17 hoặc 11 tùy phiên bản Gradle.  
Khuyến nghị: **JDK 17**

- Tải: https://adoptium.net/
- Sau khi cài, thêm biến môi trường:
  ```
  JAVA_HOME = C:\Program Files\Eclipse Adoptium\jdk-17
  ```

Kiểm tra:

```bash
java -version
```

---

### 3.3. Cài đặt Android SDK

Cài **Android Studio**, rồi mở **SDK Manager** để đảm bảo có:

- Android SDK Platform 34 hoặc 35
- Android SDK Build-Tools 34.x.x
- Android NDK (phiên bản phù hợp, xem phần 3.4)

Thêm biến môi trường:

```
ANDROID_HOME = C:\Users\<username>\AppData\Local\Android\Sdk
PATH += %ANDROID_HOME%\platform-tools
PATH += %ANDROID_HOME%\emulator
PATH += %ANDROID_HOME%\cmdline-tools\latest\bin
```

---

### 3.4. Cài đặt NDK

React Native yêu cầu **NDK** tương thích với Gradle và `react-native` version.

Ví dụ:  
Nếu dự án dùng React Native 0.76.x, nên cài:

```
NDK version: 27.0.12077973
```

Trong Android Studio → **SDK Manager → SDK Tools → NDK (Side by side)** → chọn **Show Package Details** → tick vào phiên bản phù hợp.

Nếu dùng phiên bản khác (ví dụ 27.1.x) mà thiếu `source.properties` → **build sẽ lỗi**, nên chỉ giữ lại bản phù hợp hoặc chỉnh trong `gradle.properties` hoặc `build.gradle`.

---

## 4. Cấu hình biến PATH

Ví dụ file `.bashrc` hoặc `Environment Variables` trên Windows:

```
JAVA_HOME=C:\Program Files\Eclipse Adoptium\jdk-17
ANDROID_HOME=C:\Users\<username>\AppData\Local\Android\Sdk
PATH=%PATH%;%JAVA_HOME%\bin;%ANDROID_HOME%\tools;%ANDROID_HOME%\platform-tools
```

---

## 5. Chạy dự án

### 5.1. Khởi chạy Metro bundler

```bash
npx react-native start
```

### 5.2. Build và cài ứng dụng Android

```bash
npx react-native run-android
```

Nếu lỗi emulator, chạy tay:

```bash
emulator -list-avds
emulator -avd <tên_avd>
```

Sau đó, chạy lại:

```bash
npx react-native run-android
```

---

## 6. Lỗi thường gặp

### ❌ `NDK did not have a source.properties file`

> Nguyên nhân: NDK bị lỗi hoặc cài sai version.  
> Giải pháp:
>
> - Gỡ bản NDK lỗi trong SDK Manager.
> - Cài lại đúng version (ví dụ: `27.0.12077973`).
> - Kiểm tra trong `C:\Users\<username>\AppData\Local\Android\Sdk\ndk\<version>` có file `source.properties`.

### ❌ `adb not recognized`

> Nguyên nhân: `platform-tools` chưa được thêm vào PATH.  
> Giải pháp:
>
> ```
> PATH += %ANDROID_HOME%\platform-tools
> ```

### ❌ `No emulators found`

> Chưa tạo AVD (Android Virtual Device).  
> Giải pháp: mở Android Studio → Device Manager → Create Virtual Device.

---

## 7. Gỡ lỗi nâng cao

- Build chi tiết:
  ```bash
  cd android
  gradlew.bat assembleDebug --info
  ```
- Clean cache:
  ```bash
  cd android
  gradlew clean
  cd ..
  npx react-native start --reset-cache
  ```

---

## 8. Thông tin tham khảo

- [React Native CLI Environment Setup](https://reactnative.dev/docs/environment-setup)
- [NDK Downloads](https://developer.android.com/ndk/downloads)
- [Gradle Build Docs](https://docs.gradle.org)
