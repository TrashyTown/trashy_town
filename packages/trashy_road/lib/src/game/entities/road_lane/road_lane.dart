import 'package:flame/components.dart';
import 'package:flame_behaviors/flame_behaviors.dart';
import 'package:tiled/tiled.dart';
import 'package:trashy_road/game_settings.dart';
import 'package:trashy_road/src/game/game.dart';

export 'behavior/behavior.dart';

/// {@template RoadLaneDirection}
/// The direction of the road lane.
/// {@endtemplate}
enum RoadLaneDirection {
  /// The road lane direction is horizontal, from west to east.
  leftToRight,

  /// The road lane direction is horizontal, from east to west.
  rightToLeft;

  /// Derives a direction from a boolean value.
  ///
  /// Used to decode a [RoadLaneDirection] from a Tiled extension property.
  factory RoadLaneDirection.fromBool({required bool isLeftToRight}) {
    if (isLeftToRight) {
      return RoadLaneDirection.leftToRight;
    } else {
      return RoadLaneDirection.rightToLeft;
    }
  }
}

/// {@template RoadLane}
/// A lane in the road.
///
/// Road lanes dictate how vehicles move and spawn in the game.
/// {@endtemplate}
class RoadLane extends PositionedEntity with ZIndex {
  RoadLane({
    required this.speed,
    required this.direction,
    required this.traffic,
    required this.vehicleType,
    super.position,
  }) : super(
          behaviors: [VehicleSpawningBehavior()],
        ) {
    // One tile added on because the cars are spawned one tile below road lane
    // positioning
    zIndex = super.position.y.floor() + GameSettings.gridDimensions.y.toInt();
  }

  /// Derives a [Player] from a [TiledObject].
  ///
  /// The [TiledObject] must have the following properties:
  /// - `speed`: an int representing the speed of the vehicles in the lane.
  /// - `leftToRight`: a boolean representing the direction of the lane.
  /// - `traffic`: an int representing the amount of traffic in the lane.
  factory RoadLane.fromTiledObject(TiledObject object) {
    final properties = object.properties;

    final rawSpeed = properties.getProperty('speed');
    if (rawSpeed == null || rawSpeed is! IntProperty) {
      throw ArgumentError.value(
        object,
        'object',
        'The TiledObject must have an int "speed" property.',
      );
    }
    final speed = rawSpeed.value;

    final rawDirection = properties.getProperty('leftToRight');
    if (rawDirection == null || rawDirection is! BoolProperty) {
      throw ArgumentError.value(
        object,
        'object',
        'The TiledObject must have a boolean "direction" property.',
      );
    }
    final direction = RoadLaneDirection.fromBool(
      isLeftToRight: rawDirection.value,
    );

    final rawTraffic = properties.getProperty('traffic');
    if (rawTraffic == null || rawTraffic is! IntProperty) {
      throw ArgumentError.value(
        object,
        'object',
        'The TiledObject must have an int "traffic" property.',
      );
    }
    final traffic = rawTraffic.value;
    final position = Vector2(object.x, object.y)..snap();

    final vehicleType = VehicleType.tryParse(
      object.properties.getValue<String>('type') ?? '',
    );

    if (vehicleType == null) {
      throw ArgumentError.value(
        vehicleType,
        'object.properties["type"]',
        'Invalid vehicle type',
      );
    }

    return RoadLane(
      speed: speed,
      direction: direction,
      traffic: traffic,
      vehicleType: vehicleType,
      position: position,
    );
  }

  /// The speed of the vehicles in the lane.
  final int speed;

  /// {@macro RoadLaneDirection}
  final RoadLaneDirection direction;

  /// The amount of vehicles in the lane.
  final int traffic;

  /// The type of vehicles in the lane.
  final VehicleType vehicleType;
}
