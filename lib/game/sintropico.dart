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
import 'package:sintropico/game/variables.dart';
import 'package:sintropico/l10n/l10n.dart';

class Sintropico extends FlameGame {
  Sintropico({
    required this.l10n,
    required this.effectPlayer,
    required this.textStyle,
    required Images images,
    required this.audioProcessor,
    required this.onDrumAmplitudeChanged,
  }) {
    this.images = images;
  }

  final AppLocalizations l10n;

  final AudioPlayer effectPlayer;

  final TextStyle textStyle;

  final AudioProcessor audioProcessor;

  double timeInMillis = 0;

  final Function(double opacity)? onDrumAmplitudeChanged;

  final totalDuration = 171000 * 0.5; //171000; // 2:51 minutes in milliseconds
  @override
  Color backgroundColor() => const Color.fromARGB(255, 0, 0, 0);

  @override
  Future<void> onLoad() async {
    final world = World(
      children: [],
    );

    final starSystem = StarSystem(
      numberOfStars: 10000,
      cameraSize: size,
    );

    await addAll([
      world,
      starSystem,
    ]);

    //camera = CameraComponent(world: world);
    //camera.viewfinder.position = size / 2;
    //camera.viewfinder.zoom = 1;
  }

  @override
  void update(double dt) {
    super.update(dt);
    timeInMillis += dt * 1000;

    // final drumsLevel = audioProcessor.getAmplitude("drums", timeInMillis);
    // intensityLevel = 0.5 * drumsLevel;

    // final bassLevel = audioProcessor.getAmplitude("bass", timeInMillis);
    // onTextOpacityChanged?.call(bassLevel);

    progress = (timeInMillis / totalDuration).clamp(0.0, 1.0);
    final drums = audioProcessor.getAmplitude("drums", timeInMillis);

    if (timeInMillis > totalDuration) {
      onDrumAmplitudeChanged?.call(drums * 2);
    } else {
      onDrumAmplitudeChanged?.call(drums);
    }
  }
}

Random rnd = Random();

Vector2 randomVector2() => (Vector2.random(rnd) - Vector2.random(rnd)) * 200;
