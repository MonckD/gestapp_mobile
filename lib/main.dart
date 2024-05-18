import 'package:flutter/material.dart';
import 'package:gestapp/screens/form.dart';
import 'package:gestapp/screens/home.dart';
import 'package:gestapp/screens/login.dart';
import 'package:gestapp/screens/problem.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() async{
  await _initHive();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: LoginPage(),
    );
  }
}

Future<void> _initHive() async {
  await Hive.initFlutter();
  await Hive.openBox("user");
  // ouverture d'un boite pour le stockage des informations de l'utilisateur
}
