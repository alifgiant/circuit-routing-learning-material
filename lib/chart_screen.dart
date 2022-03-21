/// Example of a combo scatter plot chart with a second series rendered as a
/// line.
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';
import 'package:simulasi_routing/algo/data.dart';
import 'package:simulasi_routing/algo/model.dart';

class MapChart extends StatelessWidget {
  final bool? animate;
  final Set<Path> paths;

  const MapChart(
    this.paths, {
    this.animate = false,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return charts.ScatterPlotChart(
      _createSampleData(),
      animate: animate,
      // Configure the default renderer as a point renderer. This will be used
      // for any series that does not define a rendererIdKey.
      //
      // This is the default configuration, but is shown here for
      // illustration.
      defaultRenderer: charts.PointRendererConfig(),
      // Custom renderer configuration for the line series.
      customSeriesRenderers: [
        charts.LineRendererConfig(
          // ID used to link series to this renderer.
          customRendererId: 'customLine',
          // Configure the regression line to be painted above the points.
          //
          // By default, series drawn by the point renderer are painted on
          // top of those drawn by a line renderer.
          layoutPaintOrder: charts.LayoutViewPaintOrder.point + 1,
        )
      ],
      behaviors: [
        charts.SeriesLegend(position: charts.BehaviorPosition.end),
      ],
    );
  }

  /// Create one series with sample hard coded data.
  List<charts.Series<Point, int>> _createSampleData() {
    // final allStos = [pnk, mat, bal, ant, sug, tka, mal, tma, kim, sud, mar];
    final allStos = [
      ColoredSto.fromSto(pnk, charts.MaterialPalette.black),
      ColoredSto.fromSto(mat, charts.MaterialPalette.blue.shadeDefault),
      ColoredSto.fromSto(bal, charts.MaterialPalette.cyan.shadeDefault),
      ColoredSto.fromSto(ant, charts.MaterialPalette.deepOrange.shadeDefault),
      ColoredSto.fromSto(sug, charts.MaterialPalette.gray.shadeDefault),
      ColoredSto.fromSto(tka, charts.MaterialPalette.green.shadeDefault),
      ColoredSto.fromSto(mal, charts.MaterialPalette.indigo.shadeDefault),
      ColoredSto.fromSto(tma, charts.MaterialPalette.lime.shadeDefault),
      ColoredSto.fromSto(kim, charts.MaterialPalette.pink.shadeDefault),
      ColoredSto.fromSto(sud, charts.MaterialPalette.purple.shadeDefault),
      ColoredSto.fromSto(mar, charts.MaterialPalette.teal.shadeDefault),
    ];

    return [
      ...allStos
          .map((e) => charts.Series<Point, int>(
                id: e.name,
                colorFn: (Point point, _) => e.color,
                domainFn: (Point point, _) => point.x,
                measureFn: (Point point, _) => point.y,
                radiusPxFn: (Point point, _) => point.radius,
                data: [e.point],
              ))
          .toList(),
      ...paths
          .map(
            (e) => charts.Series<Point, int>(
              id: e.name,
              // colorFn: (_, __) => charts.MaterialPalette.black,
              colorFn: (_, __) => e.isBusy
                  ? charts.MaterialPalette.red.shadeDefault
                  : charts.MaterialPalette.black,
              dashPatternFn: (Point point, _) => [4, 4],
              domainFn: (Point point, _) => point.x,
              measureFn: (Point point, _) => point.y,
              data: [e.start, e.end],
            )..setAttribute(
                // Configure our custom line renderer for this series.
                charts.rendererIdKey,
                'customLine',
              ),
          )
          .toList(),
    ];
  }
}

class ColoredSto extends Sto {
  final charts.Color color;

  ColoredSto(String name, Point point, this.color) : super(name, point);

  factory ColoredSto.fromSto(Sto sto, charts.Color color) {
    return ColoredSto(sto.name, sto.point, color);
  }
}
