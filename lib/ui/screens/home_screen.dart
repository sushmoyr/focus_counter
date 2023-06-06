import 'package:flutter/material.dart';
import 'package:focus_counter/ui/screens/record_screen.dart';
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
        title: Text("Focus Counter"),
      ),
      extendBody: true,
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(bottom: 16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            FloatingActionButton(
              onPressed: () {
                switch (state.action) {
                  case TimerAction.running:
                    notifier.pause();
                    break;
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
            if (state.action != TimerAction.stopped) ...[
              FloatingActionButton(
                onPressed: () {
                  notifier.restart();
                },
                elevation: 0,
                disabledElevation: 0,
                focusElevation: 0,
                highlightElevation: 0,
                hoverElevation: 0,
                heroTag: "StopButton",
                child: const Icon(Icons.location_on_outlined, size: 36),
              ),
              const SizedBox(width: 16),
              FloatingActionButton(
                onPressed: () {
                  notifier.stop();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const RecordScreen(),
                    ),
                  ).then((value) => notifier.reset());
                },
                elevation: 0,
                disabledElevation: 0,
                focusElevation: 0,
                highlightElevation: 0,
                hoverElevation: 0,
                heroTag: "StopButton",
                child: const Icon(Icons.stop_outlined, size: 36),
              ),
            ]
          ],
        ),
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
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: ListView.builder(
                  // reverse: true,
                  itemCount: state.history.length,
                  itemBuilder: (_, index) {
                    final no = state.history.length - 1 - index;
                    final item = state.history[no];
                    return ListTile(
                      leading: Text((no + 1).toString()),
                      title: Text(
                        "${item.inHours} hours ${item.inMinutes % 60} minutes ${item.inSeconds % 60} seconds",
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }
}
