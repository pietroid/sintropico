import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/particles.dart';

class Star extends AcceleratedParticle {
  Star({
    required Vector2 initialPosition,
    required double travelSpeed,
    required double distanceFromCamera,
    required double starSize,
    required this.cameraSize,
    required Color color,
  }) : super(
          position: initialPosition,
          acceleration: Vector2.zero(),
          speed:

              /// speed is inversely proportional to the distance from the center
              /// so that stars further away move faster, creating a parallax effect
              /// and a sense of depth.
              (initialPosition - cameraSize / 2) *
                  travelSpeed /
                  ((cameraSize.length / 2) * (1 + distanceFromCamera / 100)),
          child: StarParticle(
            paint: Paint()..color = color,
            finalRadius: starSize,
          ),
          lifespan: double.infinity,
        );

  final Vector2 cameraSize;

  @override
  void update(double dt) {
    if (position.x > cameraSize.x ||
        position.x < 0 ||
        position.y > cameraSize.y ||
        position.y < 0) {
      setLifespan(0);
    }
    super.update(dt);
  }
}

class StarParticle extends Particle {
  StarParticle({
    required this.paint,
    required this.finalRadius,
    super.lifespan,
  });

  final Paint paint;
  final double finalRadius;
  double radius = 0;

  @override
  void render(Canvas canvas) {
    final glowPaint = Paint()
      ..color = paint.color
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, radius * 5);
    final whitePaint = Paint()..color = const Color(0xFFFFFFFF);
    canvas.drawCircle(Offset.zero, radius * 3, glowPaint);
    canvas.drawCircle(Offset.zero, radius, whitePaint);
  }

  void update(double dt) {
    super.update(dt);
    if (radius < finalRadius) radius += (finalRadius - radius) * 2 * dt;
  }
}
