import 'dart:async';
import 'dart:math';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:pslab/others/logger_service.dart';
import 'package:noise_meter/noise_meter.dart';
import 'package:flutter/foundation.dart';
import 'package:pslab/constants.dart';

class SoundMeterStateProvider extends ChangeNotifier {
  double _currentDb = 0.0;
  StreamSubscription<NoiseReading>? _noiseSubscription;
  Timer? _timeTimer;
  final List<double> _dbData = [];
  final List<double> _timeData = [];
  final List<FlSpot> dbChartData = [];
  NoiseMeter? _noiseMeter;
  double _startTime = 0;
  double _currentTime = 0;
  final int _maxLength = 50;
  double _dbMin = 0;
  double _dbMax = 0;
  double _dbSum = 0;
  int _dataCount = 0;

  void initializeSensors() {
    try {
      _noiseMeter = NoiseMeter();
      _startTime = DateTime.now().millisecondsSinceEpoch / 1000.0;
      _timeTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        _currentTime =
            (DateTime.now().millisecondsSinceEpoch / 1000.0) - _startTime;
        _updateData();
        notifyListeners();
      });
      _noiseSubscription = _noiseMeter!.noise.listen(
        (NoiseReading noiseReading) {
          _currentDb = noiseReading.meanDecibel;
          notifyListeners();
        },
        onError: (error) {
          logger.e(
            "$soundMeterError $error",
          );
        },
        cancelOnError: true,
      );
    } catch (e) {
      logger.e("$soundMeterInitialError $e");
    }
  }

  void disposeSensors() {
    _noiseSubscription?.cancel();
    _timeTimer?.cancel();
  }

  @override
  void dispose() {
    disposeSensors();
    super.dispose();
  }

  void _updateData() {
    final db = _currentDb;
    final time = _currentTime;
    _dbData.add(db);
    _timeData.add(time);
    _dbSum += db;
    _dataCount++;
    if (_dbData.length > _maxLength) {
      final removedValue = _dbData.removeAt(0);
      _timeData.removeAt(0);
      _dbSum -= removedValue;
      _dataCount--;
    }
    if (_dbData.isNotEmpty) {
      _dbMin = _dbData.reduce(min);
      _dbMax = _dbData.reduce(max);
    }
    dbChartData.clear();
    for (int i = 0; i < _dbData.length; i++) {
      dbChartData.add(FlSpot(_timeData[i], _dbData[i]));
    }
    notifyListeners();
  }

  double getCurrentDb() => _currentDb;
  double getMinDb() => _dbMin;
  double getMaxDb() => _dbMax;
  double getAverageDb() => _dataCount > 0 ? _dbSum / _dataCount : 0.0;
  List<FlSpot> getDbChartData() => dbChartData;
  int getDataLength() => dbChartData.length;
  double getCurrentTime() => _currentTime;
  double getMaxTime() => _timeData.isNotEmpty ? _timeData.last : 0;
  double getMinTime() => _timeData.isNotEmpty ? _timeData.first : 0;
  double getTimeInterval() {
    if (_currentTime <= 10) return 2;
    if (_currentTime <= 30) return 5;
    return 10;
  }
}
