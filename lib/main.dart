import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:simulasi_routing/algo/data.dart';
import 'package:simulasi_routing/algo/model.dart';
import 'package:simulasi_routing/algo/routing_table.dart' as algo;
import 'package:simulasi_routing/chart_screen.dart';
import 'package:simulasi_routing/route_modifier.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const MyHomePage(title: 'Simulasi AHR & DNHR'),
      debugShowCheckedModeBanner: false,
      builder: EasyLoading.init(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Sto from = pnk, to = mat;
  Map<String, algo.RoutingTable> routingInformation = {};

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      EasyLoading.show(status: 'loading...');
      routingInformation = algo.createRoutingInformation();
      routingInformation.forEach((key, value) {
        print('$key : ${value.routes}');
      });
      EasyLoading.dismiss();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        centerTitle: true,
        leading: getLeftAction(context),
        actions: getRightActions(context),
      ),
      body: ListView(
        children: [
          Center(
            child: SizedBox.square(
              child: MapChart(connections),
              dimension: 850,
            ),
          ),
        ],
      ),
    );
  }

  DropdownButton<Sto> createOption(
    String hint,
    Sto value,
    void Function(Sto?) onChanged,
  ) {
    final allSto = stoNameMap.values;
    return DropdownButton<Sto>(
      key: ValueKey(hint),
      hint: Text(hint),
      value: value,
      selectedItemBuilder: (BuildContext context) {
        return allSto
            .map((e) => DropdownMenuItem(
                child: Text(
                  e.name,
                  style: const TextStyle(color: Colors.white),
                ),
                value: e))
            .toList();
      },
      items: allSto
          .map((e) => DropdownMenuItem(child: Text(e.name), value: e))
          .toList(),
      onChanged: onChanged,
    );
  }

  List<Widget> getRightActions(BuildContext context) {
    return [
      createOption('from', from, (Sto? val) {
        setState(() {
          if (val?.name == to.name) {
            final dialog = AwesomeDialog(
              context: context,
              dialogType: DialogType.ERROR,
              title: 'Gagal',
              desc: 'Awal dan Akhir tidak bisa sama',
              btnCancelOnPress: () {},
              btnCancelText: 'Mengerti',
            );
            dialog.show();
          } else {
            from = val ?? from;
          }
        });
      }),
      const SizedBox(width: 12),
      const Icon(Icons.arrow_right_alt_rounded),
      const SizedBox(width: 12),
      createOption('to', to, (Sto? val) {
        setState(() {
          if (val?.name == from.name) {
            final dialog = AwesomeDialog(
              context: context,
              dialogType: DialogType.ERROR,
              title: 'Gagal',
              desc: 'Awal dan Akhir tidak bisa sama',
              btnCancelOnPress: () {},
              btnCancelText: 'Mengerti',
            );
            dialog.show();
          } else {
            to = val ?? to;
          }
        });
      }),
      const SizedBox(width: 28),
      IconButton(
        onPressed: () => runAlgorithm(),
        icon: const Icon(Icons.play_arrow_rounded),
      ),
    ];
  }

  Widget getLeftAction(BuildContext context) {
    return IconButton(
      onPressed: () async {
        await showDialog(
          context: context,
          builder: (ctx) => const Dialog(child: RouteModifier()),
        );
        setState(() {});
      },
      icon: const Icon(Icons.settings_rounded),
    );
  }

  void runAlgorithm() {
    final busySto = connections.where((e) => e.isBusy);

    // AHR
    Stopwatch stopwatch = Stopwatch()..start();
    final routeAHR = runAHR(busySto);
    final timeAHR = 'AHR executed in ${stopwatch.elapsed}';

    // DNHR
    stopwatch = Stopwatch()..start();
    final routeDNHR = runDNHR(busySto);
    final timeDNHR = 'DNHR executed in ${stopwatch.elapsed}';

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.all(12),
          children: [
            Text(
              'AHR Result',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            Text(timeAHR),
            if (routeAHR == null)
              const Text('Route Not Found')
            else
              Text('Rute: ${routeAHR.stos.join('-')}'),
            const SizedBox(height: 32),
            Text(
              'DNHR Result',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            Text(timeDNHR),
            if (routeDNHR == null)
              const Text('Route Not Found')
            else
              Text('Rute: ${routeDNHR.stos.join('-')}'),
          ],
        ),
      ),
    );
  }

  bool isAnyPathBusy(List<String> stos, Iterable<Path> busySto) {
    if (stos.length < 2 || busySto.isEmpty) return false;
    int a = 0;
    int b = 1;
    bool busyPathFound = false;
    while (b < stos.length && !busyPathFound) {
      final stoA = stos[a];
      final stoB = stos[b];
      busyPathFound = busySto.any((element) => element.isSamePath(stoA, stoB));

      a += 1;
      b += 1;
    }
    return busyPathFound;
  }

  algo.Route? runAHR(Iterable<Path> busySto) {
    final routeInfo = routingInformation[from.name]!;
    final hierarcyRoute = routeInfo.filteredRouteTo(to.name)
      ..sort((a, b) {
        // sort route by distance for hierarcy
        return a.distance.compareTo(b.distance);
      });
    for (final route in hierarcyRoute) {
      // check wether passed sto is busy
      final isAnyBusy = isAnyPathBusy(route.stos, busySto);
      if (!isAnyBusy) return route;
    }
    return null; // route not found
  }

  algo.Route? runDNHR(Iterable<Path> busySto) {
    final routeInfo = routingInformation[from.name]!;
    final hierarcyRoute = routeInfo.filteredRouteTo(to.name)..shuffle();
    for (final route in hierarcyRoute) {
      // check wether passed sto is busy
      final isAnyBusy = isAnyPathBusy(route.stos, busySto);
      if (!isAnyBusy) return route;
    }
    return null; // route not found
  }
}
