class Air_quality {
  final double co;
  final double no2;
  final double o3;
  final double so2;
  final double pm2_5;
  final double pm10;
  final int epa;
  final int defra;

  /*
  Index	1	2	3	4	5	6	7	8	9	10
  Band	Low	Low	Low	Moderate	Moderate	Moderate	High	High	High	Very High
  µgm-3	0-11	12-23	24-35	36-41	42-47	48-53	54-58	59-64	65-70	71 or more
   */
  const Air_quality({
    required this.co,
    required this.no2,
    required this.o3,
    required this.so2,
    required this.pm2_5,
    required this.pm10,
    required this.epa,
    required this.defra,

  });

  factory Air_quality.fromJson(Map<String, dynamic> json) {
    return Air_quality(
      co: json['co'],
      no2: json['no2'],
      o3: json['o3'],
      so2: json['so2'],
      pm2_5: json['pm2_5'],
      pm10: json['pm10'],
      epa: json['epa'],
      defra: json['defra'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'co': this.co,
      'no2': this.no2,
      'o3': this.o3,
      'so2': this.so2,
      'pm2_5': this.pm2_5,
      'pm10': this.pm10,
      'epa': this.epa,
      'defra': this.defra,
    };
  }

  factory Air_quality.fromMap(Map<String, dynamic> map) {
    return Air_quality(
      co: map['co'] as double,
      no2: map['no2'] as double,
      o3: map['o3'] as double,
      so2: map['so2'] as double,
      pm2_5: map['pm2_5'] as double,
      pm10: map['pm10'] as double,
      epa: map['epa'] as int,
      defra: map['defra'] as int,
    );
  }
}