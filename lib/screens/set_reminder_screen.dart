import 'package:flutter/material.dart';

class SetReminderScreen extends StatelessWidget {
  const SetReminderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Reminder'),
        ),
      ),
    );
  }
}
