import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'calib.dart';
import 'frame3.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of our application.
  @override
  Widget build(BuildContext context) {
    return Sizer(builder: (context, orientation, deviceType) {
      return const MaterialApp(
        title: 'MagNav',
        home: MyHomePage(
          title: 'Home Page',
          backgroundColor: Colors.transparent,
        ),
      );
    });
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title, required backgroundColor});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) => Container(
      constraints: const BoxConstraints.expand(),
      decoration: const BoxDecoration(
          image: DecorationImage(
              image: AssetImage('assets/images/background1.jpg'), //set background img
              fit: BoxFit.cover)),
      child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Stack(children: <Widget>[
            //we have implemented the screen using a stack to place each object in the "wanted" place of the screen
            Container(
                alignment: AlignmentDirectional.topCenter,
                padding: EdgeInsets.symmetric(vertical: 15.h, horizontal: 0.h),
                child: Text("MagNav", // title of the app
                    textAlign: TextAlign.center, //it is placed on the top center of the screen
                    style: TextStyle(
                        fontSize: 41.sp,
                        fontWeight: FontWeight.w400,
                        height: 1.0,
                        color: const Color(0xffE7E2D8)) //styles for the title
                    )),
            Center(
                //in the center of the screen we have a small box-like container
                child: Container(
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), color: const Color(0xffE7E2D8)),
                    height: 28.h,
                    width: 90.w,
                    alignment: AlignmentDirectional.topCenter,
                    child: Column(children: <Widget>[
                      Container(
                          padding: EdgeInsets.symmetric(vertical: 2.h, horizontal: 5.w),
                          margin: EdgeInsets.all(1.w),
                          child: Text("Ready to start your next adventure?",
                              style: TextStyle(fontSize: 20.5.sp, color: const Color(0xff1B1C18)))),
                      Container(
                          padding: EdgeInsets.symmetric(vertical: 0.h, horizontal: 5.w),
                          margin: EdgeInsets.all(1.w),
                          child: Text(
                              "Before heading out select below how you want the app to determine your average step length",
                              style: TextStyle(fontSize: 13.sp, color: const Color(0xff1B1C18))))
                    ]))),
            Positioned.fill(
                //we finally used this to place the buttons on the bottom partof the screen
                top: 52.h,
                child: Align(
                    alignment: Alignment.center,
                    child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                              //this navigates to the screen after pressing the button
                              context,
                              MaterialPageRoute(builder: (builder) => const CalibInstrWidget()));
                        },
                        style: ButtonStyle(
                            //styling for the button
                            fixedSize: MaterialStateProperty.all(Size(60.w, 9.h)),
                            padding: MaterialStateProperty.all<EdgeInsets>(EdgeInsets.all(1.w)),
                            backgroundColor: const MaterialStatePropertyAll<Color>(Color(0xffA6D574)),
                            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)))),
                        child: Text('Start Calibration',
                            style: TextStyle(color: const Color(0xff1B1C18), fontSize: 12.sp),
                            textAlign: TextAlign.center)))),
            Positioned.fill(
                top: 73.h,
                child: Align(
                    alignment: Alignment.center,
                    child: ElevatedButton(
                      onPressed: () {
                        showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                                  backgroundColor: Color.fromARGB(255, 42, 48, 44),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                                  title: const Text('Success', style: TextStyle(color: Color(0xffE3E3DB))),
                                  content: const Text('Your data from Google Fit has been synced',
                                      style: TextStyle(color: Color(0xffC4C8BA))),
                                  actions: [
                                    TextButton(
                                        onPressed: () => {
                                              Navigator.of(context)
                                                  .push(MaterialPageRoute(builder: (context) => const Frame3Widget()))
                                            },
                                        child: const Text('got it',
                                            style: TextStyle(color: Color.fromARGB(255, 211, 199, 139))))
                                  ],
                                ));
                      },
                      style: ButtonStyle(
                          fixedSize: MaterialStateProperty.all(Size(60.w, 9.h)),
                          padding: MaterialStateProperty.all<EdgeInsets>(EdgeInsets.all(1.w)),
                          backgroundColor: const MaterialStatePropertyAll<Color>(Color(0xffA6D574)),
                          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                              RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)))),
                      child: Text('Sync with Google Fit',
                          style: TextStyle(color: const Color(0xff1B1C18), fontSize: 12.sp),
                          textAlign: TextAlign.center),
                    )))
          ])));
}
