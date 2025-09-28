import 'dart:math' as math;

import 'package:flutter/services.dart';
import 'package:wav/wav_file.dart';

class AudioProcessor {
  Map<String, List<double>> processedTracks = {};
  late int samplesPerSecond;

  Future<void> processAudioTracks(Map<String, String> audioFilePaths) async {
    for (final entry in audioFilePaths.entries) {
      final filePath = entry.value;

      // Load WAV file from asset and process
      final byteData = await rootBundle.load(filePath);
      final buffer = byteData.buffer;
      final wavBytes = buffer.asUint8List();

      // Parse WAV file (using a package like 'wav' or custom parser)
      final wav = Wav.read(wavBytes);
      final samples = wav.toMono();

      //final normalized = getNormalizedTrack(samples);
      //print(normalized.sublist(0, 10000));
      processedTracks[entry.key] =
          getSmoothedSamples(delinearizeSamples(samples));
      samplesPerSecond = wav.samplesPerSecond;
    }
  }

  double getMaxSample(List<double> samples) {
    return samples.reduce((a, b) => a > b ? a : b);
  }

  double getAmplitude(String track, double timeInMillis) {
    final samples = processedTracks[track] ?? [];

    final sampleIndex = ((timeInMillis / 1000) * samplesPerSecond).toInt();
    return samples[sampleIndex];
  }

  List<double> delinearizeSamples(List<double> samples) {
    //TODO
    return samples;
  }

  List<double> getSmoothedSamples(List<double> samples) {
    final List<double> smoothedSamples = [];
    double signal = 0;

    for (double sample in samples) {
      if (signal < sample) {
        signal = sample;
      }
      signal *= 0.9999;
      smoothedSamples.add(signal);
    }
    return smoothedSamples;
  }
}
