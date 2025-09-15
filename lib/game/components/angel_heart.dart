import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flutter/material.dart' hide Matrix4;

class AngelHeart extends Component {
  AngelHeart({
    required this.position,
    required this.size,
    required this.color,
    required this.rotation,
    this.phase = 0,
  });

  final Vector2 position;
  double size;
  final Color color;
  final HeartRotation rotation;
  double t = 0.0;
  double phase;

  final List<(Vector3, Vector3)> cubePairOfVertices = [
    /// Upper face
    (Vector3(-1, -1, -1), Vector3(1, -1, -1)),
    (Vector3(1, -1, -1), Vector3(1, 1, -1)),
    (Vector3(1, 1, -1), Vector3(-1, 1, -1)),
    (Vector3(-1, 1, -1), Vector3(-1, -1, -1)),

    /// Lower face
    (Vector3(-1, -1, 1), Vector3(1, -1, 1)),
    (Vector3(1, -1, 1), Vector3(1, 1, 1)),
    (Vector3(1, 1, 1), Vector3(-1, 1, 1)),
    (Vector3(-1, 1, 1), Vector3(-1, -1, 1)),

    /// Side edges
    (Vector3(-1, -1, -1), Vector3(-1, -1, 1)),
    (Vector3(1, -1, -1), Vector3(1, -1, 1)),
    (Vector3(1, 1, -1), Vector3(1, 1, 1)),
    (Vector3(-1, 1, -1), Vector3(-1, 1, 1)),
  ];

  List<(Vector3, Vector3)> get rotatedCubePairOfVertices {
    final rotationMatrix = Matrix4.identity()
      ..rotate(rotation.axis, sin(rotation.angle * t * pi) / 100);

    return cubePairOfVertices.map((pair) {
      final rotatedStart = rotationMatrix.transform3(pair.$1);
      final rotatedEnd = rotationMatrix.transform3(pair.$2);
      return (rotatedStart, rotatedEnd);
    }).toList();
  }

  List<(Vector3, Vector3)> translatedCubePairOfVertices(Vector3 delta) {
    return rotatedCubePairOfVertices.map((pair) {
      final translatedStart = pair.$1 + delta;
      final translatedEnd = pair.$2 + delta;
      return (translatedStart, translatedEnd);
    }).toList();
  }

  @override
  void render(Canvas canvas) {
    final path = Path();

    final paint = Paint()
      ..strokeWidth = 1.0
      ..color = color
      ..style = PaintingStyle.stroke;

    final glowingPaint = Paint()
      ..strokeWidth = 4.0
      ..color = color.withOpacity(0.8)
      ..style = PaintingStyle.stroke
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);

    for (final (startVertex, endVertex) in rotatedCubePairOfVertices) {
      final startX = position.x + startVertex.x * size;
      final startY = position.y + startVertex.y * size;
      final endX = position.x + endVertex.x * size;
      final endY = position.y + endVertex.y * size;

      path
        ..moveTo(startX, startY)
        ..lineTo(endX, endY);
      canvas.drawPath(path, paint);
      canvas.drawPath(path, glowingPaint);
      path.reset();
    }

    /// Draw the translated cube for the shadow effect

    final shadowDelta = Vector3(sin(8 * t * pi / 0.8571) * 0.2,
        sin(5 * t * pi / 0.8571) * 0.1, sin(5 * t * pi / 0.8571) * 0.2);
    for (final (startVertex, endVertex)
        in translatedCubePairOfVertices(shadowDelta)) {
      final startX = position.x + startVertex.x * size;
      final startY = position.y + startVertex.y * size;
      final endX = position.x + endVertex.x * size;
      final endY = position.y + endVertex.y * size;

      path
        ..moveTo(startX, startY)
        ..lineTo(endX, endY);
      canvas.drawPath(
          path, paint..color = color.withOpacity(0.8)); // Shadow effect
      path.reset();
    }
  }

  void update(double dt) {
    size = 100 + 10 * sin(t * pi / 0.8571 + phase);
    t += dt;
  }
}

class HeartRotation {
  HeartRotation({
    required this.angle,
    required this.axis,
  });
  final double angle;
  final Vector3 axis;
}
