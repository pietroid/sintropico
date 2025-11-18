import 'package:flame/game.dart' hide Route;
import 'package:flame_audio/bgm.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sintropico/game/cubit/global_state/global_state_cubit.dart';
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
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) {
          return AudioCubit(audioCache: context.read<PreloadCubit>().audio);
        }),
        BlocProvider(create: (context) {
          return GlobalStateCubit();
        }),
      ],
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
              key: const Key('sintropico_game_widget'),
              game: Sintropico(
                l10n: context.l10n,
                effectPlayer: context.read<AudioCubit>().effectPlayer,
                textStyle: textStyle,
                images: context.read<PreloadCubit>().images,
                audioProcessor: context.read<PreloadCubit>().audioProcessor,
                onDrumAmplitudeChanged: (amplitude) {
                  context.read<GlobalStateCubit>().setDrumAmplitude(amplitude);
                },
              ),
            ),
          ),
          Center(
            child: Builder(
              builder: (context) => Opacity(
                opacity: 0.8,
                child: BlocBuilder<GlobalStateCubit, GlobalStateState>(
                  builder: (context, state) => Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'SINTROPICO',
                        style: textStyle.copyWith(
                          fontSize: 120 * (1 + 0.15 * (state.drumAmplitude)),
                          letterSpacing: -10,
                          height: 0.5,
                          shadows: [
                            Shadow(
                              blurRadius: 40,
                              color: Colors.white.withOpacity(
                                  clampDouble(state.drumAmplitude * 0.2, 0, 1) +
                                      0.8),
                              offset: Offset(0, 0),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        'COSMIC  DREAMS',
                        style: textStyle.copyWith(
                          fontSize: 84 * (1 + 0.15 * (state.drumAmplitude)),
                          letterSpacing: -6,
                          shadows: [
                            Shadow(
                              blurRadius: 40,
                              color: Colors.white.withOpacity(
                                  clampDouble(state.drumAmplitude * 0.2, 0, 1) +
                                      0.8),
                              offset: Offset(0, 0),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
