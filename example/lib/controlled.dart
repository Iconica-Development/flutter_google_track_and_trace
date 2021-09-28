import 'package:flutter/material.dart';

main() {
  runApp(MaterialApp(
    home: Scaffold(
      body: Center(
        child: ControlledWidget(
            initialString: 'old value',
            onCreate: (controller) async {
              Future.delayed(const Duration(seconds: 5), () {
                controller.value = 'new value';
              });
            }),
      ),
    ),
  ));
}

enum TimePrecision {
  updateOnly,
  everySecond,
  everyMinute
}

class ControlledWidget extends StatefulWidget {
  final void Function(MyController) onCreate;
  final String? initialString;
  final TimePrecision precision;
  const ControlledWidget({
    Key? key,
    required this.onCreate,
    this.initialString,
    this.precision = TimePrecision.updateOnly,
  }) : super(key: key);

  @override
  _ControlledWidgetState createState() => _ControlledWidgetState();
}

class _ControlledWidgetState extends State<ControlledWidget> {
  late final MyController _controller;

  @override
  void initState() {
    _controller = MyController(widget.initialString ?? '');
    _controller.addListener(_onChange);
    widget.onCreate(_controller);
    super.initState();
  }

  void _onChange() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Text(_controller.value);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class MyController extends ChangeNotifier {
  String _currentString;

  MyController(String initial) : _currentString = initial;

  String get value => _currentString;

  set value(String value) {
    _currentString = value;
    notifyListeners();
  }
}
