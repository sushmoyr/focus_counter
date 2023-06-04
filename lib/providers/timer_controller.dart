import 'dart:async';
import 'dart:math';

import 'package:focus_counter/providers/alarm_controller.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

enum TimerAction { running, paused, stopped }

class TimerState {
  final int id;
  final Duration remaining;
  final Duration duration;
  final TimerAction action;

  factory TimerState.initial() => TimerState(
        id: Random().nextInt(100000),
        remaining: const Duration(seconds: 0),
        duration: const Duration(seconds: 0),
        action: TimerAction.stopped,
      );

//<editor-fold desc="Data Methods">
  const TimerState({
    required this.id,
    required this.remaining,
    required this.duration,
    required this.action,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TimerState &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          remaining == other.remaining &&
          duration == other.duration &&
          action == other.action);

  @override
  int get hashCode =>
      remaining.hashCode ^ action.hashCode ^ duration.hashCode ^ id.hashCode;

  TimerState copyWith({
    Duration? remaining,
    Duration? duration,
    TimerAction? action,
  }) {
    return TimerState(
      remaining: remaining ?? this.remaining,
      duration: duration ?? this.duration,
      action: action ?? this.action,
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
      remaining: shouldResume ? state.remaining : state.duration,
    );
    ref.read(alarmControllerProvider.notifier).scheduleAlarm(state.remaining);
    timer = Timer.periodic(_kDefaultPeriod, (timer) {
      state = state.copyWith(
        action: TimerAction.running,
        remaining: state.remaining - _kDefaultPeriod,
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
    state = TimerState.initial();
  }

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
