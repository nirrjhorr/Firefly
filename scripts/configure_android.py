#!/usr/bin/env python3
"""
Automated Android configuration helper for Firefly CI.
Configures compileSdk=35, minSdk=23, permissions, FlutterFragmentActivity,
and AGP 8 namespace compatibility for third-party plugins.
"""
import os
import re
import sys
from pathlib import Path

def configure_app_gradle():
    gradle_path = Path("android/app/build.gradle")
    if not gradle_path.exists():
        print(f"Warning: {gradle_path} not found.")
        return

    content = gradle_path.read_text(encoding="utf-8")

    # 1. compileSdk = 35
    if "compileSdk = flutter.compileSdkVersion" in content:
        content = content.replace("compileSdk = flutter.compileSdkVersion", "compileSdk = 35")
    elif "compileSdkVersion flutter.compileSdkVersion" in content:
        content = content.replace("compileSdkVersion flutter.compileSdkVersion", "compileSdkVersion 35")
    elif "compileSdk" in content:
        content = re.sub(r"compileSdk\s*=\s*\d+", "compileSdk = 35", content)
    else:
        content = re.sub(r"(android\s*\{)", r"\1\n    compileSdk = 35", content)

    # 2. minSdk = 23
    if "minSdk = flutter.minSdkVersion" in content:
        content = content.replace("minSdk = flutter.minSdkVersion", "minSdk = 23")
    elif "minSdkVersion flutter.minSdkVersion" in content:
        content = content.replace("minSdkVersion flutter.minSdkVersion", "minSdkVersion 23")
    elif "minSdk" in content:
        content = re.sub(r"minSdk\s*=\s*\d+", "minSdk = 23", content)

    gradle_path.write_text(content, encoding="utf-8")
    print("Configured android/app/build.gradle (compileSdk=35, minSdk=23).")

def configure_root_gradle():
    root_gradle = Path("android/build.gradle")
    if not root_gradle.exists():
        print(f"Warning: {root_gradle} not found.")
        return

    content = root_gradle.read_text(encoding="utf-8")
    snippet = """

subprojects {
    afterEvaluate { project ->
        if (project.hasProperty('android')) {
            project.android {
                if (namespace == null) {
                    if (project.name == 'vosk_flutter') {
                        namespace 'org.vosk.vosk_flutter'
                    } else if (project.group) {
                        namespace project.group
                    } else {
                        namespace "com.example.${project.name}"
                    }
                }
            }
        }
    }
}
"""
    if "subprojects {" not in content:
        content += snippet
        root_gradle.write_text(content, encoding="utf-8")
        print("Configured android/build.gradle with subprojects namespace fallback.")

def configure_manifest():
    manifest_path = Path("android/app/src/main/AndroidManifest.xml")
    if not manifest_path.exists():
        print(f"Warning: {manifest_path} not found.")
        return

    content = manifest_path.read_text(encoding="utf-8")
    perms = """    <uses-permission android:name="android.permission.VIBRATE" />
    <uses-permission android:name="android.permission.RECORD_AUDIO" />
    <uses-permission android:name="android.permission.USE_BIOMETRIC" />\n"""

    if "android.permission.RECORD_AUDIO" not in content:
        content = content.replace("<application", perms + "    <application")
        manifest_path.write_text(content, encoding="utf-8")
        print("Configured android/app/src/main/AndroidManifest.xml with hardware permissions.")

def configure_main_activity():
    android_dir = Path("android/app/src/main")
    for root, _, files in os.walk(android_dir):
        for f in files:
            if f in ("MainActivity.kt", "MainActivity.java"):
                p = Path(root) / f
                content = p.read_text(encoding="utf-8")
                content = content.replace(
                    "import io.flutter.embedding.android.FlutterActivity",
                    "import io.flutter.embedding.android.FlutterFragmentActivity"
                )
                content = content.replace("FlutterActivity", "FlutterFragmentActivity")
                p.write_text(content, encoding="utf-8")
                print(f"Configured {p} to inherit from FlutterFragmentActivity.")

def patch_pub_cache():
    pub_cache = Path(os.path.expanduser("~/.pub-cache"))
    if not pub_cache.exists():
        return

    for root, _, files in os.walk(pub_cache):
        if "vosk_flutter" in root and "build.gradle" in files:
            p = Path(root) / "build.gradle"
            content = p.read_text(encoding="utf-8")
            if "namespace" not in content and "android {" in content:
                content = content.replace("android {", "android {\n    namespace 'org.vosk.vosk_flutter'")
                p.write_text(content, encoding="utf-8")
                print(f"Patched namespace in pub-cache {p}")

def main():
    print("Running Android platform configuration...")
    configure_app_gradle()
    configure_root_gradle()
    configure_manifest()
    configure_main_activity()
    patch_pub_cache()
    print("Android configuration complete.")

if __name__ == "__main__":
    main()
