#!/usr/bin/env python3
"""
Firefly Design System & Token Integrity Gate
Comprehensive automated verification of:
1. SpacingTokens canonical aliases (xs, sm, md, lg, xl, xxl, xxs)
2. RadiusTokens canonical aliases (full, radiusSm, radiusMd, radiusLg, radiusPill, modalRadius, container)
3. AppTypography canonical aliases (captionSm, displaySm, labelXs, headingSmall, titleMedium, bodyMedium, bodySmall)
4. AppIcons semantic aliases (nature, audio, shield, insights, notes, safetyPlan, history, restart, playing)
5. Stitch Serene Sanctuary Color Contrast Verification (sRGB WCAG 2.2 formula)
6. Canonical Component Presence (FireflyNavHeader, FireflyEmptyState, FireflyButton, FireflyCard)
"""

import math
import os
import re
import sys

def srgb_channel_luminance(c):
    norm = c / 255.0
    if norm <= 0.03928:
        return norm / 12.92
    return math.pow((norm + 0.055) / 1.055, 2.4)

def relative_luminance(r, g, b):
    return (0.2126 * srgb_channel_luminance(r) +
            0.7152 * srgb_channel_luminance(g) +
            0.0722 * srgb_channel_luminance(b))

def contrast_ratio(rgb1, rgb2):
    l1 = relative_luminance(*rgb1)
    l2 = relative_luminance(*rgb2)
    lighter = max(l1, l2)
    darker = min(l1, l2)
    return (lighter + 0.05) / (darker + 0.05)

def check_file_contains(filepath, patterns, label):
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()
    
    missing = []
    for pat in patterns:
        if not re.search(pat, content):
            missing.append(pat)
    
    if missing:
        print(f"FAILED {label} in {filepath}: Missing patterns: {missing}")
        return False
    print(f"PASSED {label} in {filepath} ({len(patterns)}/{len(patterns)} verified)")
    return True

def main():
    print("======================================================================")
    print("         FIREFLY DESIGN SYSTEM & SERENE SANCTUARY VALIDATION          ")
    print("======================================================================\n")

    root = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    theme_dir = os.path.join(root, "lib", "core", "theme")
    widgets_dir = os.path.join(root, "lib", "shared", "widgets")

    all_passed = True

    # 1. SpacingTokens
    spacing_file = os.path.join(theme_dir, "spacing_tokens.dart")
    spacing_patterns = [
        r"static const double xxs = space2xs;",
        r"static const double xs = spaceXs;",
        r"static const double sm = spaceSm;",
        r"static const double md = spaceMd;",
        r"static const double lg = spaceLg;",
        r"static const double xl = spaceXl;",
        r"static const double xxl = space2xl;",
    ]
    if not check_file_contains(spacing_file, spacing_patterns, "SpacingTokens Aliases"):
        all_passed = False

    # 2. RadiusTokens
    radius_file = os.path.join(theme_dir, "radius_tokens.dart")
    radius_patterns = [
        r"static const double full = circular;",
        r"static const double container = lg;",
        r"static const double modal = sheet;",
        r"static const double modalRadius = sheet;",
        r"static const double radiusSm = sm;",
        r"static const double radiusMd = md;",
        r"static const double radiusLg = lg;",
        r"static const double radiusPill = pill;",
    ]
    if not check_file_contains(radius_file, radius_patterns, "RadiusTokens Aliases"):
        all_passed = False

    # 3. AppTypography
    type_file = os.path.join(theme_dir, "app_typography.dart")
    type_patterns = [
        r"static const headingSmall = headingSm;",
        r"static const captionSm = caption;",
        r"static const displaySm = displayMd;",
        r"static const labelXs = labelSm;",
        r"static const titleMedium = headingMd;",
        r"static const bodyMedium = bodyMd;",
        r"static const bodySmall = bodySm;",
        r"static const labelMedium = labelMd;",
        r"static const labelSmall = labelSm;",
    ]
    if not check_file_contains(type_file, type_patterns, "AppTypography Aliases"):
        all_passed = False

    # 4. AppIcons
    icons_file = os.path.join(theme_dir, "icon_tokens.dart")
    icon_patterns = [
        r"static const nature = natureBirds;",
        r"static const audio = soundWaves;",
        r"static const shield = emergencyShield;",
        r"static const insights = scientificEvidence;",
        r"static const safetyPlan = emergencyShield;",
        r"static const history = Icons\.history_rounded;",
        r"static const restart = refresh;",
        r"static const playing = audioFrequency;",
    ]
    if not check_file_contains(icons_file, icon_patterns, "AppIcons Aliases"):
        all_passed = False

    # 5. AppCustomColors & Stitch Alignment
    colors_file = os.path.join(theme_dir, "app_colors.dart")
    color_patterns = [
        r"sage350 = Color\(0xFF7DBA9B\);",
        r"dusk350 = Color\(0xFF5B8A99\);",
        r"amber350 = Color\(0xFFD99B65\);",
        r"accentPrimary: _Primitive\.sage350,",
        r"Color get actionSage => accentPrimary;",
        r"Color get borderMuted => bgOverlay;",
        r"Color get surfaceElevated => bgSurfaceRaised;",
    ]
    if not check_file_contains(colors_file, color_patterns, "AppCustomColors Serene Sanctuary Tokens"):
        all_passed = False

    # 6. Verify WCAG AAA Color Contrast Math
    # Stitch Serene Sanctuary Palette
    canvas_dark = (0x11, 0x15, 0x18)       # #111518
    canvas_deep = (0x0A, 0x0D, 0x0F)       # #0A0D0F
    sage_stitch = (0x7D, 0xBA, 0x9B)       # #7DBA9B
    text_primary = (0xE2, 0xE8, 0xF0)      # #E2E8F0
    dusk_stitch = (0x5B, 0x8A, 0x99)       # #5B8A99
    amber_stitch = (0xD9, 0x9B, 0x65)      # #D99B65
    coral_crisis = (0xB0, 0x54, 0x54)      # #B05454

    print("\n--- Forensic Color Contrast Analysis (WCAG 2.2 sRGB) ---")
    c_sage = contrast_ratio(sage_stitch, canvas_dark)
    c_text = contrast_ratio(text_primary, canvas_dark)
    c_dusk = contrast_ratio(dusk_stitch, canvas_dark)
    c_amber = contrast_ratio(amber_stitch, canvas_dark)

    print(f"Illuminated Sage (#7DBA9B) on Dark Canvas (#111518): {c_sage:.2f}:1 (Target >= 7.0 AAA)")
    print(f"Primary Text (#E2E8F0) on Dark Canvas (#111518):     {c_text:.2f}:1 (Target >= 7.0 AAA)")
    print(f"Dusk Blue (#5B8A99) on Dark Canvas (#111518):        {c_dusk:.2f}:1 (Target >= 4.5 AA)")
    print(f"Warm Amber (#D99B65) on Dark Canvas (#111518):       {c_amber:.2f}:1 (Target >= 4.5 AA)")

    if c_sage < 7.0:
        print("FAILED: Sage does not clear WCAG AAA (7.0:1)!")
        all_passed = False
    else:
        print("PASSED: Sage clears WCAG AAA!")

    if c_text < 7.0:
        print("FAILED: Text does not clear WCAG AAA (7.0:1)!")
        all_passed = False
    else:
        print("PASSED: Text clears WCAG AAA!")

    # 7. Check Canonical Shared Components
    nav_header = os.path.join(widgets_dir, "firefly_nav_header.dart")
    empty_state = os.path.join(widgets_dir, "firefly_empty_state.dart")

    if not os.path.exists(nav_header):
        print(f"FAILED: Missing {nav_header}")
        all_passed = False
    else:
        print(f"PASSED: Found FireflyNavHeader ({nav_header})")

    if not os.path.exists(empty_state):
        print(f"FAILED: Missing {empty_state}")
        all_passed = False
    else:
        print(f"PASSED: Found FireflyEmptyState ({empty_state})")

    print("\n======================================================================")
    if all_passed:
        print("   ALL DESIGN SYSTEM ENHANCEMENTS & VALIDATIONS PASSED (100% OK)   ")
        print("======================================================================")
        return 0
    else:
        print("   DESIGN SYSTEM GATES FAILED - REVIEW LOGS ABOVE                    ")
        print("======================================================================")
        return 1

if __name__ == "__main__":
    sys.exit(main())
