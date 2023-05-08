import 'dart:convert';
import 'package:flutter/material.dart';
import './class/weather.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';


var perfGrey = Colors.grey[250];
var perfTextColor = Colors.grey[500];
var perfFont = "Avenir";

Future<Weather> fetchWeather() async {
  final response = await http.get(Uri.parse(
      'http://api.weatherapi.com/v1/forecast.json?key=414984562c0a41a6991191302231804&q=Montreal&days=14&aqi=no&alerts=yes'));

  if (response.statusCode == 200) {
    return Weather.fromJson(jsonDecode(response.body));
  } else {
    throw Exception('Failed to load weather');
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
        backgroundColor: Colors.white,
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
                  /// [PageView.scrollDirection] defaults to [Axis.horizontal].
                  /// Use [Axis.vertical] to scroll vertically.
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
                              SizedBox(height: 32),
                              Text(
                                snapshot.data!.location.name,
                                style: TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: perfFont),
                              ),
                              Text(
                                "${DateFormat('yMMMMEEEEd').format(DateTime.parse(snapshot.data!.location.localtime))}",
                                style: TextStyle(
                                    fontSize: 24,
                                    fontFamily: perfFont),
                              ),
                              SizedBox(height: 16),
                              Text(
                                '${snapshot.data!.current.condition.text}',
                                style: TextStyle(
                                    fontSize: 24,
                                    color: perfTextColor,
                                    fontFamily: perfFont),
                              ),
                              SizedBox(height: 32),
                              Image.network(
                                '${snapshot.data!.current.condition.icon}',
                              ),
                              SizedBox(height: 32),
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
                                  SizedBox(height: 16),
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
                              SizedBox(height: 32),
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
                                      color: perfGrey,
                                      thickness: 2,
                                    ),
                                    _minMaxRowData(
                                        stringInput: 'min',
                                        tempInput: snapshot.data!.forecast
                                            .forecastday[0].day.mintempC),
                                  ],
                                ),
                              ),
                              SizedBox(height: 32),
                            ],
                          ),
                        ),
                        Divider(
                          height: 24,
                          thickness: 2,
                          indent: 20,
                          endIndent: 20,
                          color: perfGrey,
                        ),
                        Expanded(
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            padding: EdgeInsets.all(10),
                            itemCount: snapshot
                                .data!.forecast.forecastday[0].hour.length,
                            itemBuilder: (BuildContext context, int index) {
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
                          color: perfGrey,
                        ),
                        Expanded(
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            padding: EdgeInsets.all(10),
                            children: [
                              _ExtraDataBottom(
                                Name: "wind speed",
                                inputData: (snapshot.data!.current.wind_kph)
                                    .toString(),
                                Extra: " km/h",
                              ),
                              VerticalDivider(
                                color: perfGrey,
                                thickness: 2,
                                endIndent: 40,
                                indent: 40,
                              ),
                              _ExtraDataBottom(
                                Name: "sunrise",
                                inputData: (snapshot.data!.forecast
                                        .forecastday[0].astro.sunrise)
                                    .toString(),
                                Extra: "",
                              ),
                              VerticalDivider(
                                color: perfGrey,
                                thickness: 2,
                                endIndent: 40,
                                indent: 40,
                              ),
                              _ExtraDataBottom(
                                Name: "sunset",
                                inputData: (snapshot.data!.forecast
                                        .forecastday[0].astro.sunset)
                                    .toString(),
                                Extra: "",
                              ),
                              VerticalDivider(
                                color: perfGrey,
                                thickness: 2,
                                endIndent: 40,
                                indent: 40,
                              ),
                              _ExtraDataBottom(
                                Name: "humidty",
                                inputData: (snapshot.data!.forecast
                                        .forecastday[0].day.avghumidity)
                                    .toString(),
                                Extra: "%",
                              ),
                              VerticalDivider(
                                color: perfGrey,
                                thickness: 2,
                                endIndent: 40,
                                indent: 40,
                              ),
                              _ExtraDataBottom(
                                Name: "wind point",
                                inputData: (snapshot.data!.forecast
                                        .forecastday[0].hour[0].windDir)
                                    .toString(),
                                Extra: "",
                              ),
                              VerticalDivider(
                                color: perfGrey,
                                thickness: 2,
                                endIndent: 40,
                                indent: 40,
                              ),
                              _ExtraDataBottom(
                                Name: "visibility",
                                inputData: (snapshot.data!.forecast
                                        .forecastday[0].hour[0].visKm)
                                    .toString(),
                                Extra: " km",
                              ),
                              VerticalDivider(
                                color: perfGrey,
                                thickness: 2,
                                endIndent: 40,
                                indent: 40,
                              ),
                              _ExtraDataBottom(
                                Name: "moon phase",
                                inputData: (snapshot.data!.forecast
                                    .forecastday[0].astro.moon_phase),
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
                        SizedBox(height: 32),
                        Text(
                          snapshot.data!.location.name,
                          style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              fontFamily: perfFont),
                        ),
                        Text(
                          "${DateFormat('yMMMMEEEEd').format(DateTime.parse(snapshot.data!.location.localtime))}",
                          style: TextStyle(
                              fontSize: 24,
                              fontFamily: perfFont),
                        ),
                        SizedBox(height: 16),
                        Text(
                          '${snapshot.data!.current.condition.text}',
                          style: TextStyle(
                              fontSize: 24,
                              color: perfTextColor,
                              fontFamily: perfFont),
                        ),
                        SizedBox(height: 32),
                        Image.network(
                          '${snapshot.data!.current.condition.icon}',
                        ),
                        SizedBox(height: 32),
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
                            SizedBox(height: 16),
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
                        Expanded(
                          child: ListView.builder(
                            scrollDirection: Axis.vertical,
                            padding: EdgeInsets.all(10),
                            itemCount:
                                snapshot.data!.forecast.forecastday.length,
                            itemBuilder: (BuildContext context, int index) {
                              return Card(
                                child: ListTile(
                                  leading: Image.network(snapshot.data!.forecast
                                      .forecastday[index].day.condition.icon),
                                  title: Text(
                                    "${DateFormat('d MMMM,').format(DateTime.parse(snapshot.data!.forecast.forecastday[index].date))}",
                                    style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: perfFont),
                                  ),
                                  subtitle: Text(
                                    "${snapshot.data!.forecast.forecastday[index].day.avgtempC.toString()}°C\n${snapshot.data!.forecast.forecastday[index].day.condition.text}",
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: perfFont),
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
              color: perfTextColor,
              fontFamily: "Avenir",
            ),
          ),
          Text(
            "${inputData}${Extra}",
            style: TextStyle(
              fontSize: 16,
              color: Colors.black,
              fontFamily: "Avenir",
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
            color: perfTextColor,
            fontFamily: "Avenir",
          ),
        ),
        Image.network(
          iconUrl,
        ),
        Text(
          "${tempC}°C",
          style: TextStyle(
            fontSize: 16,
            color: perfTextColor,
            fontFamily: "Avenir",
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
            color: perfTextColor,
            fontFamily: perfFont,
          ),
        ),
        SizedBox(height: 12),
        Text(
          '${tempInput}',
          style: TextStyle(
            fontSize: 16,
            color: Colors.black,
            fontFamily: perfFont,
          ),
        ),
      ],
    );
  }
}
