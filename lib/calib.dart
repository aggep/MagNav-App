import 'package:flutter/material.dart';
import 'frame3.dart';
import 'dart:async';
import 'package:sizer/sizer.dart';
import 'package:pedometer/pedometer.dart';

class CalibInstrWidget extends StatefulWidget {
  const CalibInstrWidget({super.key});

  @override
  State<CalibInstrWidget> createState() => _CalibInstrWidgetState();
}

class _CalibInstrWidgetState extends State<CalibInstrWidget> {
  //initialize timer duration
  static const maxSeconds = 60;
  int seconds = maxSeconds;
  Timer? timer;

//timer method
  void startTimer() {
    if (timer != null && timer!.isActive) {
      return;
    }
    timer = Timer.periodic(const Duration(milliseconds: 300), (_) {
      //300ms for demo purposes (in real world use it would be set to 1s)
      if (seconds > 0) {
        setState(() => seconds--);
      } else {
        stopTimer();
        Navigator.of(context).push(MaterialPageRoute(builder: (context) => const Frame3Widget()));
      }
    });
  }

//method to stop the timer
  void stopTimer() {
    timer?.cancel();
  }

//bool var to change the screen layout
//when _showText = false, change the layout of the screen
  bool _showText = true;

//function to change the creen layout
  void _toggleDisplay() {
    setState(() {
      _showText = false;
    });
  }

  @override
  Widget build(BuildContext context) => Container(
      constraints: const BoxConstraints.expand(),
      child: Scaffold(
          backgroundColor: const Color(0xffE1E4D5),
          body: Stack(children: <Widget>[
            Positioned.fill(
                child: Container(
                    //alignment: AlignmentDirectional.topCenter,
                    padding: EdgeInsets.symmetric(vertical: 15.h, horizontal: 10.w),
                    //margin: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                    child: _showText
                        ? Text("Make sure you have enough walking space ahead",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.w400,
                              height: 1.0,
                              color: const Color(0xff1B1C18),
                            ))
                        : Text("Keep on walking straight until time runs out...",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.w400,
                              height: 1.0,
                              color: const Color(0xff1B1C18),
                            )))),
            Positioned.fill(
                top: 55.5.h,
                child: Container(
                    padding: EdgeInsets.symmetric(vertical: 5.h, horizontal: 10.w),
                    //margin: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                    child: _showText
                        ? Text(
                            "When you are ready, start walking in a straight line  and press the button below to begin the calibration countdown",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.w400,
                              height: 1.0,
                              color: const Color(0xff1B1C18),
                            ))
                        : PedometerWidget())),
            Positioned(
                top: 28.h,
                child: SizedBox(
                    width: 100.w,
                    child: Center(
                        child: Container(
                            decoration:
                                BoxDecoration(borderRadius: BorderRadius.circular(20), color: const Color(0xffFDFCF5)),
                            height: 25.h,
                            width: _showText ? 95.w : 55.w,
                            alignment: AlignmentDirectional.center,
                            child: Container(
                              alignment: AlignmentDirectional.center,
                              child: buildTime(),
                            ))))),
            Container(
                alignment: AlignmentDirectional.bottomCenter,
                padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 0.w),
                //margin: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                child: _showText
                    ? ElevatedButton(
                        onPressed: () {
                          startTimer();
                          _toggleDisplay();
                        },
                        style: ButtonStyle(
                            fixedSize: MaterialStateProperty.all(Size(70.w, 8.h)),
                            padding: MaterialStateProperty.all<EdgeInsets>(const EdgeInsets.all(15)),
                            backgroundColor: const MaterialStatePropertyAll<Color>(Color(0xff416914)),
                            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)))),
                        child: Text('Start Countdown',
                            style: TextStyle(color: Colors.white, fontSize: 12.sp), textAlign: TextAlign.center))
                    : Text("")),
          ])));

//countdown widget
  Widget buildTime() {
    return Text('$seconds',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 65.sp,
          fontWeight: FontWeight.w400,
          height: 1,
          color: const Color(0xff1F4E4C),
        ));
  }
}

class PedometerWidget extends StatefulWidget {
  const PedometerWidget({super.key});

  @override
  State<PedometerWidget> createState() => _PedometerWidgetState();
}

class _PedometerWidgetState extends State<PedometerWidget> {
  //pedometer steep count stream
  late Stream<StepCount> _stepCountStream;
  int _stepCount = 0;

  //shows if pedometer listener has been started
  bool pedometer_not_first_time = false;

  @override
  void initState() {
    super.initState();
    //initilize pedometer
    initPlatformState();
  }

  void onStepCount(StepCount event) {
    if (pedometer_not_first_time) {
      _stepCount += 1;
    } else {
      pedometer_not_first_time = true;
    }
  }

  //step count error handeler
  void onStepCountError(error) {
    print('onStepCountError: $error');
  }

  //method for initializing pedometer
  void initPlatformState() {
    _stepCountStream = Pedometer.stepCountStream;
    _stepCountStream.listen(onStepCount).onError(onStepCountError);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      //mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Positioned.fill(
            child: Container(
                padding: EdgeInsets.symmetric(vertical: 0.h, horizontal: 10.w),
                child: Text("Number of steps made:",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w400,
                      height: 1.0,
                      color: const Color(0xff1B1C18),
                    )))),
        Positioned.fill(
            child: Container(
                padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 10.w),
                child: Text('$_stepCount',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 55.sp, fontWeight: FontWeight.w400, height: 1.0, color: const Color(0xff707B61))))),
      ],
    );
  }
}
