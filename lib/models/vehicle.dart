import 'package:cloud_firestore/cloud_firestore.dart';

enum VehicleStatus { available, inUse, maintenance }

class Vehicle {
  final String id;
  final String plateNumber;
  final String model;
  final String brand;
  final int capacity;
  final int year;
  final VehicleStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;

  Vehicle({
    required this.id,
    required this.plateNumber,
    required this.model,
    required this.brand,
    required this.capacity,
    required this.year,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  // --- MODIFIKASI TOJSON: Simpan sebagai Timestamp Firebase ---
  Map<String, dynamic> toJson() => {
    'id': id,
    'plateNumber': plateNumber,
    'model': model,
    'brand': brand,
    'capacity': capacity,
    'year': year,
    'status': status.name,
    'createdAt': Timestamp.fromDate(createdAt), // Simpan sebagai Timestamp
    'updatedAt': Timestamp.fromDate(updatedAt), // Simpan sebagai Timestamp
  };

  // --- MODIFIKASI FROMJSON: Logika Parse Waktu yang Aman ---
  factory Vehicle.fromJson(Map<String, dynamic> json) {
    
    // Fungsi internal untuk menangani beragam tipe data waktu (No 1 & No 3)
    DateTime parseDateTime(dynamic value) {
      if (value is Timestamp) {
        return value.toDate(); // Jika format Timestamp asli
      } else if (value is String) {
        return DateTime.parse(value); // Jika format String/Teks
      } else {
        return DateTime.now(); // Cadangan jika kosong
      }
    }

    return Vehicle(
      id: json['id'] ?? '',
      plateNumber: json['plateNumber'] ?? '',
      model: json['model'] ?? '',
      brand: json['brand'] ?? '',
      capacity: json['capacity'] as int? ?? 0,
      year: json['year'] as int? ?? 0,
      status: VehicleStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => VehicleStatus.available, // Default jika status tidak cocok
      ),
      createdAt: parseDateTime(json['createdAt']),
      updatedAt: parseDateTime(json['updatedAt']),
    );
  }

  Vehicle copyWith({
    String? id,
    String? plateNumber,
    String? model,
    String? brand,
    int? capacity,
    int? year,
    VehicleStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => Vehicle(
    id: id ?? this.id,
    plateNumber: plateNumber ?? this.plateNumber,
    model: model ?? this.model,
    brand: brand ?? this.brand,
    capacity: capacity ?? this.capacity,
    year: year ?? this.year,
    status: status ?? this.status,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
}