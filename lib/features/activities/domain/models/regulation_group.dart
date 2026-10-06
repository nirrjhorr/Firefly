import 'package:flutter/material.dart';
import 'activity_category.dart';

/// The 6 Core Regulation Groups from the Firefly Activity Architecture
/// (Research Document — State-Based Regulation System v2.0).
enum RegulationGroup {
  all,
  movement,
  respiration,
  grounding,
  flow,
  expression,
  restAndSocial;

  IconData get icon {
    switch (this) {
      case RegulationGroup.all:
        return Icons.grid_view_rounded;
      case RegulationGroup.movement:
        return Icons.directions_run_rounded;
      case RegulationGroup.respiration:
        return Icons.air_rounded;
      case RegulationGroup.grounding:
        return Icons.park_rounded;
      case RegulationGroup.flow:
        return Icons.psychology_rounded;
      case RegulationGroup.expression:
        return Icons.brush_rounded;
      case RegulationGroup.restAndSocial:
        return Icons.nightlight_round;
    }
  }

  String get displayName {
    switch (this) {
      case RegulationGroup.all:
        return 'All Practices';
      case RegulationGroup.movement:
        return 'Movement & Somatic Release';
      case RegulationGroup.respiration:
        return 'Respiration & Autonomic Regulation';
      case RegulationGroup.grounding:
        return 'Grounding, Mindfulness & Nature';
      case RegulationGroup.flow:
        return 'Cognitive Flow & Attention Switching';
      case RegulationGroup.expression:
        return 'Expression, Processing & Reframing';
      case RegulationGroup.restAndSocial:
        return 'Auditory, Restorative & Social';
    }
  }

  String get shortLabel {
    switch (this) {
      case RegulationGroup.all:
        return 'All';
      case RegulationGroup.movement:
        return 'Movement';
      case RegulationGroup.respiration:
        return 'Breathing';
      case RegulationGroup.grounding:
        return 'Grounding';
      case RegulationGroup.flow:
        return 'Focus & Flow';
      case RegulationGroup.expression:
        return 'Expression';
      case RegulationGroup.restAndSocial:
        return 'Rest & Social';
    }
  }

  String get description {
    switch (this) {
      case RegulationGroup.all:
        return 'Complete evidence-based self-regulation catalog across all 6 somatic groups.';
      case RegulationGroup.movement:
        return 'Physical exertion, nervous system discharge, routine micro-actions, and progressive muscle relaxation.';
      case RegulationGroup.respiration:
        return 'Controlled autonomic breathing patterns to rapidly shift heart rate variability and down-regulate arousal.';
      case RegulationGroup.grounding:
        return 'Sensory 5-4-3-2-1 anchors, present-moment mindfulness, and guided outdoor nature micro-observation.';
      case RegulationGroup.flow:
        return 'Cognitive tasks, working memory interrupts, spatial flow puzzles, and meditative labyrinth tracing.';
      case RegulationGroup.expression:
        return 'Encrypted emotional externalization, ACT cognitive defusion, worry dumping, and creative reframing.';
      case RegulationGroup.restAndSocial:
        return 'Restorative soundscapes, multi-track audio mixing, sleep wind-down, and low-barrier connection reach-out.';
    }
  }


  Set<ActivityCategory> get categories {
    switch (this) {
      case RegulationGroup.all:
        return ActivityCategory.values.toSet();
      case RegulationGroup.movement:
        return {
          ActivityCategory.physical,
          ActivityCategory.pmr,
          ActivityCategory.behavioralActivation,
        };
      case RegulationGroup.respiration:
        return {
          ActivityCategory.respiration,
        };
      case RegulationGroup.grounding:
        return {
          ActivityCategory.sensoryGrounding,
          ActivityCategory.mindfulness,
          ActivityCategory.nature,
        };
      case RegulationGroup.flow:
        return {
          ActivityCategory.cognitiveGrounding,
          ActivityCategory.flow,
          ActivityCategory.labyrinth,
        };
      case RegulationGroup.expression:
        return {
          ActivityCategory.emotionalExpression,
          ActivityCategory.cognitiveDefusion,
          ActivityCategory.creative,
          ActivityCategory.selfCompassion,
        };
      case RegulationGroup.restAndSocial:
        return {
          ActivityCategory.audio,
          ActivityCategory.sleep,
          ActivityCategory.social,
        };
    }
  }

  bool matches(ActivityCategory category) {
    if (this == RegulationGroup.all) return true;
    return categories.contains(category);
  }
}
