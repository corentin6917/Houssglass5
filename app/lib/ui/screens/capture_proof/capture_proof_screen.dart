import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CaptureProofScreen extends ConsumerWidget {
  final String dailyGoalId;
  
  const CaptureProofScreen({super.key, required this.dailyGoalId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Capture Proof')),
      body: Center(child: Text('Proof capture for goal: $dailyGoalId')),
    );
  }
}
