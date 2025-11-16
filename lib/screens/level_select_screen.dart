import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'game/my_game.dart'; // importa tu juego

class LevelSelectScreen extends StatelessWidget {
  const LevelSelectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('EL VIAJE DEL AVENTURERO')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'DEFENSA DEL MURO',
              style: TextStyle(color: Colors.white, fontSize: 36),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                Navigator.of(
                  context,
                ).push(MaterialPageRoute(builder: (_) => const GameScreen()));
              },
              child: const Text('Jugar Nivel 1'),
            ),
          ],
        ),
      ),
    );
  }
}

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late MyGame _game;

  @override
  void initState() {
    super.initState();
    _game = MyGame(level: 1); // puedes pasar level si lo usas
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GameWidget<MyGame>(
        game: _game,
        overlayBuilderMap: {
          'Hud': (context, game) => MyGame.hudBuilder(context, game),
          'GameOver': (context, game) => _gameOverOverlay(context, game),
          'Victory': (context, game) => _victoryOverlay(context, game),
        },
        initialActiveOverlays: const ['Hud'],
      ),
    );
  }

  Widget _victoryOverlay(BuildContext context, MyGame game) {
    return Container(
      color: Colors.black54,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '¡HAS GANADO!',
              style: TextStyle(color: Colors.greenAccent, fontSize: 36),
            ),
            const SizedBox(height: 12),
            Text(
              'SCORE: ${game.scoreNotifier.value}',
              style: const TextStyle(color: Colors.white, fontSize: 20),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Volver al menú'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _gameOverOverlay(BuildContext context, MyGame game) {
    return Container(
      color: Colors.black54,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'GAME OVER',
              style: TextStyle(color: Colors.red, fontSize: 36),
            ),
            const SizedBox(height: 12),
            Text(
              'SCORE: ${game.scoreNotifier.value}',
              style: const TextStyle(color: Colors.white, fontSize: 20),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Volver'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _game.pauseEngine();
    super.dispose();
  }
}
