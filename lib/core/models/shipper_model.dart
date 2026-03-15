class ShipperModel {
  final int id;
  final String userUid;
  final String? phone;
  final String vehicleName;
  final String licensePlate;
  final bool isActive;
  final DateTime createdAt;

  ShipperModel({
    required this.id,
    required this.userUid,
    this.phone,
    required this.vehicleName,
    required this.licensePlate,
    required this.isActive,
    required this.createdAt,
  });

  factory ShipperModel.fromJson(Map<String, dynamic> json) {
    return ShipperModel(
      id: json['id'] ?? 0,
      userUid: json['user_uid']?.toString() ?? json['user_id']?.toString() ?? '',
      phone: json['phone'],
      vehicleName: json['vehicle_name'] ?? '',
      licensePlate: json['license_plate'] ?? '',
      isActive: json['is_active'] ?? true,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_uid': userUid,
      'phone': phone,
      'vehicle_name': vehicleName,
      'license_plate': licensePlate,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
