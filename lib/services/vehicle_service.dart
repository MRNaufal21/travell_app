import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:travell_app/models/vehicle.dart';

class VehicleService {
  // Referensi ke koleksi 'vehicles' di Firestore
  final CollectionReference _vehicleCollection = 
      FirebaseFirestore.instance.collection('vehicles');

  Future<List<Vehicle>> getAllVehicles() async {
    final snapshot = await _vehicleCollection.get();
    
    // Jika data di Firebase masih kosong, kita inisialisasi dengan data contoh
    if (snapshot.docs.isEmpty) {
      await _initializeSampleData();
      final newSnapshot = await _vehicleCollection.get();
      return newSnapshot.docs
          .map((doc) => Vehicle.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    }

    return snapshot.docs
        .map((doc) => Vehicle.fromJson(doc.data() as Map<String, dynamic>))
        .toList();
  }

  Future<Vehicle?> getVehicleById(String id) async {
    final doc = await _vehicleCollection.doc(id).get();
    if (doc.exists) {
      return Vehicle.fromJson(doc.data() as Map<String, dynamic>);
    }
    return null;
  }

  Future<List<Vehicle>> getAvailableVehicles() async {
    // Query langsung ke Firestore untuk status available
    final snapshot = await _vehicleCollection
        .where('status', isEqualTo: VehicleStatus.available.name)
        .get();
    
    return snapshot.docs
        .map((doc) => Vehicle.fromJson(doc.data() as Map<String, dynamic>))
        .toList();
  }

  Future<void> createVehicle(Vehicle vehicle) async {
    await _vehicleCollection.doc(vehicle.id).set(vehicle.toJson());
  }

  Future<void> updateVehicle(Vehicle vehicle) async {
    await _vehicleCollection.doc(vehicle.id).update(vehicle.toJson());
  }

  Future<void> deleteVehicle(String id) async {
    await _vehicleCollection.doc(id).delete();
  }

  Future<void> _initializeSampleData() async {
    final now = DateTime.now();
    final sampleVehicles = [
      Vehicle(
        id: 'vehicle_1',
        plateNumber: 'B 1234 ABC',
        model: 'Avanza',
        brand: 'Toyota',
        capacity: 7,
        year: 2022,
        status: VehicleStatus.available,
        createdAt: now,
        updatedAt: now,
      ),
      // ... tambahkan data contoh lainnya sesuai keinginan
    ];

    for (var v in sampleVehicles) {
      await _vehicleCollection.doc(v.id).set(v.toJson());
    }
  }
}