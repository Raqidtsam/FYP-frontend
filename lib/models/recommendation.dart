class Recommendation {
  final int id;
  final int districtId;
  final int sectorId;
  final double score;
  final String? reason;
  final String? sectorName;
  final String? districtName;

  Recommendation({
    required this.id,
    required this.districtId,
    required this.sectorId,
    required this.score,
    this.reason,
    this.sectorName,
    this.districtName,
  });

  factory Recommendation.fromJson(Map<String, dynamic> json) {
    return Recommendation(
      id: json['id'],
      districtId: json['district'],
      sectorId: json['sector'],
      score: double.parse(json['score'].toString()),
      reason: json['reason'],
      sectorName: json['sector_name'],
      districtName: json['district_name'],
    );
  }
}