import 'dart:ui';

import 'package:flame/components.dart';
import 'package:sintropico/game/components/star.dart';
import 'package:sintropico/game/constants.dart';
import 'package:sintropico/game/variables.dart';

class Communication extends Component {
  Communication({
    required this.originStar,
    required this.targetStar,
  });

  final Star originStar;
  final Star targetStar;

  double communicationTimer = 0.0;
  double totalCommunicationDuration = 0.0;
  double get progress => communicationTimer / totalCommunicationDuration;
  late Vector2 currentPosition;
  @override
  Future<void> onLoad() async {
    final length = (targetStar.position - originStar.position).length;

    totalCommunicationDuration =
        length / (intensityLevel * currentCommunicationSpeed);
  }

  @override
  void update(double dt) {
    // Update communication state here.
    communicationTimer += dt;
    if (communicationTimer >= totalCommunicationDuration) {
      // Communication complete
      removeFromParent();
    }

    currentPosition = originStar.position +
        (targetStar.position - originStar.position) * progress;

    super.update(dt);
  }

  void render(Canvas canvas) {
    final start = originStar.position;
    final end = targetStar.position;

    // Calculate the current endpoint based on progress
    final currentEnd = start + (end - start) * progress;

    final opacity = (1.0 - progress).clamp(0.0, 1.0);

    // Create a gradient from start to currentEnd
    final paint = Paint()
      ..shader = Gradient.linear(
        Offset(start.x, start.y),
        Offset(currentEnd.x, currentEnd.y),
        [
          const Color.fromARGB(255, 0, 255, 187).withOpacity(
              opacity * currentOpacityFactor), // Cyan at origin with opacity
          const Color.fromARGB(255, 0, 60, 255).withOpacity(
              opacity * currentOpacityFactor), // White at tip with opacity
        ],
        [0.0, 1.0],
      )
      ..strokeWidth = 1.0
      ..strokeCap = StrokeCap.round;

    // Draw the gradient line
    canvas.drawLine(
      Offset(start.x, start.y),
      Offset(currentEnd.x, currentEnd.y),
      paint,
    );
  }
}
