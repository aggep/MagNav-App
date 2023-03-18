import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:pedometer/pedometer.dart';
import 'package:sizer/sizer.dart';
import 'main.dart';
import 'frame3.dart';

class MapPage extends StatefulWidget {
  //const MapPage({super.key});
  final double av_step_length;
  MapPage({Key? key, required this.av_step_length}) : super(key: key);

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  //pedometer step count stream
  late Stream<StepCount> _stepCountStream;
  int _steps = 0;

  //list of paths of icons
  List<String> images = [
    'assets/images/icon0_1.png',
    'assets/images/icon0_2.png',
    'assets/images/icon1_main.png',
  ];

  //created empty list of markers
  List<Marker> _markers = <Marker>[];

  //create and initialize current_position variable to be used to display calculated current location
  //in real world use it will be set with location signal
  static double current_latitude = 38.212320;
  static double current_longitude = 23.732689;
  static LatLng current_position = LatLng(current_latitude, current_longitude);

  //calculate meters per 1 degree of latitude at the current_posiiton I also convert lat to rads from degrees
  static double meters_per_1deg_of_lat = 111132.92 -
      559.82 * cos(2 * pi / 360 * current_latitude) +
      1.175 * cos(4 * 2 * pi / 360 * current_latitude) -
      0.0023 * cos(6 * 2 * pi / 360 * current_latitude);

  //calculate meters per 1 degree of longitude at the current_posiiton
  static double meters_per_1deg_of_long = 111412.84 * cos(2 * pi / 360 * current_latitude) -
      93.5 * cos(3 * 2 * pi / 360 * current_latitude) +
      0.118 * cos(5 * 2 * pi / 360 * current_latitude);

  //we consider the above values constant for our calculations as the distance traveled using this app
  //will not be large enough to really change them

  //compass direction variable (value in degrees)
  double step_direction = 100;

  //when it is true compass listener is activated and when it is false it is deactivated
  static bool compass_listener_on = false;

  //create and initialize intermediate_position variable to be used for location calculation
  LatLng intermediate_position = current_position;

  //location_is_centred is true if camera is centered to current location
  bool location_is_centered = true;

  //step length in meters
  double step_length_m = 10;

  //varable for counting steps
  int step_count = 0;

  //flutter compass listener stream subscription
  late StreamSubscription sub;

  //if true it means location data is availiable
  bool location_data_on = false; //starting at false for demo purposes

  //list for map marker icons
  static List<BitmapDescriptor> Icon_Images = [];

  //shows if pedometer listener has been started
  bool pedometer_not_first_time = false;

  //declared method to get Images
  Future<Uint8List> getImages(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(), targetHeight: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!.buffer.asUint8List();
  }

  @override
  void initState() {
    super.initState();

    //initialize current position//this way for demo purposes (in real world use it will be set using location signal)
    current_position = LatLng(current_latitude, current_longitude);

    //set step_length_m to 10*average_step_length as taken from frame3 fro demo purposes
    step_length_m = 10 *
        (widget.av_step_length /
            100); //in real world use it would be set equal (/100 because average_step_length is in cm)

    //initilize pedometer
    initPlatformState();

    //compass event listener
    sub = (FlutterCompass.events!.listen(
      (event) {
        //listener only sets state if compass_listener_on is true to avoid always calling setState when a compass event happens (i.e all the time)
        //compass listener is then set to false
        if (compass_listener_on) {
          step_direction = event.heading! -
              90; //get new direction (0 is when the forward direction as specified in the app instructios in North)
          compass_listener_on = false; //execute only once

          //calculate lat lng offset
          List<double> offsets = lat_long_offset();

          //chage markers
          change_markers(_markers.length, offsets[0], offsets[1]);
        }
      },
    )) as StreamSubscription;

    initialize_location();
  }

  //on step count event execute compass listener actions if this is is the first time a step event happens
  //if it is just set pedometer_not_first_time to true (we do this to avoid counting a step event when the pedometer listener starts)
  void onStepCount(StepCount event) {
    if (pedometer_not_first_time) {
      compass_listener_on = true;
      _steps += 1;
    } else {
      pedometer_not_first_time = true;
    }
  }

  //method for initializing pedometer
  void initPlatformState() {
    _stepCountStream = Pedometer.stepCountStream;
    _stepCountStream.listen(onStepCount).onError(onStepCountError);
  }

  //step count error handeler
  void onStepCountError(error) {
    print('onStepCountError: $error');
  }

  //method for initializing location
  initialize_location() async {
    //load icon images for map markers
    Icon_Images.add(BitmapDescriptor.fromBytes(await getImages(images[0], 40)));
    Icon_Images.add(BitmapDescriptor.fromBytes(await getImages(images[1], 40)));
    Icon_Images.add(BitmapDescriptor.fromBytes(await getImages(images[2], 60)));

    //set initial map marker
    final start_marker = Marker(
      //set marker id
      markerId: MarkerId(0.toString()),

      //set marker icon to show that this marker reflects current position
      icon: Icon_Images[2],

      //set current position
      position: current_position,

      infoWindow: InfoWindow(
        // given title for marker
        title: 'Location: ' + 0.toString(),
      ),
    );

    //refresh map state
    setState(() {
      _markers.add(start_marker);
    });
  }

  //function for coverting a vector offset (mag(meters), direction(degrees)) to a latitiude, longitude offset
  List<double> lat_long_offset() {
    double x, y;
    y = step_length_m * cos(2 * pi / 360 * step_direction); //get offset in meters along the latitude axis
    x = step_length_m * sin(2 * pi / 360 * step_direction); //get offset in meters along the longitude axis

    double lat_offset = y / meters_per_1deg_of_lat;
    double long_offset = x / meters_per_1deg_of_long; //calculate offsets in degrees

    return [lat_offset, long_offset]; //return offsets
  }

  //function for setting new markers
  change_markers(int mark_num, double latitide_Add, double longitude_Add) async {
    LatLng inter_position =
        LatLng(current_position.latitude + latitide_Add, current_position.longitude + longitude_Add);

    step_count++; //increase step count by 1

    if (step_count % 1 == 0) {
      //if step count is multiple of 1 //for demo purposes (in real world use will be set around 10)
      LatLng new_position = inter_position;

      //create new marker
      final new_mark = Marker(
        // given marker id
        markerId: MarkerId(mark_num.toString()),

        //set marker icon to show that this marker reflects current position
        icon: Icon_Images[2],

        //set new position
        position: new_position,

        infoWindow: InfoWindow(
          //title for marker (not really necessary)
          title: 'Location: ' + mark_num.toString(),
        ),
      );

      //I also change the icon of the last marker to show that it now reflects a previous position
      final old_mark = Marker(
        markerId: MarkerId((mark_num - 1).toString()),

        //set marker icon to show that this marker reflects prev position acording to the availiability of location data
        icon: (location_data_on) ? Icon_Images[1] : Icon_Images[0],

        position: current_position,

        infoWindow: InfoWindow(
          //title for marker (not really necessary)
          title: 'Location: ' + (mark_num - 1).toString(),
        ),
      );

      //recenter camera to new position
      GoogleMapController controller = await _controller.future;
      controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
        //center camera at new position
        target: new_position,
        zoom: 19,
      )));

      //set current_position = new_position
      current_position = new_position;

      //refresh map state to reflect new marks
      setState(() {
        //set the new and refreshed old markers to _markers list and map
        _markers.removeLast();
        _markers.add(old_mark);
        _markers.add(new_mark);

        //set location_is_centered to true to show that camera is centered in current location
        location_is_centered = true;

        //set compass listener to false
        compass_listener_on = false;
      });
    }
  }

  //
  final Completer<GoogleMapController> _controller = Completer();
  //

  //set initial camera position
  final LatLng _center = current_position;

  //to be called to set controller when map is created
  void _onMapCreated(GoogleMapController controller) {
    _controller.complete(controller);
  }

  @override
  Widget build(BuildContext context) {
    //pass av_step_length to MapPageState
    widget.av_step_length;

    //Bulid Map Page
    return MaterialApp(
      home: Scaffold(
        //create app bar
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(30),
          child: AppBar(
            title: const Text(''), //no title
            backgroundColor: Color.fromARGB(255, 56, 102, 99),
          ),
        ),

        //put map in a listener to check if camera position has changed with user drag
        //to change apearance of recentering fab
        body: Listener(
          onPointerMove: (move) {
            setState(() {
              location_is_centered = false;
            });
          },
          child: GoogleMap(
            onMapCreated: _onMapCreated,

            initialCameraPosition: CameraPosition(
              target: _center,
              zoom: 12.0,
            ),

            mapType: MapType.satellite, //for satellite view

            markers: Set<Marker>.of(_markers),

            compassEnabled: true,
            zoomControlsEnabled: false,
          ),
        ),

        //on below line we are creating floating action object to hold all of the pages buttons
        floatingActionButton: Column(
          children: [
            //put transparent app bar in the top of screen (it is easier to offset the actual app bar this way)
            PreferredSize(
              preferredSize: Size.fromHeight(30),
              child: AppBar(
                title: const Text(''), //no title for now
                backgroundColor: Colors.transparent,
              ),
            ),

            const SizedBox(height: 10),

            //exit navigation button
            Container(
              height: 45,
              width: 220,
              child: FloatingActionButton.extended(
                onPressed: () {
                  showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                            backgroundColor: Color.fromARGB(255, 42, 48, 44),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                            title: const Text('Are you sure you want to end navigation?',
                                style: TextStyle(color: Color.fromARGB(255, 230, 226, 221))),
                            content: const Text(
                                'If you proceed all location data that the app has calculated for this trip so far will be lost',
                                style: TextStyle(color: Color.fromARGB(255, 203, 198, 189))),
                            actions: [
                              //when yes is pressed go to home screen
                              TextButton(
                                  onPressed: () => {
                                        //remove compass listener (otherwise Compass listener malfunctions )
                                        sub.cancel(),

                                        Navigator.of(context)
                                            .popUntil((route) => route.isFirst) //pop until home screen is reached
                                      },
                                  child:
                                      const Text('yes', style: TextStyle(color: Color.fromARGB(255, 211, 199, 139)))),
                              //when no is pressed exit dialog
                              TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('no', style: TextStyle(color: Color.fromARGB(255, 211, 199, 139))))
                            ],
                          ));
                },
                heroTag: "her1",
                label: Text("end navigation",
                    style: TextStyle(
                        color: Color.fromARGB(255, 29, 55, 0),
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.bold,
                        fontSize: 16),
                    textAlign: TextAlign.center),
                backgroundColor: Color.fromARGB(255, 166, 213, 116),
              ),
            ),

            Expanded(
              child: Align(
                alignment: FractionalOffset.topRight,
                child: Row(
                  children: [
                    const Spacer(),
                    Container(
                      height: 22,
                      width: 22,
                      child: FloatingActionButton(
                        onPressed: () {
                          setState(() {
                            location_data_on = !(location_data_on); //invert location_data_on
                          });
                        },
                        heroTag: "her_indicator",
                        backgroundColor:
                            (location_data_on) ? Color.fromARGB(255, 233, 245, 214) : Color.fromARGB(255, 255, 84, 73),
                        shape: RoundedRectangleBorder(
                          borderRadius: const BorderRadius.all(
                            Radius.circular(25),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 40),
                  ],
                ),
              ),
            ),

            //use expanded widget to place row to bottom of column
            Expanded(
              child: Align(
                alignment: FractionalOffset.bottomRight,
                child: Row(
                  children: [
                    //set position of fabs
                    const Spacer(),
                    const SizedBox(height: 80),

                    //button for exiting navigation mode
                    //I put it inside a container to set size
                    Container(
                      height: 60,
                      width: 60,
                      child: FloatingActionButton(
                        onPressed: () {
                          //set compass_listener_on to true so that the flutter compass listener calls setState and refreshes step_direction ++all else
                          compass_listener_on = true;
                        },
                        heroTag: "her2",
                        backgroundColor: Color.fromARGB(255, 107, 0, 150),
                        child: const Icon(Icons.add),
                      ),
                    ),

                    const SizedBox(width: 10),

                    //fab to recenter camera position to current location
                    //I put it inside a container to set size
                    Container(
                      height: 65,
                      width: 65,
                      child: FloatingActionButton(
                        //when pressed set camera position to current_position
                        onPressed: () async {
                          GoogleMapController controller = await _controller.future;
                          controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
                            //center camera at current posiition
                            target: current_position,
                            zoom: 18,
                          )));
                          setState(() {
                            //make button apear checked
                            location_is_centered = true;
                          });
                        },
                        heroTag: "her3",
                        backgroundColor: Color.fromARGB(255, 232, 236, 220),

                        //if camera position is centerd on current location then show fab icon
                        //as checked radio button and if not then show it as unckecked
                        child: (location_is_centered)
                            ? Icon(
                                Icons.radio_button_checked,
                                color: Color.fromARGB(255, 65, 105, 20),
                              )
                            : Icon(
                                Icons.radio_button_unchecked,
                                color: Color.fromARGB(255, 100, 105, 120),
                              ),
                        //set shape to resemble figma fab
                        shape: RoundedRectangleBorder(
                          borderRadius: const BorderRadius.all(
                            Radius.circular(25),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 30),
                  ],
                ),
              ),
            ),
          ],
        ),

        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      ),
    );
  }
}
