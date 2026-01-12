import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:travell_app/models/user.dart';
import 'package:travell_app/services/storage_service.dart';

class UserService {
  final CollectionReference _userCollection = 
      FirebaseFirestore.instance.collection('users');

  Future<List<User>> getAllUsers() async {
    final snapshot = await _userCollection.get();
    return snapshot.docs
        .map((doc) => User.fromJson(doc.data() as Map<String, dynamic>))
        .toList();
  }

  Future<User?> getUserById(String id) async {
    final doc = await _userCollection.doc(id).get();
    if (doc.exists) {
      return User.fromJson(doc.data() as Map<String, dynamic>);
    }
    return null;
  }

  Future<User?> getUserByEmail(String email) async {
    final snapshot = await _userCollection.where('email', isEqualTo: email).get();
    if (snapshot.docs.isNotEmpty) {
      return User.fromJson(snapshot.docs.first.data() as Map<String, dynamic>);
    }
    return null;
  }

  Future<List<User>> getPendingUsers() async {
    final snapshot = await _userCollection
        .where('status', isEqualTo: UserStatus.pending.name)
        .where('role', isEqualTo: UserRole.client.name)
        .get();
        
    return snapshot.docs
        .map((doc) => User.fromJson(doc.data() as Map<String, dynamic>))
        .toList();
  }

  Future<void> createUser(User user) async {
    await _userCollection.doc(user.id).set(user.toJson());
  }

  Future<void> updateUser(User user) async {
    await _userCollection.doc(user.id).update(user.toJson());
  }

  Future<void> deleteUser(String id) async {
    await _userCollection.doc(id).delete();
  }

  // Tetap gunakan StorageService khusus untuk Session Login lokal
  Future<User?> getCurrentUser() async {
    final data = await StorageService.getObject(StorageService.currentUserKey);
    if (data == null) return null;
    return User.fromJson(data);
  }

  Future<void> setCurrentUser(User user) async {
    await StorageService.saveObject(StorageService.currentUserKey, user.toJson());
  }

  Future<void> clearCurrentUser() async {
    await StorageService.removeKey(StorageService.currentUserKey);
  }
}