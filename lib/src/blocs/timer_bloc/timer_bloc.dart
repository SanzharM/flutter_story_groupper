import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:story_groupper/src/ticker/ticker.dart' as internal;

part 'timer_event.dart';
part 'timer_state.dart';

class TimerBloc extends Bloc<TimerEvent, TimerState> {
  void start() => add(TimerStartEvent());
  void _tick() => add(TimerTickEvent());
  void pause() => add(TimerPauseEvent());
  void resume() => add(TimerResumeEvent());
  void restart() => start();

  TimerBloc(
    this._ticker, {
    this.duration = const Duration(minutes: 1),
  }) : super(TimerState(
          endTime: DateTime.now().add(duration),
          durationLeft: duration,
        )) {
    on<TimerStartEvent>(_start);
    on<TimerTickEvent>(_tickEvent);
    on<TimerPauseEvent>(_pause);
    on<TimerResumeEvent>(_resume);
  }

  final internal.Ticker _ticker;
  final Duration duration;
  StreamSubscription<int>? _tickerSubscription;

  bool? get isPaused => _tickerSubscription?.isPaused;

  @override
  Future<void> close() {
    _tickerSubscription?.cancel();
    return super.close();
  }

  void _start(
    TimerStartEvent event,
    Emitter<TimerState> emit,
  ) async {
    emit(TimerState(
      endTime: DateTime.now().add(duration),
      durationLeft: duration,
    ));

    _tickerSubscription?.cancel();
    _tickerSubscription =
        _ticker.tick(ticks: duration.inMilliseconds).listen((_) => _tick());
  }

  void _tickEvent(TimerTickEvent event, Emitter<TimerState> emit) async {
    final DateTime now = DateTime.now();
    final Duration duration = state.endTime.difference(now);

    if (duration.isNegative) {
      _tickerSubscription?.cancel();
    }

    emit(state.copyWith(
      durationLeft: duration,
    ));
  }

  void _pause(
    TimerPauseEvent event,
    Emitter<TimerState> emit,
  ) async {
    emit(state.copyWith(pausedAt: DateTime.now()));
    _tickerSubscription?.pause();
  }

  void _resume(
    TimerResumeEvent event,
    Emitter<TimerState> emit,
  ) async {
    if (state.pausedAt != null) {
      final Duration pauseDuration = DateTime.now().difference(state.pausedAt!);
      emit(state.copyWith(
        endTime: state.endTime.add(pauseDuration),
      ));
    }

    _tickerSubscription?.resume();
  }
}
