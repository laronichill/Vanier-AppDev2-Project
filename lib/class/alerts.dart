import './alert.dart';

class Alerts {
  final List<Alert> alerts;

  const Alerts({
    required this.alerts,
  });

  factory Alerts.fromJson(Map<String, dynamic> json) {
    return Alerts(
      alerts: List<dynamic>.from(json['alert']).map((i) => Alert.fromJson(i)).toList(),
    );
  }
}