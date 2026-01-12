import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/foundation.dart';
import 'package:travell_app/models/user.dart';
import 'package:travell_app/services/user_service.dart';

class AuthProvider extends ChangeNotifier {
  final UserService _userService = UserService();
  final auth.FirebaseAuth _firebaseAuth = auth.FirebaseAuth.instance;
  User? _currentUser;
  bool _isLoading = false;

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _currentUser != null;
  bool get isAdmin => _currentUser?.role == UserRole.admin;

  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();
    try {
      _currentUser = await _userService.getCurrentUser();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String?> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      // 1. Logika Admin Default
      if (email.toLowerCase() == 'admin@veriflow.com' && password == 'admin123') {
        final adminUser = User(
          id: 'admin_default',
          email: 'admin@veriflow.com',
          fullName: 'Sistem Admin',
          phone: '-',
          address: 'Office',
          role: UserRole.admin,
          status: UserStatus.approved,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        _currentUser = adminUser;
        await _userService.setCurrentUser(adminUser);
        return null; // Akan langsung memicu blok finally
      }

      // 2. Login menggunakan Firebase Auth
      final auth.UserCredential credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // 3. Ambil data profil dari Firestore
      final user = await _userService.getUserById(credential.user!.uid);
      
      if (user == null) {
        await _firebaseAuth.signOut();
        return 'Data profil tidak ditemukan di database';
      }

      // 4. Validasi Status Akun
      if (user.status == UserStatus.pending) {
        await _firebaseAuth.signOut();
        return 'Akun Anda sedang diproses. Mohon tunggu persetujuan admin.';
      }

      _currentUser = user;
      await _userService.setCurrentUser(user);
      return null;

    } on auth.FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          return 'Email tidak terdaftar. Silakan buat akun baru.';
        case 'wrong-password':
          return 'Kata sandi salah. Silakan coba lagi.';
        case 'invalid-email':
          return 'Format email tidak valid.';
        case 'user-disabled':
          return 'Akun ini telah dinonaktifkan.';
        default:
          return 'Gagal masuk: ${e.message}';
      }
    } catch (e) {
      return 'Terjadi kesalahan sistem: $e';
    } finally {
      // REVISI: Apapun yang terjadi (berhasil/error), loading berhenti di sini
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String?> register({
    required String email,
    required String password,
    required String fullName,
    required String phone,
    required String address,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      // 1. Buat User di Firebase Auth
      final auth.UserCredential credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // 2. Simpan profil lengkap ke Firestore
      final newUser = User(
        id: credential.user!.uid,
        email: email,
        fullName: fullName,
        phone: phone,
        address: address,
        role: UserRole.client,
        status: UserStatus.pending,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _userService.createUser(newUser);
      
      await _firebaseAuth.signOut(); // Logout agar tidak otomatis masuk sebelum disetujui
      return null;

    } on auth.FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'email-already-in-use':
          return 'Email sudah digunakan oleh akun lain.';
        case 'weak-password':
          return 'Kata sandi terlalu lemah (minimal 6 karakter).';
        case 'invalid-email':
          return 'Format email tidak valid.';
        default:
          return 'Registrasi gagal: ${e.message}';
      }
    } catch (e) {
      return 'Gagal mendaftarkan akun: $e';
    } finally {
      // REVISI: Apapun yang terjadi (berhasil/error), loading berhenti di sini
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _firebaseAuth.signOut();
    await _userService.clearCurrentUser();
    _currentUser = null;
    notifyListeners();
  }
}