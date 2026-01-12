import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart'; // Import library grafik
import 'package:travell_app/providers/auth_provider.dart';
import 'package:travell_app/services/booking_service.dart';
import 'package:travell_app/services/user_service.dart';
import 'package:travell_app/services/vehicle_service.dart';
import 'package:travell_app/models/vehicle.dart'; // Import untuk VehicleStatus
import 'package:travell_app/theme.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final BookingService _bookingService = BookingService();
  final UserService _userService = UserService();
  final VehicleService _vehicleService = VehicleService();

  int _pendingUsersCount = 0;
  int _totalBookings = 0;
  int _pendingBookingsCount = 0;
  double _totalRevenue = 0;
  int _availableVehicles = 0;
  int _maintenanceVehicles = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  // REVISI: Mengambil data mendalam untuk grafik dan tabel
  Future<void> _loadDashboardData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      final results = await Future.wait([
        _userService.getPendingUsers(), // results[0]
        _bookingService.getTotalRevenue(), // results[1]
        _bookingService.getTotalBookingsCount(), // results[2]
        _vehicleService.getAllVehicles(), // results[3]
        _bookingService.getPendingBookings(), // results[4]
      ]);

      if (!mounted) return;

      final allVehicles = results[3] as List<Vehicle>;

      setState(() {
        _pendingUsersCount = (results[0] as List).length;
        _totalRevenue = results[1] as double;
        _totalBookings = results[2] as int;
        _pendingBookingsCount = (results[4] as List).length;

        // Menghitung status kendaraan untuk Pie Chart
        _availableVehicles = allVehicles
            .where((v) => v.status == VehicleStatus.available)
            .length;
        _maintenanceVehicles = allVehicles
            .where((v) => v.status == VehicleStatus.maintenance)
            .length;
      });
    } catch (e) {
      debugPrint("Error load dashboard: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.currentUser;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).brightness == Brightness.light
                  ? LightModeColors.gradientStart
                  : DarkModeColors.gradientStart,
              Theme.of(context).brightness == Brightness.light
                  ? LightModeColors.gradientEnd
                  : DarkModeColors.gradientEnd,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(context, user?.fullName ?? 'Admin'),
              Expanded(
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(color: Colors.white))
                    : RefreshIndicator(
                        onRefresh: _loadDashboardData,
                        child: SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: AppSpacing.paddingLg,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildStatsGrid(),
                              const SizedBox(height: 32),
                              // IMPLEMENTASI VISUALISASI RELEVAN TRAVEL
                              _buildVisualAnalysis(),
                              const SizedBox(height: 32),
                              _buildQuickActions(context),
                              const SizedBox(height: 20),
                            ],
                          ),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  // SYARAT TEKNIS NO 7: Pie Chart Armada & Tabel Booking
  Widget _buildVisualAnalysis() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Analisis Operasional Travel',
          style: context.textStyles.titleLarge?.semiBold
              .copyWith(color: Colors.white),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            children: [
              Text('Ketersediaan Armada Kendaraan',
                  style: context.textStyles.titleMedium?.semiBold),
              const SizedBox(height: 24),

              // PIE CHART: Armada (Available vs Maintenance)
              SizedBox(
                height: 180,
                child: (_availableVehicles == 0 && _maintenanceVehicles == 0)
                    ? const Center(child: Text("Belum ada data armada"))
                    : PieChart(
                        PieChartData(
                          sectionsSpace: 4,
                          centerSpaceRadius: 40,
                          sections: [
                            PieChartSectionData(
                              value: _availableVehicles.toDouble(),
                              title: '$_availableVehicles',
                              color: Colors.blue,
                              radius: 50,
                              titleStyle: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                            PieChartSectionData(
                              value: _maintenanceVehicles.toDouble(),
                              title: '$_maintenanceVehicles',
                              color: Colors.redAccent,
                              radius: 50,
                              titleStyle: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildLegendItem('Siap Jalan', Colors.blue),
                  const SizedBox(width: 20),
                  _buildLegendItem('Perbaikan', Colors.redAccent),
                ],
              ),

              const Divider(height: 40),

              // TABEL: Ringkasan Pemesanan
              Text('Statistik Pemesanan Tiket',
                  style: context.textStyles.titleMedium?.semiBold),
              const SizedBox(height: 12),
              Table(
                border: TableBorder.all(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(8)),
                children: [
                  TableRow(
                    decoration: BoxDecoration(color: Colors.grey.shade100),
                    children: const [
                      Padding(
                          padding: EdgeInsets.all(8),
                          child: Text('Keterangan',
                              style: TextStyle(fontWeight: FontWeight.bold))),
                      Padding(
                          padding: EdgeInsets.all(8),
                          child: Text('Jumlah',
                              style: TextStyle(fontWeight: FontWeight.bold))),
                    ],
                  ),
                  TableRow(
                    children: [
                      const Padding(
                          padding: EdgeInsets.all(8),
                          child: Text('Total Transaksi')),
                      Padding(
                          padding: EdgeInsets.all(8),
                          child: Text('$_totalBookings')),
                    ],
                  ),
                  TableRow(
                    children: [
                      const Padding(
                          padding: EdgeInsets.all(8),
                          child: Text('Menunggu Konfirmasi')),
                      Padding(
                          padding: EdgeInsets.all(8),
                          child: Text('$_pendingBookingsCount',
                              style: const TextStyle(
                                  color: Colors.orange,
                                  fontWeight: FontWeight.bold))),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  Widget _buildHeader(BuildContext context, String userName) {
    return Container(
      padding: AppSpacing.paddingLg,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Dashboard Admin',
                    style: context.textStyles.headlineSmall?.copyWith(
                        color: Colors.white, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text('Halo, $userName',
                    style: context.textStyles.bodyMedium
                        ?.copyWith(color: Colors.white.withAlpha(230))),
              ],
            ),
          ),
          IconButton(
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Logout'),
                  content: const Text('Apakah Anda yakin ingin keluar?'),
                  actions: [
                    TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Batal')),
                    TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('Ya')),
                  ],
                ),
              );
              if (confirm == true && mounted) {
                await context.read<AuthProvider>().logout();
                if (mounted) context.go('/');
              }
            },
            icon: const Icon(Icons.logout, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid() {
    final formatter =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    return Column(
      children: [
        Row(
          children: [
            Expanded(
                child: _buildStatCard(
                    title: 'Pending Users',
                    value: '$_pendingUsersCount',
                    icon: Icons.person_add,
                    color: LightModeColors.lightTertiary)),
            const SizedBox(width: 16),
            Expanded(
                child: _buildStatCard(
                    title: 'Total Booking',
                    value: '$_totalBookings',
                    icon: Icons.book,
                    color: LightModeColors.lightPrimary)),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
                child: _buildStatCard(
                    title: 'Pendapatan',
                    value: formatter.format(_totalRevenue),
                    icon: Icons.attach_money,
                    color: LightModeColors.lightSuccess,
                    valueStyle: context.textStyles.titleMedium?.semiBold
                        .copyWith(color: LightModeColors.lightSuccess))),
            const SizedBox(width: 16),
            Expanded(
                child: _buildStatCard(
                    title: 'Unit Armada',
                    value: '${_availableVehicles + _maintenanceVehicles}',
                    icon: Icons.directions_car,
                    color: LightModeColors.lightSecondary)),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(
      {required String title,
      required String value,
      required IconData icon,
      required Color color,
      TextStyle? valueStyle}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
                color: color.withAlpha(25),
                blurRadius: 10,
                offset: const Offset(0, 4))
          ]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                  color: color.withAlpha(25),
                  borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: color, size: 24)),
          const SizedBox(height: 16),
          FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(value,
                  style: valueStyle ??
                      context.textStyles.headlineSmall?.bold
                          .copyWith(color: color))),
          const SizedBox(height: 4),
          Text(title,
              style: context.textStyles.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant)),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Menu Utama',
            style: context.textStyles.titleLarge?.semiBold
                .copyWith(color: Colors.white)),
        const SizedBox(height: 16),
        _buildActionButton(context,
            icon: Icons.person_add_alt_1,
            title: 'Approval Registrasi',
            subtitle: '$_pendingUsersCount user menunggu',
            onTap: () => context.push('/admin/approve-users'),
            color: LightModeColors.lightTertiary),
        const SizedBox(height: 12),
        _buildActionButton(context,
            icon: Icons.list_alt,
            title: 'Kelola Booking',
            subtitle: 'Manajemen transaksi tiket',
            onTap: () => context.push('/admin/manage-bookings'),
            color: LightModeColors.lightPrimary),
        const SizedBox(height: 12),
        _buildActionButton(context,
            icon: Icons.route,
            title: 'Kelola Rute',
            subtitle: 'Atur rute & harga travel',
            onTap: () => context.push('/admin/manage-routes'),
            color: LightModeColors.lightSecondary),
        const SizedBox(height: 12),
        _buildActionButton(context,
            icon: Icons.directions_car,
            title: 'Kelola Kendaraan',
            subtitle: 'Manajemen unit armada',
            onTap: () => context.push('/admin/manage-vehicles'),
            color: Colors.orange),
      ],
    );
  }

  Widget _buildActionButton(BuildContext context,
      {required IconData icon,
      required String title,
      required String subtitle,
      required VoidCallback onTap,
      required Color color}) {
    return Material(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                      color: color.withAlpha(25),
                      borderRadius: BorderRadius.circular(16)),
                  child: Icon(icon, color: color, size: 28)),
              const SizedBox(width: 16),
              Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    Text(title,
                        style: context.textStyles.titleMedium?.semiBold),
                    const SizedBox(height: 4),
                    Text(subtitle,
                        style: context.textStyles.bodySmall?.copyWith(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant))
                  ])),
              Icon(Icons.arrow_forward_ios,
                  size: 16,
                  color: Theme.of(context).colorScheme.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          boxShadow: [
            BoxShadow(
                color: Colors.black.withAlpha(13),
                blurRadius: 10,
                offset: const Offset(0, -4))
          ]),
      child: SafeArea(
          child: Padding(
              padding: AppSpacing.paddingMd,
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildNavItem(Icons.dashboard, 'Dashboard', true, () {}),
                    _buildNavItem(Icons.info_outline, 'Tentang', false,
                        () => context.push('/about'))
                  ]))),
    );
  }

  Widget _buildNavItem(
      IconData icon, String label, bool isActive, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
            color: isActive
                ? LightModeColors.lightPrimary.withAlpha(25)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon,
                color: isActive
                    ? LightModeColors.lightPrimary
                    : Theme.of(context).colorScheme.onSurfaceVariant,
                size: 24),
            const SizedBox(height: 4),
            Text(label,
                style: context.textStyles.bodySmall?.copyWith(
                    color: isActive
                        ? LightModeColors.lightPrimary
                        : Theme.of(context).colorScheme.onSurfaceVariant,
                    fontWeight:
                        isActive ? FontWeight.w600 : FontWeight.normal)),
          ],
        ),
      ),
    );
  }
}
