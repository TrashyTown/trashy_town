import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame_behaviors/flame_behaviors.dart';
import 'package:trashy_road/game_settings.dart';
import 'package:trashy_road/src/game/game.dart';

class PushableMovingBehavior extends Behavior<Pushable> {
  /// The position the pushable is trying to move to.
  ///
  /// When its values are different than the current [Pushable.position]
  /// it will be lerped until [_targetPosition] is reached by the [Pushable].
  final Vector2 _targetPosition = Vector2.zero();

  final Vector2 _cacheVector = Vector2.zero();

  bool push(Vector2 direction) {
    if (direction.x + direction.y > 1 ||
        (direction.x != 0 && direction.y != 0)) {
      throw ArgumentError.value(
        direction,
        'direction',
        'The direction must be a unit vector.',
      );
    }
    _cacheVector
      ..setFrom(_targetPosition)
      ..add(
        direction..toGameSize(),
      )
      ..snap();

    final world = ancestors().whereType<TrashyTownWorld>().first;
    final mapEdges = world.descendants().whereType<MapEdge>().toSet();

    final isInMapEdge = mapEdges.any(
      (element) => element.isPointInside(_cacheVector + parent.hitbox.position),
    );

    if (isInMapEdge) {
      return false;
    }

    _targetPosition.setFrom(_cacheVector);
    return true;
  }

  @override
  FutureOr<void> onLoad() async {
    await super.onLoad();
    _targetPosition.setFrom(parent.position);
  }

  @override
  void update(double dt) {
    super.update(dt);
    parent.position.lerp(_targetPosition, 0.7);
  }
}
