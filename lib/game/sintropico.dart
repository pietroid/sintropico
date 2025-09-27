import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:flame/cache.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:sintropico/game/components/angel_heart.dart';
import 'package:sintropico/game/components/star_system.dart';
import 'package:sintropico/l10n/l10n.dart';

class Sintropico extends FlameGame {
  Sintropico({
    required this.l10n,
    required this.effectPlayer,
    required this.textStyle,
    required Images images,
  }) {
    this.images = images;
  }

  final AppLocalizations l10n;

  final AudioPlayer effectPlayer;

  final TextStyle textStyle;

  int counter = 0;

  @override
  Color backgroundColor() => const Color.fromARGB(255, 0, 0, 0);

  @override
  Future<void> onLoad() async {
    final world = World(
      children: [],
    );

    final camera = CameraComponent(world: world);
    final starSystem = StarSystem(
      numberOfStars: 10000,
      cameraSize: size,
    );
    final angelHeart1 = AngelHeart(
      position: size / 2,
      size: 40,
      color: const Color.fromARGB(255, 140, 228, 255),
      rotation: HeartRotation(angle: 0.01, axis: Vector3(0.1, 0.1, 0.1)),
      phase: 0,
    );
    final angelHeart2 = AngelHeart(
      position: size / 2,
      size: 40,
      color: const Color.fromARGB(255, 82, 255, 189),
      rotation: HeartRotation(angle: -0.01, axis: Vector3(0.2, 0.2, 0.3)),
      phase: pi,
    );
    final angelHeart3 = AngelHeart(
      position: size / 2,
      size: 40,
      color: const Color.fromARGB(255, 82, 117, 255),
      rotation: HeartRotation(angle: -0.05, axis: Vector3(0.2, -0.3, 0.3)),
    );
    final angelHeart4 = AngelHeart(
      position: size / 2,
      size: 40,
      color: const Color.fromARGB(255, 203, 82, 255),
      rotation: HeartRotation(angle: 0.05, axis: Vector3(0.2, -0.3, 0.3)),
    );
    await addAll([
      world,
      camera,
      starSystem,
      angelHeart1,
      angelHeart2,
      // angelHeart3,
      // angelHeart4
    ]);

    camera.viewfinder.position = size / 2;
    camera.viewfinder.zoom = 1;
  }
}

Random rnd = Random();

Vector2 randomVector2() => (Vector2.random(rnd) - Vector2.random(rnd)) * 200;
