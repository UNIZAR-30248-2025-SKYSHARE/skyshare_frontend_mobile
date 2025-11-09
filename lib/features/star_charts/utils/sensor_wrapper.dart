import 'package:sensors_plus/sensors_plus.dart';

class SensorWrapper {
  Stream<AccelerometerEvent> get accelerometerEvents => accelerometerEventStream();
  Stream<GyroscopeEvent> get gyroscopeEvents => gyroscopeEventStream();
}