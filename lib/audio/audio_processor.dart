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
      processedTracks[entry.key] =
          getNormalizedSamples(getSmoothedSamples(getOnlyPeakSpectrum(samples)))
              .toList();
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

  List<double> getOnlyPeakSpectrum(List<double> samples) {
    List<double> peakSpectrum = [];
    const chunkSize = 1024;
    const buckets = 100;

    //final audio = normalizeRmsVolume(samples, 0.3);
    STFT(chunkSize, Window.hanning(chunkSize)).run(
      samples,
      // This callback is called for each FFT'd chunk.
      (Float64x2List chunk) {
        // FFTs of real valued data contain a lot of redundant frequency data that
        // we don't want to see in our spectrogram, so discard it. See
        // [ComplexArray.discardConjugates] for more info. We also don't care
        // about the phase of the frequencies, just the amplitude, so calculate
        // magnitudes.

        final amp = chunk.discardConjugates().magnitudes();
        final listOfPowers = Float64List(buckets);
        for (int bucket = 0; bucket < buckets; ++bucket) {
          // Calculate the bucket endpoints.
          int start = (amp.length * bucket) ~/ buckets;
          int end = (amp.length * (bucket + 1)) ~/ buckets;

          // RMS works in the frequency domain too. This is essentially
          // calculating what the perceived volume would be if we were only
          // listening to this frequency bucket. Technically there are some
          // scaling factors I'm ignoring.
          // https://en.wikipedia.org/wiki/Root_mean_square#In_frequency_domain
          double power = rms(Float64List.sublistView(amp, start, end));
          listOfPowers[bucket] = power;
        }

        /// Process to get only spectrum whose peaks is above a certain threshold
        final maxPower = getMaxSample(listOfPowers);
        final threshold = 0.8 * maxPower;
        double powerSum = 0.0;
        for (int i = 0; i < listOfPowers.length; i++) {
          if (listOfPowers[i] >= threshold) {
            powerSum += listOfPowers[i];
          }
        }

        final averagePower =
            listOfPowers.isNotEmpty ? powerSum / listOfPowers.length : 0.0;

        for (int i = 0; i < chunkSize; i++) {
          peakSpectrum.add(averagePower);
        }
      },
      // Stride by half the chunk size, so that the chunks overlap.
      chunkSize ~/ 2,
    );

    return peakSpectrum;
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

  List<double> getSmoothedSamples(List<double> samples) {
    final List<double> smoothedSamples = [];
    double signal = 0;

    for (double sample in samples) {
      if (signal < sample) {
        signal = sample;
      }
      signal *= 0.999;
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
