import 'dart:ui';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame_behaviors/flame_behaviors.dart';
import 'package:tiled/tiled.dart';
import 'package:trashy_road/src/game/game.dart';

/// An untraversable rectangle.
///
/// There are usually four [MapEdge]s in a map, one for each side. They delimit
/// the area where the [Player] can moves around.
///
/// Visually, it adds a semi-transparent black rectangle to the map. Which makes
/// it easier to see the boundaries of the map, since it makes those tiles
/// directly beneath it darker.
///
/// See also:
///
/// * [Untraversable], which marks a component as untraversable.
/// * [PlayerObstacleBehavior], which makes the player unable to traverse
///  through an [Untraversable] component.
class MapEdge extends PositionedEntity with Untraversable {
  MapEdge._({required super.position, required super.size})
      : super(
          anchor: Anchor.topLeft,
        ) {
    addAll([
      PropagatingCollisionBehavior(
        RectangleHitbox(size: size),
      ),
      RectangleComponent(size: size)
        ..setColor(
          const Color.fromARGB(40, 0, 0, 0),
        ),
    ]);
  }

  /// Derives a [MapEdge] from a [TiledObject].
  factory MapEdge.fromTiledObject(TiledObject tiledObject) {
    return MapEdge._(
      position: Vector2(tiledObject.x, tiledObject.y),
      size: Vector2(tiledObject.width, tiledObject.height),
    );
  }
}
