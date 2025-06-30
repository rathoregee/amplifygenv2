import 'package:flutter/material.dart';

class MoreLinksPage extends StatelessWidget {
  final String title;

  const MoreLinksPage({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(child: Text('$title Content')),
    );
  }
}
