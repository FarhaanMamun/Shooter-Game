import 'dart:async';

class Streams {
  StreamController<double> shooterStreamController =
          StreamController.broadcast(),
      bulletStreamController = StreamController.broadcast();

  Sink get shooterStream => shooterStreamController.sink;
  Sink get bulletStream => bulletStreamController.sink;

  Stream<double> get shooterStreamGet => shooterStreamController.stream;
  Stream<double> get bulletStreamGet => bulletStreamController.stream;

  addValue(double value) {
    shooterStream.add(value);
  }

  addBulletValue(double value) {
    bulletStream.add(value);
  }

  voiddispose() {
    shooterStreamController.close();
    bulletStreamController.close();
  }
}

Streams stream = Streams();
