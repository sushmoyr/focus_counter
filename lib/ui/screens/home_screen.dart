import 'package:flutter/material.dart';
import 'package:focus_counter/ui/widgets/timer_widget.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../providers/timer_controller.dart';
import '../widgets/time_selection_widget.dart';

class HomeScreen extends HookConsumerWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(timerControllerProvider);
    final notifier = ref.read(timerControllerProvider.notifier);
    return Scaffold(
      appBar: AppBar(
        title: Text("Focus Counter ${state.remaining.inSeconds}"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Expanded(
              child: AnimatedSwitcher(
                duration: kThemeAnimationDuration,
                child: state.action == TimerAction.stopped
                    ? const TimeSelectionWidget()
                    : const TimerWidget(),
              ),
            ),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FloatingActionButton(
                    onPressed: () {
                      switch (state.action) {
                        case TimerAction.running:
                          notifier.pause();
                        case TimerAction.paused:
                        case TimerAction.stopped:
                          final message = notifier.start();
                          if (message != null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(message),
                              ),
                            );
                          }
                      }
                    },
                    elevation: 0,
                    disabledElevation: 0,
                    focusElevation: 0,
                    highlightElevation: 0,
                    hoverElevation: 0,
                    heroTag: "PlayPauseButton",
                    child: state.action == TimerAction.running
                        ? const Icon(Icons.pause)
                        : const Icon(Icons.play_arrow_outlined, size: 36),
                  ),
                  AnimatedSize(
                    duration: kThemeAnimationDuration,
                    curve: Curves.easeInOut,
                    child: state.action != TimerAction.stopped
                        ? const SizedBox(width: 16)
                        : const SizedBox(width: 0),
                  ),
                  if (state.action != TimerAction.stopped)
                    FloatingActionButton(
                      onPressed: () {
                        notifier.stop();
                      },
                      elevation: 0,
                      disabledElevation: 0,
                      focusElevation: 0,
                      highlightElevation: 0,
                      hoverElevation: 0,
                      heroTag: "StopButton",
                      child: const Icon(Icons.stop_outlined, size: 36),
                    ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
