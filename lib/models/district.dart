class District {
  final int id;
  final int regionId;
  final String name;
  final double latitude;
  final double longitude;

  District({
    required this.id,
    required this.regionId,
    required this.name,
    required this.latitude,
    required this.longitude,
  });

  factory District.fromJson(Map<String, dynamic> json) {
    return District(
      id: json['id'],
      regionId: json['region'] is int ? json['region'] : int.parse(json['region'].toString()),
      name: json['name'],
      latitude: double.parse(json['latitude'].toString()),
      longitude: double.parse(json['longitude'].toString()),
    );
  }
}