import 'dart:ui' as ui;

import 'package:cube/crop_image_extension.dart';
import 'package:cube/cube_elements/cube.dart';
import 'package:cube/cube_status_text.dart';
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

  Cube cube = Cube();

  late final Ticker _ticker;
  late DateTime _lastTick;

  @override
  void initState() {
    super.initState();
    _loadImages();
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
    final needTicker = !cube.isMotionless();
    if (needTicker && !_ticker.isActive) {
      _ticker.start();
    } else if (!needTicker && _ticker.isActive) {
      _ticker.stop();
    }
  }

  void _onTick(Duration _) {
    final now = DateTime.now();
    final dt = now.difference(_lastTick).inMilliseconds / 1000.0;
    _lastTick = now;

    if (!cube.isMotionless()) {
      setState(() {
        cube.oX.calculateRotationAngle(dt);
        cube.oY.calculateRotationAngle(dt);
        cube.oZ.calculateRotationAngle(dt);

        cube.edgeBottom.oZ.calculateRotationAngle(dt);
        cube.edgeMedium.oZ.calculateRotationAngle(dt);
        cube.edgeTop.oZ.calculateRotationAngle(dt);
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
                                  edges: [
                                    cube.edgeBottom,
                                    cube.edgeMedium,
                                    cube.edgeTop,
                                  ],
                                  rotationAngleX: cube.oX.rotationAngle,
                                  rotationAngleY: cube.oY.rotationAngle,
                                  rotationAngleZ: cube.oZ.rotationAngle,
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
                  _buildSlider(cube.oX.rotationSpeed, (value) {
                    setState(() => cube.oX.rotationSpeed = value);
                    _updateTicker();
                  }),
                  _buildSlider(cube.oY.rotationSpeed, (value) {
                    setState(() => cube.oY.rotationSpeed = value);
                    _updateTicker();
                  }),
                  _buildSlider(cube.oZ.rotationSpeed, (value) {
                    setState(() => cube.oZ.rotationSpeed = value);
                    _updateTicker();
                  }),
                  _buildSlider(cube.edgeBottom.oZ.rotationSpeed, (value) {
                    setState(() => cube.edgeBottom.oZ.rotationSpeed = value);
                    _updateTicker();
                  }),
                  _buildSlider(cube.edgeMedium.oZ.rotationSpeed, (value) {
                    setState(() => cube.edgeMedium.oZ.rotationSpeed = value);
                    _updateTicker();
                  }),
                  _buildSlider(cube.edgeTop.oZ.rotationSpeed, (value) {
                    setState(() => cube.edgeTop.oZ.rotationSpeed = value);
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
    return InkWell(
      onTap: () {
        setState(() {
          cube.resetOrientation();
          cube.stopMotion();
        });
      },
      child: const Icon(Icons.stop_circle_rounded),
    );
  }

  Widget _buildSlider(double value, ValueChanged<double> onChanged) =>
      Slider(value: value, min: -180, max: 180, onChanged: onChanged);
}
