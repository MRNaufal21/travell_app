import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:travell_app/screens/auth/login_screen.dart';
import 'package:travell_app/screens/auth/register_screen.dart';
import 'package:travell_app/screens/about_screen.dart';
import 'package:travell_app/screens/client/client_home_screen.dart';
import 'package:travell_app/screens/client/new_booking_screen.dart';
import 'package:travell_app/screens/client/booking_history_screen.dart';
import 'package:travell_app/screens/admin/admin_dashboard_screen.dart';
import 'package:travell_app/screens/admin/approve_users_screen.dart';
import 'package:travell_app/screens/admin/manage_bookings_screen.dart';
import 'package:travell_app/screens/admin/manage_routes_screen.dart';
import 'package:travell_app/screens/admin/manage_vehicles_screen.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: AppRoutes.login,
    routes: [
      GoRoute(
        path: AppRoutes.login,
        name: 'login',
        pageBuilder: (context, state) => NoTransitionPage(child: const LoginScreen()),
      ),
      GoRoute(
        path: AppRoutes.register,
        name: 'register',
        pageBuilder: (context, state) => NoTransitionPage(child: const RegisterScreen()),
      ),
      GoRoute(
        path: AppRoutes.about,
        name: 'about',
        pageBuilder: (context, state) => NoTransitionPage(child: const AboutScreen()),
      ),
      GoRoute(
        path: AppRoutes.clientHome,
        name: 'clientHome',
        pageBuilder: (context, state) => NoTransitionPage(child: const ClientHomeScreen()),
      ),
      GoRoute(
        path: AppRoutes.newBooking,
        name: 'newBooking',
        pageBuilder: (context, state) => NoTransitionPage(
          child: NewBookingScreen(selectedRoute: state.extra as dynamic),
        ),
      ),
      GoRoute(
        path: AppRoutes.clientHistory,
        name: 'clientHistory',
        pageBuilder: (context, state) => NoTransitionPage(child: const BookingHistoryScreen()),
      ),
      GoRoute(
        path: AppRoutes.adminDashboard,
        name: 'adminDashboard',
        pageBuilder: (context, state) => NoTransitionPage(child: const AdminDashboardScreen()),
      ),
      GoRoute(
        path: AppRoutes.approveUsers,
        name: 'approveUsers',
        pageBuilder: (context, state) => NoTransitionPage(child: const ApproveUsersScreen()),
      ),
      GoRoute(
        path: AppRoutes.manageBookings,
        name: 'manageBookings',
        pageBuilder: (context, state) => NoTransitionPage(child: const ManageBookingsScreen()),
      ),
      GoRoute(
        path: AppRoutes.manageRoutes,
        name: 'manageRoutes',
        pageBuilder: (context, state) => NoTransitionPage(child: const ManageRoutesScreen()),
      ),
      GoRoute(
        path: AppRoutes.manageVehicles,
        name: 'manageVehicles',
        pageBuilder: (context, state) => NoTransitionPage(child: const ManageVehiclesScreen()),
      ),
      // Di dalam AppRouter class pada file lib/nav.dart
      GoRoute(
        path: '/admin/manage-vehicles',
        builder: (context, state) => const ManageVehiclesScreen(),
      ),
      GoRoute(
        path: '/admin/manage-routes',
        builder: (context, state) => const ManageRoutesScreen(),
      ),
    ],
  );
}

class AppRoutes {
  static const String login = '/';
  static const String register = '/register';
  static const String about = '/about';
  
  static const String clientHome = '/client/home';
  static const String newBooking = '/client/new-booking';
  static const String clientHistory = '/client/history';
  
  static const String adminDashboard = '/admin/dashboard';
  static const String approveUsers = '/admin/approve-users';
  static const String manageBookings = '/admin/manage-bookings';
  static const String manageRoutes = '/admin/manage-routes';
  static const String manageVehicles = '/admin/manage-vehicles';
}
