import 'package:decimal/decimal.dart';

import './condition.dart';
import './air_quality.dart';

class Current {
  final int last_updated_epoch;
  final String last_updated;
  final double temp_c;
  final double temp_f;
  final int is_day;
  final Condition condition;
  final double wind_mph;
  final double wind_kph;
  final int wind_degree;
  final String wind_dir;
  final double pressure_mb;
  final double pressure_in;
  final double precip_mm;
  final double precip_in;
  final int humidity;
  final int cloud;
  final double feelslike_c;
  final double feelslike_f;
  final double vis_km;
  final double vis_miles;
  final double uv;
  final double gust_mph;
  final double gust_kph;


  const Current({
    required this.last_updated_epoch,
    required this.last_updated,
    required this.temp_c,
    required this.temp_f,
    required this.is_day,
    required this.condition,
    required this.wind_mph,
    required this.wind_kph,
    required this.wind_degree,
    required this.wind_dir,
    required this.pressure_mb,
    required this.pressure_in,
    required this.precip_mm,
    required this.precip_in,
    required this.humidity,
    required this.cloud,
    required this.feelslike_c,
    required this.feelslike_f,
    required this.vis_km,
    required this.vis_miles,
    required this.uv,
    required this.gust_mph,
    required this.gust_kph,
  });

  factory Current.fromJson(Map<String, dynamic> json) {
    return Current(
      last_updated_epoch: json['last_updated_epoch'],
      last_updated: json['last_updated'],
      temp_c: json['temp_c'],
      temp_f: json['temp_f'],
      is_day: json['is_day'],
      condition: Condition.fromJson(Map<String, dynamic>.from(json['condition'])),
      wind_mph: json['wind_mph'],
      wind_kph: json['wind_kph'],
      wind_degree: json['wind_degree'],
      wind_dir: json['wind_dir'],
      pressure_mb: json['pressure_mb'],
      pressure_in: json['pressure_in'],
      precip_mm: json['precip_mm'],
      precip_in: json['precip_in'],
      humidity: json['humidity'],
      cloud: json['cloud'],
      feelslike_c: json['feelslike_c'],
      feelslike_f: json['feelslike_f'],
      vis_km: json['vis_km'],
      vis_miles: json['vis_miles'],
      uv: json['uv'],
      gust_mph: json['gust_mph'],
      gust_kph: json['gust_kph'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'last_updated_epoch': this.last_updated_epoch,
      'last_updated': this.last_updated,
      'temp_c': this.temp_c,
      'temp_f': this.temp_f,
      'is_day': this.is_day,
      'condition': this.condition,
      'wind_mph': this.wind_mph,
      'wind_kph': this.wind_kph,
      'wind_degree': this.wind_degree,
      'wind_dir': this.wind_dir,
      'pressure_mb': this.pressure_mb,
      'pressure_in': this.pressure_in,
      'precip_mm': this.precip_mm,
      'precip_in': this.precip_in,
      'humidity': this.humidity,
      'cloud': this.cloud,
      'feelslike_c': this.feelslike_c,
      'feelslike_f': this.feelslike_f,
      'vis_km': this.vis_km,
      'vis_miles': this.vis_miles,
      'uv': this.uv,
      'gust_mph': this.gust_mph,
      'gust_kph': this.gust_kph,
    };
  }
}