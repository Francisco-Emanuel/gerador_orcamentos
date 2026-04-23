import 'package:flutter/material.dart';
import 'home_page.dart';
import 'historico_page.dart';
import 'configuracoes_page.dart';

class MainNavigation extends StatefulWidget {
  @override
  _MainNavigationState createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    HomePage(),
    HistoricoPage(),
    ConfiguracoesPage(), // Nova tela
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              'Desenvolvido por Francisco Soares',
              style: TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold),
            ),
          ),
          BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) => setState(() => _currentIndex = index),
            items: [
              BottomNavigationBarItem(icon: Icon(Icons.add_box_outlined), label: 'Novo'),
              BottomNavigationBarItem(icon: Icon(Icons.history), label: 'Histórico'),
              BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Configurações'),
            ],
          ),
        ],
      ),
    );
  }
}