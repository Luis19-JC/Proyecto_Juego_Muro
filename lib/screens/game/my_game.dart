import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import '../../components/boiling_oil_component.dart';

enum DifficultyStage { easy, medium, hard }

// =========================
// GOBLIN
// =========================
class GoblinComponent extends RectangleComponent with CollisionCallbacks {
  final MyGame game;
  final Function() onBreach;
  final Function() onKilled;

  int health;
  final int maxHealth;
  double speed;

  GoblinComponent({
    required this.game,
    required this.onBreach,
    required this.onKilled,
    required Vector2 position,
    required this.speed,
    this.maxHealth = 1,
    Paint? paint,
    Vector2? size,
  }) : health = maxHealth,
       super(
         position: position,
         size: size ?? Vector2(30, 30),
         paint: paint ?? (Paint()..color = Colors.red),
       );

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    add(RectangleHitbox());
  }

  @override
  void update(double dt) {
    super.update(dt);
    position.y -= speed * dt;

    final criticalY = game.size.y * 0.40;
    if (position.y <= criticalY) {
      onBreach();
      removeFromParent();
    }
  }

  void hit() {
    health--;
    if (health <= 0) {
      onKilled();
      removeFromParent();
    }
  }
}

// =========================
// MINIBOSS
// =========================
class MiniBossComponent extends GoblinComponent {
  MiniBossComponent({
    required super.game,
    required super.onBreach,
    required super.onKilled,
    required super.position,
    required super.speed,
    super.maxHealth = 25,
  }) : super(paint: Paint()..color = Colors.purple, size: Vector2(45, 45));

  @override
  void hit() {
    super.hit();
    if (health > 0) {
      paint.color = Colors.purple.shade100;
      Future.delayed(const Duration(milliseconds: 120), () {
        paint.color = Colors.purple;
      });
    }
  }
}

// =========================
// GOBLIN SPAWNER
// =========================
class GoblinSpawner extends TimerComponent {
  final MyGame game;
  final Vector2 gameSize;
  final Function() onBreach;
  final Function() onGoblinKilled;
  final Function() onMiniBossKilled;

  DifficultyStage _currentStage = DifficultyStage.easy;

  static const int easyToMediumLimit = 10;
  static const int mediumToHardLimit = 15;
  static const int goblinsBeforeMiniBoss = 40;

  static const Map<DifficultyStage, Map<String, double>> difficultySettings = {
    DifficultyStage.easy: {'spawn': 2.0, 'defender': 1.5, 'speed': 80.0},
    DifficultyStage.medium: {'spawn': 1.5, 'defender': 1.0, 'speed': 100.0},
    DifficultyStage.hard: {'spawn': 1.0, 'defender': 0.5, 'speed': 120.0},
  };

  final Random _rnd = Random();

  // Posiciones X de las cuerdas debajo de los calderos
  late final List<double> ropePositionsX;

  GoblinSpawner({
    required this.game,
    required this.gameSize,
    required this.onBreach,
    required this.onGoblinKilled,
    required this.onMiniBossKilled,
  }) : super(
         period: difficultySettings[DifficultyStage.easy]!['spawn']!,
         autoStart: true,
         repeat: true,
       );

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    // Inicializa el cooldown del defensor
    game.defenderCooldownNotifier.value =
        difficultySettings[_currentStage]!['defender']!;
    // Rellenar posiciones de las cuerdas
    ropePositionsX = game._cauldrons
        .map((c) => c.position.x + c.size.x / 2)
        .toList();
  }

  void registerKill() {
    final totalKills = game._goblinsKilledCount;

    if (game.children.whereType<MiniBossComponent>().isEmpty) {
      if (_currentStage == DifficultyStage.easy &&
          totalKills >= easyToMediumLimit) {
        _changeDifficulty(DifficultyStage.medium);
      } else if (_currentStage == DifficultyStage.medium &&
          totalKills >= easyToMediumLimit + mediumToHardLimit) {
        _changeDifficulty(DifficultyStage.hard);
      }
    }
  }

  void _changeDifficulty(DifficultyStage newStage) {
    if (newStage == _currentStage) return;
    _currentStage = newStage;

    final settings = difficultySettings[newStage]!;
    timer.stop();
    timer.limit = settings['spawn']!;
    timer.start();

    game.defenderCooldownNotifier.value = settings['defender']!;

    game.add(
      TextComponent(
        text: '¡OLEADA ${newStage.toString().split('.').last.toUpperCase()}!',
        position: game.size / 2,
        anchor: Anchor.center,
        priority: 100,
        textRenderer: TextPaint(
          style: const TextStyle(color: Colors.yellow, fontSize: 24),
        ),
      ),
    );
    Future.delayed(const Duration(seconds: 2), () {
      game.children
          .whereType<TextComponent>()
          .lastOrNull
          ?.removeFromParent();
    });
  }

  @override
  void onTick() {
    final totalKills = game._goblinsKilledCount;
    final hasMiniBoss = game.children
        .whereType<MiniBossComponent>()
        .isNotEmpty;

    if (totalKills >= goblinsBeforeMiniBoss &&
        !hasMiniBoss &&
        !game._miniBossKilled) {
      timer.stop();
      game.add(
        MiniBossComponent(
          game: game,
          onBreach: onBreach,
          onKilled: onMiniBossKilled,
          position: Vector2(gameSize.x / 2, gameSize.y),
          speed: 40,
        ),
      );
      return;
    }

    if (hasMiniBoss) return;

    final activeEnemies = game.children.whereType<GoblinComponent>().length;
    if (activeEnemies >= 10) return;

    // Spawn goblin en una de las cuerdas
    final startX = ropePositionsX[_rnd.nextInt(ropePositionsX.length)];
    final speed = difficultySettings[_currentStage]!['speed']!;
    final newGoblin = GoblinComponent(
      game: game,
      onBreach: onBreach,
      onKilled: () => registerKill(),
      position: Vector2(startX - 15, gameSize.y),
      speed: speed,
    );
    game.add(newGoblin);
  }
}

// =========================
// DEFENDER COMPONENT
// =========================
class DefenderComponent extends PositionComponent {
  late RectangleComponent _body;
  late RectangleComponent _cooldownBar;

  final MyGame game;

  DefenderComponent(this.game);

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    final defenderY = game.size.y * 0.45;

    _body = RectangleComponent(
      position: Vector2(game.size.x / 2 - 22, defenderY - 155),
      size: Vector2(45, 45),
      paint: Paint()..color = Colors.blueAccent,
    );
    add(_body);

    _cooldownBar = RectangleComponent(
      position: Vector2(_body.position.x, _body.position.y - 6),
      size: Vector2(45, 4),
      paint: Paint()..color = Colors.red,
    );
    add(_cooldownBar);

    game.defenderCooldownNotifier.addListener(_updateCooldownBar);
  }

  void _updateCooldownBar() {
    final currentStage = game._spawner?._currentStage ?? DifficultyStage.easy;
    final maxCd = GoblinSpawner.difficultySettings[currentStage]!['defender']!;
    final progress = 1 - (game._lastShotTime / maxCd).clamp(0.0, 1.0);
    _cooldownBar.size.x = 45 * progress;
  }

  @override
  void onRemove() {
    super.onRemove();
    game.defenderCooldownNotifier.removeListener(_updateCooldownBar);
  }
}

// =========================
// MYGAME
// =========================
class MyGame extends FlameGame with TapCallbacks, HasCollisionDetection {
  final int level;
  MyGame({this.level = 1});

  // HUD
  final ValueNotifier<int> scoreNotifier = ValueNotifier<int>(0);
  final ValueNotifier<int> breachesNotifier = ValueNotifier<int>(0);
  final ValueNotifier<double> defenderCooldownNotifier = ValueNotifier<double>(
    0.0,
  );
  final ValueNotifier<double> abilityCooldownNotifier = ValueNotifier<double>(
    0.0,
  );

  static const int maxBreaches = 5;

  double _lastShotTime = 0.0;
  double _abilityCooldownTimer = 0.0;
  bool _isGameOver = false;
  int _goblinsKilledCount = 0;
  bool _miniBossKilled = false;

  GoblinSpawner? _spawner;

  // ----- CAULDRONS + ROPES -----
  final List<RectangleComponent> _cauldrons = [];

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Fondo / muro
    add(
      RectangleComponent(
        size: size,
        paint: Paint()..color = const Color(0xFF696969),
      ),
    );

    // Zona crítica
    add(
      RectangleComponent(
        position: Vector2(0, size.y * 0.40),
        size: Vector2(size.x, size.y * 0.05),
        paint: Paint()..color = Colors.red.withAlpha((255 * 0.4).round()),
      ),
    );

    add(DefenderComponent(this));

    // --- Calderos + cuerdas ---
    final caldY = size.y * 0.42;
    final spacing = size.x / 5;
    for (int i = 1; i <= 4; i++) {
      final caldX = spacing * i - 30 / 2;
      final cald = RectangleComponent(
        position: Vector2(caldX, caldY),
        size: Vector2(30, 30),
        paint: Paint()..color = Colors.orange,
      );
      _cauldrons.add(cald);
      add(cald);

      // Dibujo de cuerda (solo visual)
      final rope = RectangleComponent(
        position: Vector2(caldX + 12, caldY + 30),
        size: Vector2(6, size.y * 0.55),
        paint: Paint()..color = Colors.brown,
      );
      add(rope);
    }

    _spawner = GoblinSpawner(
      game: this,
      gameSize: size,
      onBreach: _handleBreach,
      onGoblinKilled: _handleGoblinKilled,
      onMiniBossKilled: _handleMiniBossKilled,
    );
    add(_spawner!);

    overlays.add('Hud');
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (_abilityCooldownTimer > 0) {
      _abilityCooldownTimer = (_abilityCooldownTimer - dt).clamp(
        0,
        double.infinity,
      );
      abilityCooldownNotifier.value = _abilityCooldownTimer;
    }

    if (_isGameOver) return;

    if (_lastShotTime > 0) {
      _lastShotTime -= dt;
      if (_lastShotTime < 0) _lastShotTime = 0;
    }
    defenderCooldownNotifier.value = _lastShotTime;
  }

  @override
  void onTapDown(TapDownEvent event) {
    if (_isGameOver) return;
    if (_lastShotTime > 0) return;

    final tapPosition = event.canvasPosition;
    final tapped = componentsAtPoint(tapPosition);

    for (final c in tapped.whereType<GoblinComponent>()) {
      _handleAttack(c);

      final currentStage = _spawner?._currentStage ?? DifficultyStage.easy;
      _lastShotTime =
          GoblinSpawner.difficultySettings[currentStage]!['defender']!;
      return;
    }
  }

  void _handleAttack(GoblinComponent goblin) {
    goblin.hit();
    scoreNotifier.value += 10;
  }

  void _handleGoblinKilled() {
    _goblinsKilledCount++;
  }

  void _handleMiniBossKilled() {
    _miniBossKilled = true;
    _showVictoryOverlay();
  }

  void activateBoilingOil() {
    if (_abilityCooldownTimer > 0) return;
    add(BoilingOilComponent(game: this, damage: 5));
    _abilityCooldownTimer = 5;
    abilityCooldownNotifier.value = 5;
  }

  void _handleBreach() {
    breachesNotifier.value++;
    if (breachesNotifier.value >= maxBreaches) endGame(false);
  }

  void _showVictoryOverlay() {
    pauseEngine();
    overlays.remove('Hud');
    overlays.add('Victory');
  }

  void pauseSpawning() {
    _spawner?.timer.stop();
  }

  void resumeSpawning() {
    _spawner?.timer.start();
  }

  // Llamadas desde BoilingOilComponent cuando goblin o miniboss mueren por aceite
  void onGoblinKilledByOil() {
    _goblinsKilledCount++;
    scoreNotifier.value += 10;
    // Opcional: chequear victoria
    if (_goblinsKilledCount >= GoblinSpawner.goblinsBeforeMiniBoss &&
        _miniBossKilled) {
      endGame(true);
    }
  }

  void onMiniBossKilledByOil() {
    _miniBossKilled = true;
    onGoblinKilledByOil(); // reanudar spawn si estaba pausado
  }

  void endGame(bool victory) {
    if (_isGameOver) return;
    _isGameOver = true;
    pauseEngine();
    overlays.remove('Hud');
    overlays.add('GameOver');
  }

  static Widget hudBuilder(BuildContext context, MyGame game) {
    return IgnorePointer(
      ignoring: false,
      child: SafeArea(
        child: Stack(
          children: [
            Positioned(
              top: 12,
              left: 12,
              right: 12,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ValueListenableBuilder<int>(
                    valueListenable: game.scoreNotifier,
                    builder: (_, score, __) => Text(
                      'SCORE: $score',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  ValueListenableBuilder<int>(
                    valueListenable: game.breachesNotifier,
                    builder: (_, breaches, __) => Text(
                      'BREACHES: $breaches / ${MyGame.maxBreaches}',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              right: 16,
              bottom: 16,
              child: GestureDetector(
                onTap: game.activateBoilingOil,
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.orangeAccent,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha((255 * 0.3).round()),
                        blurRadius: 6,
                        offset: const Offset(2, 2),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
