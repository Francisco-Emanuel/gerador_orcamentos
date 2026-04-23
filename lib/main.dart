import 'package:flutter/material.dart';
import 'screen/main_navigation.dart';

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
        // Configuração visual para a BottomBar
        navigationBarTheme: NavigationBarThemeData(
          indicatorColor: Colors.blue.withOpacity(0.2),
        ),
      ),
      home: MainNavigation(), // Inicia no Wrapper de navegação
    );
  }
}