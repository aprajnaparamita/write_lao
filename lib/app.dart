import 'package:flutter/material.dart';

class WriteItLaoApp extends StatelessWidget {
  const WriteItLaoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Write Lao',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF4A7BCC)),
        useMaterial3: true,
      ),
      home: const Scaffold(
        body: Center(child: Text('Write Lao')),
      ),
    );
  }
}
