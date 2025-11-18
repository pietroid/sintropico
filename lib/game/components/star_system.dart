import 'dart:math' as Math;

import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:sintropico/game/components/communication.dart';
import 'package:sintropico/game/components/star.dart';
import 'package:sintropico/game/constants.dart';
import 'package:sintropico/game/variables.dart';

const initialSpeed = 400.0;
const finalSpeed = 200.0;

class StarSystem extends Component {
  StarSystem({
    required this.numberOfStars,
    required this.cameraSize,
  });

  final int numberOfStars;
  final Vector2 cameraSize;

  @override
  Future<void> onLoad() async {
    for (var i = 0; i < numberOfStars; i++) {
      await add(
        ParticleSystemComponent(
          particle: Star(
            color: randomStarColor,
            initialPosition: Vector2(cameraSize.x / 2, cameraSize.y / 2) +
                Vector2(
                  (Math.Random().nextDouble() - 0.5) * cameraSize.x,
                  (Math.Random().nextDouble() - 0.5) * cameraSize.y,
                ),
            travelSpeed: 2000,
            distanceFromCamera: 0,
            starSize: starSizeDistribution(),
            cameraSize: cameraSize,
            globalParams: GlobalParams(
              baseStarSize: 1.0,
            ),
          ),
        ),
      );
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (children.length < numberOfStars) {
      final starsToAdd = numberOfStars - children.length;
      for (var i = 0; i < starsToAdd; i++) {
        add(
          ParticleSystemComponent(
            particle: Star(
              color: randomStarColor,
              initialPosition: Vector2(cameraSize.x / 2, cameraSize.y / 2) +
                  Vector2(
                    (Math.Random().nextDouble() - 0.5) * cameraSize.x,
                    (Math.Random().nextDouble() - 0.5) * cameraSize.y,
                  ),
              travelSpeed:
                  initialSpeed + (finalSpeed - initialSpeed) * progress,
              distanceFromCamera: 0,
              starSize: starSizeDistribution(),
              cameraSize: cameraSize,
              globalParams: GlobalParams(
                baseStarSize: 1.0,
              ),
            ),
          ),
        );
      }
    }
    for (var i = 0; i < currentCommunicationFrequency * intensityLevel; i++) {
      // make stars communicate with each other
      final allStars = children.whereType<ParticleSystemComponent>();
      final allNumberOfStars = allStars.length;

      final baseRandomIndex = Math.Random().nextInt(allNumberOfStars);

      // get a random star
      final baseStar = allStars.elementAt(baseRandomIndex);

      // get a different random star
      final sample = allStars.where((star) =>
          ((baseStar.particle as Star).position -
                  (star.particle as Star).position)
              .length <
          currentMaxCommunicationDistance);

      final targetRandomIndex = Math.Random().nextInt(sample.length);
      final targetStar = sample.elementAt(targetRandomIndex);

      // add communication effect between baseStar and targetStar
      add(
        Communication(
          originStar: baseStar.particle as Star,
          targetStar: targetStar.particle as Star,
        ),
      );
    }
  }
}

Color get randomStarColor {
  final colors = colorDistribution();
  final random = Math.Random();
  return colors[random.nextInt(colors.length)];
}

List<Color> colorDistribution() => [
      Color.fromARGB(255, 255, 108, 49),
      Color(0xFFFFD26A),
      Color.fromARGB(255, 255, 246, 226),
      Color.fromARGB(255, 255, 246, 226),
      Color.fromARGB(255, 45, 104, 255),
    ];

double starSizeDistribution() {
  final random = Math.Random();
  final value = random.nextDouble();
  // Using a cubic distribution to favor smaller stars
  return Math.pow(value, 20).toDouble() * 1.5;
}
