import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart' as vm;
import 'dart:typed_data';
import 'dart:async';

// Размеры параллелепипеда (3:3:1)
const double w = 180, h = 180, d = 60;
void main() => runApp(
  MaterialApp(
    home: ParallelepipedsApp(),
    debugShowCheckedModeBanner: false,
    theme: ThemeData(scaffoldBackgroundColor: Color(0xFFEAEAEA)),
  ),
);

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

class _ParallelepipedsAppState extends State<ParallelepipedsApp> {
  ui.Image? wideImage;
  ui.Image? narrowImage;
  bool imagesLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadImages();
    _reset();
  }

  Future<void> _loadImages() async {
    final wide = await _loadImage('assets/face_wide.drawio.png').crop();
    final narrow = await _loadImage('assets/face_narrow.drawio.png').crop();
    setState(() {
      wideImage = wide;
      narrowImage = narrow;
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
      cubes[1].rotateZ = -53;
      cubes[2].rotateZ = -21;
    });
  }

  @override
  Widget build(BuildContext context) {
    final z0 = cubes[0].rotateZ;
    final z1 = cubes[1].rotateZ;
    final z2 = cubes[2].rotateZ;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: AspectRatio(
                  aspectRatio: 1,
                  child:
                      !imagesLoaded
                          ? const Center(child: CircularProgressIndicator())
                          : CustomPaint(
                            painter: ParallelepipedsPainter(
                              cubes: cubes,
                              globX: globX,
                              globY: globY,
                              globZ: globZ,
                              wideImage: wideImage,
                              narrowImage: narrowImage,
                            ),
                            size: Size.infinite,
                          ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                spacing: 8,
                children: [
                  // _buildSlider(globX, (v) => setState(() => globX = v)),
                  _buildSlider(globY, (v) => setState(() => globY = v)),
                  // _buildSlider(globZ, (v) => setState(() => globZ = v)),
                  // _buildSlider(z0, (v) => setState(() => cubes[0].rotateZ = v)),
                  _buildSlider(z1, (v) => setState(() => cubes[1].rotateZ = v)),
                  _buildSlider(z2, (v) => setState(() => cubes[2].rotateZ = v)),
                  ElevatedButton(onPressed: _reset, child: const Text('Сброс')),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSlider(double value, ValueChanged<double> onChanged) =>
      SliderTheme(
        data: SliderTheme.of(context).copyWith(
          trackHeight: 4,
          activeTrackColor: const Color(0xFF757575),
          inactiveTrackColor: const Color(0xFFBABABA),
          thumbColor: const Color(0xFF757575),
          overlayColor: const Color(0x00BABABA),
          thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 14),
          overlayShape: const RoundSliderOverlayShape(overlayRadius: 20),
          tickMarkShape: SliderTickMarkShape.noTickMark,
          valueIndicatorShape: SliderComponentShape.noOverlay,
          showValueIndicator: ShowValueIndicator.never,
          // Убираем лишние отступы
          trackShape: const RoundedRectSliderTrackShape(),
        ),
        child: Slider(value: value, min: -180, max: 180, onChanged: onChanged),
      );
}

class ParallelepipedsPainter extends CustomPainter {
  final List<ParallelepipedState> cubes;
  final double globX, globY, globZ;
  final ui.Image? wideImage;
  final ui.Image? narrowImage;
  ParallelepipedsPainter({
    required this.cubes,
    required this.globX,
    required this.globY,
    required this.globZ,
    required this.wideImage,
    required this.narrowImage,
  });

  // Центры для трёх параллелепипедов
  final List<vm.Vector3> centers = [
    vm.Vector3(0, 0, 0),
    vm.Vector3(0, 0, 0),
    vm.Vector3(0, 0, 0),
  ];

  // Вершины параллелепипеда (относительно центра)
  List<vm.Vector3> getVertices() => [
    vm.Vector3(-w / 2, -h / 2, -d / 2),
    vm.Vector3(w / 2, -h / 2, -d / 2),
    vm.Vector3(w / 2, h / 2, -d / 2),
    vm.Vector3(-w / 2, h / 2, -d / 2),
    vm.Vector3(-w / 2, -h / 2, d / 2),
    vm.Vector3(w / 2, -h / 2, d / 2),
    vm.Vector3(w / 2, h / 2, d / 2),
    vm.Vector3(-w / 2, h / 2, d / 2),
  ];

  final List<List<int>> faces = const [
    [0, 1, 2, 3], // back
    [4, 5, 6, 7], // front
    [0, 1, 5, 4], // top
    [3, 2, 6, 7], // bottom
    [1, 2, 6, 5], // right
    [0, 3, 7, 4], // left
  ];

  // 6 картинок для каждой грани (пока wide/narrow, потом можно разные)
  List<ui.Image?> get faceImages => [
    wideImage, // back [0,1,2,3]
    wideImage, // front [4,5,6,7]
    narrowImage, // top [0,1,5,4]
    narrowImage, // bottom [3,2,6,7]
    narrowImage, // right [1,2,6,5]
    narrowImage, // left [0,3,7,4]
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final Offset center = Offset(size.width / 2, size.height / 2);
    // Глобальная матрица вращения
    final Matrix4 global =
        Matrix4.identity()
          ..rotateX(vm.radians(globX))
          ..rotateY(vm.radians(globY))
          ..rotateZ(vm.radians(globZ));

    late List<int> order =
        (globY >= -150 && globY <= 30) ? [0, 1, 2] : [2, 1, 0];

    for (int i in order) {
      final ParallelepipedState state = cubes[i];
      // Локальная матрица: вращение и сдвиг вдоль своей оси (Z)
      final Matrix4 local =
          Matrix4.identity()
            ..rotateX(vm.radians(state.rotateX))
            ..rotateY(vm.radians(state.rotateY))
            ..rotateZ(vm.radians(state.rotateZ))
            ..translate(state.moveX, state.moveY, state.moveZ);
      // Центр параллелепипеда
      final Matrix4 model =
          Matrix4.identity()
            ..translate(centers[i].x, centers[i].y, centers[i].z);
      // Итоговая матрица: global * model * local
      final Matrix4 transform = global * model * local;
      // Трансформируем вершины
      final verts = getVertices().map((v) => transform.transform3(v)).toList();
      final projected = verts.map((v) => _project(v, center)).toList();
      // Painter: painter's algorithm (по глубине)
      final List<_FaceDepth> faceDepths = [
        for (int f = 0; f < faces.length; f++)
          _FaceDepth(
            f,
            faces[f].map((idx) => verts[idx].z).reduce((a, b) => a + b) / 4,
          ),
      ];
      faceDepths.sort((a, b) => a.depth.compareTo(b.depth));
      for (final fd in faceDepths) {
        final path =
            Path()..moveTo(
              projected[faces[fd.index][0]].dx,
              projected[faces[fd.index][0]].dy,
            );
        for (int j = 1; j < 4; j++) {
          path.lineTo(
            projected[faces[fd.index][j]].dx,
            projected[faces[fd.index][j]].dy,
          );
        }
        path.close();
        // Картинка для этой грани
        final ui.Image? img = faceImages[fd.index];
        final idxs = faces[fd.index];
        if (img != null) {
          // Точки на экране (в порядке обхода)
          final List<Offset> dst = [
            projected[idxs[0]],
            projected[idxs[1]],
            projected[idxs[2]],
            projected[idxs[3]],
          ];
          // Точки в текстуре (в том же порядке)
          final List<Offset> im = [
            Offset(0, 0),
            Offset(img.width.toDouble(), 0),
            Offset(img.width.toDouble(), img.height.toDouble()),
            Offset(0, img.height.toDouble()),
          ];
          // Два треугольника: 0-1-2, 0-2-3
          final vertices = ui.Vertices(
            ui.VertexMode.triangles,
            [dst[0], dst[1], dst[2], dst[0], dst[2], dst[3]],
            textureCoordinates: [im[0], im[1], im[2], im[0], im[2], im[3]],
          );
          final paint =
              Paint()
                ..shader = ImageShader(
                  img,
                  TileMode.clamp,
                  TileMode.clamp,
                  Matrix4.identity().storage,
                );
          canvas.drawVertices(vertices, BlendMode.modulate, paint);
        }
      }
    }
  }

  Offset _project(vm.Vector3 v, Offset center) {
    // Простая ортогональная проекция (можно добавить перспективу)
    return Offset(center.dx + v.x, center.dy + v.y);
  }

  @override
  bool shouldRepaint(covariant ParallelepipedsPainter oldDelegate) {
    return cubes != oldDelegate.cubes ||
        globX != oldDelegate.globX ||
        globY != oldDelegate.globY ||
        globZ != oldDelegate.globZ;
  }
}

class _FaceDepth {
  final int index;
  final double depth;
  _FaceDepth(this.index, this.depth);
}

extension FutureCropImageExtension on Future<ui.Image> {
  Future<ui.Image> crop() async {
    final image = await this;
    final byteData = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
    if (byteData == null) return image;

    final Uint8List pixels = byteData.buffer.asUint8List();
    final int width = image.width, height = image.height;

    int top = height, bottom = 0, left = width, right = 0;
    bool hasOpaque = false;

    for (int y = 0; y < height; y++) {
      bool rowHasOpaque = false;
      final int rowStart = y * width * 4;

      for (int x = 0; x < width; x++) {
        final int index = rowStart + (x << 2) + 3;
        if (pixels[index] != 0) {
          rowHasOpaque = hasOpaque = true;
          if (x < left) left = x;
          if (x > right) right = x;
        }
      }

      if (rowHasOpaque) {
        if (y < top) top = y;
        bottom = y;
      }
    }

    if (!hasOpaque) return image;

    final int newWidth = right - left + 1;
    final int newHeight = bottom - top + 1;
    if (newWidth <= 0 || newHeight <= 0) return image;

    final Uint8List newPixels = Uint8List(newWidth * newHeight * 4);
    for (int y = 0; y < newHeight; y++) {
      final int srcStart = ((y + top) * width + left) * 4;
      final int dstStart = y * newWidth * 4;
      newPixels.setRange(dstStart, dstStart + newWidth * 4, pixels, srcStart);
    }

    return _decodeImage(newPixels, newWidth, newHeight);
  }

  Future<ui.Image> _decodeImage(Uint8List px, int w, int h) {
    final c = Completer<ui.Image>();
    ui.decodeImageFromPixels(px, w, h, ui.PixelFormat.rgba8888, c.complete);
    return c.future;
  }
}
