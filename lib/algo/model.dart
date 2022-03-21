import 'dart:math';

final randomize = Random();

class Path {
  final Sto from, to;
  bool isBusy;

  Path(this.from, this.to) : isBusy = randomize.nextBool();

  String get name => '${from.name}-${to.name}';
  Point get start => from.point;
  Point get end => to.point;

  bool isSamePath(String start, String end) {
    return (start == from.name && end == to.name) ||
        (end == from.name && start == to.name);
  }
}

class Point {
  final int x;
  final int y;
  final double radius;

  const Point(this.x, this.y, this.radius);
}

class Sto {
  final String name;
  final Point point;

  Sto(this.name, this.point);
}
