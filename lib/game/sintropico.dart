import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:flame/cache.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/particles.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:sintropico/game/components/counter_component.dart';
import 'package:sintropico/game/components/star.dart';
import 'package:sintropico/game/components/star_system.dart';
import 'package:sintropico/game/entities/unicorn/unicorn.dart';
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
    await addAll([world, camera, starSystem]);

    camera.viewfinder.position = size / 2;
    camera.viewfinder.zoom = 1;
  }
}

Random rnd = Random();

Vector2 randomVector2() => (Vector2.random(rnd) - Vector2.random(rnd)) * 200;
