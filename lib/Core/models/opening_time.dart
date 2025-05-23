class OpeningTime {
  final String? openingId;
  final String dayOfWeek;
  final String? openTime;
  final String? closeTime;
  final bool is24Hours;
  final String? timezone;

  OpeningTime({
    this.openingId,
    required this.dayOfWeek,
    this.openTime,
    this.closeTime,
    required this.is24Hours,
    this.timezone,
  });

  factory OpeningTime.fromJson(Map<String, dynamic> json) {
    return OpeningTime(
      openingId: json['openingId'] as String?,
      dayOfWeek: json['dayOfWeek'] as String,
      openTime: json['openTime'] as String?,
      closeTime: json['closeTime'] as String?,
      is24Hours: json['is24Hours'] as bool? ?? false,
      timezone: json['timezone'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'dayOfWeek': dayOfWeek,
      'is24Hours': is24Hours,
    };
    if (openingId != null) map['openingId'] = openingId;
    if (openTime != null) map['openTime'] = openTime;
    if (closeTime != null) map['closeTime'] = closeTime;
    if (timezone != null) map['timezone'] = timezone;
    return map;
  }
}
