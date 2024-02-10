import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:trashy_road/game_settings.dart';
import 'package:trashy_road/gen/assets.gen.dart';
import 'package:trashy_road/src/game/game.dart';

/// A barrel.
///
/// Barrels, are obstacles that are placed around the map, they are used to
/// block the player's path.
class Barrel extends Obstacle {
  Barrel._({
    required Vector2 position,
  }) : super(
          position: _snapToGrid(position),
          priority: position.y.floor(),
          size: Vector2(1, 2)..multiply(GameSettings.gridDimensions),
          children: [
            _BarrelSpriteComponent(),
          ],
        );

  /// Derives a [Barrel] from a [TiledObject].
  factory Barrel.fromTiledObject(TiledObject tiledObject) {
    return Barrel._(
      position: Vector2(tiledObject.x, tiledObject.y),
    );
  }
}

class _BarrelSpriteComponent extends SpriteComponent with HasGameReference {
  _BarrelSpriteComponent() : super();

  @override
  FutureOr<void> onLoad() async {
    await super.onLoad();

    sprite = await Sprite.load(Assets.images.barrel.path, images: game.images);
  }
}

Vector2 _snapToGrid(Vector2 vector) {
  return (vector - (vector % GameSettings.gridDimensions))
    ..y -= GameSettings.gridDimensions.y * 2;
}
