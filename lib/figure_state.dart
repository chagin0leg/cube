class EdgeState {
  AxisState oX, oY, oZ;

  EdgeState({AxisState? oX, AxisState? oY, AxisState? oZ})
    : oX = oX ?? AxisState(rotationAngle: 90 - 35.264),
      oY = oY ?? AxisState(rotationAngle: 45),
      oZ = oZ ?? AxisState();
}

class AxisState {
  static const double _period = 6.0;

  double rotationAngle;
  double rotationSpeed;
  double offset;

  AxisState({this.rotationAngle = 0, this.rotationSpeed = 0, this.offset = 0});

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
