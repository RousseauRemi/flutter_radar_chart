library flutter_radar_chart;

import 'dart:ui';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'dart:math' show pi, cos, sin;

const defaultGraphColors = [
  Colors.green,
  Colors.blue,
  Colors.red,
  Colors.orange,
];

class Tick {
  final int value;
  final Widget label;
  const Tick({required this.value, required this.label});
}

class RadarFeature {
  final Widget label;
  final num value;
  final Widget? tooltip;
  
  const RadarFeature({
    required this.label,
    required this.value,
    this.tooltip,
  });
}

class RadarDataSet {
  final List<RadarFeature> features;
  final Color color;
  
  const RadarDataSet({
    required this.features,
    required this.color,
  });
}

class RadarChart extends StatefulWidget {
  final List<Tick> ticks;
  final List<RadarDataSet> dataSets;
  final bool reverseAxis;
  final TextStyle ticksTextStyle;
  final Color outlineColor;
  final Color axisColor;
  final int sides;
  final bool showLegend;

  const RadarChart({
    Key? key,
    required this.ticks,
    required this.dataSets,
    this.reverseAxis = false,
    this.ticksTextStyle = const TextStyle(color: Colors.grey, fontSize: 12),
    this.outlineColor = Colors.black,
    this.axisColor = Colors.grey,
    this.sides = 0,
    this.showLegend = false,
  }) : super(key: key);

  factory RadarChart.light({
    required List<Tick> ticks,
    required List<RadarDataSet> dataSets,
    bool reverseAxis = false,
    bool useSides = false,
    bool showLegend = false,
  }) {
    return RadarChart(
      ticks: ticks,
      dataSets: dataSets,
      reverseAxis: reverseAxis,
      sides: useSides ? dataSets[0].features.length : 0,
      showLegend: showLegend,
    );
  }

  factory RadarChart.dark({
    required List<Tick> ticks,
    required List<RadarDataSet> dataSets,
    bool reverseAxis = false,
    bool useSides = false,
    bool showLegend = false,
  }) {
    return RadarChart(
      ticks: ticks,
      dataSets: dataSets,
      reverseAxis: reverseAxis,
      outlineColor: Colors.white,
      axisColor: Colors.grey,
      ticksTextStyle: const TextStyle(color: Colors.white, fontSize: 12),
      sides: useSides ? dataSets[0].features.length : 0,
      showLegend: showLegend,
    );
  }

  @override
  _RadarChartState createState() => _RadarChartState();
}

class _RadarChartState extends State<RadarChart> with SingleTickerProviderStateMixin {
  double fraction = 0;
  late Animation<double> animation;
  late AnimationController animationController;
  Map<int, bool> hoveredFeatures = {};

  @override
  void initState() {
    super.initState();
    animationController = AnimationController(
      duration: Duration(milliseconds: 1000),
      vsync: this,
    );

    animation = Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(
      curve: Curves.fastOutSlowIn,
      parent: animationController,
    ))..addListener(() {
      setState(() {
        fraction = animation.value;
      });
    });

    animationController.forward();
  }

  @override
  void didUpdateWidget(RadarChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    animationController.reset();
    animationController.forward();
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxHeight);
        final centerX = size.width / 2.0;
        final centerY = size.height / 2.0;
        final smallestDimension = math.min(size.width, size.height);
        final radius = smallestDimension * 0.35; // Reduced from 0.8 to give more space for labels
        final angle = (2 * pi) / widget.dataSets[0].features.length;
        final scaleFactor = smallestDimension / 400; // Base scale on reference size

        return Stack(
          children: [
            CustomPaint(
              size: Size(double.infinity, double.infinity),
              painter: RadarChartPainter(
                widget.ticks,
                widget.dataSets,
                widget.reverseAxis,
                TextStyle(
                  color: widget.ticksTextStyle.color,
                  fontSize: math.max(8, widget.ticksTextStyle.fontSize! * scaleFactor),
                  fontWeight: widget.ticksTextStyle.fontWeight,
                ),
                widget.outlineColor,
                widget.axisColor,
                widget.sides,
                this.fraction,
              ),
            ),
            // Add tick labels with scaled positions
            ...widget.ticks.asMap().entries.map((entry) {
              final index = entry.key;
              final tick = entry.value;
              final tickRadius = (radius / (widget.ticks.length)) * (index + 1);
              
              return Positioned(
                left: centerX - (20 * scaleFactor),
                top: centerY - tickRadius - (10 * scaleFactor),
                child: Transform.scale(
                  scale: math.max(0.6, scaleFactor),
                  child: tick.label,
                ),
              );
            }).toList(),
            // Add feature labels with scaled positions and sizes
            ...widget.dataSets[0].features.asMap().entries.map((entry) {
              final index = entry.key;
              final feature = entry.value;
              final featureAngle = angle * index - pi / 2;
              
              final labelRadius = radius + (25.0 * scaleFactor);
              final xAngle = cos(featureAngle);
              final yAngle = sin(featureAngle);
              final labelX = centerX + labelRadius * xAngle;
              final labelY = centerY + labelRadius * yAngle;

              final isRightSide = xAngle > 0;
              final alignment = isRightSide ? Alignment.centerLeft : Alignment.centerRight;
              final labelOffset = isRightSide ? (10.0 * scaleFactor) : (-10.0 * scaleFactor);

              return Positioned(
                left: labelX + labelOffset - (isRightSide ? 0 : 100 * scaleFactor),
                top: labelY - (20 * scaleFactor),
                child: MouseRegion(
                  onEnter: (_) => setState(() => hoveredFeatures[index] = true),
                  onExit: (_) => setState(() => hoveredFeatures[index] = false),
                  child: Stack(
                    children: [
                      Container(
                        constraints: BoxConstraints(
                          maxWidth: 150 * scaleFactor,
                        ),
                        child: Transform.scale(
                          scale: math.max(0.6, scaleFactor),
                          alignment: isRightSide ? Alignment.centerLeft : Alignment.centerRight,
                          child: Align(
                            alignment: alignment,
                            child: feature.label,
                          ),
                        ),
                      ),
                      if (hoveredFeatures[index] == true && feature.tooltip != null)
                        Positioned(
                          left: isRightSide ? 0 : null,
                          right: isRightSide ? null : 0,
                          bottom: 25 * scaleFactor,
                          child: AnimatedOpacity(
                            duration: Duration(milliseconds: 200),
                            opacity: hoveredFeatures[index] == true ? 1.0 : 0.0,
                            child: Transform.scale(
                              scale: math.max(0.6, scaleFactor),
                              child: Container(
                                constraints: BoxConstraints(
                                  maxWidth: 200 * scaleFactor,
                                  minWidth: 100 * scaleFactor,
                                ),
                                padding: EdgeInsets.all(8 * scaleFactor),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(4 * scaleFactor),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black26,
                                      blurRadius: 4 * scaleFactor,
                                      offset: Offset(0, 2 * scaleFactor),
                                    ),
                                  ],
                                ),
                                child: feature.tooltip!,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ],
        );
      },
    );
  }
}

class RadarChartPainter extends CustomPainter {
  final List<Tick> ticks;
  final List<RadarDataSet> dataSets;
  final bool reverseAxis;
  final TextStyle ticksTextStyle;
  final Color outlineColor;
  final Color axisColor;
  final int sides;
  final double fraction;

  RadarChartPainter(
    this.ticks,
    this.dataSets,
    this.reverseAxis,
    this.ticksTextStyle,
    this.outlineColor,
    this.axisColor,
    this.sides,
    this.fraction,
  );

  Path variablePath(Size size, double radius, int sides) {
    var path = Path();
    var angle = (math.pi * 2) / sides;

    Offset center = Offset(size.width / 2, size.height / 2);

    if (sides < 3) {
      path.addOval(Rect.fromCircle(
        center: center,
        radius: radius,
      ));
    } else {
      Offset startPoint = Offset(radius * cos(-pi / 2), radius * sin(-pi / 2));
      path.moveTo(startPoint.dx + center.dx, startPoint.dy + center.dy);

      for (int i = 1; i <= sides; i++) {
        double x = radius * cos(angle * i - pi / 2) + center.dx;
        double y = radius * sin(angle * i - pi / 2) + center.dy;
        path.lineTo(x, y);
      }
      path.close();
    }
    return path;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2.0;
    final centerY = size.height / 2.0;
    final centerOffset = Offset(centerX, centerY);
    final radius = math.min(centerX, centerY) * 0.8;
    final scale = radius / ticks.last.value;

    // Painting the chart outline
    var outlinePaint = Paint()
      ..color = outlineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..isAntiAlias = true;

    var ticksPaint = Paint()
      ..color = axisColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..isAntiAlias = true;

    canvas.drawPath(variablePath(size, radius, this.sides), outlinePaint);

    var tickDistance = radius / (ticks.length);
    var tickLabels = reverseAxis ? ticks.reversed.toList() : ticks;

    // Draw feature axes and labels
    var angle = (2 * pi) / dataSets[0].features.length;
    dataSets[0].features.asMap().forEach((index, feature) {
      var featureAngle = angle * index;
      var xAngle = cos(featureAngle - pi / 2);
      var yAngle = sin(featureAngle - pi / 2);

      // Draw axis line
      var featureOffset = Offset(centerX + radius * xAngle, centerY + radius * yAngle);
      canvas.drawLine(centerOffset, featureOffset, ticksPaint);
    });

    // Painting each dataset
    dataSets.asMap().forEach((dataSetIndex, dataSet) {
      var graphPaint = Paint()
        ..color = dataSet.color.withOpacity(0.3)
        ..style = PaintingStyle.fill;

      var graphOutlinePaint = Paint()
        ..color = dataSet.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0
        ..isAntiAlias = true;

      var path = Path();

      dataSet.features.asMap().forEach((index, feature) {
        var xAngle = cos(angle * index - pi / 2);
        var yAngle = sin(angle * index - pi / 2);
        var scaledPoint = scale * feature.value * fraction;

        if (index == 0) {
          if (reverseAxis) {
            path.moveTo(centerX, centerY - (radius * fraction - scaledPoint));
          } else {
            path.moveTo(centerX, centerY - scaledPoint);
          }
        } else {
          if (reverseAxis) {
            path.lineTo(
              centerX + (radius * fraction - scaledPoint) * xAngle,
              centerY + (radius * fraction - scaledPoint) * yAngle,
            );
          } else {
            path.lineTo(
              centerX + scaledPoint * xAngle,
              centerY + scaledPoint * yAngle,
            );
          }
        }
      });

      path.close();
      canvas.drawPath(path, graphPaint);
      canvas.drawPath(path, graphOutlinePaint);
    });
  }

  @override
  bool shouldRepaint(RadarChartPainter oldDelegate) {
    return oldDelegate.fraction != fraction;
  }
}
