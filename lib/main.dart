import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart' as vm;

void main() => runApp(const MaterialApp(home: ParallelepipedsApp()));

class ParallelepipedsApp extends StatefulWidget {
  const ParallelepipedsApp({super.key});

  @override
  State<ParallelepipedsApp> createState() => _ParallelepipedsAppState();
}

class ParallelepipedState {
  double rotateX;
  double rotateY;
  double rotateZ;
  double moveX;
  double moveY;
  double moveZ;

  ParallelepipedState({
    this.rotateX = 45,
    this.rotateY = 45,
    this.rotateZ = 0,
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
    final wide = await _loadImage('assets/face_wide.drawio.png');
    final narrow = await _loadImage('assets/face_narrow.drawio.png');
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
  double globX = 0;
  double globY = 0;
  double globZ = 0;

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
      cubes[0].moveZ = -60;
      cubes[1].moveZ = 0;
      cubes[2].moveZ = 60;
      cubes[0].rotateZ += 0;
      cubes[1].rotateZ += 0;
      cubes[2].rotateZ += 0;
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
                      imagesLoaded
                          ? CustomPaint(
                            painter: ParallelepipedsPainter(
                              cubes: cubes,
                              globX: globX,
                              globY: globY,
                              globZ: globZ,
                              wideImage: wideImage,
                              narrowImage: narrowImage,
                            ),
                            size: Size.infinite,
                          )
                          : const Center(child: CircularProgressIndicator()),
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

  Widget _buildSlider(
    double value,
    ValueChanged<double> onChanged, {
    double min = -135,
    double max = 35,
  }) => Row(
    children: [
      Expanded(
        child: Slider(
          value: value,
          min: min,
          max: max,
          divisions: (max - min).toInt() ~/ 5,
          onChanged: (v) {
            onChanged(v);
          },
        ),
      ),
      SizedBox(width: 8),
      Text(value.toStringAsFixed(1)),
    ],
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

  // Размеры параллелепипеда (3:3:1)
  static const double w = 180, h = 180, d = 60;

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

    for (int i = 0; i < 3; i++) {
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
