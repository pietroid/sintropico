import 'package:audioplayers/audioplayers.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flame/cache.dart';
import 'package:flutter/widgets.dart';
import 'package:sintropico/fft/fft_processor.dart';

part 'preload_state.dart';

class PreloadCubit extends Cubit<PreloadState> {
  PreloadCubit(
      {required this.images, required this.audio, required this.fftProcessor})
      : super(const PreloadState.initial());

  final Images images;
  final AudioCache audio;
  final FFTProcessor fftProcessor;
  List<Uri> audioFiles = [];

  /// Load items sequentially allows display of what is being loaded
  Future<void> loadSequentially() async {
    final phases = [
      PreloadPhase('audio', () async {
        audioFiles = await audio.loadAll(["assets/audio/cosmic_dreams.wav"]);
      }),
      PreloadPhase(
        'images',
        () => images.loadAll(["assets/images/unicorn_animation.png"]),
      ),
      PreloadPhase(
        'fft',
        () => fftProcessor.processFFT(audioFiles[0]),
      )
    ];

    emit(state.copyWith(totalCount: phases.length));
    for (final phase in phases) {
      emit(state.copyWith(currentLabel: phase.label));
      // Throttle phases to take at least 1/5 seconds
      await Future.wait([
        Future.delayed(Duration.zero, phase.start),
        Future<void>.delayed(const Duration(milliseconds: 200)),
      ]);
      emit(state.copyWith(loadedCount: state.loadedCount + 1));
    }
  }
}

@immutable
class PreloadPhase {
  const PreloadPhase(this.label, this.start);

  final String label;
  final ValueGetter<Future<void>> start;
}
