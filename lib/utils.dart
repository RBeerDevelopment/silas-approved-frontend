import 'dart:math' as math;

double calcDistance(lat1, lng1, lat2, lng2) {
  const R = 6371e3;
  double phi1 = lat1 * math.pi / 180;
  double phi2 = lat2 * math.pi / 180;

  double deltaPhi = (lat2 - lat1) * math.pi / 180;
  double deltaLambda = (lng2 - lng1) * math.pi / 180;

  double a = math.sin(deltaPhi / 2) * math.sin(deltaPhi / 2) +
      math.cos(phi1) *
          math.cos(phi2) *
          math.sin(deltaLambda / 2) *
          math.sin(deltaLambda / 2);
  double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));

  return (R * c);
}
