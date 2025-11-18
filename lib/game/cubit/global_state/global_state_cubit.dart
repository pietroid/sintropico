import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'global_state_state.dart';

class GlobalStateCubit extends Cubit<GlobalStateState> {
  GlobalStateCubit() : super(const GlobalStateState(drumAmplitude: 0.0));

  void setDrumAmplitude(double amplitude) {
    final currentAmplitude = state.drumAmplitude;
    if (amplitude > currentAmplitude) {
      emit(GlobalStateState(drumAmplitude: amplitude));
    } else {
      emit(GlobalStateState(drumAmplitude: currentAmplitude * 0.98)); // decay
    }
  }
}
