import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pslab/theme/colors.dart';

class LoggedDataChartScreen extends StatefulWidget {
  final List<List<dynamic>> data;
  final String fileName;

  const LoggedDataChartScreen(
      {super.key, required this.data, required this.fileName});

  @override
  State<LoggedDataChartScreen> createState() => _LoggedDataChartScreenState();
}

class _LoggedDataChartScreenState extends State<LoggedDataChartScreen> {
  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }

  double _getSafeInterval(double maxValue, {int divisions = 5}) {
    if (maxValue <= 0) return 1.0;
    final double interval = (maxValue / divisions).ceilToDouble();
    return interval > 0 ? interval : 1.0;
  }

  @override
  Widget build(BuildContext context) {
    final List<FlSpot> spots = [];
    double maxLux = 0;
    double maxTime = 0;

    for (int i = 1; i < widget.data.length; i++) {
      final row = widget.data[i];
      if (row.length >= 3) {
        final time = (row[1] as num).toDouble();
        final lux = (row[2] as num).toDouble();
        spots.add(FlSpot(time, lux));
        if (lux > maxLux) maxLux = lux;
        if (time > maxTime) maxTime = time;
      }
    }

    double chartWidth = spots.length * 12.0;
    final screenWidth = MediaQuery.of(context).size.width;
    if (chartWidth < screenWidth) {
      chartWidth = screenWidth;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.fileName,
          style: TextStyle(color: appBarContentColor, fontSize: 15),
        ),
        backgroundColor: primaryRed,
        iconTheme: IconThemeData(color: appBarContentColor),
      ),
      body: SafeArea(
        child: spots.isEmpty
            ? const Center(child: Text('No valid data to display.'))
            : SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Container(
                  width: chartWidth,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                  child: LineChart(
                    LineChartData(
                      backgroundColor: chartBackgroundColor,
                      titlesData: FlTitlesData(
                        show: true,
                        topTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        bottomTitles: AxisTitles(
                          axisNameWidget: const Text('Time (s)'),
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 30,
                            interval: _getSafeInterval(maxTime, divisions: 10),
                          ),
                        ),
                        leftTitles: AxisTitles(
                          axisNameWidget: const Text('Lux (lx)'),
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 45,
                            interval: _getSafeInterval(maxLux, divisions: 5),
                          ),
                        ),
                        rightTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                      ),
                      gridData: FlGridData(
                        show: true,
                        drawHorizontalLine: true,
                        drawVerticalLine: true,
                        horizontalInterval:
                            _getSafeInterval(maxLux, divisions: 5),
                        verticalInterval:
                            _getSafeInterval(maxTime, divisions: 10),
                      ),
                      borderData: FlBorderData(
                        show: true,
                        border: Border.all(color: chartBorderColor),
                      ),
                      minY: 0,
                      maxY: maxLux > 0 ? maxLux * 1.1 : 10,
                      minX: 0,
                      maxX: maxTime,
                      lineBarsData: [
                        LineChartBarData(
                          spots: spots,
                          isCurved: true,
                          color: chartLineColor,
                          barWidth: 2.0,
                          dotData: const FlDotData(show: false),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}
