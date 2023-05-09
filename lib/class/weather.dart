import './location.dart';
import './current.dart';
import './forecast.dart';
import './alerts.dart';

class Weather {
  final Location location;
  final Current current;
  final Forecast forecast;
  final Alerts alerts;

  const Weather({
    required this.location,
    required this.current,
    required this.forecast,
    required this.alerts,
  });

  factory Weather.fromJson(Map<String, dynamic> json) {
    return Weather(
      location: Location.fromJson(Map<String, dynamic>.from(json['location'])),
      current: Current.fromJson(Map<String, dynamic>.from(json['current'])),
      forecast: Forecast.fromJson(Map<String, dynamic>.from(json['forecast'])),
      alerts: Alerts.fromJson(Map<String, dynamic>.from(json['alerts'])),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'location': this.location,
      'current': this.current,
      'forecast': this.forecast,
      'alerts': this.alerts,
    };
  }

  factory Weather.fromMap(Map<String, dynamic> map) {
    return Weather(
      location: map['location'],
      current: map['current'],
      forecast: map['forecast'],
      alerts: map['alerts'],
    );
  }
}