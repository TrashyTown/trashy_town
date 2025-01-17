import 'dart:async';

import 'package:basura/basura.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tiled/tiled.dart';
import 'package:trashy_road/gen/gen.dart';
import 'package:trashy_road/src/audio/audio.dart';
import 'package:trashy_road/src/game/game.dart';
import 'package:trashy_road/src/loading/loading.dart';
import 'package:trashy_road/src/maps/maps.dart';
import 'package:trashy_road/src/score/score.dart';

class GamePage extends StatelessWidget {
  const GamePage({
    required GameMapIdentifier identifier,
    required TiledMap map,
    super.key,
  })  : _map = map,
        _identifier = identifier;

  /// The identifier for the route.
  static String identifier = 'maps_menu';

  static Route<void> route({
    required GameMapIdentifier identifier,
    required TiledMap tiledMap,
  }) {
    return BasuraBlackEaseInOut<void>(
      settings: RouteSettings(name: identifier.name),
      builder: (_) => GamePage(
        identifier: identifier,
        map: tiledMap,
      ),
    );
  }

  /// The identifier of the game.
  final GameMapIdentifier _identifier;

  /// The map to play.
  ///
  /// Usually loaded from the [TiledCache] provided by the [PreloadCubit].
  final TiledMap _map;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => GameBloc(
        identifier: _identifier,
        map: _map,
      ),
      child: const _GameView(),
    );
  }
}

class _GameView extends StatefulWidget {
  const _GameView();

  @override
  State<_GameView> createState() => _GameViewState();
}

class _GameViewState extends State<_GameView> {
  TrashyTownGame? _game;

  @override
  Widget build(BuildContext context) {
    final gameBloc = context.read<GameBloc>();
    final isTutorial = gameBloc.state.identifier == GameMapIdentifier.tutorial;

    return GameBackgroundMusicListener(
      child: MultiBlocListener(
        listeners: [
          _GameCompletionListener(),
          _GameLostTimeIsUpListener(),
          _GameLostRunnedOverListener(),
        ],
        child: GestureDetector(
          onTapUp: (details) => _game?.onTapUp(details),
          onPanStart: (details) => _game?.onPanStart(details),
          onPanUpdate: (details) => _game?.onPanUpdate(details),
          onPanEnd: (details) => _game?.onPanEnd(details),
          behavior: HitTestBehavior.translucent,
          child: Stack(
            children: [
              const Positioned.fill(child: _GameBackground()),
              Align(
                child: TrashyTownGameWidget(
                  onGameCreated: (game) => _game = game,
                ),
              ),
              const Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: EdgeInsets.all(12),
                  child: InventoryHud(),
                ),
              ),
              const Align(
                alignment: Alignment.topCenter,
                child: Padding(
                  padding: EdgeInsets.all(12),
                  child: TopHud(),
                ),
              ),
              if (isTutorial)
                const Align(
                  alignment: Alignment(0, -0.6),
                  child: TutorialHud(),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GameCompletionListener extends BlocListener<GameBloc, GameState> {
  _GameCompletionListener()
      : super(
          listenWhen: (previous, current) =>
              current.status == GameStatus.completed,
          listener: (context, state) {
            assert(
              state.score != null,
              'The game is completed, but the score is null.',
            );
            context.read<AudioCubit>().playEffect(GameSoundEffects.stagePass);

            final gameMapsBloc = context.read<GameMapsBloc>();
            final gameMap = gameMapsBloc.state.maps[state.identifier];
            final scoreRating = ScoreRating.fromSteps(
              score: state.score,
              steps: gameMap!.ratingSteps,
            );

            context.read<GameMapsBloc>().add(
                  GameMapCompletedEvent(
                    identifier: state.identifier,
                    score: state.score!,
                  ),
                );
            Navigator.push(
              context,
              ScorePage.route(
                identifier: state.identifier,
                scoreRating: scoreRating,
              ),
            );
          },
        );
}

class _GameLostRunnedOverListener extends BlocListener<GameBloc, GameState> {
  _GameLostRunnedOverListener()
      : super(
          listenWhen: (previous, current) =>
              current.status == GameStatus.lost &&
              current.lostReason == GameLostReason.vehicleRunningOver,
          listener: (context, state) {
            context.read<AudioCubit>().playEffect(GameSoundEffects.gameOver);
            context.read<GameBloc>().add(const GameResetEvent());
          },
        );
}

class _GameLostTimeIsUpListener extends BlocListener<GameBloc, GameState> {
  _GameLostTimeIsUpListener()
      : super(
          listenWhen: (previous, current) =>
              current.status == GameStatus.lost &&
              current.lostReason == GameLostReason.timeIsUp,
          listener: (context, state) {
            final gameBloc = context.read<GameBloc>()
              ..add(const GamePausedEvent());
            final navigator = Navigator.of(context)
              ..push(GameTimeIsUpPage.route());

            // TODO(alestiago): Refactor this to stop using microtasks and
            // Future.delayed. Instead, consider other approaches to stagger
            // the animations.
            scheduleMicrotask(() async {
              await Future<void>.delayed(
                GameTimeIsUpPageRouteBuilder.animationDuration * 2,
              );
              gameBloc.add(const GameResetEvent());
              await Future<void>.delayed(
                PlayingHudTransition.animationDuration ~/ 2,
              );
              navigator.pop();
            });
          },
        );
}

class _GameBackground extends StatelessWidget {
  const _GameBackground();

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      Assets.images.sprites.grass.path,
      repeat: ImageRepeat.repeat,
      color: const Color.fromARGB(40, 0, 0, 0),
      colorBlendMode: BlendMode.darken,
    );
  }
}
