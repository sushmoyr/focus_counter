import 'dart:async';

import 'package:hooks_riverpod/hooks_riverpod.dart';

enum TimerAction { running, paused, stopped }

class TimerState {
  final Duration remaining;
  final Duration duration;
  final TimerAction action;

  factory TimerState.initial() => const TimerState(
        remaining: Duration(seconds: 0),
        duration: Duration(seconds: 0),
        action: TimerAction.stopped,
      );

//<editor-fold desc="Data Methods">
  const TimerState({
    required this.remaining,
    required this.duration,
    required this.action,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TimerState &&
          runtimeType == other.runtimeType &&
          remaining == other.remaining &&
          duration == other.duration &&
          action == other.action);

  @override
  int get hashCode => remaining.hashCode ^ action.hashCode ^ duration.hashCode;

  TimerState copyWith({
    Duration? remaining,
    Duration? duration,
    TimerAction? action,
  }) {
    return TimerState(
      remaining: remaining ?? this.remaining,
      duration: duration ?? this.duration,
      action: action ?? this.action,
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
    timer?.cancel();
  }

  void stop() {
    timer?.cancel();
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
