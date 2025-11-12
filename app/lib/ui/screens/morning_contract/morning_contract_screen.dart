import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme.dart';

class MorningContractScreen extends ConsumerStatefulWidget {
  const MorningContractScreen({super.key});

  @override
  ConsumerState<MorningContractScreen> createState() => _MorningContractScreenState();
}

class _MorningContractScreenState extends ConsumerState<MorningContractScreen> {
  final List<TextEditingController> _controllers = [];
  final int _maxGoals = 3;

  @override
  void initState() {
    super.initState();
    _controllers.add(TextEditingController());
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _addGoalField() {
    if (_controllers.length < _maxGoals) {
      setState(() {
        _controllers.add(TextEditingController());
      });
    }
  }

  void _removeGoalField(int index) {
    if (_controllers.length > 1) {
      setState(() {
        _controllers[index].dispose();
        _controllers.removeAt(index);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Morning Contract'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/home'),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                '8:00 AM',
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      color: AppColors.goldenGrain,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Set 1-3 goals for today. Each goal will be auto-evaluated.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 32),
              Expanded(
                child: ListView.builder(
                  itemCount: _controllers.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _controllers[index],
                              decoration: InputDecoration(
                                labelText: 'Goal ${index + 1}',
                                hintText: 'e.g., Morning run',
                              ),
                            ),
                          ),
                          if (_controllers.length > 1)
                            IconButton(
                              icon: const Icon(Icons.remove_circle),
                              onPressed: () => _removeGoalField(index),
                              color: AppColors.sosRed,
                            ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              if (_controllers.length < _maxGoals)
                TextButton.icon(
                  onPressed: _addGoalField,
                  icon: const Icon(Icons.add),
                  label: const Text('Add Another Goal'),
                ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  // TODO: Save goals and call backend for auto-evaluation
                  context.go('/home');
                },
                child: const Text('Commit Goals'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
