
import 'dbhelper.dart';

class Markers {
  int? id;
  double? latitude;
  double? longitude;
  String? title;

  Markers(this.id, this.latitude, this.longitude, this.title);

  Markers.fromMap(Map<String, dynamic> map) {
    id = map['id'];
    latitude = map['latitude'];
    longitude = map['longitude'];
    title = map['title'];
  }

  Map<String, dynamic> toMap() {
    return {
      DatabaseHelper.columnid: id,
      DatabaseHelper.columnlatitude: latitude,
      DatabaseHelper.columnlongitude: longitude,
      DatabaseHelper.columntitle: title,
    };
  }
}