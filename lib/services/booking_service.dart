import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:travell_app/models/booking.dart';

class BookingService {
  final CollectionReference _bookingCollection = 
      FirebaseFirestore.instance.collection('bookings');

  Future<List<Booking>> getAllBookings() async {
    final snapshot = await _bookingCollection.get();
    return snapshot.docs
        .map((doc) => Booking.fromJson(doc.data() as Map<String, dynamic>))
        .toList();
  }

  Future<Booking?> getBookingById(String id) async {
    final doc = await _bookingCollection.doc(id).get();
    if (doc.exists) {
      return Booking.fromJson(doc.data() as Map<String, dynamic>);
    }
    return null;
  }

  Future<List<Booking>> getBookingsByUserId(String userId) async {
    final snapshot = await _bookingCollection
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .get();
        
    return snapshot.docs
        .map((doc) => Booking.fromJson(doc.data() as Map<String, dynamic>))
        .toList();
  }

  Future<List<Booking>> getPendingBookings() async {
    final snapshot = await _bookingCollection
        .where('status', isEqualTo: BookingStatus.pending.name)
        .orderBy('createdAt', descending: true)
        .get();
        
    return snapshot.docs
        .map((doc) => Booking.fromJson(doc.data() as Map<String, dynamic>))
        .toList();
  }

  Future<void> createBooking(Booking booking) async {
    await _bookingCollection.doc(booking.id).set(booking.toJson());
  }

  Future<void> updateBooking(Booking booking) async {
    await _bookingCollection.doc(booking.id).update(booking.toJson());
  }

  Future<void> deleteBooking(String id) async {
    await _bookingCollection.doc(id).delete();
  }

  Future<double> getTotalRevenue() async {
    // Mengambil data pemesanan yang sukses untuk menghitung pendapatan
    final snapshot = await _bookingCollection
        .where('status', whereIn: [BookingStatus.confirmed.name, BookingStatus.completed.name])
        .get();

    final bookings = snapshot.docs
        .map((doc) => Booking.fromJson(doc.data() as Map<String, dynamic>));

    return bookings.fold<double>(0.0, (sum, b) => sum + b.totalPrice);
  }

  Future<int> getTotalBookingsCount() async {
    final snapshot = await _bookingCollection.get();
    return snapshot.size;
  }
}