part of 'timer_bloc.dart';

class TimerState extends Equatable {
  const TimerState({
    required this.endTime,
    this.durationLeft = Duration.zero,
    this.pausedAt,
  });

  final DateTime endTime;
  final Duration durationLeft;
  final DateTime? pausedAt;

  Duration durationPassed(Duration duration) {
    final DateTime startTime = endTime.subtract(duration);
    return endTime.subtract(durationLeft).difference(startTime);
  }

  TimerState copyWith({
    DateTime? endTime,
    Duration? durationLeft,
    DateTime? pausedAt,
  }) {
    return TimerState(
      endTime: endTime ?? this.endTime,
      durationLeft: durationLeft ?? this.durationLeft,
      pausedAt: pausedAt,
    );
  }

  bool isFinished() {
    return DateTime.now().isAfter(endTime) || durationLeft.inMilliseconds <= 0;
  }

  @override
  List<Object?> get props => [endTime, durationLeft, pausedAt];
}
