import 'dart:convert';

import 'forecastday.dart';
import 'dart:ffi';

class Forecast {
  final List<Forecastday> forecastday;

  const Forecast({
    required this.forecastday,
  });

  factory Forecast.fromJson(Map<String, dynamic> json) {
    return Forecast(
      forecastday: List<dynamic>.from(json['forecastday']).map((i) => Forecastday.fromJson(i)).toList(),
    );
  }
}