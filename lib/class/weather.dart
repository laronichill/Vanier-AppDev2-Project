import './location.dart';
import './current.dart';
import './forecast.dart';

class Weather {
  final Location location;
  final Current current;
  final Forecast forecast;

  const Weather({
    required this.location,
    required this.current,
    required this.forecast,
  });

  factory Weather.fromJson(Map<String, dynamic> json) {
    return Weather(
      location: Location.fromJson(Map<String, dynamic>.from(json['location'])),
      current: Current.fromJson(Map<String, dynamic>.from(json['current'])),
      forecast: Forecast.fromJson(Map<String, dynamic>.from(json['forecast'])),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'location': this.location,
      'current': this.current,
      'current': this.forecast,
    };
  }

  factory Weather.fromMap(Map<String, dynamic> map) {
    return Weather(
      location: map['location'],
      current: map['current'],
      forecast: map['forecast'],
    );
  }
}