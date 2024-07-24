import 'package:flutter/material.dart';
import 'package:todo_list2/list.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized(); // Add this line

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: ' TODO List',
      theme: ThemeData(
        brightness: Brightness.dark,
        useMaterial3: true,
      ),
      home: List(),
    );
  }
}
