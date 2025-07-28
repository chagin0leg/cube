import 'package:cube/cube_elements/axis.dart';

class Edge {
  static const double _oXRotationAngle = 54.736; // 90 - 35.264
  static const double _oYRotationAngle = 45;

  Axis oX, oY, oZ;

  Edge({Axis? oX, Axis? oY, Axis? oZ})
    : oX = oX ?? Axis(rotationAngle: _oXRotationAngle),
      oY = oY ?? Axis(rotationAngle: _oYRotationAngle),
      oZ = oZ ?? Axis();

  void resetOrientation() {
    oX.resetOrientation();
    oY.resetOrientation();
    oZ.resetOrientation();
  }

  void stopMotion() {
    oX.resetMotion();
    oY.resetMotion();
    oZ.resetMotion();
  }
}
