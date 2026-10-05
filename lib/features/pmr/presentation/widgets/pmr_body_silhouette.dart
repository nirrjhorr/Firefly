import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/models/pmr_zone.dart';

/// Interactive clinical anatomical body silhouette for PMR.
/// Renders an understated, low-stimulation human figure with glowing target zone highlights.
class PmrBodySilhouette extends StatelessWidget {
  final PmrMuscleZone activeZone;
  final PmrPhase phase;
  final double phaseProgress;
  final ValueChanged<PmrMuscleZone>? onZoneTap;
  final double height;

  const PmrBodySilhouette({
    super.key,
    required this.activeZone,
    required this.phase,
    required this.phaseProgress,
    this.onZoneTap,
    this.height = 360,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    // Determine highlight color based on active clinical phase
    final Color highlightColor;
    switch (phase) {
      case PmrPhase.tense:
      case PmrPhase.hold:
        // Contraction: Warm Amber / Gold glow
        highlightColor = const Color(0xFFE5A93C);
        break;
      case PmrPhase.release:
      case PmrPhase.notice:
        // Relaxation: Soothing Sage
        highlightColor = colors.actionSage;
        break;
    }

    return SizedBox(
      height: height,
      width: height * 0.55,
      child: CustomPaint(
        painter: _PmrSilhouettePainter(
          activeZone: activeZone,
          highlightColor: highlightColor,
          phaseProgress: phaseProgress,
          phase: phase,
          baseColor: colors.bgSurfaceElevated,
          outlineColor: colors.borderSubtle,
        ),
      ),
    );
  }
}

class _PmrSilhouettePainter extends CustomPainter {
  final PmrMuscleZone activeZone;
  final Color highlightColor;
  final double phaseProgress;
  final PmrPhase phase;
  final Color baseColor;
  final Color outlineColor;

  _PmrSilhouettePainter({
    required this.activeZone,
    required this.highlightColor,
    required this.phaseProgress,
    required this.phase,
    required this.baseColor,
    required this.outlineColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cx = w / 2;

    final basePaint = Paint()
      ..color = baseColor
      ..style = PaintingStyle.fill;

    final outlinePaint = Paint()
      ..color = outlineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    // 1. Draw Head & Face
    final headRect = Rect.fromCenter(
      center: Offset(cx, h * 0.13),
      width: w * 0.28,
      height: h * 0.16,
    );
    final headRRect = RRect.fromRectAndRadius(headRect, Radius.circular(w * 0.14));
    canvas.drawRRect(headRRect, basePaint);
    canvas.drawRRect(headRRect, outlinePaint);

    // 2. Neck
    final neckRect = Rect.fromLTWH(cx - w * 0.08, h * 0.21, w * 0.16, h * 0.05);
    canvas.drawRect(neckRect, basePaint);
    canvas.drawRect(neckRect, outlinePaint);

    // 3. Torso (Chest & Stomach)
    final torsoPath = Path()
      ..moveTo(cx - w * 0.30, h * 0.26) // Left shoulder
      ..lineTo(cx + w * 0.30, h * 0.26) // Right shoulder
      ..lineTo(cx + w * 0.24, h * 0.54) // Right hip
      ..lineTo(cx - w * 0.24, h * 0.54) // Left hip
      ..close();
    canvas.drawPath(torsoPath, basePaint);
    canvas.drawPath(torsoPath, outlinePaint);

    // 4. Left Arm & Hand
    final leftArmPath = Path()
      ..moveTo(cx - w * 0.30, h * 0.26)
      ..lineTo(cx - w * 0.42, h * 0.44) // Elbow
      ..lineTo(cx - w * 0.44, h * 0.54) // Wrist
      ..lineTo(cx - w * 0.41, h * 0.57) // Hand
      ..lineTo(cx - w * 0.36, h * 0.54)
      ..lineTo(cx - w * 0.35, h * 0.44)
      ..lineTo(cx - w * 0.26, h * 0.28)
      ..close();
    canvas.drawPath(leftArmPath, basePaint);
    canvas.drawPath(leftArmPath, outlinePaint);

    // 5. Right Arm & Hand
    final rightArmPath = Path()
      ..moveTo(cx + w * 0.30, h * 0.26)
      ..lineTo(cx + w * 0.42, h * 0.44) // Elbow
      ..lineTo(cx + w * 0.44, h * 0.54) // Wrist
      ..lineTo(cx + w * 0.41, h * 0.57) // Hand
      ..lineTo(cx + w * 0.36, h * 0.54)
      ..lineTo(cx + w * 0.35, h * 0.44)
      ..lineTo(cx + w * 0.26, h * 0.28)
      ..close();
    canvas.drawPath(rightArmPath, basePaint);
    canvas.drawPath(rightArmPath, outlinePaint);

    // 6. Left Leg & Foot
    final leftLegPath = Path()
      ..moveTo(cx - w * 0.23, h * 0.54)
      ..lineTo(cx - w * 0.20, h * 0.72) // Knee
      ..lineTo(cx - w * 0.18, h * 0.90) // Ankle
      ..lineTo(cx - w * 0.24, h * 0.95) // Foot tip
      ..lineTo(cx - w * 0.11, h * 0.95)
      ..lineTo(cx - w * 0.11, h * 0.90)
      ..lineTo(cx - w * 0.08, h * 0.72)
      ..lineTo(cx - w * 0.04, h * 0.54)
      ..close();
    canvas.drawPath(leftLegPath, basePaint);
    canvas.drawPath(leftLegPath, outlinePaint);

    // 7. Right Leg & Foot
    final rightLegPath = Path()
      ..moveTo(cx + w * 0.23, h * 0.54)
      ..lineTo(cx + w * 0.20, h * 0.72) // Knee
      ..lineTo(cx + w * 0.18, h * 0.90) // Ankle
      ..lineTo(cx + w * 0.24, h * 0.95) // Foot tip
      ..lineTo(cx + w * 0.11, h * 0.95)
      ..lineTo(cx + w * 0.11, h * 0.90)
      ..lineTo(cx + w * 0.08, h * 0.72)
      ..lineTo(cx + w * 0.04, h * 0.54)
      ..close();
    canvas.drawPath(rightLegPath, basePaint);
    canvas.drawPath(rightLegPath, outlinePaint);

    // 8. Paint the Active Zone Highlight Glow
    _paintZoneGlow(canvas, size, cx, w, h);
  }

  void _paintZoneGlow(Canvas canvas, Size size, double cx, double w, double h) {
    // Pulse animation intensity
    final pulse = 0.7 + 0.3 * math.sin(phaseProgress * math.pi * 2);
    final glowPaint = Paint()
      ..color = highlightColor.withOpacity((0.35 * pulse).clamp(0.1, 0.7))
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);

    final lineGlowPaint = Paint()
      ..color = highlightColor.withOpacity(0.9)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    switch (activeZone) {
      case PmrMuscleZone.forehead:
        final r = Rect.fromCenter(
          center: Offset(cx, h * 0.085),
          width: w * 0.22,
          height: h * 0.055,
        );
        canvas.drawOval(r, glowPaint);
        canvas.drawOval(r, lineGlowPaint);
        break;

      case PmrMuscleZone.face:
        final r = Rect.fromCenter(
          center: Offset(cx, h * 0.13),
          width: w * 0.22,
          height: h * 0.06,
        );
        canvas.drawOval(r, glowPaint);
        canvas.drawOval(r, lineGlowPaint);
        break;

      case PmrMuscleZone.jaw:
        final r = Rect.fromCenter(
          center: Offset(cx, h * 0.18),
          width: w * 0.18,
          height: h * 0.05,
        );
        canvas.drawOval(r, glowPaint);
        canvas.drawOval(r, lineGlowPaint);
        break;

      case PmrMuscleZone.neckShoulders:
        final r = Rect.fromCenter(
          center: Offset(cx, h * 0.26),
          width: w * 0.55,
          height: h * 0.08,
        );
        canvas.drawOval(r, glowPaint);
        canvas.drawOval(r, lineGlowPaint);
        break;

      case PmrMuscleZone.handsArms:
        final leftArmGlow = Rect.fromCenter(
          center: Offset(cx - w * 0.38, h * 0.48),
          width: w * 0.16,
          height: h * 0.22,
        );
        final rightArmGlow = Rect.fromCenter(
          center: Offset(cx + w * 0.38, h * 0.48),
          width: w * 0.16,
          height: h * 0.22,
        );
        canvas.drawOval(leftArmGlow, glowPaint);
        canvas.drawOval(leftArmGlow, lineGlowPaint);
        canvas.drawOval(rightArmGlow, glowPaint);
        canvas.drawOval(rightArmGlow, lineGlowPaint);
        break;

      case PmrMuscleZone.chest:
        final r = Rect.fromCenter(
          center: Offset(cx, h * 0.34),
          width: w * 0.42,
          height: h * 0.12,
        );
        canvas.drawOval(r, glowPaint);
        canvas.drawOval(r, lineGlowPaint);
        break;

      case PmrMuscleZone.stomach:
      case PmrMuscleZone.back:
        final r = Rect.fromCenter(
          center: Offset(cx, h * 0.46),
          width: w * 0.38,
          height: h * 0.12,
        );
        canvas.drawOval(r, glowPaint);
        canvas.drawOval(r, lineGlowPaint);
        break;

      case PmrMuscleZone.thighs:
        final leftThigh = Rect.fromCenter(
          center: Offset(cx - w * 0.13, h * 0.63),
          width: w * 0.16,
          height: h * 0.18,
        );
        final rightThigh = Rect.fromCenter(
          center: Offset(cx + w * 0.13, h * 0.63),
          width: w * 0.16,
          height: h * 0.18,
        );
        canvas.drawOval(leftThigh, glowPaint);
        canvas.drawOval(leftThigh, lineGlowPaint);
        canvas.drawOval(rightThigh, glowPaint);
        canvas.drawOval(rightThigh, lineGlowPaint);
        break;

      case PmrMuscleZone.calvesFeet:
        final leftCalf = Rect.fromCenter(
          center: Offset(cx - w * 0.15, h * 0.84),
          width: w * 0.15,
          height: h * 0.22,
        );
        final rightCalf = Rect.fromCenter(
          center: Offset(cx + w * 0.15, h * 0.84),
          width: w * 0.15,
          height: h * 0.22,
        );
        canvas.drawOval(leftCalf, glowPaint);
        canvas.drawOval(leftCalf, lineGlowPaint);
        canvas.drawOval(rightCalf, glowPaint);
        canvas.drawOval(rightCalf, lineGlowPaint);
        break;
    }
  }

  @override
  bool shouldRepaint(covariant _PmrSilhouettePainter oldDelegate) {
    return oldDelegate.activeZone != activeZone ||
        oldDelegate.phase != phase ||
        oldDelegate.phaseProgress != phaseProgress ||
        oldDelegate.highlightColor != highlightColor;
  }
}
