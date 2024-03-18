import 'package:clock/clock.dart';
import 'package:flame/components.dart';
import 'package:flame_behaviors/flame_behaviors.dart';
import 'package:flame_bloc/flame_bloc.dart';
import 'package:flutter/widgets.dart';
import 'package:trashy_road/game_settings.dart';
import 'package:trashy_road/src/audio/audio.dart';
import 'package:trashy_road/src/game/game.dart';

enum Direction { up, down, left, right }

/// A behavior that allows the player to move around the game.
final class PlayerMovingBehavior extends Behavior<Player>
    with
        FlameBlocReader<GameBloc, GameState>,
        ParentIsA<Player>,
        HasGameReference<TrashyTownGame> {
  /// The delay between player moves for each item in the inventory.
  static const _maxMovementDelay = Duration(milliseconds: 125);

  /// The curve used to calculate the delay between player moves.
  static const _delayCurve = Curves.easeInCubic;

  /// The buffer time between the player's movement and the next move.
  static const _movementBufferTime = Duration(milliseconds: 50);

  /// The base time it takes for the player to move from one position to
  /// another.
  static const baseMoveTime = Duration(milliseconds: 150);

  /// The delay between player moves.
  Duration moveDelay = baseMoveTime;

  /// States whether the player is currently moving.
  bool _isMoving = false;

  /// The position the player is trying to move to.
  ///
  /// When its values are different than the current [Player.position]
  /// it will be lerped until [_targetPosition] is reached by the [Player].
  final Vector2 _targetPosition = Vector2.zero();

  /// The position the player was at before the current [_targetPosition].
  final Vector2 _previousPosition = Vector2.zero();

  /// A int that contains the time when the next move can be made.
  DateTime _nextMoveTime = DateTime.fromMicrosecondsSinceEpoch(0);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    _targetPosition.setFrom(parent.position);
    _previousPosition.setFrom(parent.position);
  }

  @override
  void update(double dt) {
    super.update(dt);
    final now = clock.now();
    final timeUntilDone = _nextMoveTime.difference(now);
    final hasArrived = _nextMoveTime.isBefore(now);

    if (!hasArrived && _isMoving) {
      parent.position.curve(
        from: _previousPosition,
        to: _targetPosition,
        curve: Curves.easeInOut,
        percentCompletion:
            1 - (timeUntilDone.inMilliseconds / moveDelay.inMilliseconds),
      );
    }

    // This ensures there has been at least one frame of the user at the end
    // destination before the user can set the next location.

    // If this isn't done the user will skip back momentarily as the
    //_previousPosition is outdated.
    if (hasArrived && _isMoving) {
      _isMoving = false;
      parent.position.setFrom(_targetPosition);
      _previousPosition.setFrom(_targetPosition);

      game.audioBloc.playEffect(GameSoundEffects.step1);
    }
  }

  /// Calculates the delay between player moves based on the inventory's size.
  ///
  /// This equates to roughly the following values.
  /// 1 trash: 153ms (+0ms)
  /// 2 trash: 161ms (+8ms)
  /// 3 trash: 179ms (+26ms)
  /// 4 trash: 217ms (+64ms)
  /// 5 trash: 275ms (+122ms)
  ///
  /// The goal of this is to make the game feel more challenging as the player
  /// collects more trash.
  Duration calculateMoveDelay() {
    final weightCompensation = _delayCurve
            .transform(bloc.state.inventory.items.length / Inventory.size) *
        _maxMovementDelay.inMilliseconds;

    final delayMilliseconds =
        weightCompensation.toInt() + baseMoveTime.inMilliseconds;

    return Duration(milliseconds: delayMilliseconds);
  }

  void move(Direction direction) {
    final isFirstInteraction = bloc.state.status == GameStatus.ready;
    if (isFirstInteraction) {
      bloc.add(const GameInteractedEvent());
    }

    final now = clock.now();

    if (now.isBefore(_nextMoveTime) || _isMoving) {
      return;
    }
    _targetPosition.setFrom(parent.position);
    if (direction == Direction.left) {
      _targetPosition.x -= GameSettings.gridDimensions.x;
    } else if (direction == Direction.right) {
      _targetPosition.x += GameSettings.gridDimensions.x;
    } else if (direction == Direction.down) {
      _targetPosition.y += GameSettings.gridDimensions.y;
    } else if (direction == Direction.up) {
      _targetPosition.y -= GameSettings.gridDimensions.y;
    }
    parent.hop(direction);
    _isMoving = true;

    moveDelay = calculateMoveDelay();
    _nextMoveTime = now.add(moveDelay - _movementBufferTime);
  }

  void bounceBack() {
    _targetPosition.setFrom(_previousPosition);
    _previousPosition.setFrom(parent.position);
  }
}

extension on Vector2 {
  static final _reusableVector = Vector2.zero();

  /// Moves the vector to the target position using a [Curve].
  void curve({
    required Vector2 from,
    required Vector2 to,
    required Curve curve,
    required double percentCompletion,
  }) {
    setFrom(
      _reusableVector
        ..setFrom(to)
        ..sub(from)
        ..scale(curve.transform(percentCompletion))
        ..add(from),
    );
  }
}
