import 'package:flame/components.dart';
import 'package:flame_behaviors/flame_behaviors.dart';
import 'package:trashy_road/src/game/game.dart';

/// Communicates to the [PlayerKeyboardMovingBehavior] that the player
/// has collided with an [Untraversable] component.
class PushableUntraversableBehavior
    extends CollisionBehavior<Untraversable, Pushable>
    with HasGameReference<TrashyTownGame> {
  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    Untraversable other,
  ) {
    super.onCollisionStart(intersectionPoints, other);
    if (!other.untraversable) {
      return;
    }

    // get average position of intersection points
    final averagePosition = intersectionPoints.reduce(
          (value, element) => value + element,
        ) /
        intersectionPoints.length.toDouble();

    final hitboxCentre = parent.hitbox.absoluteCenter;

    final direction = averagePosition - hitboxCentre;

    if (direction.x.abs() > direction.y.abs()) {
      direction
        ..x = direction.x.sign
        ..y = 0;
    } else {
      direction
        ..x = 0
        ..y = direction.y.sign;
    }

    parent.findBehavior<PushableMovingBehavior>().push(-direction);
    final world = ancestors().whereType<TrashyTownWorld>().first;
    final player = world.descendants().whereType<Player>().first;
    // bounce the player back
    player.findBehavior<PlayerMovingBehavior>().bounceBack();
  }
}
