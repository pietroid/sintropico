import 'dart:math' as math;
import 'dart:typed_data';

import 'package:fftea/stft.dart';
import 'package:fftea/util.dart';
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

      processedTracks[entry.key] = getSmoothedSamples(samples).toList();
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

  Float64List getNormalizedSamples(List<double> samples) {
    final maxSample = getMaxSample(samples);
    if (maxSample == 0) {
      return Float64List.fromList(samples);
    }
    final factor = 1.0 / maxSample;
    final output = Float64List.fromList(samples);
    for (int i = 0; i < samples.length; ++i) {
      output[i] *= factor;
    }
    return output;
  }

  Float64List normalizeRmsVolume(List<double> audio, double target) {
    double factor = target / rms(audio);
    final output = Float64List.fromList(audio);
    for (int i = 0; i < audio.length; ++i) {
      output[i] *= factor;
    }
    return output;
  }

  List<double> highPassFilter(List<double> input, double alpha) {
    List<double> output = List.filled(input.length, 0.0);

    for (int i = 1; i < input.length; i++) {
      output[i] = alpha * (output[i - 1] + input[i] - input[i - 1]);
    }

    return output;
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

  double rms(List<double> audio) {
    if (audio.isEmpty) {
      return 0;
    }
    double squareSum = 0;
    for (final x in audio) {
      squareSum += x * x;
    }
    return math.sqrt(squareSum / audio.length);
  }
}
