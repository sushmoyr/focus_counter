import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter/material.dart';

import '../../providers/timer_controller.dart';

class TimeSelectionWidget extends HookConsumerWidget {
  const TimeSelectionWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(timerControllerProvider.notifier);
    return LayoutBuilder(builder: (context, constraints) {
      assert(constraints.maxHeight.isFinite,
          "Height is infinite. Height of this widget must be fixed.");

      return SizedBox(
        height: constraints.maxHeight,
        child: Row(
          children: [
            Expanded(
              child: Center(
                child: _ScrollableNumberSelector(
                  max: 24,
                  onSelected: notifier.updateHours,
                ),
              ),
            ),
            Expanded(
              child: Center(
                child: _ScrollableNumberSelector(
                  max: 60,
                  onSelected: notifier.updateMinutes,
                ),
              ),
            ),
            Expanded(
              child: Center(
                child: _ScrollableNumberSelector(
                  max: 60,
                  onSelected: notifier.updateSeconds,
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}

class _ScrollableNumberSelector extends HookWidget {
  const _ScrollableNumberSelector({
    super.key,
    required this.max,
    required this.onSelected,
  });

  final int max;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final selectedIndex = useState(0);
    return Center(
      child: ListWheelScrollView.useDelegate(
        itemExtent: 60,
        onSelectedItemChanged: (index) {
          selectedIndex.value = index;
          onSelected(index);
        },
        squeeze: 0.8,
        perspective: 0.001,
        // physics: ClampingScrollPhysics()..applyTo(PageScrollPhysics()),
        // physics: PageScrollPhysics(parent: ClampingScrollPhysics()),
        childDelegate: ListWheelChildBuilderDelegate(
          builder: (context, index) {
            return Padding(
              padding: const EdgeInsets.all(0),
              child: AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: DefaultTextStyle.of(context).style.copyWith(
                      color: index == selectedIndex.value
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context)
                              .colorScheme
                              .outline
                              .withOpacity(0.8),
                      fontSize: 48,
                    ),
                child: Text(
                  index.toString(),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          },
          childCount: max,
        ),
      ),
    );
  }
}
