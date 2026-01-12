import 'package:cloud_firestore/cloud_firestore.dart';

class TravelRoute {
  final String id;
  final String origin;
  final String destination;
  final double distanceKm;
  final int durationMinutes;
  final double pricePerPerson;
  final double discount; 
  final DateTime createdAt;
  final DateTime updatedAt;

  TravelRoute({
    required this.id,
    required this.origin,
    required this.destination,
    required this.distanceKm,
    required this.durationMinutes,
    required this.pricePerPerson,
    this.discount = 0, 
    required this.createdAt,
    required this.updatedAt,
  });

  // --- TAMBAHKAN GETTER INI (No 2) ---
  // Menghitung harga akhir secara otomatis
  double get finalPrice {
    if (discount <= 0) return pricePerPerson;
    return pricePerPerson - (pricePerPerson * (discount / 100));
  }

  factory TravelRoute.fromJson(Map<String, dynamic> json) {
    DateTime parseDateTime(dynamic value) {
      if (value is Timestamp) {
        return value.toDate();
      } else if (value is String) {
        return DateTime.parse(value);
      } else {
        return DateTime.now();
      }
    }

    return TravelRoute(
      id: json['id'] ?? '',
      origin: json['origin'] ?? '',
      destination: json['destination'] ?? '',
      distanceKm: (json['distanceKm'] ?? 0).toDouble(),
      durationMinutes: json['durationMinutes'] ?? 0,
      pricePerPerson: (json['pricePerPerson'] ?? 0).toDouble(),
      discount: (json['discount'] ?? 0).toDouble(),
      createdAt: parseDateTime(json['createdAt']),
      updatedAt: parseDateTime(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'origin': origin,
      'destination': destination,
      'distanceKm': distanceKm,
      'durationMinutes': durationMinutes,
      'pricePerPerson': pricePerPerson,
      'discount': discount,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }
}