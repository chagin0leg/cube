import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart' as vm;

// Размеры параллелепипеда (3:3:1)
const double width = 180, height = 180, depth = 60;

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

class ParallelepipedsPainter extends CustomPainter {
  final List<ParallelepipedState> cubes;
  final double globX, globY, globZ;
  final List<List<ui.Image?>> faceImages;
  ParallelepipedsPainter({
    required this.cubes,
    required this.globX,
    required this.globY,
    required this.globZ,
    required this.faceImages,
  });

  // Центры для трёх параллелепипедов
  final List<vm.Vector3> centers = [
    vm.Vector3(0, 0, 0),
    vm.Vector3(0, 0, 0),
    vm.Vector3(0, 0, 0),
  ];

  // Вершины параллелепипеда (относительно центра)
  List<vm.Vector3> getVertices() => [
    vm.Vector3(-width / 2, -height / 2, -depth / 2),
    vm.Vector3(width / 2, -height / 2, -depth / 2),
    vm.Vector3(width / 2, height / 2, -depth / 2),
    vm.Vector3(-width / 2, height / 2, -depth / 2),
    vm.Vector3(-width / 2, -height / 2, depth / 2),
    vm.Vector3(width / 2, -height / 2, depth / 2),
    vm.Vector3(width / 2, height / 2, depth / 2),
    vm.Vector3(-width / 2, height / 2, depth / 2),
  ];

  final List<List<int>> faces = const [
    [0, 1, 2, 3], // back
    [4, 5, 6, 7], // front
    [0, 1, 5, 4], // top
    [3, 2, 6, 7], // bottom
    [1, 2, 6, 5], // right
    [0, 3, 7, 4], // left
  ];

  bool inSector(double angle, double from, double to) {
    if (from < to) return angle >= from && angle <= to;
    return angle >= from || angle <= to;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final Offset center = Offset(size.width / 2, size.height / 2);
    // Глобальная матрица вращения
    final Matrix4 global =
        Matrix4.identity()
          ..rotateX(vm.radians(globX))
          ..rotateY(vm.radians(globY))
          ..rotateZ(vm.radians(globZ));

    late List<int> order = inSector(globY, 210, 30) ? [0, 1, 2] : [2, 1, 0];

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
      // --- Используем индивидуальные картинки граней ---
      final List<ui.Image?> faceImages = this.faceImages[i];
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
    bool cubesChanged = false;
    for (int i = 0; i < cubes.length; i++) {
      final c = cubes[i];
      final o = oldDelegate.cubes[i];
      if (c.rotateX != o.rotateX ||
          c.rotateY != o.rotateY ||
          c.rotateZ != o.rotateZ ||
          c.moveX != o.moveX ||
          c.moveY != o.moveY ||
          c.moveZ != o.moveZ) {
        cubesChanged = true;
        break;
      }
    }
    return cubesChanged ||
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
