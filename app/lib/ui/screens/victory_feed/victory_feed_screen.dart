import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class VictoryFeedScreen extends ConsumerWidget {
  const VictoryFeedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Victory Feed')),
      body: ListView.builder(
        itemCount: 10,
        itemBuilder: (context, index) => Card(
          child: ListTile(title: Text('Victory $index')),
        ),
      ),
    );
  }
}
