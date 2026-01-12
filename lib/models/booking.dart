enum BookingStatus { pending, confirmed, cancelled, completed }

class Booking {
  final String id;
  final String userId;
  final String routeId;
  final String origin;
  final String destination;
  final DateTime travelDate;
  final int passengers;
  final double totalPrice;
  final BookingStatus status;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  Booking({
    required this.id,
    required this.userId,
    required this.routeId,
    required this.origin,
    required this.destination,
    required this.travelDate,
    required this.passengers,
    required this.totalPrice,
    required this.status,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'routeId': routeId,
    'origin': origin,
    'destination': destination,
    'travelDate': travelDate.toIso8601String(),
    'passengers': passengers,
    'totalPrice': totalPrice,
    'status': status.name,
    'notes': notes,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  factory Booking.fromJson(Map<String, dynamic> json) => Booking(
    id: json['id'] as String,
    userId: json['userId'] as String,
    routeId: json['routeId'] as String,
    origin: json['origin'] as String,
    destination: json['destination'] as String,
    travelDate: DateTime.parse(json['travelDate'] as String),
    passengers: json['passengers'] as int,
    totalPrice: (json['totalPrice'] as num).toDouble(),
    status: BookingStatus.values.firstWhere((e) => e.name == json['status']),
    notes: json['notes'] as String?,
    createdAt: DateTime.parse(json['createdAt'] as String),
    updatedAt: DateTime.parse(json['updatedAt'] as String),
  );

  Booking copyWith({
    String? id,
    String? userId,
    String? routeId,
    String? origin,
    String? destination,
    DateTime? travelDate,
    int? passengers,
    double? totalPrice,
    BookingStatus? status,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => Booking(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    routeId: routeId ?? this.routeId,
    origin: origin ?? this.origin,
    destination: destination ?? this.destination,
    travelDate: travelDate ?? this.travelDate,
    passengers: passengers ?? this.passengers,
    totalPrice: totalPrice ?? this.totalPrice,
    status: status ?? this.status,
    notes: notes ?? this.notes,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
}
