import 'package:flutter/material.dart';
import 'screen/home_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(GeradorOrcamentosApp());
}

class GeradorOrcamentosApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'App de Orçamentos',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: HomePage(),
    );
  }
}