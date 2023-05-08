import 'dart:async';
import 'dart:ffi';
import 'dart:io';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:awesome_notifications/i_awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';

import 'package:flutter/cupertino.dart';

import 'package:geolocator/geolocator.dart';

import 'database/dbhelper.dart';
import 'database/markers.dart';

import 'dart:convert';
import 'package:http/http.dart' as http;
import './class/weather.dart';
import 'package:geocoding/geocoding.dart';

// MAIN CONFIG
var mainAppColor = Colors.teal;
var mainDividerColor = Colors.grey[300];
var mainColorScheme = Color.fromARGB(255, 0, 120, 120);
// Lists for MainMenuPage() and LocationsPage()
List<Markers> markersTable = [];
List<Placemark> placemarks = [];
List<Markers> markersTableOrdered = [];
List<Marker> markers2Marker = [];
LatLng currentLatLng = LatLng(45.50, -73.6);

Future<Position> _determinePosition() async {
  bool serviceEnabled;
  LocationPermission permission;

  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    return Future.error('Location services are disabled.');
  }

  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      return Future.error('Location permissions are denied');
    }
  }

  if (permission == LocationPermission.deniedForever) {
    return Future.error(
        'Location permissions are permanently denied, we cannot request permissions.');
  }

  return await Geolocator.getCurrentPosition();
}

Future<Weather> fetchWeather([String? cu]) async {
  String url =
      "http://api.weatherapi.com/v1/forecast.json?key=414984562c0a41a6991191302231804&q=${currentLatLng.latitude},${currentLatLng.longitude}&days=14&aqi=no&alerts=yes";

  final response = await http.get(Uri.parse(url));
  if (response.statusCode == 200) {
    return Weather.fromJson(jsonDecode(response.body));
  } else {
    throw Exception('Failed to load weather');
  }
}

void _insert(latitude, longitude, title, dbHelper) async {
  Map<String, dynamic> row = {
    DatabaseHelper.columnlatitude: latitude,
    DatabaseHelper.columnlongitude: longitude,
    DatabaseHelper.columntitle: title,
  };
  Markers markers = Markers.fromMap(row);
  final id = await dbHelper.insert(markers);
}

void _queryAll(context, dbHelper) async {
  final allRows = await dbHelper.queryAllRows();
  markersTable.clear();
  allRows.forEach((row) => markersTable.add(Markers.fromMap(row)));
  markers2Marker.clear();
  markersTable.forEach((element) async {
    markers2Marker.add(
      new Marker(
        markerId: MarkerId(element.title!),
        position: LatLng(element.latitude!, element.longitude!),
        infoWindow: InfoWindow(title: '${element.title}'),
        draggable: false,
        onTap: () {
          /*
          showModalBottomSheet<void>(
              context: context,
              builder: (BuildContext context) {
                return SizedBox(
                  height: 150,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20.0, 30.0, 20.0, 20.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        IconButton(onPressed: () {
                          _query(element.id,dbHelper);
                          _delete(element.id, dbHelper);
                          _queryAll(context, dbHelper);
                          Navigator.pushReplacementNamed(context, '/', arguments: null);
                        }, icon: const Icon(Icons.delete_outline)),
                        Text('Trash'),
                      ],
                    ),
                  ),
                );
              });*/
        },
      ),
    );
  });
}

void _query(title, dbHelper) async {
  final allRows = await dbHelper.queryRows(title);
  markersTableOrdered.clear();
  allRows.forEach((row) => markersTableOrdered.add(Markers.fromMap(row)));
}

void _update(id, latitude, longitude, title, dbHelper) async {
  Markers marker = Markers(id, latitude, longitude, title);
  final rowsAffected = await dbHelper.update(marker);
}

void _delete(id, dbHelper) async {
  final rowsDeleted = await dbHelper.delete(id);
}

void _deleteAll(dbHelper) async {
  final rowsDeleted = await dbHelper.deleteAll();
}

void sendNotification(var title, var body) {
  AwesomeNotifications().createNotification(
    content: NotificationContent(
        displayOnForeground: true,
        displayOnBackground: true,
        id: 10,
        channelKey: 'basic_channel',
        title: '${title}',
        body: '${body}'),
  );
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  AwesomeNotifications().initialize(
    null,
    [
      NotificationChannel(
          channelKey: 'basic_channel',
          channelName: 'Basic Notifications',
          channelDescription: 'Notify of date under notifications page')
    ],
    debug: true,
  );

  runApp(TheSquidApp());
}

class TheSquidApp extends StatelessWidget {
  const TheSquidApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Serum Squid App',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: mainColorScheme,
      ),
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: <String, WidgetBuilder>{
        '/': (context) => MainMenuPage(),
        '/LocationsPage': (context) => LocationsPage(),
        '/WeatherPage': (context) => weatherApp(),
        /*'/CalendarPage': (context) => CalendarPage(),
      '/MaintenancePage': (context) => MaintenancePage(),*/
        '/SettingsPage': (context) => SettingsPage(),
        '/Exit': (context) => logout(),
      },
    );
  }
}

class MainMenuPage extends StatefulWidget {
  MainMenuPage({Key? key}) : super(key: key);

  @override
  State<MainMenuPage> createState() => _MainMenuPageState();
}

class _MainMenuPageState extends State<MainMenuPage> {
  final dbHelper = DatabaseHelper.instance;
  TextEditingController areaNameController = TextEditingController();
  TextEditingController searchBarController = TextEditingController();

  Completer<GoogleMapController> _controller = Completer<GoogleMapController>();

  @override
  Widget build(BuildContext context) {
    final arguments = ModalRoute.of(context)!.settings.arguments;
    return Scaffold(
      appBar: CustomAppBar(),
      body: GoogleMap(
        mapType: MapType.normal,
        initialCameraPosition: CameraPosition(
          target: currentLatLng,
          zoom: 13,
        ),
        myLocationButtonEnabled: false,
        myLocationEnabled: true,
        compassEnabled: true,
        mapToolbarEnabled: false,
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
        },
        onLongPress: (LatLng latlng) {
          _insertMarkerDialog(context, latlng);
        },
        onCameraMove: (CameraPosition position) {
          currentLatLng =
              LatLng(position.target.latitude, position.target.longitude);
        },
        markers: Set<Marker>.of(markers2Marker),
        zoomControlsEnabled: false,
      ),
      drawer: NavBar(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            _goToCurrentLocation();
          });
        },
        mini: false,
        child: Icon(Icons.my_location),
        backgroundColor: mainAppColor,
      ),
    );
  }

  Future<void> _insertMarkerDialog(BuildContext context, LatLng latLng) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('New Marker Name'),
          content: TextField(
            decoration: InputDecoration(hintText: "Name Of New Marker"),
            controller: areaNameController,
          ),
          actions: <Widget>[
            ElevatedButton(
              child: Text('CANCEL'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            ElevatedButton(
              child: Text('OK'),
              onPressed: () {
                if (areaNameController.text.isNotEmpty) {
                  setState(() {
                    _insert(latLng.latitude, latLng.longitude,
                        areaNameController.text, dbHelper);
                    _queryAll(context, dbHelper);
                  });
                  Navigator.pop(context);
                } else {
                  SnackBar(
                    content: Text('No name given!'),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _goToCurrentLocation() async {
    await _determinePosition();
    Position position = await _determinePosition();
    final GoogleMapController controller = await _controller.future;
    setState(() {
      currentLatLng = LatLng(position.latitude, position.longitude);
      controller.animateCamera(CameraUpdate.newCameraPosition(
          CameraPosition(target: currentLatLng, zoom: 16.0)));
    });
  }
}

class LocationsPage extends StatefulWidget {
  const LocationsPage({Key? key}) : super(key: key);

  @override
  State<LocationsPage> createState() => _LocationsPageState();
}
Future<Placemark> GetPosition(double? latitude, double? longitude) async {
  placemarks = await placemarkFromCoordinates(latitude!, longitude!);
  return placemarks.first;
}

class _LocationsPageState extends State<LocationsPage> {
  final dbHelper = DatabaseHelper.instance;

  @override
  Widget build(BuildContext context) {
    _queryAll(context, dbHelper);
    return Scaffold(
      appBar: CustomAppBar(),
      body: Center(
          child: Column(
        children: [
          Expanded(
            child: ListView.builder(
                scrollDirection: Axis.vertical,
                padding: EdgeInsets.all(10),
                itemCount: markersTable.length,
                itemBuilder: (BuildContext context, int index) {
                  Placemark newplace = GetPosition(markersTable[index].latitude, markersTable[index].longitude) as Placemark;
                  return Card(
                    child: ListTile(
                        leading: Icon(Icons.notifications),
                        title: Text('${markersTable[index].title}'),
                        subtitle: Text(
                            '${newplace.street} - ${newplace.administrativeArea}'),
                        onTap: () {
                          showModalBottomSheet<void>(
                              context: context,
                              builder: (BuildContext context) {
                                return SizedBox(
                                  height: 150,
                                  child: Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 32.0),
                                    child: ListView(
                                      shrinkWrap: true,
                                      scrollDirection: Axis.horizontal,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                              20.0, 30.0, 20.0, 20.0),
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              IconButton(
                                                  onPressed: () {
                                                    currentLatLng = LatLng(
                                                        double.parse(
                                                            markersTable[index]
                                                                .latitude
                                                                .toString()),
                                                        double.parse(
                                                            markersTable[index]
                                                                .longitude
                                                                .toString()));
                                                    Navigator
                                                        .pushReplacementNamed(
                                                            context, '/',
                                                            arguments: null);
                                                  },
                                                  icon: const Icon(Icons.map)),
                                              Text('Map'),
                                            ],
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                              20.0, 30.0, 20.0, 20.0),
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              IconButton(
                                                  onPressed: () {},
                                                  icon: const Icon(
                                                      Icons.update_outlined)),
                                              Text('Update'),
                                            ],
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                              20.0, 30.0, 20.0, 20.0),
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              IconButton(
                                                  onPressed: () {
                                                    _query(
                                                        markersTable[index].id,
                                                        dbHelper);
                                                    _delete(
                                                        markersTable[index]
                                                            .id
                                                            ?.toInt(),
                                                        dbHelper);
                                                    _queryAll(context, dbHelper);
                                                    Navigator.pushReplacementNamed(context,'/LocationsPage', arguments: null);
                                                  },
                                                  icon: const Icon(
                                                      Icons.delete_outline)),
                                              Text('Trash'),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              });
                        }),
                  );
                }),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _deleteAll(dbHelper);
                _queryAll(context, dbHelper);
              });
              Navigator.pushReplacementNamed(context, '/', arguments: null);
            },
            child: Text("Delete All Locations"),
          ),
        ],
      )),
      drawer: NavBar(),
    );
  }
}

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(),
      body: Center(
        child: Column(
          children: [],
        ),
      ),
      drawer: NavBar(),
    );
  }
}

class CustomAppBar extends AppBar {
  CustomAppBar()
      : super(
          backgroundColor: mainAppColor,
          title: Text(
            "SquidApp",
          ),
        );
/*
iconTheme: IconThemeData(
color: Colors.black, //change your color here
),
backgroundColor: Colors.white,
title: Text(
"this is app bar",
style: TextStyle(color: Color(Constant.colorBlack)),
),
elevation: 0.0,
automaticallyImplyLeading: false,
actions: <Widget>[
IconButton(
icon: Icon(Icons.notifications),
onPressed: () => null,
),
IconButton(
icon: Icon(Icons.person),
onPressed: () => null,
),
],
*/
}

class NavBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: <Widget>[
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: <Widget>[
                Container(
                  padding: EdgeInsets.all(30),
                  color: mainAppColor,
                  child: Row(
                    children: <Widget>[
                      Image.network(
                        'https://cdn.icon-icons.com/icons2/2108/PNG/512/flutter_icon_130936.png',
                        fit: BoxFit.cover,
                        width: 90,
                        height: 90,
                      ),
                    ],
                  ),
                ),
                ListTile(
                  leading: Icon(Icons.home),
                  title: Text('Home Page'),
                  onTap: () => Navigator.pushReplacementNamed(context, '/',
                      arguments: null),
                ),
                ListTile(
                  leading: Icon(Icons.share_location),
                  title: Text('Locations'),
                  onTap: () => Navigator.pushReplacementNamed(
                      context, '/LocationsPage',
                      arguments: null),
                ),
                ListTile(
                  leading: Icon(Icons.thermostat),
                  title: Text('Weather'),
                  onTap: () => Navigator.pushReplacementNamed(
                      context, '/WeatherPage',
                      arguments: null),
                ),
                /*ListTile(
                  leading: Icon(Icons.notifications),
                  title: Text('Calendar'),
                  onTap: () =>
                      Navigator.pushReplacementNamed(context, '/CalendarPage',
                          arguments: null),
                ),
                ListTile(
                  leading: Icon(Icons.notifications),
                  title: Text('Maintenance'),
                  onTap: () =>
                      Navigator.pushReplacementNamed(context, '/MaintenancePage',
                          arguments: null),
                ),*/
              ],
            ),
          ),
          Container(
              child: Align(
                  alignment: FractionalOffset.bottomCenter,
                  child: Container(
                      child: Column(
                    children: <Widget>[
                      CustomDivider(),
                      ListTile(
                        leading: Icon(Icons.settings),
                        title: Text('Settings'),
                        onTap: () => Navigator.pushReplacementNamed(
                            context, '/SettingsPage',
                            arguments: null),
                      ),
                      ListTile(
                        title: Text('Exit'),
                        leading: Icon(Icons.logout),
                        onTap: () => Navigator.pushReplacementNamed(
                            context, '/Exit',
                            arguments: null),
                      ),
                    ],
                  ))))
        ],
      ),
    );
  }
}

class logout extends StatelessWidget {
  const logout({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(),
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Are you sure you want to exit?",
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      SystemNavigator.pop();
                    },
                    child: Text("Yes"),
                  ),
                ),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      sendNotification("TYYY", "<333333");
                    },
                    child: Text("No"),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
      drawer: NavBar(),
    );
  }
}

class CustomDivider extends StatelessWidget {
  final double? thickness;
  final double? indent;
  final double? endIndent;

  CustomDivider({this.thickness = 2, this.indent = 5, this.endIndent = 5});

  @override
  Widget build(BuildContext context) {
    return Divider(
      color: Colors.grey[300],
      thickness: thickness,
      indent: indent,
      endIndent: endIndent,
    );
  }
}

class weatherApp extends StatefulWidget {
  const weatherApp({Key? key}) : super(key: key);

  @override
  State<weatherApp> createState() => _weatherAppState();
}

class _weatherAppState extends State<weatherApp> {
  late Future<Weather> futureWeather;

  @override
  void initState() {
    super.initState();
    futureWeather = fetchWeather();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(),
      body: SafeArea(
        child: FutureBuilder<Weather>(
          future: futureWeather,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              // Removes all previous hour data before current time.
              snapshot.data!.forecast.forecastday[0].hour.removeWhere(
                  (element) => DateTime.parse(element.time)
                      .isBefore(DateTime.now().subtract(Duration(hours: 1))));
              final PageController controller = PageController();
              return PageView(
                controller: controller,
                children: <Widget>[
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(height: 4),
                            Text(
                              snapshot.data!.location.name,
                              style: TextStyle(
                                  fontSize: 32, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              "${DateFormat('yMMMMEEEEd').format(DateTime.parse(snapshot.data!.location.localtime))}",
                              style: TextStyle(fontSize: 24),
                            ),
                            Text(
                              '${snapshot.data!.current.condition.text}',
                              style: TextStyle(fontSize: 24),
                            ),
                            Image.network(
                              '${snapshot.data!.current.condition.icon}',
                              fit: BoxFit.cover,
                              width: 96,
                              height: 96,
                            ),
                            SizedBox(height: 8),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  '${snapshot.data!.current.temp_c}°C',
                                  style: TextStyle(
                                    fontSize: 64,
                                    color: Colors.black,
                                    fontFamily: "sans-serif-light",
                                  ),
                                ),
                                Text(
                                  '${snapshot.data!.current.temp_f}°F',
                                  style: TextStyle(
                                    fontSize: 32,
                                    color: Colors.black,
                                    fontFamily: "sans-serif-light",
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 8),
                            IntrinsicHeight(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  _minMaxRowData(
                                      stringInput: 'max',
                                      tempInput: snapshot.data!.forecast
                                          .forecastday[0].day.maxtempC),
                                  VerticalDivider(
                                    thickness: 2,
                                  ),
                                  _minMaxRowData(
                                      stringInput: 'min',
                                      tempInput: snapshot.data!.forecast
                                          .forecastday[0].day.mintempC),
                                ],
                              ),
                            ),
                            SizedBox(height: 8),
                          ],
                        ),
                      ),
                      Divider(
                        height: 24,
                        thickness: 2,
                        indent: 20,
                        endIndent: 20,
                      ),
                      Expanded(
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: EdgeInsets.all(10),
                          itemCount: 24,
                          itemBuilder: (BuildContext context, int index) {
                            if (snapshot.data!.forecast.forecastday.length <=
                                24) {
                              for (int hourindex = 0;
                                  hourindex <
                                      (24 -
                                          snapshot.data!.forecast.forecastday
                                              .length);
                                  hourindex++) {
                                snapshot.data!.forecast.forecastday[0].hour.add(
                                    snapshot.data!.forecast.forecastday[1]
                                        .hour[hourindex]);
                              }
                            }
                            DateTime date = DateTime.parse(snapshot.data!
                                .forecast.forecastday[0].hour[index].time);
                            return Container(
                              padding: EdgeInsets.all(10),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  _TempWidget(
                                      dateInput: date,
                                      iconUrl: snapshot
                                          .data!
                                          .forecast
                                          .forecastday[0]
                                          .hour[index]
                                          .condition
                                          .icon,
                                      tempC: snapshot.data!.forecast
                                          .forecastday[0].hour[index].tempC),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                      Divider(
                        height: 24,
                        thickness: 2,
                        indent: 20,
                        endIndent: 20,
                      ),
                      Expanded(
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          padding: EdgeInsets.all(10),
                          children: [
                            _ExtraDataBottom(
                              Name: "wind speed",
                              inputData:
                                  (snapshot.data!.current.wind_kph).toString(),
                              Extra: " km/h",
                            ),
                            VerticalDivider(
                              thickness: 2,
                              endIndent: 40,
                              indent: 40,
                            ),
                            _ExtraDataBottom(
                              Name: "sunrise",
                              inputData: (snapshot.data!.forecast.forecastday[0]
                                      .astro.sunrise)
                                  .toString(),
                              Extra: "",
                            ),
                            VerticalDivider(
                              thickness: 2,
                              endIndent: 40,
                              indent: 40,
                            ),
                            _ExtraDataBottom(
                              Name: "sunset",
                              inputData: (snapshot.data!.forecast.forecastday[0]
                                      .astro.sunset)
                                  .toString(),
                              Extra: "",
                            ),
                            VerticalDivider(
                              thickness: 2,
                              endIndent: 40,
                              indent: 40,
                            ),
                            _ExtraDataBottom(
                              Name: "humidty",
                              inputData: (snapshot.data!.forecast.forecastday[0]
                                      .day.avghumidity)
                                  .toString(),
                              Extra: "%",
                            ),
                            VerticalDivider(
                              thickness: 2,
                              endIndent: 40,
                              indent: 40,
                            ),
                            _ExtraDataBottom(
                              Name: "wind point",
                              inputData: (snapshot.data!.forecast.forecastday[0]
                                      .hour[0].windDir)
                                  .toString(),
                              Extra: "",
                            ),
                            VerticalDivider(
                              thickness: 2,
                              endIndent: 40,
                              indent: 40,
                            ),
                            _ExtraDataBottom(
                              Name: "visibility",
                              inputData: (snapshot.data!.forecast.forecastday[0]
                                      .hour[0].visKm)
                                  .toString(),
                              Extra: " km",
                            ),
                            VerticalDivider(
                              thickness: 2,
                              endIndent: 40,
                              indent: 40,
                            ),
                            _ExtraDataBottom(
                              Name: "moon phase",
                              inputData: (snapshot.data!.forecast.forecastday[0]
                                  .astro.moon_phase),
                              Extra: "",
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(height: 4),
                      Text(
                        snapshot.data!.location.name,
                        style: TextStyle(
                            fontSize: 32, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        "${DateFormat('yMMMMEEEEd').format(DateTime.parse(snapshot.data!.location.localtime))}",
                        style: TextStyle(fontSize: 24),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.network(
                            '${snapshot.data!.current.condition.icon}',
                            fit: BoxFit.cover,
                            width: 96,
                            height: 96,
                          ),
                          Text(
                            '${snapshot.data!.current.temp_c}°C',
                            style: TextStyle(
                              fontSize: 64,
                              color: Colors.black,
                              fontFamily: "sans-serif-light",
                            ),
                          ),
                          SizedBox(height: 4),
                        ],
                      ),
                      Expanded(
                        child: ListView.builder(
                          scrollDirection: Axis.vertical,
                          padding: EdgeInsets.all(10),
                          itemCount: snapshot.data!.forecast.forecastday.length,
                          itemBuilder: (BuildContext context, int index) {
                            return Card(
                              child: ListTile(
                                leading: Image.network(snapshot.data!.forecast
                                    .forecastday[index].day.condition.icon),
                                title: Text(
                                  "${DateFormat('d MMMM,').format(DateTime.parse(snapshot.data!.forecast.forecastday[index].date))}",
                                  style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold),
                                ),
                                subtitle: Text(
                                  "${snapshot.data!.forecast.forecastday[index].day.avgtempC.toString()}°C\n${snapshot.data!.forecast.forecastday[index].day.condition.text}",
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              );
            } else {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
          },
        ),
      ),
      drawer: NavBar(),
    );
  }
}

class _ExtraDataBottom extends StatelessWidget {
  final String Name;
  final String inputData;
  final String Extra;

  _ExtraDataBottom(
      {required this.Name, required this.inputData, required this.Extra});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(15),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            "${Name}",
            style: TextStyle(
              fontSize: 16,
            ),
          ),
          Text(
            "${inputData}${Extra}",
            style: TextStyle(
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}

class _TempWidget extends StatelessWidget {
  final DateTime dateInput;
  final String iconUrl;
  final double tempC;

  _TempWidget(
      {required this.dateInput, required this.iconUrl, required this.tempC});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          "${DateFormat('E,').add_j().format(dateInput)}",
          style: TextStyle(
            fontSize: 16,
          ),
        ),
        Image.network(
          iconUrl,
        ),
        Text(
          "${tempC}°C",
          style: TextStyle(
            fontSize: 16,
          ),
        ),
      ],
    );
  }
}

class _minMaxRowData extends StatelessWidget {
  final String stringInput;
  final double tempInput;

  _minMaxRowData({required this.stringInput, required this.tempInput});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          "${stringInput}",
          style: TextStyle(
            fontSize: 16,
          ),
        ),
        SizedBox(height: 12),
        Text(
          '${tempInput}',
          style: TextStyle(
            fontSize: 16,
            color: Colors.black,
          ),
        ),
      ],
    );
  }
}
