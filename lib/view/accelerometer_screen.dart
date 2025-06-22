import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pslab/constants.dart';
import 'package:pslab/view/widgets/guide_widget.dart';
import 'package:pslab/providers/accelerometer_state_provider.dart';
import 'package:pslab/view/widgets/common_scaffold_widget.dart';
import 'package:pslab/view/widgets/accelerometer_card.dart';

class AccelerometerScreen extends StatefulWidget {
  const AccelerometerScreen({super.key});

  @override
  State<StatefulWidget> createState() => _AccelerometerScreenState();
}

class _AccelerometerScreenState extends State<AccelerometerScreen> {
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
        ChangeNotifierProvider<AccelerometerStateProvider>(
          create: (_) => AccelerometerStateProvider()..initializeSensors(),
        ),
      ],
      child: Stack(children: [
        CommonScaffold(
            title: accelerometer,
            onGuidePressed: _showInstrumentGuide,
            body: SafeArea(
                child: Column(
              children: [
                Expanded(
                    child:
                        AccelerometerCard(color: Colors.yellow, axis: xAxis)),
                Expanded(
                    child:
                        AccelerometerCard(color: Colors.purple, axis: yAxis)),
                Expanded(
                    child: AccelerometerCard(color: Colors.green, axis: zAxis)),
              ],
            ))),
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
