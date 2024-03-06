import 'package:basura/basura.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trashy_road/gen/assets.gen.dart';
import 'package:trashy_road/src/loading/loading.dart';
import 'package:trashy_road/src/maps/maps.dart';

/// {@template PausePage}
/// A page that displays the pause menu.
/// {@endtemplate}
class PausePage extends StatelessWidget {
  /// {@macro PausePage}
  const PausePage({
    required this.title,
    required this.onResume,
    required this.onReplay,
    super.key,
  });

  static Route<void> route({
    required String title,
    required bool Function() onResume,
    required bool Function() onReplay,
  }) {
    return _PausePageRouteBuilder(
      builder: (context) => PausePage(
        title: title,
        onResume: onResume,
        onReplay: onReplay,
      ),
    );
  }

  /// The title of the pause menu.
  final String title;

  /// {@template PausePage.onResume}
  /// A callback that is called when the game is resumed.
  ///
  /// If it returns `true`, the [PausePage] will be popped.
  /// {@endtemplate}
  final bool Function() onResume;

  /// {@template PausePage.onReplay}
  /// A callback that is called when the game is replayed.
  ///
  /// If it returns `true`, the [PausePage] will be popped.
  /// {@endtemplate}
  final bool Function() onReplay;

  void _onResume(BuildContext context) {
    if (onResume()) {
      Navigator.of(context).pop();
    }
  }

  void _onReplay(BuildContext context) {
    if (onReplay()) {
      Navigator.of(context).pop();
    }
  }

  void _onMenu(BuildContext context) {
    Navigator.of(context).popUntil(
      (route) => route.settings.name == MapsMenuPage.identifier,
    );
  }

  @override
  Widget build(BuildContext context) {
    const spacing = SizedBox(width: 8);
    final screenSize = MediaQuery.sizeOf(context);

    final basuraTheme = BasuraTheme.of(context);
    final textStyle = basuraTheme.textTheme.cardHeading.copyWith(
      letterSpacing: -80,
      fontSize: 100,
    );

    return DefaultTextStyle(
      style: textStyle,
      child: Center(
        child: SizedBox.square(
          dimension:
              (screenSize.shortestSide * 0.5).clamp(300, double.infinity),
          child: _PaperBackground(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    flex: 2,
                    child: Center(
                      child: AutoSizeText(title, style: textStyle),
                    ),
                  ),
                  Flexible(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _ImageIcon(
                          imagePath: Assets.images.menuIcon.path,
                          onPressed: () => _onMenu(context),
                        ),
                        spacing,
                        _ImageIcon(
                          imagePath: Assets.images.playIcon.path,
                          dimension: 80,
                          onPressed: () => _onResume(context),
                        ),
                        spacing,
                        _ImageIcon(
                          imagePath: Assets.images.replayIcon.path,
                          onPressed: () => _onReplay(context),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PaperBackground extends StatelessWidget {
  const _PaperBackground({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final preloadCubit = context.read<PreloadCubit>();
    final image = preloadCubit.imageProviderCache
        .fromCache(Assets.images.paperBackground.path);

    return DecoratedBox(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: image,
          fit: BoxFit.fill,
        ),
      ),
      child: child,
    );
  }
}

class _ImageIcon extends StatelessWidget {
  const _ImageIcon({
    required this.imagePath,
    this.onPressed,
    this.dimension = 50,
  });

  final String imagePath;

  final VoidCallback? onPressed;

  final double dimension;

  @override
  Widget build(BuildContext context) {
    final preloadCubit = context.read<PreloadCubit>();
    final image = preloadCubit.imageProviderCache.fromCache(imagePath);

    return AnimatedHoverBrightness(
      child: GestureDetector(
        onTap: onPressed,
        child: Image(
          image: image,
          width: dimension,
          height: dimension,
          filterQuality: FilterQuality.medium,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}

class _PausePageRouteBuilder<T> extends PageRouteBuilder<T> {
  _PausePageRouteBuilder({
    required WidgetBuilder builder,
    super.settings,
  }) : super(
          opaque: false,
          transitionDuration: const Duration(milliseconds: 500),
          pageBuilder: (context, animation, secondaryAnimation) =>
              builder(context),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final begin = BoxDecoration(
              color: const Color(0xff000000).withOpacity(0),
            );
            final end = BoxDecoration(
              color: const Color(0xff000000).withOpacity(0.4),
            );

            final decorationCurvedAnimation =
                CurvedAnimation(parent: animation, curve: Curves.easeIn);
            final decorationTween = DecorationTween(begin: begin, end: end);
            final decorationAnimate =
                decorationTween.animate(decorationCurvedAnimation);

            final scaleCurvedAnimation =
                CurvedAnimation(parent: animation, curve: Curves.easeIn);
            final scaleTween = Tween<double>(begin: 0.5, end: 1);
            final scaleAnimate = scaleTween.animate(scaleCurvedAnimation);

            final opacityCurve =
                CurvedAnimation(parent: animation, curve: Curves.linear);
            final opacityTween = Tween<double>(begin: 0.2, end: 1);
            final opacityAnimate = opacityTween.animate(opacityCurve);

            return DecoratedBoxTransition(
              decoration: decorationAnimate,
              child: ScaleTransition(
                scale: scaleAnimate,
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 100),
                  opacity: opacityAnimate.value,
                  child: child,
                ),
              ),
            );
          },
        );
}
