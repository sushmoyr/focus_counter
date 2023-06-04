import 'dart:math';

import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:vibration/vibration.dart';

final alarmControllerProvider =
    AutoDisposeNotifierProvider<AlarmController, void>(() => AlarmController());

@pragma("vm:entry-point")
void alarmCallback(int id) {
  print("Alarm fired: $id");
  Vibration.vibrate(
      duration: 10000, pattern: [500, 2000, 500, 2000], repeat: 3);
}

class AlarmController extends AutoDisposeNotifier<void> {
  late int alarmId;
  @override
  void build() {
    alarmId = Random().nextInt(100000);
  }

  void scheduleAlarm(Duration remaining) {
    print("alarm id: $alarmId");
    print("Remaining: $remaining");
    print("Start at: ${DateTime.now().add(remaining)}");
    AndroidAlarmManager.oneShot(
      remaining,
      alarmId,
      alarmCallback,
      // startAt: DateTime.now().add(remaining),
      exact: true,
      alarmClock: true,
    ).then((value) => print("Alarm scheduled: $value"));
  }

  void stopAlarm() {
    AndroidAlarmManager.cancel(alarmId);
    Vibration.cancel();
  }
}
