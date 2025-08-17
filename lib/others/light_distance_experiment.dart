import 'package:flutter/material.dart';
import 'package:pslab/view/about_us_screen.dart';
import '../models/experiment_step.dart';
import '../models/experiment_config.dart';

class MoveTowardsLightStep extends ExperimentStep {
  MoveTowardsLightStep()
      : super(
          id: 'move_towards',
          instruction: 'Move towards the light source',
        );

  @override
  bool checkCondition(List<double> values, List<double> timeData) {
    if (values.length < 5) return false;

    final lastFive = values.sublist(values.length - 5);
    int increasingCount = 0;

    for (int i = 1; i < lastFive.length; i++) {
      if (lastFive[i] > lastFive[i - 1]) {
        increasingCount++;
      }
    }

    return increasingCount >= 3;
  }
}

class MoveAwayFromLightStep extends ExperimentStep {
  MoveAwayFromLightStep()
      : super(
          id: 'move_away',
          instruction: 'Move away from the light source',
        );

  @override
  bool checkCondition(List<double> values, List<double> timeData) {
    if (values.length < 5) return false;

    final lastFive = values.sublist(values.length - 5);
    int decreasingCount = 0;

    for (int i = 1; i < lastFive.length; i++) {
      if (lastFive[i] < lastFive[i - 1]) {
        decreasingCount++;
      }
    }

    return decreasingCount >= 3;
  }
}

class StabilizeReadingStep extends ExperimentStep {
  StabilizeReadingStep()
      : super(
          id: 'stabilize',
          instruction: 'Hold your position and let the reading stabilize',
        );

  @override
  bool checkCondition(List<double> values, List<double> timeData) {
    if (values.length < 5) return false;

    final lastFive = values.sublist(values.length - 5);
    final average = lastFive.reduce((a, b) => a + b) / lastFive.length;

    for (double value in lastFive) {
      if ((value - average).abs() / average > 0.1) {
        return false;
      }
    }

    return true;
  }
}

final lightDistanceExperiment = ExperimentConfig(
  id: 'light_distance',
  title: appLocalizations.lightIntensityVsDistance,
  description: appLocalizations.lightIntensityVsDistanceDesc,
  icon: Icons.lightbulb,
  targetScreen: '/luxmeter',
  guideSteps: [
    {
      'title': 'Setup',
      'content':
          'Place your device near a light source (lamp, window, or flashlight).',
      'image': 'assets/images/Untitled design (1).gif',
    },
    {
      'title': 'Preparation',
      'content':
          'Make sure you have space to move towards the light source gradually.',
      'image': 'assets/images/Untitled design.gif',
    },
    {
      'title': 'Instructions',
      'content':
          'You will measure light intensity at different distances. Follow the on-screen prompts to move closer or farther from the light source.',
      'image': 'assets/images/Untitled design (2).gif',
    },
  ],
  experimentSteps: [
    StabilizeReadingStep(),
    MoveTowardsLightStep(),
    StabilizeReadingStep(),
    MoveAwayFromLightStep(),
    StabilizeReadingStep(),
  ],
);
