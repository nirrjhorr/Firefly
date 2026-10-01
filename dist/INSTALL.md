# Firefly v1.0.0 Sideload Installation Guide

## Package Information
- **Package File:** `dist/firefly-v1.0.0-debug.apk`
- **Application ID:** `app.firefly`
- **Version:** `1.0.0+1`
- **Build Hash (SHA-256):** `78ec35d85a697444247f011df30859c88e7f8db7cdf4da6281d8b85fc68acde7`
- **Security Policy:** 100% Offline Zero-Network Enforced

## Sideload via ADB (Recommended)
Connect your physical Android test device via USB with USB Debugging enabled, then execute:

```bash
# Verify device connection
adb devices

# Sideload / install the test package
adb install -r dist/firefly-v1.0.0-debug.apk

# Launch the app directly
adb shell monkey -p app.firefly -c android.intent.category.LAUNCHER 1
```

## Hash Verification
Verify package integrity prior to installation:
```powershell
Get-FileHash -Algorithm SHA256 dist\firefly-v1.0.0-debug.apk
```
