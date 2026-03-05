class ShipperModel {
  final int id;
  final int userId;
  final String? phone;
  final String vehicleName;
  final String licensePlate;
  final bool isActive;
  final DateTime createdAt;

  ShipperModel({
    required this.id,
    required this.userId,
    this.phone,
    required this.vehicleName,
    required this.licensePlate,
    required this.isActive,
    required this.createdAt,
  });

  factory ShipperModel.fromJson(Map<String, dynamic> json) {
    return ShipperModel(
      id: json['id'],
      userId: json['user_id'],
      phone: json['phone'],
      vehicleName: json['vehicle_name'],
      licensePlate: json['license_plate'],
      isActive: json['is_active'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'phone': phone,
      'vehicle_name': vehicleName,
      'license_plate': licensePlate,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
