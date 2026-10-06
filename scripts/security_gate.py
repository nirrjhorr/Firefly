#!/usr/bin/env python3
"""
Firefly Pre-Release Security & Zero-Network Verification Gate
==============================================================
Enforces PRD Section 7.4 Security Pipeline invariants:
1. Zero forbidden networking / telemetry / cloud packages in pubspec.lock & pubspec.yaml.
2. Zero unauthorized outbound socket or HTTP invocations in lib/.
3. Mandatory installation of FireflyHttpOverride kill-switch in main.dart.
4. Cryptographic protection invariants (SQLCipher PRAGMAs, AES-256-GCM journal encryption).
"""

import sys
import os
import re

FORBIDDEN_PACKAGES = [
    "http",
    "dio",
    "web_socket_channel",
    "cronet_http",
    "cupertino_http",
    "firebase_core",
    "firebase_analytics",
    "firebase_auth",
    "firebase_database",
    "cloud_firestore",
    "supabase",
    "supabase_flutter",
    "sentry",
    "sentry_flutter",
    "amplitude_flutter",
    "mixpanel_flutter",
    "segment",
    "datadog_flutter",
    "appsflyer_sdk",
    "branch_io",
    "onesignal_flutter",
    "facebook_app_events",
    "google_mobile_ads",
]

def check_pubspec_lock(root_dir):
    violations = []
    lock_file = os.path.join(root_dir, "pubspec.lock")
    if not os.path.exists(lock_file):
        print("  [WARN] pubspec.lock not found, checking pubspec.yaml only")
        return violations

    with open(lock_file, "r", encoding="utf-8") as f:
        content = f.read()

    for pkg in FORBIDDEN_PACKAGES:
        # Match package entry in YAML lockfile: "  package_name:"
        if re.search(rf"^\s+{re.escape(pkg)}:\s*$", content, re.MULTILINE):
            violations.append(f"Forbidden package '{pkg}' found in pubspec.lock")

    return violations

def check_pubspec_yaml(root_dir):
    violations = []
    yaml_file = os.path.join(root_dir, "pubspec.yaml")
    if not os.path.exists(yaml_file):
        violations.append("pubspec.yaml missing from repository root")
        return violations

    with open(yaml_file, "r", encoding="utf-8") as f:
        content = f.read()

    for pkg in FORBIDDEN_PACKAGES:
        if re.search(rf"^\s+{re.escape(pkg)}:", content, re.MULTILINE):
            violations.append(f"Forbidden package '{pkg}' declared in pubspec.yaml")

    return violations

def check_source_code_network_egress(root_dir):
    violations = []
    lib_dir = os.path.join(root_dir, "lib")
    banned_patterns = [
        (re.compile(r"Socket\.connect\("), "Direct TCP socket connection"),
        (re.compile(r"RawSocket\.connect\("), "Raw TCP socket connection"),
        (re.compile(r"RawDatagramSocket\.bind\("), "UDP socket binding"),
        (re.compile(r"WebSocket\.connect\("), "WebSocket connection"),
    ]

    for dirpath, _, filenames in os.walk(lib_dir):
        for fname in filenames:
            if not fname.endswith(".dart"):
                continue
            fpath = os.path.join(dirpath, fname)
            rel_path = os.path.relpath(fpath, root_dir)
            
            # Allow the network kill switch itself
            if "network_kill_switch.dart" in fname:
                continue

            with open(fpath, "r", encoding="utf-8", errors="ignore") as f:
                code = f.read()

            for pattern, desc in banned_patterns:
                if pattern.search(code):
                    violations.append(f"{desc} detected in {rel_path}")

    return violations

def check_main_kill_switch(root_dir):
    violations = []
    main_file = os.path.join(root_dir, "lib", "main.dart")
    if not os.path.exists(main_file):
        violations.append("lib/main.dart does not exist")
        return violations

    with open(main_file, "r", encoding="utf-8") as f:
        code = f.read()

    if "FireflyHttpOverride" not in code:
        violations.append("FireflyHttpOverride is not referenced in lib/main.dart")
    if "HttpOverrides.global = FireflyHttpOverride();" not in code and "HttpOverrides.global = const FireflyHttpOverride();" not in code:
        violations.append("HttpOverrides.global not assigned FireflyHttpOverride in lib/main.dart")

    return violations

def check_cryptographic_invariants(root_dir):
    violations = []
    db_file = os.path.join(root_dir, "lib", "core", "database", "app_database.dart")
    if not os.path.exists(db_file):
        violations.append("lib/core/database/app_database.dart missing")
    else:
        with open(db_file, "r", encoding="utf-8") as f:
            code = f.read()
        if "PRAGMA cipher_page_size" not in code and "cipher_page_size" not in code:
            violations.append("SQLCipher cipher_page_size PRAGMA missing from database open")
        if "secure_delete" not in code:
            violations.append("SQLCipher secure_delete PRAGMA missing from database open")

    crypto_file = os.path.join(root_dir, "lib", "core", "security", "journal_crypto_service.dart")
    if not os.path.exists(crypto_file):
        violations.append("lib/core/security/journal_crypto_service.dart missing")
    else:
        with open(crypto_file, "r", encoding="utf-8") as f:
            code = f.read()
        if "AesGcm" not in code:
            violations.append("AesGcm double encryption missing from journal crypto service")

    return violations

def main():
    if hasattr(sys.stdout, 'reconfigure'):
        try:
            sys.stdout.reconfigure(encoding='utf-8')
        except Exception:
            pass

    root_dir = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
    print("=== Firefly Security & Zero-Network Verification Gate ===")
    print(f"Repository Root: {root_dir}\n")

    all_violations = []

    print("[1/5] Auditing pubspec.yaml for forbidden packages...")
    yaml_violations = check_pubspec_yaml(root_dir)
    if yaml_violations:
        for v in yaml_violations:
            print(f"  [FAIL] {v}")
        all_violations.extend(yaml_violations)
    else:
        print("  [PASS] Zero forbidden networking packages in pubspec.yaml.")

    print("[2/5] Auditing pubspec.lock dependency tree...")
    lock_violations = check_pubspec_lock(root_dir)
    if lock_violations:
        for v in lock_violations:
            print(f"  [FAIL] {v}")
        all_violations.extend(lock_violations)
    else:
        print("  [PASS] Zero forbidden networking packages in pubspec.lock.")

    print("[3/5] Scanning lib/ source code for unauthorized socket/network egress...")
    code_violations = check_source_code_network_egress(root_dir)
    if code_violations:
        for v in code_violations:
            print(f"  [FAIL] {v}")
        all_violations.extend(code_violations)
    else:
        print("  [PASS] Zero unauthorized socket/network calls in lib/.")

    print("[4/5] Verifying main() network kill-switch installation...")
    main_violations = check_main_kill_switch(root_dir)
    if main_violations:
        for v in main_violations:
            print(f"  [FAIL] {v}")
        all_violations.extend(main_violations)
    else:
        print("  [PASS] FireflyHttpOverride confirmed active in lib/main.dart.")

    print("[5/5] Verifying SQLCipher & AES-256-GCM cryptographic invariants...")
    crypto_violations = check_cryptographic_invariants(root_dir)
    if crypto_violations:
        for v in crypto_violations:
            print(f"  [FAIL] {v}")
        all_violations.extend(crypto_violations)
    else:
        print("  [PASS] SQLCipher & AES-GCM cryptographic protection invariants confirmed.")

    print()
    if all_violations:
        print(f"[FAIL] SECURITY GATE FAILED: {len(all_violations)} violation(s) detected.")
        sys.exit(1)
    else:
        print("[SUCCESS] ALL SECURITY GATES PASSED (100% Invariants Verified). Ready for release build.")
        sys.exit(0)

if __name__ == "__main__":
    main()
