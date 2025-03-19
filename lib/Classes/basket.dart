import 'package:flame/components.dart';

class Basket extends SpriteComponent {
  final bool isLeft;

  Basket({required Vector2 position, required this.isLeft})
      : super(size: Vector2(100, 100), position: position);

  @override
  Future<void> onLoad() async {
    sprite = await Sprite.load("assets/imags/basket.jpg"); 
  }
}
