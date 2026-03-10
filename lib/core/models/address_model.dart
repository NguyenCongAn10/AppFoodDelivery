class AddressModel {
  final int? id;
  final String userUid;
  final String address;
  final double? latitude;
  final double? longitude;
  final bool isDefault;
  final DateTime? createdAt;

  AddressModel({
    this.id,
    required this.userUid,
    required this.address,
    this.latitude,
    this.longitude,
    required this.isDefault,
    this.createdAt,
  });

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      id: json['id'],
      userUid: json['user_uid'],
      address: json['address'],
      latitude: json['latitude'] != null ? (json['latitude'] as num).toDouble() : null,
      longitude: json['longitude'] != null ? (json['longitude'] as num).toDouble() : null,
      isDefault: json['is_default'] ?? false,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'user_uid': userUid,
      'address': address,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      'is_default': isDefault,
      if (createdAt != null) 'created_at': createdAt?.toIso8601String(),
    };
  }
}
