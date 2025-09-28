import 'dart:ui';

import 'package:flame/components.dart';
import 'package:sintropico/audio/audio_processor.dart';

class Pulsation extends Component {
  Pulsation({
    required this.position,
    required this.audioProcessor,
    required this.track,
    required this.radius,
    required this.color,
  });

  final AudioProcessor audioProcessor;
  final Vector2 position;
  final String track;
  final double radius;
  final Color color;

  double currentAmplitude = 0.0;
  double timeInMillis = 0.0;

  @override
  void render(Canvas canvas) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final finalRadius = radius + currentAmplitude * radius;
    canvas.drawCircle(Offset(position.x, position.y), finalRadius, paint);
  }

  @override
  void update(double dt) {
    super.update(dt);
    timeInMillis += dt * 1000;
    currentAmplitude = audioProcessor.getAmplitude(track, timeInMillis);
  }
}
