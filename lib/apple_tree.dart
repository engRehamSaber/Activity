import 'package:array_course/Classes/tree.dart';
import 'package:array_course/ball_to_goal.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'dart:async';

class ActivityOne extends StatelessWidget {
  const ActivityOne({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GameWidget(game: ApplePickingGame(
            onActivityComplete: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const CongratulationsScreen()),
            );
          })),
        ],
      ),
    );
  }
}

class ApplePickingGame extends FlameGame {
  final VoidCallback onActivityComplete;
  late TextComponent instructionText;
  late Timer instructionTimer;
  String currentInstruction = "";
  bool assistanceShown = false;
  int successfulAttempts = 0;
  int totalAttempts = 0;
  late Arrow arrow;

  ApplePickingGame({required this.onActivityComplete}) {
    instructionTimer = Timer(5, onTick: showAssistance, repeat: false);
  }

  @override
  Future<void> onLoad() async {
    add(Tree());
    add(Basket(position: Vector2(50, 500), isLeft: true));
    add(Basket(position: Vector2(300, 500), isLeft: false));

    instructionText = TextComponent(
      text: "",
      position: Vector2(150, 50),
      anchor: Anchor.center,
    );
    add(instructionText);

    arrow = Arrow();
    add(arrow);

    for (int i = 0; i < 10; i++) {
      add(Apple(
          position: Vector2(100 + (i % 5) * 50, 200 + (i ~/ 5) * 50),
          gameRef: this));
    }

    generateNewInstruction();
  }

  void generateNewInstruction() {
    currentInstruction = (DateTime.now().second % 2 == 0)
        ? "ضع التفاحة في السلة اليسرى"
        : "ضع التفاحة في السلة اليمنى";
    instructionText.text = currentInstruction;
    instructionTimer.start();
    assistanceShown = false;

    arrow.hide();
  }

  void showAssistance() {
    if (!assistanceShown) {
      assistanceShown = true;

      if (currentInstruction.contains("اليسرى")) {
        arrow.show(Vector2(100, 450));
      } else {
        arrow.show(Vector2(350, 450));
      }
    }
  }

  void checkAttempt(bool isCorrect) {
    totalAttempts++;
    if (isCorrect) {
      successfulAttempts++;
    }

    if (successfulAttempts / totalAttempts >= 0.8 && totalAttempts >= 10) {
      onActivityComplete();
    } else {
      generateNewInstruction();
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
  final ApplePickingGame gameRef;

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
    bool correctBasket =
        (position.x < 200 && gameRef.currentInstruction.contains("اليسرى")) ||
            (position.x > 200 && gameRef.currentInstruction.contains("اليمنى"));

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

class CongratulationsScreen extends StatelessWidget {
  const CongratulationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("🎉تهانينا! 🎉",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const ActivityTwo()),
                );
              },
              child:
                  const Icon(Icons.arrow_forward, size: 50, color: Colors.blue),
            ),
          ],
        ),
      ),
    );
  }
}
