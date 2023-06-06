import 'package:flutter/material.dart';
import 'package:focus_counter/providers/timer_controller.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class RecordScreen extends ConsumerWidget {
  const RecordScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(timerControllerProvider).history;
    final totalDuration = history.fold(
        Duration.zero, (previousValue, element) => previousValue + element);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Record'),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          children: [
            Text(
              "Total: ${totalDuration.inHours} hours ${totalDuration.inMinutes % 60} minutes ${totalDuration.inSeconds % 60} seconds",
              style: Theme.of(context).textTheme.titleMedium,
            )
          ],
        ),
      ),
      body: ListView.builder(
        // reverse: true,
        itemCount: history.length,
        itemBuilder: (_, index) {
          final item = history[index];
          return ListTile(
            leading: Text((index + 1).toString()),
            title: Text(
              "${item.inHours} hours ${item.inMinutes % 60} minutes ${item.inSeconds % 60} seconds",
            ),
          );
        },
      ),
    );
  }
}
