import 'dart:async';
import 'dart:math';

import 'package:focus_counter/providers/alarm_controller.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

enum TimerAction { running, paused, stopped }

class TimerState {
  final int id;
  final Duration elapsed;
  final Duration duration;
  final TimerAction action;
  final List<Duration> history;

  // Duration get remaining => duration - elapsed;

  factory TimerState.initial() => TimerState(
        id: Random().nextInt(100000),
        elapsed: const Duration(seconds: 0),
        duration: const Duration(seconds: 0),
        action: TimerAction.stopped,
      );

//<editor-fold desc="Data Methods">
  const TimerState({
    required this.id,
    required this.elapsed,
    required this.duration,
    required this.action,
    this.history = const [],
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TimerState &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          elapsed == other.elapsed &&
          duration == other.duration &&
          history == other.history &&
          action == other.action);

  @override
  int get hashCode =>
      elapsed.hashCode ^
      action.hashCode ^
      duration.hashCode ^
      history.hashCode ^
      id.hashCode;

  TimerState copyWith({
    Duration? elapsed,
    Duration? duration,
    TimerAction? action,
    List<Duration>? history,
  }) {
    return TimerState(
      elapsed: elapsed ?? this.elapsed,
      duration: duration ?? this.duration,
      action: action ?? this.action,
      history: history ?? this.history,
      id: id,
    );
  }
//</editor-fold>
}

final timerControllerProvider =
    AutoDisposeNotifierProvider<TimerController, TimerState>(
        () => TimerController());

class TimerController extends AutoDisposeNotifier<TimerState> {
  Timer? timer;

  static const _kDefaultPeriod = Duration(seconds: 1);

  @override
  TimerState build() {
    ref.onDispose(dispose);
    return TimerState.initial();
  }

  void restart() {
    stop();
    start();
  }

  String? start() {
    switch (state.action) {
      case TimerAction.running:
        stop();
        break;
      case TimerAction.paused:
      case TimerAction.stopped:
        break;
    }

    if (state.duration == Duration.zero) {
      return "Can't start when duration is zero.";
    }

    bool shouldResume = state.action == TimerAction.paused;
    state = state.copyWith(
      action: TimerAction.running,
      elapsed: shouldResume ? state.elapsed : Duration.zero,
    );
    ref
        .read(alarmControllerProvider.notifier)
        .scheduleAlarm(state.duration - state.elapsed);
    timer = Timer.periodic(_kDefaultPeriod, (timer) {
      state = state.copyWith(
        action: TimerAction.running,
        elapsed: state.elapsed + _kDefaultPeriod,
      );
    });
    return null;
  }

  void pause() {
    state = state.copyWith(action: TimerAction.paused);
    ref.read(alarmControllerProvider.notifier).stopAlarm();
    timer?.cancel();
  }

  void stop() {
    timer?.cancel();
    ref.read(alarmControllerProvider.notifier).stopAlarm();
    timer = null;
    state = state.copyWith(
      action: TimerAction.stopped,
      elapsed: Duration.zero,
      history: [...state.history, state.elapsed],
    );
  }

  void reset() => state = TimerState.initial();

  void updateMinutes(int minutes) {
    final duration = state.duration;
    state = state.copyWith(
      duration: Duration(
        minutes: minutes,
        seconds: duration.inSeconds.remainder(60),
        hours: duration.inHours.remainder(24),
      ),
    );
  }

  void updateSeconds(int seconds) {
    final duration = state.duration;
    state = state.copyWith(
        duration: Duration(
      seconds: seconds,
      minutes: duration.inMinutes.remainder(60),
      hours: duration.inHours.remainder(24),
    ));
  }

  void updateHours(int hours) {
    final duration = state.duration;
    state = state.copyWith(
      duration: Duration(
        hours: hours,
        minutes: duration.inMinutes.remainder(60),
        seconds: duration.inSeconds.remainder(60),
      ),
    );
  }

  void dispose() {
    timer?.cancel();
    timer = null;
  }
}
