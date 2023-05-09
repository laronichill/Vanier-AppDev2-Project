class Alert {
  final String headline;
  final String msgtype;
  final String severity;
  final String urgency;
  final String areas;
  final String category;
  final String certainty;
  final String event;
  final String note;
  final String effective;
  final String expires;
  final String desc;
  final String instruction;


  Alert({
      required this.headline,
      required this.msgtype,
      required this.severity,
      required this.urgency,
      required this.areas,
      required this.category,
      required this.certainty,
      required this.event,
      required this.note,
      required this.effective,
      required this.expires,
      required this.desc,
      required this.instruction
  });

  factory Alert.fromJson(Map<String, dynamic> json) {
    return Alert(
      headline: json['headline'],
      msgtype: json['msgtype'],
      severity: json['severity'],
      urgency: json['urgency'],
      areas: json['areas'],
      category: json['category'],
      certainty: json['certainty'],
      event: json['event'],
      note: json['note'],
      effective: json['effective'],
      expires: json['expires'],
      desc: json['desc'],
      instruction: json['instruction'],
    );
  }

  @override
  String toString() {
    return 'Alert{headline: $headline, msgtype: $msgtype, severity: $severity, urgency: $urgency, areas: $areas, category: $category, certainty: $certainty, event: $event, note: $note, effective: $effective, expires: $expires, desc: $desc, instruction: $instruction}';
  }
}