part of 'global_state_cubit.dart';

class GlobalStateState extends Equatable {
  const GlobalStateState({required this.drumAmplitude});

  final double drumAmplitude;

  @override
  List<Object> get props => [drumAmplitude];
}
