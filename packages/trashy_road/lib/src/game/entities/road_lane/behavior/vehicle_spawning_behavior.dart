import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame_behaviors/flame_behaviors.dart';
import 'package:trashy_road/src/game/game.dart';

/// {@template VehicleSpawningBehavior}
/// Spawns vehicles in the road lane.
/// {@endtemplate}
class VehicleSpawningBehavior extends Behavior<RoadLane>
    with HasGameReference<TrashyTownGame> {
  /// {@macro VehicleSpawningBehavior}
  VehicleSpawningBehavior();

  /// The minimum traffic variation.
  ///
  /// A random amount between [_minTrafficVariation] and 1 will be used to
  /// determine the distance between cars in the same lane.
  ///
  /// The lower this value, the more variation there will be between the
  /// distance between cars.
  static const _minTrafficVariation = 0.8;

  /// Removes the need to create a new instance of [Vector2] every frame.
  final Vector2 _vector2Cache = Vector2.zero();

  @override
  FutureOr<void> onLoad() async {
    await super.onLoad();

    for (var i = 0; i < parent.traffic; i++) {
      var startPosition = (i / parent.traffic) * game.bounds!.bottomRight.x;

      startPosition *= _minTrafficVariation +
          (game.random.nextDouble() * (1 - _minTrafficVariation));

      if (parent.direction == RoadLaneDirection.rightToLeft) {
        startPosition *= -1;
      }

      parent.add(
        Vehicle.fromRoadLane(parent)..position.x = startPosition,
      );
    }
  }

  @override
  void update(double dt) {
    final vehicles = parent.children.whereType<Vehicle>();
    for (final vehicle in vehicles) {
      _vector2Cache
        ..setFrom(parent.position)
        ..add(vehicle.position);
      final isWithinBound = game.bounds!.isPointInside(_vector2Cache);
      if (!isWithinBound) {
        vehicle.position.setAll(0);
      }
    }
  }
}
