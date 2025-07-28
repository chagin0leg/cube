import 'package:cube/cube_elements/axis.dart';
import 'package:cube/cube_elements/edge.dart';

class Cube {
  // Размеры параллелепипеда (3:3:1)
  static const double width = 180, height = 180, depth = 60;

  Axis oX, oY, oZ;
  Edge edgeBottom, edgeMedium, edgeTop;

  Cube({
    Axis? oX,
    Axis? oY,
    Axis? oZ,
    Edge? edgeBottom,
    Edge? edgeMedium,
    Edge? edgeTop,
  }) : oX = oX ?? Axis(),
       oY = oY ?? Axis(),
       oZ = oZ ?? Axis(),
       edgeBottom = edgeBottom ?? Edge(oZ: Axis(offset: -depth)),
       edgeMedium = edgeMedium ?? Edge(),
       edgeTop = edgeTop ?? Edge(oZ: Axis(offset: depth));

  bool isMotionless() {
    return oX.rotationSpeed == 0 &&
        oY.rotationSpeed == 0 &&
        oZ.rotationSpeed == 0 &&
        edgeBottom.oX.rotationSpeed == 0 &&
        edgeBottom.oY.rotationSpeed == 0 &&
        edgeBottom.oZ.rotationSpeed == 0 &&
        edgeMedium.oX.rotationSpeed == 0 &&
        edgeMedium.oY.rotationSpeed == 0 &&
        edgeMedium.oZ.rotationSpeed == 0 &&
        edgeTop.oX.rotationSpeed == 0 &&
        edgeTop.oY.rotationSpeed == 0 &&
        edgeTop.oZ.rotationSpeed == 0;
  }

  void resetOrientation() {
    oX.resetOrientation();
    oY.resetOrientation();
    oZ.resetOrientation();

    edgeBottom.resetOrientation();
    edgeMedium.resetOrientation();
    edgeTop.resetOrientation();
  }

  void stopMotion() {
    oX.resetMotion();
    oY.resetMotion();
    oZ.resetMotion();

    edgeBottom.stopMotion();
    edgeMedium.stopMotion();
    edgeTop.stopMotion();
  }
}
