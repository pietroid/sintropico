import 'package:flame/game.dart' hide Route;
import 'package:flame_audio/bgm.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sintropico/game/game.dart';
import 'package:sintropico/l10n/l10n.dart';
import 'package:sintropico/loading/cubit/cubit.dart';

class GamePage extends StatelessWidget {
  const GamePage({super.key});

  static Route<void> route() {
    return MaterialPageRoute<void>(
      builder: (_) => const GamePage(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        return AudioCubit(audioCache: context.read<PreloadCubit>().audio);
      },
      child: const Scaffold(
        body: SafeArea(child: GameView()),
      ),
    );
  }
}

class GameView extends StatefulWidget {
  const GameView({super.key});

  @override
  State<GameView> createState() => _GameViewState();
}

class _GameViewState extends State<GameView> {
  late final Bgm bgm;

  @override
  void initState() {
    super.initState();
    bgm = context.read<AudioCubit>().bgm;
    bgm.play(
      "assets/audio/cosmic_dreams.wav",
    );
  }

  @override
  void dispose() {
    bgm.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme.bodySmall!.copyWith(
          color: Colors.white,
          fontSize: 4,
        );
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pop();
      },
      child: Stack(
        children: [
          Positioned.fill(
            child: GameWidget(
              game: Sintropico(
                l10n: context.l10n,
                effectPlayer: context.read<AudioCubit>().effectPlayer,
                textStyle: textStyle,
                images: context.read<PreloadCubit>().images,
                audioProcessor: context.read<PreloadCubit>().audioProcessor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
