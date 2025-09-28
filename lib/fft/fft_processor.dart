import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:fftea/stft.dart';
import 'package:fftea/util.dart';
import 'package:wav/wav_file.dart';

class FFTProcessor {
  // FFT processing code here

  late final double numberOfSamplesPerSecond;
  final List<Float64List> spectrogram = [];

  Future<void> processFFT(Uri audioFile) async {
    final bytes = await File(audioFile.toFilePath()).readAsBytes();
    final audioData = Wav.read(bytes);
    print('Processing FFT for ${audioFile.toFilePath()}');
    final audio = normalizeRmsVolume(audioData.toMono(), 0.3);

    // Set up the STFT. The chunk size is the number of audio samples in each
    // chunk to be FFT'd. The buckets is the number of frequency buckets to
    // split the resulting FFT into when printing.

    const chunkSize = 4096;
    const buckets = 200;
    STFT(chunkSize, Window.hanning(chunkSize)).run(
      audio,
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
        spectrogram.add(listOfPowers);
      },
      // Stride by half the chunk size, so that the chunks overlap.
      chunkSize ~/ 2,
    );

    numberOfSamplesPerSecond = (spectrogram.length) / (audioData.duration);
  }

  Float64List getCurrentSpectrum(int timeInMillis) {
    final index = (timeInMillis / 1000 * numberOfSamplesPerSecond).floor();
    if (index < 0 || index >= spectrogram.length) {
      return Float64List(0);
    }
    return spectrogram[index];
  }

  double getTotalPowerNormalized(int timeInMillis) {
    final spectrum = getCurrentSpectrum(timeInMillis);
    double totalPower = 0;
    for (final power in spectrum) {
      totalPower += power;
    }
    return totalPower;
  }

  Float64List normalizeRmsVolume(List<double> audio, double target) {
    double factor = target / rms(audio);
    final output = Float64List.fromList(audio);
    for (int i = 0; i < audio.length; ++i) {
      output[i] *= factor;
    }
    return output;
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
