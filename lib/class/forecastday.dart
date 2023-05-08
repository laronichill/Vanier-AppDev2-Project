import 'dart:ffi';
import './astro.dart';
import './day.dart';
import './hour.dart';

class Forecastday {
  final String date;
  final int date_epoch;
  final Day day;
  final Astro astro;
  final List<Hour> hour;

  Forecastday({
      required this.date,
      required this.date_epoch,
      required this.day,
      required this.astro,
      required this.hour
    });

  factory Forecastday.fromJson(Map<String, dynamic> json) {
    return Forecastday(
      date: json['date'],
      date_epoch: json['date_epoch'],
      day: Day.fromJson(Map<String, dynamic>.from(json['day'])),
      astro: Astro.fromJson(Map<String, dynamic>.from(json['astro'])),
      hour: List<dynamic>.from(json['hour']).map((i) => Hour.fromJson(i)).toList(),
    );
  }

}
