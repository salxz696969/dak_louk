import 'package:dak_louk/screens/home_screen.dart';
import 'package:dak_louk/widgets/base_scaffold.dart';
import 'package:flutter/material.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 99, 175, 76),
          primary: const Color.fromARGB(255, 71, 161, 43),
        ),
        useMaterial3: true,
      ),
      home: const BaseScaffold(body: HomeScreen()),
    );
  }
}
