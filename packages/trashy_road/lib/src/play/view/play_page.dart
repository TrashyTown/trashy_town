// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

import 'package:basura/basura.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:trashy_road/gen/assets.gen.dart';
import 'package:trashy_road/l10n/l10n.dart';
import 'package:trashy_road/src/maps/maps.dart';

class PlayPage extends StatelessWidget {
  const PlayPage({super.key});

  /// The identifier for the route.
  static String identifier = 'play';

  static Route<void> route() {
    return BasuraBlackEaseInOut<void>(
      settings: RouteSettings(name: identifier),
      builder: (_) => const PlayPage(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xff5F97C4),
            Color(0xff64A5CC),
          ],
        ),
      ),
      child: Stack(
        children: [
          Align(
            alignment: const Alignment(0, -0.85),
            child: SizedBox.square(
              dimension: size.shortestSide / 1.6,
              child: AspectRatio(
                aspectRatio: 776 / 458,
                child: Image.asset(
                  Assets.images.display.logo.path,
                  fit: BoxFit.contain,
                  alignment: Alignment.topCenter,
                ),
              ),
            ),
          ),
          Positioned.fill(
            top: null,
            child: Transform.translate(
              offset: Offset(
                0,
                size.width > size.height
                    ? (size.width - size.height) / ((1920 / 732) * 2)
                    : 0,
              ),
              child: Image.asset(
                Assets.images.display.playBackgroundHouses.path,
                fit: BoxFit.cover,
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomLeft,
            child: SizedBox.fromSize(
              size: const Size(236, 277),
              child: Image.asset(
                Assets.images.display.playerStill.path,
                fit: BoxFit.none,
              ),
            ),
          ),
          const Align(
            alignment: Alignment(0, 0.2),
            child: SizedBox(
              width: 150,
              height: 150,
              child: _PlayButton(),
            ),
          ),
          if (kIsWeb)
            const Align(
              alignment: Alignment(0, 0.8),
              child: SizedBox(
                width: 150,
                height: 150,
                child: _GitHubLink(),
              ),
            ),
        ],
      ),
    );
  }
}

class _GitHubLink extends StatelessWidget {
  const _GitHubLink();

  static const _repositoryUrl = 'https://github.com/alestiago/trashy_town';

  void _onTap() {
    html.window.open(_repositoryUrl, 'new tab');
  }

  @override
  Widget build(BuildContext context) {
    final theme = BasuraTheme.of(context);
    final l10n = context.l10n;
    return AnimatedHoverBrightness(
      child: GestureDetector(
        onTap: _onTap,
        child: _PaperBackground(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: DefaultTextStyle(
              style: theme.textTheme.gitHubLink,
              child: AutoSizeText(
                l10n.checkOutTheCode,
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PlayButton extends StatelessWidget {
  const _PlayButton();

  Future<void> _onPlay(BuildContext context) async {
    final navigator = Navigator.of(context);
    await navigator.push(MapsMenuPage.route());
  }

  @override
  Widget build(BuildContext context) {
    return _PaperBackground(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: _ImageIcon(
          image: Assets.images.display.playIcon.provider(),
          onPressed: () => _onPlay(context),
        ),
      ),
    );
  }
}

class _PaperBackground extends StatelessWidget {
  const _PaperBackground({
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: Assets.images.display.paperBackgroundSquare.provider(),
          fit: BoxFit.fill,
        ),
      ),
      child: child,
    );
  }
}

class _ImageIcon extends StatelessWidget {
  const _ImageIcon({
    required this.image,
    this.onPressed,
  });

  final ImageProvider image;

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    const dimension = 50.0;
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
