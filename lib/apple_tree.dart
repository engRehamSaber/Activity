import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_vibrate/flutter_vibrate.dart';
import 'dart:async';

class ActivityOne extends StatelessWidget {
  const ActivityOne({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GameWidget(game: AppleGame(onActivityComplete: () {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text("🎉 تهانينا!"),
                content: const Text("لقد أكملت النشاط الأول بنجاح!"),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("حسنًا"),
                  ),
                ],
              ),
            );
          })),
        ],
      ),
    );
  }
}

class AppleGame extends FlameGame {
  final VoidCallback onActivityComplete;
  late TextComponent instructionText;
  late Timer instructionTimer;
  String currentInstruction = "";
  bool assistanceShown = false;
  int successfulAttempts = 0;
  int totalAttempts = 0;
  int currentAttempt = 0;
  bool isRightPhase = true;
  int phaseCount = 0;
  late Arrow arrow;
  final AudioPlayer player = AudioPlayer();

  AppleGame({required this.onActivityComplete}) {
    instructionTimer = Timer(5, onTick: showAssistance, repeat: false);
  }

  @override
  Future<void> onLoad() async {
    add(Basket(position: Vector2(50, 500), isLeft: true));
    add(Basket(position: Vector2(300, 500), isLeft: false));

    instructionText = TextComponent(
      text: "",
      position: Vector2(150, 50),
      anchor: Anchor.center,
    );
    add(instructionText);

    add(Apple(position: Vector2(200, 400), gameRef: this));

    arrow = Arrow();
    add(arrow);

    updateInstruction();
  }

  void updateInstruction() {
    instructionText.text = isRightPhase
        ? "ضع التفاحة في السلة اليمنى"
        : "ضع التفاحة في السلة اليسرى";
    instructionTimer.start();
    assistanceShown = false;
    arrow.hide();
  }

  void showAssistance() {
    if (!assistanceShown) {
      assistanceShown = true;
      if (isRightPhase) {
        arrow.show(Vector2(350, 450));
      } else {
        arrow.show(Vector2(100, 450));
      }
    }
  }

  void checkAttempt(bool isCorrect) {
    totalAttempts++;
    if (isCorrect) {
      successfulAttempts++;
      player.play(AssetSource('assets/sounds/correct.mp3'));
    } else {
      player.play(AssetSource('assets/sounds/wrong.mp3'));
      Vibrate.feedback(FeedbackType.error);
    }

    currentAttempt++;
    if (currentAttempt >= 5) {
      nextPhase();
    }
  }

  void nextPhase() {
    currentAttempt = 0;
    phaseCount++;

    if (phaseCount == 5) {
      isRightPhase = false;
    }

    if (phaseCount >= 10) {
      checkCompletion();
    } else {
      updateInstruction();
    }
  }

  void checkCompletion() {
    if (successfulAttempts / totalAttempts >= 0.8) {
      onActivityComplete();
    }
  }
}

class Basket extends SpriteComponent {
  final bool isLeft;

  Basket({required Vector2 position, required this.isLeft})
      : super(size: Vector2(100, 100), position: position);

  @override
  Future<void> onLoad() async {
    sprite = await Sprite.load("assets/imags/basket.png");
  }
}

class Apple extends SpriteComponent with DragCallbacks {
  final AppleGame gameRef;

  Apple({required Vector2 position, required this.gameRef})
      : super(size: Vector2(50, 50), position: position);

  @override
  Future<void> onLoad() async {
    sprite = await Sprite.load("assets/imags/apple.png");
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    position.add(event.localDelta);
  }

  @override
  void onDragEnd(DragEndEvent event) {
    super.onDragEnd(event);
    bool correctBasket = (position.x < 200 && !gameRef.isRightPhase) ||
        (position.x > 200 && gameRef.isRightPhase);

    gameRef.checkAttempt(correctBasket);
    gameRef.arrow.hide();
  }
}

class Arrow extends SpriteComponent {
  Arrow() : super(size: Vector2(50, 50), position: Vector2(-100, -100));

  @override
  Future<void> onLoad() async {
    sprite = await Sprite.load("assets/imags/arrow.png");
  }

  void show(Vector2 newPosition) {
    position = newPosition;
    opacity = 1.0;
  }

  void hide() {
    position = Vector2(-100, -100);
  }
}
