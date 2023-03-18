import 'package:flutter/material.dart';
import 'frame3.dart';
import 'package:sizer/sizer.dart';

class InfoWidget extends StatefulWidget {
  const InfoWidget({Key? key}) : super(key: key);

  @override
  _InfoWidgetState createState() => _InfoWidgetState();
}

class _InfoWidgetState extends State<InfoWidget> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color(0xff9FD0CC),
        body: Stack(children: <Widget>[
          Positioned.fill(
              top: 12.h,
              bottom: 73.h,
              left: 10.w,
              right: 10.w,
              child: Container(
                  alignment: AlignmentDirectional.center,
                  padding: EdgeInsets.symmetric(vertical: 0.h, horizontal: 2.w),
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), color: const Color(0xffE1E4D5)),
                  child: Text("Start by setting your bag in front of you with its front pockets facing towards you",
                      style: TextStyle(fontSize: 16.sp, color: const Color(0xff003735))))),
          Positioned.fill(
              top: 29.h,
              bottom: 50.5.h,
              left: 10.w,
              right: 10.w,
              child: Container(
                  alignment: AlignmentDirectional.center,
                  padding: EdgeInsets.symmetric(vertical: 0.h, horizontal: 2.w),
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), color: const Color(0xffE1E4D5)),
                  child: Text(
                      "Then place your phone as flat as possible in your bag and with the camera side facing to your right side as precisely as possible too",
                      style: TextStyle(fontSize: 16.sp, color: const Color(0xff003735))))),
          Positioned.fill(
              top: 51.5.h,
              bottom: 22.h,
              left: 10.w,
              right: 10.w,
              child: Container(
                  alignment: AlignmentDirectional.center,
                  padding: EdgeInsets.symmetric(vertical: 0.h, horizontal: 2.w),
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), color: const Color(0xffE1E4D5)),
                  child: Text(
                      "To achieve that you can place in your bag, under your phone, a book or any other hard and flat object and then secure it with a piece of clothing so that it does not move around when you are walking",
                      style: TextStyle(fontSize: 16.sp, color: const Color(0xff003735))))),
          Positioned.fill(
              top: 83.h,
              bottom: 9.h,
              left: 10.5.w,
              right: 11.w,
              child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop(MaterialPageRoute(builder: (context) => const Frame3Widget()));
                  }, //pop back to frame3 - this page is not needed anymore, so there is no reason for it to remain in the stack
                  style: ButtonStyle(
                      fixedSize: MaterialStateProperty.all(Size(70.w, 8.h)),
                      padding: MaterialStateProperty.all<EdgeInsets>(const EdgeInsets.all(15)),
                      backgroundColor: const MaterialStatePropertyAll<Color>(Color(0xff376664)),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)))),
                  child: Text('I am ready', style: TextStyle(color: Colors.white, fontSize: 13.sp))))
        ]));
  }
}
