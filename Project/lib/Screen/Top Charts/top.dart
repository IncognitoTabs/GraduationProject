import 'package:flutter/foundation.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';

List localSongs = [];
List globalSongs = [];
bool localFetched = false;
bool globalFetched = false;
final ValueNotifier<bool> localFetchFinished = ValueNotifier<bool>(false);
final ValueNotifier<bool> globalFetchFinished = ValueNotifier<bool>(false);

class TopCharts extends StatefulWidget {
  const TopCharts({super.key});

  @override
  State<TopCharts> createState() => _TopChartsState();
}

class _TopChartsState extends State<TopCharts> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}