import 'package:nanobot/chat_screen.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.from(
        colorScheme: ColorScheme.dark(primary: Colors.white),
      ),
      debugShowCheckedModeBanner: false,
      home: ChatScreen(),
    );
  }
}
