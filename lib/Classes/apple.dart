import 'package:flame/components.dart';
import 'package:flame/events.dart';

class Apple extends SpriteComponent with DragCallbacks {
  Apple({required Vector2 position}) : super(size: Vector2(40, 40), position: position);

  @override
  Future<void> onLoad() async {
    sprite = await Sprite.load("assets/imags/apple.jpg"); 
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    position.add(event.localDelta);
  }
}
