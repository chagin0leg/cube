class Axis {
  static const double _period = 6.0;

  double rotationAngle, rotationSpeed, offset;
  final double _initialRotationAngle, _initialRotationSpeed, _initialOffset;

  Axis({this.rotationAngle = 0, this.rotationSpeed = 0, this.offset = 0})
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
