class PlaceResult {
  final String displayName;
  final double lat;
  final double lon;

  const PlaceResult({
    required this.displayName,
    required this.lat,
    required this.lon,
  });

  factory PlaceResult.fromJson(Map<String, dynamic> json) {
    return PlaceResult(
      displayName: json['display_name'] as String? ?? '',
      lat: double.tryParse(json['lat'].toString()) ?? 0.0,
      lon: double.tryParse(json['lon'].toString()) ?? 0.0,
    );
  }
}
