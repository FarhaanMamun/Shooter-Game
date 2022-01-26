import 'dart:math';
import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sensors/sensors.dart';
import 'package:shooter_game/controller.dart';
import 'main.dart';

class MyGameState extends State<MyGame> with TickerProviderStateMixin {
  Animation<double>? bulletAnimation, targetAnimation;
  AnimationController? bulletController, targetController;
  double bulletYPoint = 0;
  double targetYPoint = 0;
  double bulletXPoint = 0;
  double targetXPoint = 0;
  double x = 0;
  int count = 1;
  int endGame = 0;
  var rand = Random();
  static const Color white = Colors.white;
  Widget box = Container(
    height: 30,
    width: 30,
    color: white,
  );
  void init() {
    bulletController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    accelerometerEvents.listen(
      (AccelerometerEvent event) {
        if ((-x * 5 - event.x).abs() > 0.1) {
          if (event.x < -5) {
            stream.addValue(1);
          } else if (event.x > 5) {
            stream.addValue(-1);
          } else {
            x = -double.parse(event.x.toStringAsFixed(1)) / 5;
            stream.addValue(x);
          }
        }
      },
    );
    initialize();
  }

  void initialize() {
    bulletYPoint = 1;
    targetYPoint = -1;
    bulletAnimation = Tween(begin: 1.0, end: -1.0).animate(bulletController!)
      ..addStatusListener(
        (event) {
          if (event == AnimationStatus.completed) {
            bulletController!.reset();
            bulletController!.forward();
          }
        },
      )
      ..addListener(
        () {
          stream.bulletStream.add(bulletAnimation!.value);
        },
      );
    bulletController!.forward();
    targetController = AnimationController(
      duration:
          Duration(milliseconds: count < 45 ? 10000 - (count * 200) : 1000),
      vsync: this,
    );
    targetAnimation = Tween(begin: -1.0, end: 1.0).animate(targetController!)
      ..addListener(
        () {
          setState(
            () {
              targetYPoint = targetAnimation!.value;
            },
          );
          if (targetAnimation!.value == 1) {
            endGame = 2;
          }
        },
      );
    targetController!.forward();
  }

  @override
  Widget build(BuildContext context) {
    if (bulletXPoint > targetXPoint - 0.15 &&
        bulletXPoint < targetXPoint + 0.15) {
      if (bulletYPoint < targetYPoint) {
        setState(
          () {
            count++;
            if (rand.nextBool()) {
              targetXPoint = rand.nextDouble();
            } else {
              targetXPoint = -rand.nextDouble();
            }
          },
        );
        bulletController!.reset();
        initialize();
      }
    }

    if (endGame == 1 && bulletAnimation!.value == 1) {
      bulletXPoint = x;
    }

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Stack(
        children: <Widget>[
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(0),
            ),
            child: const FlareActor(
              "assets/background.flr",
              alignment: Alignment.center,
              fit: BoxFit.fitWidth,
              animation: "rotate",
            ),
          ),
          Scaffold(
            backgroundColor: Colors.transparent,
            body: endGame != 1
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        const SizedBox(
                          height: 160,
                          width: 60,
                          child: FlareActor(
                            "assets/bullet.flr",
                            // alignment: Alignment(bulletXPoint, stream.data),
                            fit: BoxFit.fitHeight,
                            animation: "float",
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            "Box Shooter",
                            style: TextStyle(
                              color: Colors.yellow,
                              fontSize: 40,
                            ),
                          ),
                        ),
                        Text(
                          endGame == 2 ? "Points: ${count - 1}" : "",
                          style: const TextStyle(
                            color: white,
                            fontSize: 35,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            init();
                            endGame = 1;
                            count = 1;
                            initialize();
                          },
                          child: SizedBox(
                            height: 60,
                            width: 60,
                            child: (endGame == 2)
                                ? const Icon(
                                    Icons.refresh,
                                    color: Colors.white,
                                    size: 45,
                                  )
                                : const FlareActor(
                                    "assets/play_button.flr",
                                    alignment: Alignment.center,
                                    fit: BoxFit.cover,
                                    animation: "animate",
                                  ),
                          ),
                        ),
                      ],
                    ),
                  )
                : Column(
                    children: <Widget>[
                      Expanded(
                        child: Stack(
                          children: <Widget>[
                            Align(
                              alignment: const Alignment(0.8, -0.9),
                              child: Text(
                                " ${count - 1}",
                                style: const TextStyle(
                                  fontSize: 25,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            StreamBuilder(
                              initialData: 1.0,
                              stream: stream.bulletStreamGet,
                              builder: (context, stream) {
                                bulletYPoint = stream.data as double;
                                return Align(
                                  alignment: Alignment(
                                    bulletXPoint,
                                    bulletYPoint,
                                  ),
                                  child:
                                      //  Icon(Icons.arrow_upward)
                                      SizedBox(
                                    width: 15,
                                    child: FlareActor(
                                      "assets/bullet.flr",
                                      alignment: Alignment(
                                        bulletXPoint,
                                        bulletYPoint,
                                      ),
                                      fit: BoxFit.fitWidth,
                                      animation: "float",
                                    ),
                                  ),
                                );
                              },
                            ),
                            Align(
                              alignment: Alignment(targetXPoint, targetYPoint),
                              child: SizedBox(
                                width: 40,
                                child: FlareActor(
                                  "assets/target.flr",
                                  alignment:
                                      Alignment(targetXPoint, targetYPoint),
                                  fit: BoxFit.fitWidth,
                                  animation: "Preview2",
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      StreamBuilder(
                        initialData: 0.0,
                        stream: stream.shooterStreamGet,
                        builder: (ctx, stream) {
                          x = stream.data as double;
                          return Align(
                            alignment: Alignment(x, 1),
                            child: const SizedBox(
                              width: 60,
                              height: 20,
                              child: FlareActor(
                                "assets/earth.flr",
                                alignment: Alignment.center,
                                fit: BoxFit.fitWidth,
                                animation: "Preview2",
                              ),
                            ),
                            //box
                          );
                        },
                      )
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}
