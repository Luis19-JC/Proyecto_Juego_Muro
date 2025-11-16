import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _musicEnabled = true;
  bool _soundEffectsEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Ajustes',
          style: TextStyle(color: Colors.white, fontFamily: 'Medieval'), // White text for title
        ),
        backgroundColor: Colors.black, // Black background
        iconTheme: const IconThemeData(
          color: Colors.white,
        ), // White back button
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage(
              'assets/fondos/fondo_sonido.png',
            ), // Use the same background as home
            fit: BoxFit.cover,
          ),
        ),
        child: ListView(
          children: [
            SwitchListTile(
              title: const Text(
                'Música',
                style: TextStyle(color: Colors.white, fontSize: 20, fontFamily: 'Medieval'),
              ),
              value: _musicEnabled,
              onChanged: (bool value) {
                setState(() {
                  _musicEnabled = value;
                  // TODO: Implement actual music toggle logic
                });
              },
              activeThumbColor: Colors.brown,
            ),
            SwitchListTile(
              title: const Text(
                'Efectos de Sonido',
                style: TextStyle(color: Colors.white, fontSize: 20, fontFamily: 'Medieval'),
              ),
              value: _soundEffectsEnabled,
              onChanged: (bool value) {
                setState(() {
                  _soundEffectsEnabled = value;
                  // TODO: Implement actual sound effects toggle logic
                });
              },
              activeThumbColor: Colors.brown,
            ),
          ],
        ),
      ),
    );
  }
}
