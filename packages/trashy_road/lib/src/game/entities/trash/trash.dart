import 'dart:math';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame_behaviors/flame_behaviors.dart';
import 'package:flame_bloc/flame_bloc.dart';
import 'package:meta/meta.dart';
import 'package:tiled/tiled.dart';
import 'package:trashy_road/game_settings.dart';
import 'package:trashy_road/gen/assets.gen.dart';
import 'package:trashy_road/src/audio/audio.dart';
import 'package:trashy_road/src/game/game.dart';

export 'behaviors/behaviors.dart';

/// The different types of [Trash].
enum TrashType {
  plastic._('plastic'),
  organic._('organic'),
  paper._('paper');

  const TrashType._(this.name);

  /// The [name] of the trash type in the Tiled map.
  final String name;

  @internal
  static TrashType? tryParse(String value) => _valueToEnumMap[value];

  static final _valueToEnumMap = <String, TrashType>{
    for (final value in TrashType.values) value.name: value,
  };
}

/// A piece of trash.
///
/// Trash is usually scattered around the road and the player has to pick it up
/// to keep the map clean.
class Trash extends PositionedEntity
    with HasGameReference<TrashyTownGame>, ZIndex, Untraversable {
  Trash._({
    required Vector2 position,
    required this.trashType,
    super.children,
  }) : super(
          anchor: Anchor.bottomLeft,
          size: Vector2(1, 2)..toGameSize(),
          position: position..snap(),
          priority: position.y.floor(),
          behaviors: [
            DroppingBehavior(
              drop: Vector2(0, -45),
              minDuration: 0.1,
            ),
            TrashShakingBehavior(),
            PropagatingCollisionBehavior(
              RectangleHitbox(
                isSolid: true,
                size: GameSettings.gridDimensions,
                position: Vector2(0, GameSettings.gridDimensions.y),
              ),
            ),
          ],
        ) {
    zIndex = position.y.floor();
    untraversable = false;
  }

  Trash._plastic({
    required Vector2 position,
    required PlasticStyle style,
  }) : this._(
          position: position,
          trashType: TrashType.plastic,
          children: [_PlasticSpriteGroup._fromStyle(style)],
        );

  Trash._organic({
    required Vector2 position,
    required OrganicStyle style,
  }) : this._(
          position: position,
          trashType: TrashType.organic,
          children: [_OrganicSpriteGroup._fromStyle(style)],
        );

  Trash._paper({
    required Vector2 position,
    required PaperStyle style,
  }) : this._(
          position: position,
          trashType: TrashType.paper,
          children: [_PaperSpriteGroup._fromStyle(style)],
        );

  /// Derives a [Trash] from a [TiledObject].
  factory Trash.fromTiledObject(TiledObject tiledObject) {
    final type = TrashType.tryParse(
      tiledObject.properties.getValue<String>('type') ?? '',
    );
    final position = Vector2(tiledObject.x, tiledObject.y)..snap();

    switch (type) {
      case TrashType.plastic:
        final style = PlasticStyle._randomize();
        return Trash._plastic(position: position, style: style);
      case TrashType.organic:
        final style = OrganicStyle._randomize();
        return Trash._organic(position: position, style: style);
      case TrashType.paper:
        final style = PaperStyle._randomize();
        return Trash._paper(position: position, style: style);
      case null:
        throw ArgumentError.value(
          type,
          'tiledObject.properties["type"]',
          'Invalid trash type',
        );
    }
  }

  /// Collects the trash.
  void collect() {
    game.audioBloc.playEffect(GameSoundEffects.trashCollected);
    removeFromParent();
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    add(
      FlameBlocListener<GameBloc, GameState>(
        onNewState: _toggleTraversable,
      ),
    );
  }

  void _toggleTraversable(GameState state) =>
      untraversable = state.inventory.items.length == Inventory.size;

  final TrashType trashType;
}

/// The different styles of plastic bottles.
enum PlasticStyle {
  /// {@template _PlasticStyle.plasticBottleOne}
  /// A crushed plastic bottle that is laying on the ground with its lid facing
  /// east.
  /// {@endtemplate}
  plasticBottleOne,

  /// {@template _PlasticStyle.plasticBottleTwo}
  /// A crushed plastic bottle that is laying on the ground with its lid facing
  /// south-east.
  /// {@endtemplate}
  plasticBottleTwo,

  /// {@template _PlasticStyle.coldTakeAwayCup}
  /// A takeaway cup with a straw.
  /// {@endtemplate}
  coldTakeAwayCup,

  /// {@template _PlasticStyle.straw}
  /// A plastic straw.
  /// {@endtemplate}
  straw,

  /// {@template _PlasticStyle.canHolder}
  /// A plastic can holder.
  /// {@endtemplate}
  canHolder;

  factory PlasticStyle._randomize({
    @visibleForTesting Random? random,
  }) {
    return PlasticStyle
        .values[(random ?? _random).nextInt(PlasticStyle.values.length)];
  }

  static final _random = Random();
}

/// The different styles of apple cores.
enum OrganicStyle {
  /// {@template _OrganicStyle.one}
  /// Two apple cores in a group, one is laying on the ground and the other is
  /// laying on top of the first one.
  /// {@endtemplate}
  one,

  /// {@template _OrganicStyle.two}
  /// A single apple core laying on the ground.
  /// {@endtemplate}
  two,

  /// {@template _OrganicStyle.banana}
  /// A single banana peel on the ground.
  /// {@endtemplate}
  banana,

  /// {@template _OrganicStyle.sandwich}
  /// A sandwich on the ground
  /// {@endtemplate}
  sandwich;

  factory OrganicStyle._randomize({
    @visibleForTesting Random? random,
  }) {
    return OrganicStyle
        .values[(random ?? _random).nextInt(OrganicStyle.values.length)];
  }

  static final _random = Random();
}

/// The different styles of paper.
enum PaperStyle {
  /// {@template _PaperStyle.one}
  /// Paper in a neat pile.
  /// {@endtemplate}
  one,

  /// {@template _PaperStyle.two}
  /// Paper scattered around.
  /// {@endtemplate}
  two,

  /// {@template _PaperStyle.hotTakeAwayCup}
  /// A hot coffee takeaway cup.
  /// {@endtemplate}
  hotTakeAwayCup,

  /// {@template _PaperStyle.hotTakeAwayCup}
  /// A scrumpled up piece of paper.
  /// {@endtemplate}
  paperBall;

  factory PaperStyle._randomize({
    @visibleForTesting Random? random,
  }) {
    return PaperStyle
        .values[(random ?? _random).nextInt(PaperStyle.values.length)];
  }

  static final _random = Random();
}

/// A plastic bottle.
///
/// Renders the plastic bottle.
class _PlasticSpriteGroup extends PositionComponent
    with HasGameRef<TrashyTownGame> {
  _PlasticSpriteGroup._({
    required String spritePath,
    super.scale,
  }) : super(
          // The `position` and `scale` have been eyeballed to match with the
          // appearance of the map.
          position: Vector2(0.5, 1.4)..toGameSize(),
          anchor: Anchor.center,
          children: [
            GameSpriteComponent.fromPath(
              anchor: Anchor.center,
              spritePath: spritePath,
            ),
          ],
        );

  /// Derives a [_PlasticSpriteGroup] from a [PlasticStyle].
  factory _PlasticSpriteGroup._fromStyle(
    PlasticStyle style,
  ) {
    switch (style) {
      case PlasticStyle.plasticBottleOne:
        return _PlasticSpriteGroup._plasticBottleOne();
      case PlasticStyle.plasticBottleTwo:
        return _PlasticSpriteGroup._plasticBottleTwo();
      case PlasticStyle.coldTakeAwayCup:
        return _PlasticSpriteGroup._coldTakeAwayCup();
      case PlasticStyle.straw:
        return _PlasticSpriteGroup._straw();
      case PlasticStyle.canHolder:
        return _PlasticSpriteGroup._canHolder();
    }
  }

  /// {@macro _PlasticStyle.plasticBottleOne}
  factory _PlasticSpriteGroup._plasticBottleOne() => _PlasticSpriteGroup._(
        spritePath: Assets.images.sprites.plasticBottle1.path,
        scale: Vector2.all(0.5),
      );

  /// {@macro _PlasticBo_PlasticStylettleStyle.plasticBottleTwo}
  factory _PlasticSpriteGroup._plasticBottleTwo() => _PlasticSpriteGroup._(
        spritePath: Assets.images.sprites.plasticBottle2.path,
        scale: Vector2.all(0.5),
      );

  /// {@macro _PlasticStyle.coldTakeAwayCup}
  factory _PlasticSpriteGroup._coldTakeAwayCup() => _PlasticSpriteGroup._(
        spritePath: Assets.images.sprites.takeawayCupCold.path,
        scale: Vector2.all(0.8),
      );

  /// {@macro _PlasticStyle.straw}
  factory _PlasticSpriteGroup._straw() => _PlasticSpriteGroup._(
        spritePath: Assets.images.sprites.plasticStraw.path,
        scale: Vector2.all(0.8),
      );

  /// {@macro _PlasticStyle.canHolder}
  factory _PlasticSpriteGroup._canHolder() => _PlasticSpriteGroup._(
        spritePath: Assets.images.sprites.canHolder.path,
        scale: Vector2.all(0.8),
      );
}

/// An apple core.
///
/// Renders an apple core.
class _OrganicSpriteGroup extends PositionComponent
    with HasGameRef<TrashyTownGame> {
  _OrganicSpriteGroup._({
    required String spritePath,
  }) : super(
          // The `position` and `scale` have been eyeballed to match with the
          // appearance of the map.
          position: Vector2(0.6, 1.4)..toGameSize(),
          scale: Vector2.all(0.5),
          anchor: Anchor.center,
          children: [
            GameSpriteComponent.fromPath(
              anchor: Anchor.center,
              spritePath: spritePath,
            ),
          ],
        );

  /// Derives an [_OrganicSpriteGroup] from an [OrganicStyle].
  factory _OrganicSpriteGroup._fromStyle(
    OrganicStyle style,
  ) {
    switch (style) {
      case OrganicStyle.one:
        return _OrganicSpriteGroup._styleOne();
      case OrganicStyle.two:
        return _OrganicSpriteGroup._styleTwo();
      case OrganicStyle.banana:
        return _OrganicSpriteGroup._banana();
      case OrganicStyle.sandwich:
        return _OrganicSpriteGroup._sandwich();
    }
  }

  /// {@macro _OrganicStyle.one}
  factory _OrganicSpriteGroup._styleOne() => _OrganicSpriteGroup._(
        spritePath: Assets.images.sprites.appleCore1.path,
      );

  /// {@macro _OrganicStyle.two}
  factory _OrganicSpriteGroup._styleTwo() => _OrganicSpriteGroup._(
        spritePath: Assets.images.sprites.appleCore2.path,
      );

  /// {@macro _OrganicStyle.banana}
  factory _OrganicSpriteGroup._banana() => _OrganicSpriteGroup._(
        spritePath: Assets.images.sprites.banana.path,
      );

  /// {@macro _OrganicStyle.sandwich}
  factory _OrganicSpriteGroup._sandwich() => _OrganicSpriteGroup._(
        spritePath: Assets.images.sprites.sandwich.path,
      );
}

/// A stack of paper
///
/// Renders a stack of paper.
class _PaperSpriteGroup extends PositionComponent
    with HasGameRef<TrashyTownGame> {
  _PaperSpriteGroup._({
    required String spritePath,
  }) : super(
          // The `position` and `scale` have been eyeballed to match with the
          // appearance of the map.
          position: Vector2(0.6, 1.4)..toGameSize(),
          scale: Vector2.all(0.5),
          anchor: Anchor.center,
          children: [
            GameSpriteComponent.fromPath(
              anchor: Anchor.center,
              spritePath: spritePath,
            ),
          ],
        );

  /// Derives an [_PaperSpriteGroup] from an [PaperStyle].
  factory _PaperSpriteGroup._fromStyle(
    PaperStyle style,
  ) {
    switch (style) {
      case PaperStyle.one:
        return _PaperSpriteGroup._styleOne();
      case PaperStyle.two:
        return _PaperSpriteGroup._styleTwo();
      case PaperStyle.hotTakeAwayCup:
        return _PaperSpriteGroup._hotTakeAwayCup();
      case PaperStyle.paperBall:
        return _PaperSpriteGroup._paperBall();
    }
  }

  /// {@macro _PaperStyle.one}
  factory _PaperSpriteGroup._styleOne() => _PaperSpriteGroup._(
        spritePath: Assets.images.sprites.paper1.path,
      );

  /// {@macro _PaperStyle.two}
  factory _PaperSpriteGroup._styleTwo() => _PaperSpriteGroup._(
        spritePath: Assets.images.sprites.paper2.path,
      );

  /// {@macro _PaperStyle.hotTakeAwayCup}
  factory _PaperSpriteGroup._hotTakeAwayCup() => _PaperSpriteGroup._(
        spritePath: Assets.images.sprites.takeawayCupHot.path,
      );

  /// {@macro _PaperStyle.hotTakeAwayCup}
  factory _PaperSpriteGroup._paperBall() => _PaperSpriteGroup._(
        spritePath: Assets.images.sprites.paperBall.path,
      );
}
