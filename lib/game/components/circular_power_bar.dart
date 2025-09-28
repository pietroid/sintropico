import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:sintropico/audio/audio_processor.dart';

class CircularPowerBar extends Component {
  CircularPowerBar({
    required this.audioProcessor,
    required this.position,
  });

  final AudioProcessor audioProcessor;
  final Vector2 position;

  double timeInMillis = 0.0;

  double bassAmplitude = 0.0;
  double drumsAmplitude = 0.0;
  double guitarAmplitude = 0.0;
  double keyboardsAmplitude = 0.0;
  double pianoAmplitude = 0.0;
  double stringsAmplitude = 0.0;

  @override
  void render(Canvas canvas) {
    final center = Offset(position.x, position.y);
    final radius = 200.0;

    drawArcSegmentWithAmplitude(
        canvas, center, bassAmplitude, Colors.red, 0, 2 * math.pi / 6, radius);
    drawArcSegmentWithAmplitude(canvas, center, drumsAmplitude, Colors.green,
        math.pi / 3, 2 * math.pi / 3, radius);
    drawArcSegmentWithAmplitude(canvas, center, guitarAmplitude, Colors.blue,
        2 * math.pi / 3, math.pi, radius);
    drawArcSegmentWithAmplitude(canvas, center, keyboardsAmplitude,
        Colors.yellow, math.pi, 4 * math.pi / 3, radius);
    drawArcSegmentWithAmplitude(canvas, center, pianoAmplitude, Colors.purple,
        4 * math.pi / 3, 5 * math.pi / 3, radius);
    drawArcSegmentWithAmplitude(canvas, center, stringsAmplitude, Colors.orange,
        5 * math.pi / 3, 2 * math.pi, radius);
  }

  void drawArcSegmentWithAmplitude(
    Canvas canvas,
    Offset center,
    double amplitude,
    Color color,
    double startAngle,
    double finalAngle,
    double radius,
  ) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final arcRadius = (1 - amplitude) * radius;

    final path = Path()
      ..moveTo(center.dx + arcRadius * math.sin(startAngle),
          center.dy + arcRadius * math.cos(startAngle))
      ..lineTo(center.dx + radius * math.sin(startAngle),
          center.dy + radius * math.cos(startAngle))
      ..lineTo(center.dx + radius * math.sin(finalAngle),
          center.dy + radius * math.cos(finalAngle))
      // ..arcTo(Rect.fromCircle(center: center, radius: radius), -startAngle,
      //     -(finalAngle - startAngle), false)
      ..lineTo(center.dx + arcRadius * math.sin(finalAngle),
          center.dy + arcRadius * math.cos(finalAngle))
      // ..arcTo(Rect.fromCircle(center: center, radius: arcRadius), -finalAngle,
      //     finalAngle - startAngle, false)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  void update(double dt) {
    super.update(dt);
    timeInMillis += dt * 1000;

    bassAmplitude = audioProcessor.getAmplitude("bass", timeInMillis);
    drumsAmplitude = audioProcessor.getAmplitude("drums", timeInMillis);
    guitarAmplitude = audioProcessor.getAmplitude("guitar", timeInMillis);
    keyboardsAmplitude = audioProcessor.getAmplitude("keyboards", timeInMillis);
    pianoAmplitude = audioProcessor.getAmplitude("piano", timeInMillis);
    stringsAmplitude = audioProcessor.getAmplitude("strings", timeInMillis);
  }
}
