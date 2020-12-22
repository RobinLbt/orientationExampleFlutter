import 'dart:math' as math;
import 'package:vector_math/vector_math_64.dart' as vect;

List<double> getOrientation(List<double> r) {
  List<double> result = List<double>(3);
  if (r.length == 9) {
    result[0] = math.atan2(r[1], r[4]);
    result[1] = math.asin(-r[7]);
    result[2] = math.atan2(-r[6], r[8]);
  } else {
    result[0] = math.atan2(r[1], r[5]);
    result[1] = math.asin(-r[9]);
    result[2] = math.atan2(-r[8], r[10]);
  }
  return result;
}

List<double> getRotationMatrix(vect.Vector3 gravity, vect.Vector3 geomagnetic) {
  List<double> result = List<double>(9);
  double ax = gravity[0];
  double ay = gravity[1];
  double az = gravity[2];
  final double ex = geomagnetic[0];
  final double ey = geomagnetic[1];
  final double ez = geomagnetic[2];
  double hx = ey * az - ez * ay;
  double hy = ez * ax - ex * az;
  double hz = ex * ay - ey * ax;
  final double normH = math.sqrt(hx * hx + hy * hy + hz * hz);
  if (normH < 0.1) {
    return null;
  }
  final double invH = 1.0 / normH;
  hx *= invH;
  hy *= invH;
  hz *= invH;
  final double invA = 1.0 / math.sqrt(ax * ax + ay * ay + az * az);
  ax *= invA;
  ay *= invA;
  az *= invA;
  final double mx = ay * hz - az * hy;
  final double my = az * hx - ax * hz;
  final double mz = ax * hy - ay * hx;
  result[0] = hx;
  result[1] = hy;
  result[2] = hz;
  result[3] = mx;
  result[4] = my;
  result[5] = mz;
  result[6] = ax;
  result[7] = ay;
  result[8] = az;

  return result;
}
