// TODO: вынести в константы углы

const double _oXRotationAngle = 54.736; // 90 - 35.264
const double _oYRotationAngle = 45;

class CubeState {
  // Размеры параллелепипеда (3:3:1)
  static const double width = 180, height = 180, depth = 60;

  AxisState oX, oY, oZ;
  EdgeState edgeBottom, edgeMedium, edgeTop;

  CubeState({
    AxisState? oX,
    AxisState? oY,
    AxisState? oZ,
    EdgeState? edgeBottom,
    EdgeState? edgeMedium,
    EdgeState? edgeTop,
  }) : oX = oX ?? AxisState(),
       oY = oY ?? AxisState(),
       oZ = oZ ?? AxisState(),
       edgeBottom = edgeBottom ?? EdgeState(oZ: AxisState(offset: -depth)),
       edgeMedium = edgeMedium ?? EdgeState(),
       edgeTop = edgeTop ?? EdgeState(oZ: AxisState(offset: depth));

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

class EdgeState {
  AxisState oX, oY, oZ;

  EdgeState({AxisState? oX, AxisState? oY, AxisState? oZ})
    : oX = oX ?? AxisState(rotationAngle: _oXRotationAngle),
      oY = oY ?? AxisState(rotationAngle: _oYRotationAngle),
      oZ = oZ ?? AxisState();

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

class AxisState {
  static const double _period = 6.0;

  double rotationAngle, rotationSpeed, offset;
  final double _initialRotationAngle, _initialRotationSpeed, _initialOffset;

  AxisState({this.rotationAngle = 0, this.rotationSpeed = 0, this.offset = 0})
    : _initialRotationAngle = rotationAngle,
      _initialRotationSpeed = rotationSpeed,
      _initialOffset = offset;

  void resetOrientation() {
    rotationAngle = _initialRotationAngle;
    offset = _initialOffset;
  }

  void resetMotion() {
    rotationSpeed = _initialRotationSpeed;
  }

  void calculateRotationAngle(double dt) {
    rotationAngle = _calculateAngle(rotationAngle, rotationSpeed, dt);
  }

  double _calculateAngle(double angle, speed, dt) {
    double result;

    result = angle + speed * dt / _period;
    result = _normalizeAngle(result);

    return result;
  }

  double _normalizeAngle(double angle) {
    angle = angle % 360.0;
    if (angle < 0) angle += 360.0;

    return angle;
  }
}
