import 'dart:ui' as ui;

import 'package:cube/crop_image_extension.dart';
import 'package:cube/cube_status_text.dart';
import 'package:cube/parallelepipeds_painter.dart';
import 'package:cube/theme/app_colors.dart';
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
  ui.Image? baseImage;
  List<List<ui.Image?>>? faceImagesList;
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
    final wide = await _loadImage('assets/face_wide.drawio.png').crop();
    final narrow = await _loadImage('assets/face_narrow.drawio.png').crop();
    final base = await _loadImage('assets/base.drawio.png');
    final wide_inside =
        await _loadImage('assets/face_wide_inside.drawio.png').crop();
    setState(() {
      baseImage = base;
      faceImagesList = // Для каждого параллелепипеда свой набор граней
          [
        [
          wide, // back
          wide_inside, // front
          narrow, // top
          narrow, // bottom
          narrow, // right
          narrow, // left
        ],
        [
          wide_inside, // back
          wide_inside, // front
          narrow, // top
          narrow, // bottom
          narrow, // right
          narrow, // left
        ],
        [
          wide_inside, // back
          wide, // front
          narrow, // top
          narrow, // bottom
          narrow, // right
          narrow, // left
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
                      : RawImage(image: baseImage!, width: 120),
                  Center(
                    child:
                        !imagesLoaded
                            ? const Center(child: CircularProgressIndicator())
                            : RepaintBoundary(
                              child: CustomPaint(
                                size: Size.infinite,
                                painter: ParallelepipedsPainter(
                                  cubes: cubes,
                                  globX: globX,
                                  globY: globY,
                                  globZ: globZ,
                                  faceImagesList: faceImagesList!,
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
    );
  }

  Widget _resetButton() {
    return InkWell(
      onTap: _reset,
      child: const Icon(
        Icons.stop_circle_rounded,
        size: 48,
        color: AppColors.grey,
      ),
    );
  }

  Widget _buildSlider(double value, ValueChanged<double> onChanged) =>
      SliderTheme(
        data: SliderTheme.of(context).copyWith(
          trackHeight: 2,
          activeTrackColor: AppColors.grey,
          inactiveTrackColor: AppColors.lightGrey,
          thumbColor: AppColors.grey,
          overlayColor: AppColors.lightGrey.withValues(alpha: 0x00),
          thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 14),
          overlayShape: const RoundSliderOverlayShape(overlayRadius: 20),
          tickMarkShape: SliderTickMarkShape.noTickMark,
          valueIndicatorShape: SliderComponentShape.noOverlay,
          showValueIndicator: ShowValueIndicator.never,
          trackShape: const RoundedRectSliderTrackShape(),
        ),
        child: Slider(value: value, min: -180, max: 180, onChanged: onChanged),
      );
}
