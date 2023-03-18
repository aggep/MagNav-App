import 'package:flutter/material.dart';
import 'main.dart';
import 'package:sizer/sizer.dart';
import 'info.dart';
import 'mapPage.dart';
import 'main.dart';

class Frame3Widget extends StatefulWidget {
  const Frame3Widget({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _Frame3WidgetState createState() => _Frame3WidgetState();
}

class _Frame3WidgetState extends State<Frame3Widget> {
  //variable for average step
  static double average_step_length = 65.87;

  @override
  void initState() {
    super.initState();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color(0xffE1E4D5),
        body: Stack(children: <Widget>[
          Container(
              alignment: AlignmentDirectional.topCenter,
              padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 0.w),
              child: Text("Your average step length is...", style: TextStyle(fontSize: 17.5.sp, color: Colors.black))),
          Positioned(
              top: 25.h,
              right: 26.w,
              child: SizedBox(
                  height: 10.h,
                  width: 37.w,
                  child: Text('$average_step_length' + "cm",
                      style: TextStyle(fontSize: 23.5.sp, color: const Color(0xff416914))))),
          Positioned(
              top: 40.h,
              right: 15.w,
              child: SizedBox(
                  height: 30.h,
                  width: 69.w,
                  child: Text(
                      "Now all that's left is placing your phone in your bag according to the app instructions and beginning your journey",
                      style: TextStyle(fontSize: 14.sp, height: 1, color: const Color(0xff44483D))))),
          const Center(), //we needed this to be added so that the rest of the widgets could be correctly positioned on the screen
          Positioned(
              top: 58.h,
              right: 15.w,
              child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(
                      //go to mapPage frame
                      builder: (context) => new MapPage(av_step_length: average_step_length, key: UniqueKey()),
                    )); //pass average step length to mapPage
                  },
                  style: ButtonStyle(
                      fixedSize: MaterialStateProperty.all(Size(70.w, 8.h)),
                      padding: MaterialStateProperty.all<EdgeInsets>(const EdgeInsets.all(15)),
                      backgroundColor: const MaterialStatePropertyAll<Color>(Color(0xff416914)),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)))),
                  child: Text('Start navigation',
                      style: TextStyle(color: Colors.white, fontSize: 12.sp), textAlign: TextAlign.center))),
          Positioned(
              top: 69.h,
              right: 15.w,
              child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        //go to info frame
                        builder: (context) => const InfoWidget()));
                  },
                  style: ButtonStyle(
                      fixedSize: MaterialStateProperty.all(Size(70.w, 8.h)),
                      padding: MaterialStateProperty.all<EdgeInsets>(const EdgeInsets.all(15)),
                      backgroundColor: const MaterialStatePropertyAll<Color>(Color(0xff376664)),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)))),
                  child: Text('See phone placement instructions',
                      style: TextStyle(color: Colors.white, fontSize: 12.sp), textAlign: TextAlign.center))),
          Positioned(
              top: 80.h,
              right: 15.w,
              child: ElevatedButton(
                  onPressed: () => {
                        Navigator.of(context).popUntil((route) => route.isFirst)
                      }, //pop all the frames in the stack until you find the first(main page) - it is better to pop instead of push since we do not want to fill the stack with the same pages
                  style: ButtonStyle(
                      fixedSize: MaterialStateProperty.all(Size(70.w, 8.h)),
                      padding: MaterialStateProperty.all<EdgeInsets>(const EdgeInsets.all(15)),
                      backgroundColor: const MaterialStatePropertyAll<Color>(Color(0xff376664)),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)))),
                  child: Text('Go back to home screen',
                      style: TextStyle(color: Colors.white, fontSize: 12.sp), textAlign: TextAlign.center)))
        ]));
  }
}
