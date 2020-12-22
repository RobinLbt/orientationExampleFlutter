import 'dart:async';

import 'package:flutter/material.dart';

import 'package:vector_math/vector_math_64.dart' as vector;
import 'package:flutter_sensors/flutter_sensors.dart';

import 'computation.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  StreamSubscription<SensorEvent> _accelSubscription;
  List<double> _accelData;

  StreamSubscription<SensorEvent> _magnetoSubscription;
  List<double> _magnetoData;

  List<double> _rotationMatrix;
  List<double> _orientationAngles = List<double>(3);

  @override
  void initState() {
    initSensors();
    super.initState();
  }

  Future<void> initSensors() async {
    final streamAccel = await SensorManager().sensorUpdates(
      sensorId: Sensors.ACCELEROMETER,
      interval: Sensors.SENSOR_DELAY_UI,
    );
    _accelSubscription = streamAccel.listen((sensorEvent) {
      setState(() {
        _accelData = sensorEvent.data;
      });
      _onSensorChange();
    });

    final streamMagneto = await SensorManager().sensorUpdates(
      sensorId: Sensors.MAGNETIC_FIELD,
      interval: Sensors.SENSOR_DELAY_UI,
    );
    _accelSubscription = streamMagneto.listen((sensorEvent) {
      setState(() {
        _magnetoData = sensorEvent.data;
      });
      _onSensorChange();
    });
  }

  void _onSensorChange() {
    _rotationMatrix = getRotationMatrix(
        vector.Vector3(_accelData[0], _accelData[1], _accelData[2]),
        vector.Vector3(_magnetoData[0], _magnetoData[1], _magnetoData[2]));
    _orientationAngles = getOrientation(_rotationMatrix);
  }

  @override
  void dispose() {
    _accelSubscription.cancel();
    _magnetoSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Stack(children: [
          if (_accelData != null)
            Align(
                alignment: Alignment.topCenter,
                child: Text(_accelData.toString())),
          if (_magnetoData != null)
            Align(
                alignment: Alignment.bottomCenter,
                child: Text(_magnetoData.toString())),
          if (_rotationMatrix != null)
            Center(
              child: Transform(
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.001)
                  ..rotateX(_orientationAngles[0])
                  ..rotateY(_orientationAngles[1])
                  ..rotateZ(_orientationAngles[2]),
                alignment: Alignment.center,
                child: Container(
                  width: 100,
                  height: 100,
                  color: Colors.red,
                ),
              ),
            )
        ]),
      ),
    );
  }
}
