import 'package:flame/components.dart';

class Tree extends SpriteComponent {
  Tree() : super(size: Vector2(300, 400), position: Vector2(50, 100));

  @override
  Future<void> onLoad() async {
    sprite = await Sprite.load("assets/imags/tree.jpg"); 
  }
}
