import 'package:flutter/material.dart';
import 'package:flutter_radar_chart/flutter_radar_chart.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Radar Chart Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool darkMode = false;
  bool useSides = false;
  double numberOfFeatures = 3;

  @override
  Widget build(BuildContext context) {
    const ticks = [
      Tick(value: 7, label: Text('7')),
      Tick(value: 14, label: Text('14')),
      Tick(value: 21, label: Text('21')),
      Tick(value: 28, label: Text('28')),
      Tick(value: 35, label: Text('35')),
    ];

    var features = ["AA", "BB", "CC", "DD", "EE", "FF", "GG", "HH"];
    var data = [
      [10.0, 20, 28, 5, 16, 15, 17, 6],
      [14.5, 1, 4, 14, 23, 10, 6, 19]
    ];

    features = features.sublist(0, numberOfFeatures.floor());
    data = data.map((graph) => graph.sublist(0, numberOfFeatures.floor())).toList();

    // Convert features to RadarFeature objects
    var radarFeatures = features.map((feature) => RadarFeature(
      label: Text(feature),
      value: data[0][features.indexOf(feature)],
    )).toList();

    var radarFeatures2 = features.map((feature) => RadarFeature(
      label: Text(feature),
      value: data[1][features.indexOf(feature)],
    )).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('Radar Chart Example'),
      ),
      body: Container(
        color: darkMode ? Colors.black : Colors.white,
        child: Column(
          children: [
            // Controls
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Row(
                children: [
                  Text(
                    darkMode ? 'Light mode' : 'Dark mode',
                    style: TextStyle(color: darkMode ? Colors.white : Colors.black),
                  ),
                  Switch(
                    value: darkMode,
                    onChanged: (value) => setState(() => darkMode = value),
                  ),
                  const Spacer(),
                  Text(
                    'Features: ${numberOfFeatures.floor()}',
                    style: TextStyle(color: darkMode ? Colors.white : Colors.black),
                  ),
                  Slider(
                    value: numberOfFeatures,
                    min: 3,
                    max: 8,
                    divisions: 5,
                    onChanged: (value) => setState(() => numberOfFeatures = value),
                  ),
                ],
              ),
            ),
            // Charts row
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            'Chart 1',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: darkMode ? Colors.white : Colors.black,
                            ),
                          ),
                        ),
                        Expanded(
                          child: darkMode
                              ? RadarChart.dark(
                                  ticks: ticks,
                                  dataSets: [
                                    RadarDataSet(
                                      features: radarFeatures,
                                      color: Colors.blue,
                                    ),
                                  ],
                                  reverseAxis: true,
                                  useSides: useSides,
                                )
                              : RadarChart.light(
                                  ticks: ticks,
                                  dataSets: [
                                    RadarDataSet(
                                      features: radarFeatures,
                                      color: Colors.blue,
                                    ),
                                  ],
                                  reverseAxis: true,
                                  useSides: useSides,
                                ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            'Chart 2',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: darkMode ? Colors.white : Colors.black,
                            ),
                          ),
                        ),
                        Expanded(
                          child: darkMode
                              ? RadarChart.dark(
                                  ticks: ticks,
                                  dataSets: [
                                    RadarDataSet(
                                      features: radarFeatures2,
                                      color: Colors.red,
                                    ),
                                  ],
                                  reverseAxis: true,
                                  useSides: useSides,
                                )
                              : RadarChart.light(
                                  ticks: ticks,
                                  dataSets: [
                                    RadarDataSet(
                                      features: radarFeatures2,
                                      color: Colors.red,
                                    ),
                                  ],
                                  reverseAxis: true,
                                  useSides: useSides,
                                ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
