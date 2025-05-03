import 'package:flutter/material.dart';

class TimerWidget extends StatelessWidget {
  final int timeSpent;

  const TimerWidget({Key? key, required this.timeSpent}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final minutes = timeSpent ~/ 60;
    final seconds = timeSpent % 60;

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'Time Invested',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                fontWeight: FontWeight.bold,
                fontFamily: 'monospace',
              ),
            ),
          ],
        ),
      ),
    );
  }
}