import 'package:flame/game.dart';
import 'package:flame_behaviors/flame_behaviors.dart';
import 'package:trashy_road/src/game/game.dart';

/// Communicates to the [PlayerKeyboardMovingBehavior] that the player
/// has collided with an [Untraversable] component.
class PlayerPushingBehavior extends CollisionBehavior<Pushable, Player> {
  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    Pushable other,
  ) {
    super.onCollisionStart(intersectionPoints, other);
    // get average position of intersection points
    final averagePosition = intersectionPoints.reduce(
          (value, element) => value + element,
        ) /
        intersectionPoints.length.toDouble();

    final hitboxCentre = other.hitbox.absoluteCenter;

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
    final canPush =
        other.findBehavior<PushableMovingBehavior>().push(-direction);
    if (!canPush) {
      parent.findBehavior<PlayerMovingBehavior>().bounceBack();
    }
  }
}
