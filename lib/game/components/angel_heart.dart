import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';

class AngelHeart extends Component {
  AngelHeart({
    required this.position,
    required this.size,
    required this.color,
    required this.rotation,
  });

  final Vector2 position;
  double size;
  final Color color;
  final HeartRotation rotation;
  double t = 0.0;

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
      ..rotate(rotation.axis, rotation.angle);

    return cubePairOfVertices.map((pair) {
      final rotatedStart = rotationMatrix.transform3(pair.$1);
      final rotatedEnd = rotationMatrix.transform3(pair.$2);
      return (rotatedStart, rotatedEnd);
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
  }

  void update(double dt) {
    size = 100 + 10 * sin(t * pi / 0.8571);
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
