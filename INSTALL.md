# Installing Photo Quest

This guide walks you through setting up Flutter and running **Photo Quest** on your local machine.

---

# System Requirements

## Windows

- Windows 10 or Windows 11 (64-bit)
- Git
- Flutter SDK **3.47.0 or newer**
- Android Studio (latest stable)
- Android SDK
- Android Emulator or physical Android device

## macOS

- macOS (latest supported version)
- Xcode
- CocoaPods
- Flutter SDK
- Android Studio (optional for Android development)

## Linux

- Ubuntu or another supported Linux distribution
- Git
- Flutter SDK
- Android Studio
- Android SDK

---

# 1. Install Git

Download Git:

https://git-scm.com/downloads

Verify the installation:

```bash
git --version
```

---

# 2. Install Flutter

Download the latest stable Flutter SDK:

https://flutter.dev/docs/get-started/install

Choose your operating system.

Extract Flutter somewhere permanent.

### Windows

Recommended:

```
C:\src\flutter
```

or

```
D:\flutter
```

Avoid:

```
C:\Program Files\
```

---

# 3. Add Flutter to PATH

## Windows

1. Search **Environment Variables**
2. Open **Edit the system environment variables**
3. Click **Environment Variables**
4. Edit the **Path** variable
5. Add

```
C:\src\flutter\bin
```

Restart your terminal.

Verify:

```bash
flutter --version
```

---

# 4. Install Android Studio

Download:

https://developer.android.com/studio

During installation, install:

- Android SDK
- Android SDK Platform
- Android Emulator
- Android SDK Command-line Tools

---

# 5. Install Flutter and Dart plugins

Open Android Studio.

Navigate to:

```
Settings
→ Plugins
→ Marketplace
```

Install:

- Flutter
- Dart

Restart Android Studio.

---

# 6. Accept Android Licenses

Run:

```bash
flutter doctor --android-licenses
```

Accept every license.

---

# 7. Verify Flutter

Run:

```bash
flutter doctor
```

A healthy installation should resemble:

```text
[✓] Flutter
[✓] Android toolchain
[✓] Android Studio
[✓] Chrome
[✓] Connected device
```

Resolve any remaining issues before continuing.

---

# 8. Clone the Repository

```bash
git clone https://github.com/Christian0162/photoquest.git

cd photoquest
```

---

# 9. Install Dependencies

```bash
flutter pub get
```

---

# 10. Generate Source Code

Photo Quest uses Drift and Riverpod code generation.

Generate the required files:

```bash
dart run build_runner build --delete-conflicting-outputs
```

Whenever you change:

- Drift tables
- DAOs
- `@riverpod` providers

run the command again.

---

# 11. Launch an Emulator

From Android Studio:

```
Tools
→ Device Manager
→ Create Device
```

Start the emulator.

Alternatively, connect a physical Android device with USB debugging enabled.

---

# 12. Run the Application

```bash
flutter run
```

Flutter will automatically build and launch the application.

---

# 13. Useful Flutter Commands

Get dependencies:

```bash
flutter pub get
```

Upgrade packages:

```bash
flutter pub upgrade
```

Generate code:

```bash
dart run build_runner build --delete-conflicting-outputs
```

Watch for code changes:

```bash
dart run build_runner watch --delete-conflicting-outputs
```

Clean the project:

```bash
flutter clean
```

Reinstall dependencies:

```bash
flutter pub get
```

Run the application:

```bash
flutter run
```

List connected devices:

```bash
flutter devices
```

---

# 14. Verify Code Quality

Before creating a commit or pull request, run:

```bash
dart format lib test

flutter analyze

flutter test
```

These are the same checks executed by the GitHub CI workflow.

---

# Troubleshooting

## Flutter command not found

Ensure Flutter has been added to your system `PATH`.

Restart your terminal after editing environment variables.

---

## Android SDK not found

Open Android Studio.

```
Settings
→ Android SDK
```

Install the latest SDK Platform and SDK Tools.

---

## No devices available

Check connected devices:

```bash
flutter devices
```

If none are listed:

- Start an Android emulator
- Connect a physical device
- Enable USB debugging

---

## Build Runner generated files are outdated

Regenerate them:

```bash
dart run build_runner build --delete-conflicting-outputs
```

---

## Flutter Doctor reports errors

Run:

```bash
flutter doctor
```

Fix every issue marked with an **✗** before continuing.

---

# Project Structure

After setup, your project should resemble:

```text
photoquest/
├── android/
├── assets/
├── docs/
├── ios/
├── lib/
├── test/
├── pubspec.yaml
└── README.md
```

---

# Next Steps

Once everything is working:

- Read the [README.md](../README.md) for project features and architecture.
- Review [CLAUDE.md](../CLAUDE.md) for the complete engineering specification.
- Create a new branch before making changes.
- Run formatting, analysis, and tests before submitting a pull request.

Happy coding! 📸
