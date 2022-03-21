import 'package:flutter/material.dart';
import 'package:simulasi_routing/algo/data.dart';

class RouteModifier extends StatefulWidget {
  const RouteModifier({Key? key}) : super(key: key);

  @override
  State<RouteModifier> createState() => _RouteModifierState();
}

class _RouteModifierState extends State<RouteModifier> {
  @override
  Widget build(BuildContext context) {
    return ListView(
      shrinkWrap: true,
      padding: const EdgeInsets.all(12),
      children: [
        Text(
          'Pengaturan Ketersediaan Rute',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 12),
        ...createRouteOption(),
      ],
    );
  }

  List<Widget> createRouteOption() {
    return connections
        .map(
          (e) => SwitchListTile(
            value: !e.isBusy,
            onChanged: (val) {
              setState(() {
                e.isBusy = !val;
              });
            },
            title: Text(e.name),
            dense: true,
          ),
        )
        .toList();
  }
}
