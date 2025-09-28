import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:flame/cache.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:sintropico/audio/audio_processor.dart';
import 'package:sintropico/game/components/angel_heart.dart';
import 'package:sintropico/game/components/circular_power_bar.dart';
import 'package:sintropico/game/components/pulsation.dart';
import 'package:sintropico/game/components/star_system.dart';
import 'package:sintropico/l10n/l10n.dart';

class Sintropico extends FlameGame {
  Sintropico({
    required this.l10n,
    required this.effectPlayer,
    required this.textStyle,
    required Images images,
    required this.audioProcessor,
  }) {
    this.images = images;
  }

  final AppLocalizations l10n;

  final AudioPlayer effectPlayer;

  final TextStyle textStyle;

  final AudioProcessor audioProcessor;

  int totalTimeMillis = 0;

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

    final pulsationDrums = Pulsation(
      position: size / 2 - Vector2(100, 0),
      audioProcessor: audioProcessor,
      track: "drums",
      radius: 70,
      color: const Color.fromARGB(255, 0, 255, 0),
    );

    final pulsationBass = Pulsation(
      position: size / 2 + Vector2(100, 0),
      audioProcessor: audioProcessor,
      track: "bass",
      radius: 50,
      color: const Color.fromARGB(255, 255, 0, 0),
    );

    final pulsationPiano = Pulsation(
      position: size / 2 + Vector2(0, 100),
      audioProcessor: audioProcessor,
      track: "piano",
      radius: 60,
      color: const Color.fromARGB(255, 0, 0, 255),
    );

    final pulsationGuitar = Pulsation(
      position: size / 2 + Vector2(0, -100),
      audioProcessor: audioProcessor,
      track: "guitar",
      radius: 40,
      color: const Color.fromARGB(255, 255, 255, 0),
    );

    final pulsationKeyboards = Pulsation(
      position: size / 2 + Vector2(70, 70),
      audioProcessor: audioProcessor,
      track: "keyboards",
      radius: 30,
      color: const Color.fromARGB(255, 0, 255, 255),
    );

    final pulsationStrings = Pulsation(
      position: size / 2 + Vector2(-70, -70),
      audioProcessor: audioProcessor,
      track: "strings",
      radius: 80,
      color: const Color.fromARGB(255, 255, 0, 255),
    );

    final circularPowerBar = CircularPowerBar(
      audioProcessor: audioProcessor,
      position: size / 2,
    );

    await addAll([
      world,
      camera,
      starSystem, circularPowerBar,
      // pulsationDrums,
      // pulsationBass,
      // pulsationPiano,
      // pulsationGuitar,
      // pulsationKeyboards,
      // pulsationStrings,
      //angelHeart1,x
      //angelHeart2,
      // angelHeart3,
      // angelHeart4
    ]);

    camera.viewfinder.position = size / 2;
    camera.viewfinder.zoom = 1;
  }
}

Random rnd = Random();

Vector2 randomVector2() => (Vector2.random(rnd) - Vector2.random(rnd)) * 200;
