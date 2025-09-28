import 'dart:ui';

import 'package:flame/components.dart';
import 'package:sintropico/fft/fft_processor.dart';

class Spectre extends Component {
  Spectre({
    required this.position,
    required this.size,
    required this.fftProcessor,
  });

  final Vector2 position;
  final Vector2 size;
  final FFTProcessor fftProcessor;
  int currentTimeMillis = 0;

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final paint = Paint()
      ..color = const Color.fromARGB(255, 255, 255, 255)
      ..style = PaintingStyle.fill;

    if (fftProcessor.spectrogram.isEmpty) {
      return;
    }

    final currentSpectrum = fftProcessor.getCurrentSpectrum(currentTimeMillis);

    final bucketWidth = size.x / currentSpectrum.length;
    final maxHeight = size.y;

    for (int i = 0; i < currentSpectrum.length / 2; i++) {
      final powers = currentSpectrum;
      for (int j = 0; j < powers.length; j++) {
        final power = powers[j];
        final height = (power / 10.0) * maxHeight;
        final rect = Rect.fromLTWH(
          position.x + j * bucketWidth,
          position.y + maxHeight - height,
          bucketWidth - 1,
          height,
        );
        canvas.drawRect(rect, paint);
      }
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    currentTimeMillis += (dt * 1000).toInt();
  }
}
