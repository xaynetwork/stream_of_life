import 'package:flutter/material.dart';
import 'package:stream_of_life/src/renderer.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Stream Of Life',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const Renderer(),
    );
  }
}
