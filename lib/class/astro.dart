class Astro {
  final String moon_illumination;
  final String moon_phase;
  final String moonrise;
  final String moonset;
  final String sunrise;
  final String sunset;

  const Astro({
    required this.moon_illumination,
    required this.moon_phase,
    required this.moonrise,
    required this.moonset,
    required this.sunrise,
    required this.sunset,
  });

  factory Astro.fromJson(Map<String, dynamic> json) {
    return Astro(
      moon_illumination: json['moon_illumination'],
      moon_phase: json['moon_phase'],
      moonrise: json['moonrise'],
      moonset: json['moonset'],
      sunrise: json['sunrise'],
      sunset: json['sunset'],
    );
  }

}