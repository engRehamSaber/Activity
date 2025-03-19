import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'dart:async';

class ActivityTwo extends StatelessWidget {
  const ActivityTwo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GameWidget(game: BallGame(onActivityComplete: () {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text("🎉 تهانينا!"),
                content: const Text("لقد أكملت النشاط الثاني بنجاح!"),
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

class BallGame extends FlameGame {
  final VoidCallback onActivityComplete;
  late TextComponent instructionText;
  late Timer instructionTimer;
  String currentInstruction = "";
  bool assistanceShown = false;
  int successfulAttempts = 0;
  int totalAttempts = 0;
  late Arrow arrow;

  BallGame({required this.onActivityComplete}) {
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

    add(Ball(position: Vector2(200, 400), gameRef: this));

    arrow = Arrow();
    add(arrow);

    generateNewInstruction();
  }

  void generateNewInstruction() {
    currentInstruction = (DateTime.now().second % 2 == 0)
        ? "ضع الكرة في الشبكة اليسرى"
        : "ضع الكرة في الشبكة اليمنى";
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
    sprite = await Sprite.load("assets/imags/goal.png");
  }
}

class Ball extends SpriteComponent with DragCallbacks {
  final BallGame gameRef;

  Ball({required Vector2 position, required this.gameRef})
      : super(size: Vector2(50, 50), position: position);

  @override
  Future<void> onLoad() async {
    sprite = await Sprite.load("assets/imags/ball.jpg");
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
