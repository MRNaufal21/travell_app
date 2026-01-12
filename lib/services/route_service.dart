import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:travell_app/models/route.dart';

class RouteService {
  final CollectionReference _routeCollection = 
      FirebaseFirestore.instance.collection('routes');

  Future<List<TravelRoute>> getAllRoutes() async {
    final snapshot = await _routeCollection.get();
    
    // Jika koleksi kosong, inisialisasi dengan data contoh ke Firestore
    if (snapshot.docs.isEmpty) {
      await _initializeSampleData();
      final newSnapshot = await _routeCollection.get();
      return newSnapshot.docs
          .map((doc) => TravelRoute.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    }

    return snapshot.docs
        .map((doc) => TravelRoute.fromJson(doc.data() as Map<String, dynamic>))
        .toList();
  }

  Future<TravelRoute?> getRouteById(String id) async {
    final doc = await _routeCollection.doc(id).get();
    if (doc.exists) {
      return TravelRoute.fromJson(doc.data() as Map<String, dynamic>);
    }
    return null;
  }

  Future<void> createRoute(TravelRoute route) async {
    await _routeCollection.doc(route.id).set(route.toJson());
  }

  Future<void> updateRoute(TravelRoute route) async {
    await _routeCollection.doc(route.id).update(route.toJson());
  }

  Future<void> deleteRoute(String id) async {
    await _routeCollection.doc(id).delete();
  }

  Future<void> _initializeSampleData() async {
    final now = DateTime.now();
    final sampleRoutes = [
      TravelRoute(
        id: 'route_1',
        origin: 'Jakarta',
        destination: 'Bandung',
        distanceKm: 150,
        pricePerPerson: 150000,
        durationMinutes: 180,
        createdAt: now,
        updatedAt: now,
      ),
      TravelRoute(
        id: 'route_2',
        origin: 'Jakarta',
        destination: 'Surabaya',
        distanceKm: 750,
        pricePerPerson: 450000,
        durationMinutes: 720,
        createdAt: now,
        updatedAt: now,
      ),
      // Tambahkan data lainnya sesuai kebutuhan
    ];

    for (var route in sampleRoutes) {
      await _routeCollection.doc(route.id).set(route.toJson());
    }
  }
}