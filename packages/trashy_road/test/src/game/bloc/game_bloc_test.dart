import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tiled/tiled.dart';
import 'package:trashy_road/src/game/game.dart';

class _MockTiledMap extends Mock implements TiledMap {}

class _MockObjectGroup extends Mock implements ObjectGroup {}

class _MockTiledObject extends Mock implements TiledObject {}

void main() {
  group('$GameBloc', () {
    late TiledMap map;
    late _MockObjectGroup trashLayer;

    setUp(() {
      map = _MockTiledMap();
      trashLayer = _MockObjectGroup();
      when(() => trashLayer.objects).thenReturn([]);
      when(() => map.layerByName('TrashLayer')).thenReturn(trashLayer);
    });

    test('can be instantiated', () {
      expect(() => GameBloc(map: map), returnsNormally);
    });

    group('$GameInteractedEvent', () {
      blocTest<GameBloc, GameState>(
        'playing status after the user interacts with the game',
        build: () => GameBloc(map: map),
        act: (bloc) => bloc.add(const GameInteractedEvent()),
        expect: () => [
          GameState(
            map: map,
            status: GameStatus.playing,
            inventory: const Inventory.empty(),
          ),
        ],
      );
    });

    group('$GameCollectedTrashEvent', () {
      blocTest<GameBloc, GameState>(
        'does not fill the inventory with trash when the user collects trash '
        'and the game is not playing',
        build: () => GameBloc(map: map),
        act: (bloc) =>
            bloc.add(const GameCollectedTrashEvent(type: TrashType.plastic)),
        expect: () => <GameState>[],
      );

      blocTest<GameBloc, GameState>(
        'fills the inventory with trash when the user collects trash '
        'and the game is playing',
        build: () => GameBloc(map: map),
        act: (bloc) => bloc
          ..add(const GameInteractedEvent())
          ..add(const GameCollectedTrashEvent(type: TrashType.plastic)),
        expect: () => [
          GameState(
            map: map,
            status: GameStatus.playing,
            inventory: const Inventory.empty(),
          ),
          GameState(
            map: map,
            status: GameStatus.playing,
            inventory: const Inventory(glassTrash: 0, plasticTrash: 1),
          ),
        ],
      );

      blocTest<GameBloc, GameState>(
        'increments the correct type of trash when the user collects trash '
        'and the game is playing',
        build: () => GameBloc(map: map),
        act: (bloc) => bloc
          ..add(const GameInteractedEvent())
          ..add(const GameCollectedTrashEvent(type: TrashType.plastic))
          ..add(const GameCollectedTrashEvent(type: TrashType.glass)),
        expect: () => [
          GameState(
            map: map,
            status: GameStatus.playing,
            inventory: const Inventory.empty(),
          ),
          GameState(
            map: map,
            status: GameStatus.playing,
            inventory: const Inventory(glassTrash: 0, plasticTrash: 1),
          ),
          GameState(
            map: map,
            status: GameStatus.playing,
            inventory: const Inventory(glassTrash: 1, plasticTrash: 1),
          ),
        ],
      );
    });

    group('$GameDepositedTrashEvent', () {
      blocTest<GameBloc, GameState>(
        'does nothing when the game is not playing',
        build: () => GameBloc(map: map),
        act: (bloc) =>
            bloc.add(const GameDepositedTrashEvent(type: TrashType.plastic)),
        expect: () => <GameState>[],
      );

      blocTest<GameBloc, GameState>(
        'empties the inventory with trash when the user deposits trash '
        'and the game is playing',
        build: () => GameBloc(map: map),
        setUp: () => when(() => trashLayer.objects)
            .thenReturn([_MockTiledObject(), _MockTiledObject()]),
        act: (bloc) => bloc
          ..add(const GameInteractedEvent())
          ..add(const GameCollectedTrashEvent(type: TrashType.plastic))
          ..add(const GameDepositedTrashEvent(type: TrashType.plastic)),
        expect: () => [
          GameState(
            map: map,
            status: GameStatus.playing,
            inventory: const Inventory.empty(),
          ),
          GameState(
            map: map,
            status: GameStatus.playing,
            inventory: const Inventory(glassTrash: 0, plasticTrash: 1),
          ),
          GameState(
            map: map,
            status: GameStatus.playing,
            inventory: const Inventory.empty(),
            collectedTrash: 1,
          ),
        ],
      );

      blocTest<GameBloc, GameState>(
        'empties the correct type of trash when the user deposits trash '
        'and the game is playing',
        build: () => GameBloc(map: map),
        setUp: () => when(() => trashLayer.objects)
            .thenReturn([_MockTiledObject(), _MockTiledObject()]),
        act: (bloc) => bloc
          ..add(const GameInteractedEvent())
          ..add(const GameCollectedTrashEvent(type: TrashType.plastic))
          ..add(const GameCollectedTrashEvent(type: TrashType.glass))
          ..add(const GameDepositedTrashEvent(type: TrashType.plastic)),
        expect: () => [
          GameState(
            map: map,
            status: GameStatus.playing,
            inventory: const Inventory.empty(),
          ),
          GameState(
            map: map,
            status: GameStatus.playing,
            inventory: const Inventory(glassTrash: 0, plasticTrash: 1),
          ),
          GameState(
            map: map,
            status: GameStatus.playing,
            inventory: const Inventory(glassTrash: 1, plasticTrash: 1),
          ),
          GameState(
            map: map,
            status: GameStatus.playing,
            inventory: const Inventory(glassTrash: 1, plasticTrash: 0),
            collectedTrash: 1,
          ),
        ],
      );

      blocTest<GameBloc, GameState>(
        'completes the game when all the trash is deposited ',
        build: () => GameBloc(map: map),
        setUp: () => when(() => trashLayer.objects)
            .thenReturn([_MockTiledObject(), _MockTiledObject()]),
        act: (bloc) => bloc
          ..add(const GameInteractedEvent())
          ..add(const GameCollectedTrashEvent(type: TrashType.plastic))
          ..add(const GameCollectedTrashEvent(type: TrashType.plastic))
          ..add(const GameDepositedTrashEvent(type: TrashType.plastic))
          ..add(const GameDepositedTrashEvent(type: TrashType.plastic)),
        expect: () => [
          GameState(
            map: map,
            status: GameStatus.playing,
            inventory: const Inventory.empty(),
          ),
          GameState(
            map: map,
            status: GameStatus.playing,
            inventory: const Inventory(plasticTrash: 1, glassTrash: 0),
          ),
          GameState(
            map: map,
            status: GameStatus.playing,
            inventory: const Inventory(plasticTrash: 2, glassTrash: 0),
          ),
          GameState(
            map: map,
            status: GameStatus.playing,
            inventory: const Inventory(plasticTrash: 1, glassTrash: 0),
            collectedTrash: 1,
          ),
          GameState(
            map: map,
            status: GameStatus.completed,
            inventory: const Inventory.empty(),
            collectedTrash: 2,
          ),
        ],
      );
    });

    group('$GamePausedEvent', () {
      blocTest<GameBloc, GameState>(
        'pauses the game when the user was previously playing the game',
        build: () => GameBloc(map: map),
        act: (bloc) => bloc
          ..add(const GameInteractedEvent())
          ..add(const GamePausedEvent()),
        expect: () => [
          GameState(
            map: map,
            status: GameStatus.playing,
            inventory: const Inventory.empty(),
          ),
          GameState(
            map: map,
            status: GameStatus.paused,
            inventory: const Inventory.empty(),
          ),
        ],
      );
    });

    group('$GameResumedEvent', () {
      blocTest<GameBloc, GameState>(
        '''does not resume the game when the user was not previously paused''',
        build: () => GameBloc(map: map),
        act: (bloc) => bloc.add(const GameResumedEvent()),
        expect: () => <GameState>[],
      );

      blocTest<GameBloc, GameState>(
        'resumes the game when the user was previously paused',
        build: () => GameBloc(map: map),
        act: (bloc) => bloc
          ..add(const GameInteractedEvent())
          ..add(const GamePausedEvent())
          ..add(const GameResumedEvent()),
        expect: () => [
          GameState(
            map: map,
            status: GameStatus.playing,
            inventory: const Inventory.empty(),
          ),
          GameState(
            map: map,
            status: GameStatus.paused,
            inventory: const Inventory.empty(),
          ),
          GameState(
            map: map,
            status: GameStatus.playing,
            inventory: const Inventory.empty(),
          ),
        ],
      );
    });

    group('$GameResetEvent', () {
      blocTest<GameBloc, GameState>(
        'resets the game',
        build: () => GameBloc(map: map),
        act: (bloc) => bloc
          ..add(const GameInteractedEvent())
          ..add(const GameCollectedTrashEvent(type: TrashType.plastic))
          ..add(const GameResetEvent()),
        expect: () => [
          GameState(
            map: map,
            status: GameStatus.playing,
            inventory: const Inventory.empty(),
          ),
          GameState(
            map: map,
            status: GameStatus.playing,
            inventory: const Inventory(plasticTrash: 1, glassTrash: 0),
          ),
          GameState(
            map: map,
            status: GameStatus.resetting,
            inventory: const Inventory.empty(),
          ),
        ],
      );
    });
  });
}
