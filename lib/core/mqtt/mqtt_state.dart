import 'package:equatable/equatable.dart';

sealed class MqttState extends Equatable {
  final String? errorMessage;
  const MqttState({this.errorMessage});

  @override
  List<Object?> get props => [errorMessage];
}

final class Disconnected extends MqttState {
  const Disconnected({super.errorMessage});

  @override
  List<Object?> get props => [super.errorMessage];
}

final class Disconnecting extends MqttState {
  @override
  List<Object?> get props => [];
}

final class Connected extends MqttState {
  const Connected({super.errorMessage});

  @override
  List<Object?> get props => [super.errorMessage];
}

final class Connecting extends MqttState {
  @override
  List<Object?> get props => [];
}
