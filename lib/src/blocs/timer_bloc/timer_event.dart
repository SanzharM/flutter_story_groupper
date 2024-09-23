part of 'timer_bloc.dart';

sealed class TimerEvent extends Equatable {
  const TimerEvent();

  @override
  List<Object?> get props => [];
}

final class TimerStartEvent extends TimerEvent {}

final class TimerTickEvent extends TimerEvent {}

final class TimerPauseEvent extends TimerEvent {}

final class TimerResumeEvent extends TimerEvent {}

final class TimerRestartEvent extends TimerEvent {}
