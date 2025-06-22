import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pslab/providers/gyroscope_state_provider.dart';
import 'package:pslab/constants.dart';
import 'package:pslab/view/widgets/guide_widget.dart';
import 'package:pslab/view/widgets/gyroscope_card.dart';
import 'package:pslab/view/widgets/common_scaffold_widget.dart';

class GyroscopeScreen extends StatefulWidget {
  const GyroscopeScreen({super.key});

  @override
  State<StatefulWidget> createState() => _GyroscopeScreenState();
}

class _GyroscopeScreenState extends State<GyroscopeScreen> {
  bool _showGuide = false;
  void _showInstrumentGuide() {
    setState(() {
      _showGuide = true;
    });
  }

  void _hideInstrumentGuide() {
    setState(() {
      _showGuide = false;
    });
  }

  List<Widget> _getSoundMeterContent() {
    return [
      const InstrumentIntroText(
        text: 'Sound meter Introduction',
      ),
      const InstrumentImage(
        imagePath: 'assets/images/bh1750_schematic.png',
        height: 250.0,
        caption: 'PSLab device connection diagram',
      ),
      const InstrumentIntroText(
        text: 'To measure the loudness in the environment in decibel(dB)',
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<GyroscopeProvider>(
          create: (_) => GyroscopeProvider()..initializeSensors(),
        ),
      ],
      child: Stack(children: [
        CommonScaffold(
          title: gyroscopeTitle,
          onGuidePressed: _showInstrumentGuide,
          body: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: GyroscopeCard(color: Colors.yellow, axis: xAxis),
                ),
                Expanded(
                  child: GyroscopeCard(color: Colors.purple, axis: yAxis),
                ),
                Expanded(
                  child: GyroscopeCard(color: Colors.green, axis: zAxis),
                ),
              ],
            ),
          ),
        ),
        if (_showGuide)
          InstrumentOverviewDrawer(
            instrumentName: 'Sound Meter',
            content: _getSoundMeterContent(),
            onHide: _hideInstrumentGuide,
          ),
      ]),
    );
  }
}
