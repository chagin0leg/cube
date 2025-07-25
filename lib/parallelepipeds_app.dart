import 'dart:ui' as ui;

import 'package:cube/crop_image_extension.dart';
import 'package:cube/cube_status_text.dart';
import 'package:cube/parallelepipeds_painter.dart';
import 'package:cube/theme/theme_notifier.dart';
import 'package:cube/theme/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class ParallelepipedsApp extends StatefulWidget {
  const ParallelepipedsApp({super.key});

  @override
  State<ParallelepipedsApp> createState() => _ParallelepipedsAppState();
}

class ParallelepipedState {
  double rotateX, rotateY, rotateZ, moveX, moveY, moveZ;
  ParallelepipedState({
    // Углы вращения для изометрической проекции
    this.rotateX = 90 - 35.264, // 30 градусов от горизонтали
    this.rotateY = 45, // 45 градусов от вертикали
    this.rotateZ = 0, // Не требуется вращение вокруг оси Z
    this.moveX = 0,
    this.moveY = 0,
    this.moveZ = 0,
  });
}

class _ParallelepipedsAppState extends State<ParallelepipedsApp>
    with SingleTickerProviderStateMixin {
  ui.Image? baseImageLight;
  ui.Image? baseImageDark;
  List<List<ui.Image?>>? faceImagesLight;
  List<List<ui.Image?>>? faceImagesDark;
  bool imagesLoaded = false;

  double speedGlobY = 0;
  double speedZ1 = 0;
  double speedZ2 = 0;

  late final Ticker _ticker;
  late DateTime _lastTick;
  bool _tickerActive = false;

  @override
  void initState() {
    super.initState();
    _loadImages();
    _reset();
    _lastTick = DateTime.now();
    _ticker = createTicker(_onTick);
    _updateTicker();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  void _updateTicker() {
    final needTicker = speedGlobY != 0 || speedZ1 != 0 || speedZ2 != 0;
    if (needTicker && !_tickerActive) {
      _ticker.start();
      _tickerActive = true;
    } else if (!needTicker && _tickerActive) {
      _ticker.stop();
      _tickerActive = false;
    }
  }

  double _wrap(double angle) {
    angle = angle % 360.0;
    if (angle < 0) angle += 360.0;
    return angle;
  }

  void _onTick(Duration _) {
    final now = DateTime.now();
    final dt = now.difference(_lastTick).inMilliseconds / 1000.0;
    const double per = 6.0;
    _lastTick = now;
    if (speedGlobY != 0 || speedZ1 != 0 || speedZ2 != 0) {
      setState(() {
        globY = _wrap(globY + speedGlobY * dt / per);
        cubes[1].rotateZ = _wrap(cubes[1].rotateZ + speedZ1 * dt / per);
        cubes[2].rotateZ = _wrap(cubes[2].rotateZ + speedZ2 * dt / per);
      });
    } else {
      _updateTicker();
    }
  }

  Future<void> _loadImages() async {
    final wideLight =
        await _loadImage('assets/light/face_wide.drawio.png').crop();
    final narrowLight =
        await _loadImage('assets/light/face_narrow.drawio.png').crop();
    final baseLight = await _loadImage('assets/light/base.drawio.png');
    final wideInsideLight =
        await _loadImage('assets/light/face_wide_inside.drawio.png').crop();

    final wideDark =
        await _loadImage('assets/dark/face_wide.drawio.png').crop();
    final narrowDark =
        await _loadImage('assets/dark/face_narrow.drawio.png').crop();
    final baseDark = await _loadImage('assets/dark/base.drawio.png');
    final wideInsideDark =
        await _loadImage('assets/dark/face_wide_inside.drawio.png').crop();

    setState(() {
      baseImageLight = baseLight;
      faceImagesLight = [
        // Для каждого параллелепипеда свой набор граней
        [
          wideLight, // back
          wideInsideLight, // front
          narrowLight, // top
          narrowLight, // bottom
          narrowLight, // right
          narrowLight, // left
        ],
        [
          wideInsideLight, // back
          wideInsideLight, // front
          narrowLight, // top
          narrowLight, // bottom
          narrowLight, // right
          narrowLight, // left
        ],
        [
          wideInsideLight, // back
          wideLight, // front
          narrowLight, // top
          narrowLight, // bottom
          narrowLight, // right
          narrowLight, // left
        ],
      ];

      baseImageDark = baseDark;
      faceImagesDark = [
        // Для каждого параллелепипеда свой набор граней
        [
          wideDark, // back
          wideInsideDark, // front
          narrowDark, // top
          narrowDark, // bottom
          narrowDark, // right
          narrowDark, // left
        ],
        [
          wideInsideDark, // back
          wideInsideDark, // front
          narrowDark, // top
          narrowDark, // bottom
          narrowDark, // right
          narrowDark, // left
        ],
        [
          wideInsideDark, // back
          wideDark, // front
          narrowDark, // top
          narrowDark, // bottom
          narrowDark, // right
          narrowDark, // left
        ],
      ];

      imagesLoaded = true;
    });
  }

  Future<ui.Image> _loadImage(String asset) async {
    final data = await DefaultAssetBundle.of(context).load(asset);
    final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
    final frame = await codec.getNextFrame();
    return frame.image;
  }

  // Глобальное вращение (XYZ)
  double globX = 0, globY = 0, globZ = 0;

  // Состояния для каждого параллелепипеда
  final List<ParallelepipedState> cubes = [
    ParallelepipedState(),
    ParallelepipedState(),
    ParallelepipedState(),
  ];

  void _reset() {
    setState(() {
      globX = 0;
      globY = 0;
      globZ = 0;
      cubes[0].moveZ = -d;
      cubes[1].moveZ = 0;
      cubes[2].moveZ = d;
      cubes[0].rotateZ = 0;
      cubes[1].rotateZ = 0;
      cubes[2].rotateZ = 0;
      speedGlobY = 0;
      speedZ1 = 0;
      speedZ2 = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final double vGlobY = speedGlobY;
    final double vZ1 = speedZ1;
    final double vZ2 = speedZ2;

    ThemeNotifier notifier = ThemeProvider.of(context);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  !imagesLoaded
                      ? const Center(child: CircularProgressIndicator())
                      : RawImage(
                        image:
                            notifier.mode == ThemeMode.light
                                ? baseImageLight
                                : baseImageDark,
                        width: 120,
                      ),
                  Center(
                    child:
                        !imagesLoaded
                            ? const Center(child: CircularProgressIndicator())
                            : RepaintBoundary(
                              key: ValueKey(notifier.mode),
                              child: CustomPaint(
                                size: Size.infinite,
                                painter: ParallelepipedsPainter(
                                  cubes: cubes,
                                  globX: globX,
                                  globY: globY,
                                  globZ: globZ,
                                  faceImagesList:
                                      notifier.mode == ThemeMode.light
                                          ? faceImagesLight!
                                          : faceImagesDark!,
                                ),
                              ),
                            ),
                  ),
                  Positioned(top: 16, right: 16, child: _resetButton()),
                  Positioned(top: 16, left: 48, child: const CubeStatusText()),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 48),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                spacing: 8,
                children: [
                  _buildSlider(vGlobY, (v) {
                    setState(() => speedGlobY = v);
                    _updateTicker();
                  }),
                  _buildSlider(vZ1, (v) {
                    setState(() => speedZ1 = v);
                    _updateTicker();
                  }),
                  _buildSlider(vZ2, (v) {
                    setState(() => speedZ2 = v);
                    _updateTicker();
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _themeButton(),
    );
  }

  Widget _resetButton() {
    return InkWell(onTap: _reset, child: const Icon(Icons.stop_circle_rounded));
  }

  Widget _buildSlider(double value, ValueChanged<double> onChanged) =>
      Slider(value: value, min: -180, max: 180, onChanged: onChanged);

  Widget _themeButton() {
    return InkWell(
      onTap: () {
        ThemeNotifier notifier = ThemeProvider.of(context);

        if (notifier.mode == ThemeMode.light) {
          notifier.setMode(ThemeMode.dark);
        } else {
          notifier.setMode(ThemeMode.light);
        }
      },
      child: const Icon(Icons.brightness_6_outlined),
    );
  }
}
