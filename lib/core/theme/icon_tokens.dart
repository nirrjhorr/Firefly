import 'package:flutter/material.dart';

/// Standardized icon sizes across Firefly.
/// Establishes clear optical hierarchy from tiny badges to hero states.
abstract final class IconSizeTokens {
  /// 14dp - Badges, metadata indicators, chip tags, micro-labels
  static const double xs = 14.0;

  /// 16dp - Auxiliary inline icons, chip icons, compact action triggers
  static const double sm = 16.0;

  /// 18dp - Secondary button icons, input field affixes, dialog actions
  static const double md = 18.0;

  /// 20dp - App bar leading/trailing action buttons, medium buttons
  static const double appAction = 20.0;

  /// 22dp - Bottom navigation bar destinations, primary CTA buttons
  static const double nav = 22.0;

  /// 24dp - Primary standalone action icons, standard card headers
  static const double standard = 24.0;

  /// 26dp - Prominent selector tiles (e.g. mood anchor tiles)
  static const double tile = 26.0;

  /// 32dp - Empty state icons, section feature anchors
  static const double lg = 32.0;

  /// 48dp - Completion milestones, modal hero anchors, biometric guard
  static const double hero = 48.0;

  /// 64dp - Splash, major state empty illustrations
  static const double illustration = 64.0;
}

/// Canonical, semantic icon dictionary for Firefly.
///
/// Principles:
/// - Cohesive visual family: Material Rounded (`*_rounded`) and intentional outline counterparts
/// - Semantically accurate: Icons communicate their specific clinical/emotional action
/// - Calming & non-startling: Gentle curves, zero harsh geometry, no aggressive visual spikes
/// - No emojis as UI icons
/// - Accessible: Every icon is paired with or backed by semantic naming
abstract final class AppIcons {
  // ── Global Navigation ───────────────────────────────────────────────────────
  static const checkIn = Icons.wb_twilight_rounded;
  static const checkInSelected = Icons.wb_twilight;
  static const breathe = Icons.air_rounded;
  static const breatheSelected = Icons.air;
  static const journal = Icons.edit_note_rounded;
  static const journalSelected = Icons.edit_note;
  static const tinySteps = Icons.directions_walk_rounded;
  static const tinyStepsSelected = Icons.directions_walk;
  static const progress = Icons.spa_rounded;
  static const progressSelected = Icons.spa;

  // ── Directional & Navigation Actions ────────────────────────────────────────
  static const back = Icons.arrow_back_ios_new_rounded;
  static const forward = Icons.arrow_forward_ios_rounded;
  static const chevronRight = Icons.chevron_right_rounded;
  static const chevronLeft = Icons.chevron_left_rounded;
  static const chevronDown = Icons.keyboard_arrow_down_rounded;
  static const chevronUp = Icons.keyboard_arrow_up_rounded;
  static const close = Icons.close_rounded;
  static const clear = Icons.clear_rounded;
  static const home = Icons.home_rounded;
  static const homeOutlined = Icons.home_outlined;

  // ── Core Actions ────────────────────────────────────────────────────────────
  static const add = Icons.add_rounded;
  static const edit = Icons.edit_rounded;
  static const editOutlined = Icons.edit_outlined;
  static const delete = Icons.delete_outline_rounded;
  static const purge = Icons.auto_delete_rounded;
  static const refresh = Icons.refresh_rounded;
  static const shuffle = Icons.shuffle_rounded;
  static const search = Icons.search_rounded;
  static const searchOff = Icons.search_off_rounded;
  static const filter = Icons.tune_rounded;
  static const check = Icons.check_rounded;
  static const checkCircle = Icons.check_circle_outline_rounded;
  static const checkCircleFilled = Icons.check_circle_rounded;
  static const undo = Icons.undo_rounded;

  // ── Mood Anchor Icons (Outlined / Rounded Cohesive Set) ─────────────────────
  static const moodHeavy = Icons.nightlight_outlined;
  static const moodLow = Icons.cloud_outlined;
  static const moodHere = Icons.adjust_rounded;
  static const moodLight = Icons.light_mode_outlined;
  static const moodOpen = Icons.wb_sunny_outlined;

  // ── Behavioral Activation & Tiny Steps Categories ──────────────────────────
  static const sensory = Icons.remove_red_eye_outlined;
  static const physical = Icons.accessibility_new_rounded;
  static const environment = Icons.wb_sunny_outlined;
  static const nourishment = Icons.water_drop_outlined;

  // ── Audio & Media ───────────────────────────────────────────────────────────
  static const play = Icons.play_arrow_rounded;
  static const pause = Icons.pause_rounded;
  static const stop = Icons.stop_rounded;
  static const timer = Icons.timer_outlined;
  static const volumeUp = Icons.volume_up_rounded;
  static const volumeDown = Icons.volume_down_rounded;
  static const volumeMute = Icons.volume_off_rounded;
  static const soundWaves = Icons.waves_rounded;
  static const audioFrequency = Icons.graphic_eq_rounded;
  static const singingBowl = Icons.notifications_none_rounded;
  static const natureBirds = Icons.forest_outlined;
  static const waterDrop = Icons.water_drop_outlined;
  static const license = Icons.description_outlined;
  static const scientificEvidence = Icons.science_outlined;

  // ── Safety Plan & Crisis Guardrails ─────────────────────────────────────────
  static const emergencyShield = Icons.shield_outlined;
  static const emergencyAlert = Icons.emergency_rounded;
  static const phone = Icons.call_rounded;
  static const sms = Icons.chat_bubble_outline_rounded;
  static const warningSign = Icons.warning_amber_rounded;
  static const lock = Icons.lock_outline_rounded;
  static const lockOpen = Icons.lock_open_rounded;
  static const contactPerson = Icons.person_outline_rounded;
  static const contactAdd = Icons.person_add_rounded;
  static const professionalMedical = Icons.medical_services_outlined;
  static const safeEnvironment = Icons.health_and_safety_outlined;

  // ── Journaling & Reflections ────────────────────────────────────────────────
  static const dictationMic = Icons.mic_rounded;
  static const dictationMicOff = Icons.mic_off_rounded;
  static const unsentLetter = Icons.mail_outline_rounded;
  static const burnFlame = Icons.local_fire_department_rounded;
  static const burnFlameOutlined = Icons.local_fire_department_outlined;
  static const wordCount = Icons.short_text_rounded;
  static const vaultLock = Icons.shield_outlined;

  // ── System Status & Feedback ────────────────────────────────────────────────
  static const info = Icons.info_outline_rounded;
  static const warning = Icons.warning_amber_rounded;
  static const error = Icons.error_outline_rounded;
  static const success = Icons.check_circle_outline_rounded;
}
