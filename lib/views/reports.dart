import 'package:flutter/material.dart';
import 'package:aws_amplify_app/amplify.dart';

class ReportsPage extends StatelessWidget {
  const ReportsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reports Page')),
      body: const Center(child: TodoScreen()),
    );
  }
}
