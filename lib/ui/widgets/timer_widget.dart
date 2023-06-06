import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../providers/timer_controller.dart';

class TimerWidget extends HookConsumerWidget {
  const TimerWidget({super.key});

  String _getTimeText(Duration duration) {
    final hour = duration.abs().inHours % 24;
    final minute = duration.abs().inMinutes % 60;
    final second = duration.abs().inSeconds % 60;

    return "${hour.toStringAsFixed(0).padLeft(2, "0")}:${minute.toStringAsFixed(0).padLeft(2, "0")}:${second.toStringAsFixed(0).padLeft(2, "0")}";
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(timerControllerProvider);
    final progress = (state.elapsed.inSeconds / state.duration.inSeconds);
    print(progress);

    final Color progressColor = progress > 1
        ? Theme.of(context).colorScheme.error
        : Theme.of(context).colorScheme.primary;
    final animationController =
        useAnimationController(duration: const Duration(seconds: 1));
    animationController.animateTo(progress);
    return LayoutBuilder(
      builder: (context, constraints) {
        double width = 0, height = 0;
        if (!constraints.hasInfiniteWidth) {
          width = constraints.maxWidth;
        }

        if (!constraints.hasInfiniteHeight) {
          height = constraints.maxHeight;
        }

        double dimens = min(width, height);
        if (width == 0 || height == 0) {
          dimens = width != 0 ? width : height;
        }
        // print("dimens: $dimens");

        return AnimatedBuilder(
          animation: animationController,
          builder: (BuildContext context, Widget? child) {
            return CustomPaint(
              painter: TimerPainter(
                progress: animationController,
                progressColor: progressColor,
              ),
              child: child,
            );
          },
          child: SizedBox.square(
            dimension: dimens,
            child: Center(
              child: InkWell(
                onTap: () {
                  showTimePicker(
                      context: context,
                      initialTime: const TimeOfDay(hour: 00, minute: 00));
                },
                child: Text(
                  _getTimeText(state.elapsed),
                  style: Theme.of(context).textTheme.displayLarge,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class TimerPainter extends CustomPainter {
  const TimerPainter({
    required this.progress,
    required this.progressColor,
  }) : super(repaint: progress);

  final Animation<double> progress;
  final Color progressColor;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final paint = Paint()
      ..color = progressColor
      ..strokeWidth = 16
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    Rect rect = Rect.fromCenter(
      center: center,
      width: size.width,
      height: size.height,
    );

    double startAngle = -pi / 2;
    double sweepAngle = 2 * pi * progress.value;
    bool useCenter = false;

    canvas.drawArc(rect, startAngle, sweepAngle, useCenter, paint);
  }

  @override
  bool shouldRepaint(covariant TimerPainter oldDelegate) {
    return oldDelegate.progressColor != progressColor;
  }
}
