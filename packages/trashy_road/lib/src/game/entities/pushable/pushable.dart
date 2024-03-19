import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame_behaviors/flame_behaviors.dart';
import 'package:flutter/material.dart';
import 'package:trashy_road/game_settings.dart';
import 'package:trashy_road/src/game/game.dart';

export 'behaviors/behaviors.dart';

class Pushable extends PositionedEntity with ZIndex {
  // An pushable box.
  //
  // The box takes up 1x1 tile space.
  Pushable.box({required Vector2 position})
      : this._(
          position: position,
          hitbox: RectangleHitbox(
            size: Vector2(1, 1)..toGameSize(),
          ),
          children: [
            RectangleComponent(
              anchor: Anchor.bottomLeft,
              size: Vector2(1, 1)..toGameSize(),
              paint: Paint()..color = Colors.red,
            ),
          ],
        );

  Pushable._({
    required Vector2 super.position,
    required this.hitbox,
    super.children,
  }) : super(
          anchor: Anchor.bottomLeft,
          priority: position.y.floor(),
          behaviors: [
            DroppingBehavior(
              drop: Vector2(0, -50),
              minDuration: 0.15,
            ),
            PushableMovingBehavior(),
            PushableObstacleBehavior(),
          ],
        ) {
    zIndex = position.y.floor();
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    final world = ancestors().whereType<TrashyTownWorld>().first;
    final mapEdges = world.descendants().whereType<MapEdge>().toSet();

    final isInMapEdge = mapEdges
        .any((element) => element.isPointInside(position + hitbox.position));

    if (!isInMapEdge) {
      add(
        PropagatingCollisionBehavior(
          hitbox
            ..isSolid = true
            ..anchor = Anchor.bottomLeft,
        ),
      );
    }
  }

  final RectangleHitbox hitbox;
  @override
  void update(double dt) {
    zIndex = position.y.floor();

    super.update(dt);
  }
}
