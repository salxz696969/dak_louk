import 'package:flutter/material.dart';
import 'package:dak_louk/ui/widgets/base_scaffold.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color.fromARGB(255, 250, 255, 246),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 99, 175, 76),
          primary: const Color.fromARGB(255, 34, 99, 51),
          secondary: const Color.fromARGB(255, 56, 141, 32),
          
        ),
        useMaterial3: true,
      ),
      home: const BaseScaffold(),
    );
  }
}
