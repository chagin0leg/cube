import 'dart:ui' as ui;

import 'package:cube/crop_image_extension.dart';
import 'package:cube/cube_status_text.dart';
import 'package:cube/figure_state.dart';
import 'package:cube/parallelepipeds_painter.dart';
import 'package:cube/theme_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class CubePage extends StatefulWidget {
  const CubePage({super.key});

  @override
  State<CubePage> createState() => _CubePageState();
}

class _CubePageState extends State<CubePage>
    with SingleTickerProviderStateMixin {
  ui.Image? baseImage;
  List<List<ui.Image?>>? faceImages;
  bool imagesLoaded = false;

  double cubeRotationAngleX = 0, cubeRotationAngleY = 0, cubeRotationAngleZ = 0;
  double cubeRotationSpeedX = 0, cubeRotationSpeedY = 0, cubeRotationSpeedZ = 0;

  late final Ticker _ticker;
  late DateTime _lastTick;

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
    final needTicker = hasRotationSpeed();
    if (needTicker && !_ticker.isActive) {
      _ticker.start();
    } else if (!needTicker && _ticker.isActive) {
      _ticker.stop();
    }
  }

  bool hasRotationSpeed() {
    return cubeRotationSpeedX != 0 ||
        cubeRotationSpeedY != 0 ||
        cubeRotationSpeedZ != 0 ||
        edges[0].oZ.rotationSpeed != 0 ||
        edges[1].oZ.rotationSpeed != 0 ||
        edges[2].oZ.rotationSpeed != 0;
  }

  double _normalizeAngle(double angle) {
    angle = angle % 360.0;
    if (angle < 0) angle += 360.0;
    return angle;
  }

  void _onTick(Duration _) {
    const double period = 6.0;
    final now = DateTime.now();
    final dt = now.difference(_lastTick).inMilliseconds / 1000.0;
    _lastTick = now;
    if (hasRotationSpeed()) {
      setState(() {
        cubeRotationAngleX = _normalizeAngle(
          cubeRotationAngleX + cubeRotationSpeedX * dt / period,
        );
        cubeRotationAngleY = _normalizeAngle(
          cubeRotationAngleY + cubeRotationSpeedY * dt / period,
        );
        cubeRotationAngleZ = _normalizeAngle(
          cubeRotationAngleZ + cubeRotationSpeedZ * dt / period,
        );

        edges[0].oZ.calculateRotationAngle(dt);
        edges[1].oZ.calculateRotationAngle(dt);
        edges[2].oZ.calculateRotationAngle(dt);
      });
    } else {
      _updateTicker();
    }
  }

  Future<void> _loadImages() async {
    final wide = await _loadImage('assets/face_wide.drawio.png').crop();
    final narrow = await _loadImage('assets/face_narrow.drawio.png').crop();
    final base = await _loadImage('assets/base.drawio.png');
    final wideInside =
        await _loadImage('assets/face_wide_inside.drawio.png').crop();

    setState(() {
      baseImage = base;
      faceImages = [
        // Для каждого параллелепипеда свой набор граней
        [
          wide, // back
          wideInside, // front
          narrow, // top
          narrow, // bottom
          narrow, // right
          narrow, // left
        ],
        [
          wideInside, // back
          wideInside, // front
          narrow, // top
          narrow, // bottom
          narrow, // right
          narrow, // left
        ],
        [
          wideInside, // back
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

  // Состояния для каждого параллелепипеда
  final List<EdgeState> edges = [
    EdgeState(oZ: AxisState(offset: -depth)), // [Zhuravlev] нижний левый (Z0)
    EdgeState(), // [Zhuravlev] средний (Z1)
    EdgeState(oZ: AxisState(offset: depth)), // [Zhuravlev] верхний правый (Z2)
  ];

  void _reset() {
    setState(() {
      cubeRotationAngleX = 0;
      cubeRotationAngleY = 0;
      cubeRotationAngleZ = 0;
      cubeRotationSpeedX = 0;
      cubeRotationSpeedY = 0;
      cubeRotationSpeedZ = 0;

      edges[0].oZ.offset = -depth;
      edges[1].oZ.offset = 0;
      edges[2].oZ.offset = depth;
      edges[0].oZ.rotationAngle = 0;
      edges[1].oZ.rotationAngle = 0;
      edges[2].oZ.rotationAngle = 0;
      edges[0].oZ.rotationSpeed = 0;
      edges[1].oZ.rotationSpeed = 0;
      edges[2].oZ.rotationSpeed = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsetsGeometry.fromLTRB(48, 16, 16, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [const CubeStatusText(), _resetButton()],
              ),
            ),
            Expanded(
              child:
                  imagesLoaded
                      ? Stack(
                        alignment: Alignment.bottomCenter,
                        children: [
                          RawImage(image: baseImage!, width: 120),
                          Transform.translate(
                            offset: Offset(0, -32),
                            child: RepaintBoundary(
                              child: CustomPaint(
                                size: Size.infinite,
                                painter: EdgesPainter(
                                  edges: edges,
                                  rotationAngleX: cubeRotationAngleX,
                                  rotationAngleY: cubeRotationAngleY,
                                  globZ: cubeRotationAngleZ,
                                  faceImages: faceImages!,
                                ),
                              ),
                            ),
                          ),
                        ],
                      )
                      : Center(child: CircularProgressIndicator()),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 48),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                spacing: 8,
                children: [
                  _buildSlider(cubeRotationSpeedX, (value) {
                    setState(() => cubeRotationSpeedX = value);
                    _updateTicker();
                  }),
                  _buildSlider(cubeRotationSpeedY, (value) {
                    setState(() => cubeRotationSpeedY = value);
                    _updateTicker();
                  }),
                  _buildSlider(cubeRotationSpeedZ, (value) {
                    setState(() => cubeRotationSpeedZ = value);
                    _updateTicker();
                  }),
                  _buildSlider(edges[0].oZ.rotationSpeed, (value) {
                    setState(() => edges[0].oZ.rotationSpeed = value);
                    _updateTicker();
                  }),
                  _buildSlider(edges[1].oZ.rotationSpeed, (value) {
                    setState(() => edges[1].oZ.rotationSpeed = value);
                    _updateTicker();
                  }),
                  _buildSlider(edges[2].oZ.rotationSpeed, (value) {
                    setState(() => edges[2].oZ.rotationSpeed = value);
                    _updateTicker();
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: ThemeButton(),
    );
  }

  Widget _resetButton() {
    return InkWell(onTap: _reset, child: const Icon(Icons.stop_circle_rounded));
  }

  Widget _buildSlider(double value, ValueChanged<double> onChanged) =>
      Slider(value: value, min: -180, max: 180, onChanged: onChanged);
}
