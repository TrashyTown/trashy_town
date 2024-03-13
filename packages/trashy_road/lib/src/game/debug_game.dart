import 'dart:async';

import 'package:basura/basura.dart';
import 'package:flame/components.dart';
import 'package:flutter/rendering.dart';
import 'package:trashy_road/src/game/game.dart';

/// {@template DebugTrashyTownGame}
/// A [TrashyTownGame] that is used for debugging purposes.
/// {@endtemplate}
class DebugTrashyTownGame extends TrashyTownGame {
  /// {@macro DebugTrashyTownGame}
  DebugTrashyTownGame({
    required super.gameBloc,
    required super.audioBloc,
    required super.random,
    required super.resolution,
    required super.images,
  }) {
    debugMode = true;
  }

  @override
  FutureOr<void> onLoad() async {
    await super.onLoad();

    add(
      FpsTextComponent()
        ..position = Vector2(10, 55)
        ..textRenderer = TextPaint(
          style: const TextStyle(
            color: BasuraColors.black,
            fontSize: 24,
          ),
        ),
    );
  }
}
