import 'package:sintropico/game/constants.dart';

double intensityLevel = 1; // 0 from 1

double progress = 0.0;

double get currentCommunicationSpeed =>
    initialCommunicationSpeed +
    (finalCommunicationSpeed - initialCommunicationSpeed) * progress;
double get currentMaxCommunicationDistance =>
    initialMaxCommunicationDistance +
    (finalMaxCommunicationDistance - initialMaxCommunicationDistance) *
        progress;
int get currentCommunicationFrequency => (initialCommunicationFrequency +
        (finalCommunicationFrequency - initialCommunicationFrequency) *
            progress)
    .toInt();
double get currentOpacityFactor =>
    initialOpacityFactor +
    (finalOpacityFactor - initialOpacityFactor) * progress;
