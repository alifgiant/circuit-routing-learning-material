import 'dart:math';

import 'package:simulasi_routing/algo/data.dart';
import 'package:simulasi_routing/algo/model.dart';

class Route {
  final List<String> stos;

  Route(this.stos);
}

class CandidateRoute extends Route {
  final String next;

  CandidateRoute(List<String> stos, this.next) : super(stos);
}

class MeasuredRoute extends Route {
  final double distance;

  MeasuredRoute(List<String> stos, this.distance) : super(stos);

  @override
  String toString() {
    return '${stos.toString()}=$distance';
  }
}

class RoutingTable {
  Set<String> directLine = {};
  Set<MeasuredRoute> routes = {};

  List<MeasuredRoute> filteredRouteTo(
    String destination,
  ) {
    return routes.where((element) => element.stos.last == destination).toList();
  }
}

double _euclidDistance(Point a, Point b) {
  final xSquare = a.x - b.x;
  final ySquare = a.y - b.y;
  return sqrt(pow(xSquare, 2) + pow(ySquare, 2));
}

double _calculateDistance(List<String> stoNames) {
  if (stoNames.length < 2) return 0;
  int a = 0;
  int b = 1;
  double distance = 0;
  while (b < stoNames.length) {
    final stoA = stoNameMap[stoNames[a]]!;
    final stoB = stoNameMap[stoNames[b]]!;
    distance = _euclidDistance(stoA.point, stoB.point);
    a += 1;
    b += 1;
  }
  return distance;
}

Map<String, RoutingTable> createRoutingInformation() {
  Map<String, RoutingTable> routingInfo = {};

  final allStos = stoNameMap.values;

  // create empty tables
  for (Sto sto in allStos) {
    routingInfo[sto.name] = RoutingTable();
  }

  // setup direct line
  for (Path path in connections) {
    // point A
    routingInfo[path.from.name]!.directLine.add(path.to.name);

    // point B
    routingInfo[path.to.name]!.directLine.add(path.from.name);
  }

  // setup all route
  for (String stoKey in routingInfo.keys) {
    final routeTable = routingInfo[stoKey];

    // get all first candidate route from direct line
    final candidateRoute = routingInfo[stoKey]!
        .directLine
        .map((e) => CandidateRoute([stoKey], e))
        .toSet();

    // iterate all candidate route to get valid route
    while (candidateRoute.isNotEmpty) {
      final inspectee = candidateRoute.first;
      candidateRoute.remove(inspectee);

      // if candidate route valid, add it to routing table route
      if (!inspectee.stos.contains(inspectee.next)) {
        final validSto = [...inspectee.stos, inspectee.next];
        final totalDistance = _calculateDistance(validSto);
        routeTable!.routes.add(MeasuredRoute(validSto, totalDistance));

        // refill candidate route by next direct line
        final nextStoTableInfo = routingInfo[inspectee.next];
        for (var element in nextStoTableInfo!.directLine) {
          candidateRoute.add(CandidateRoute(validSto, element));
        }
      }
    }
  }

  return routingInfo;
}
