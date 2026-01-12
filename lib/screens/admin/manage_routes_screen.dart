import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Tambahkan untuk FilteringTextInputFormatter
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:travell_app/models/route.dart';
import 'package:travell_app/services/route_service.dart';
import 'package:travell_app/theme.dart';

class ManageRoutesScreen extends StatefulWidget {
  const ManageRoutesScreen({super.key});

  @override
  State<ManageRoutesScreen> createState() => _ManageRoutesScreenState();
}

class _ManageRoutesScreenState extends State<ManageRoutesScreen> {
  final RouteService _routeService = RouteService();
  List<TravelRoute> _routes = [];
  bool _isLoading = true;

  // Controllers
  final _originController = TextEditingController();
  final _destController = TextEditingController();
  final _distController = TextEditingController();
  final _durController = TextEditingController();
  final _priceController = TextEditingController();
  final _discountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadRoutes();
  }

  @override
  void dispose() {
    _originController.dispose();
    _destController.dispose();
    _distController.dispose();
    _durController.dispose();
    _priceController.dispose();
    _discountController.dispose();
    super.dispose();
  }

  // PERBAIKAN: Logika Finally & Feedback Error
  Future<void> _loadRoutes() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    
    try {
      _routes = await _routeService.getAllRoutes();
    } catch (e) {
      debugPrint("Error Load Routes: $e");
      // Feedback jika terjadi error (seperti Missing Index)
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Gagal memuat data: $e"), 
            backgroundColor: Colors.red
          ),
        );
      }
    } finally {
      // JAMINAN: Loading pasti berhenti di sini
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteRoute(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Rute'),
        content: const Text('Yakin ingin menghapus rute ini?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
          TextButton(
            onPressed: () => Navigator.pop(context, true), 
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() => _isLoading = true);
      try {
        await _routeService.deleteRoute(id);
        await _loadRoutes();
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  void _showAddDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tambah Rute'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: _originController, decoration: const InputDecoration(labelText: 'Asal')),
              TextField(controller: _destController, decoration: const InputDecoration(labelText: 'Tujuan')),
              TextField(
                controller: _distController, 
                decoration: const InputDecoration(labelText: 'Jarak (km)'), 
                keyboardType: TextInputType.number
              ),
              TextField(
                controller: _durController, 
                decoration: const InputDecoration(labelText: 'Durasi (menit)'), 
                keyboardType: TextInputType.number
              ),
              // PERBAIKAN: Input Harga dengan keyboard angka
              TextField(
                controller: _priceController, 
                decoration: const InputDecoration(labelText: 'Harga Asli (Contoh: 300000)'), 
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
              TextField(
                controller: _discountController, 
                decoration: const InputDecoration(labelText: 'Diskon (%)'), 
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () async {
              // PERBAIKAN: Membersihkan input dari karakter non-angka (seperti titik)
              String cleanPrice = _priceController.text.replaceAll(RegExp(r'[^0-9]'), '');
              String cleanDiscount = _discountController.text.replaceAll(RegExp(r'[^0-9]'), '');

              final r = TravelRoute(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                origin: _originController.text,
                destination: _destController.text,
                distanceKm: double.tryParse(_distController.text) ?? 0,
                durationMinutes: int.tryParse(_durController.text) ?? 0,
                // Menggunakan harga yang sudah dibersihkan
                pricePerPerson: double.tryParse(cleanPrice) ?? 0, 
                discount: double.tryParse(cleanDiscount) ?? 0, 
                createdAt: DateTime.now(),
                updatedAt: DateTime.now(),
              );

              await _routeService.createRoute(r);
              if (mounted) Navigator.pop(context);
              
              _originController.clear(); _destController.clear(); 
              _distController.clear(); _durController.clear();
              _priceController.clear(); _discountController.clear();
              
              _loadRoutes();
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDialog,
        backgroundColor: Colors.white,
        child: const Icon(Icons.add_location_alt, color: LightModeColors.lightSecondary),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).brightness == Brightness.light ? LightModeColors.gradientStart : DarkModeColors.gradientStart,
              Theme.of(context).brightness == Brightness.light ? LightModeColors.gradientEnd : DarkModeColors.gradientEnd,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator(color: Colors.white))
                    : RefreshIndicator(
                        onRefresh: _loadRoutes,
                        child: ListView.builder(
                          padding: AppSpacing.paddingLg,
                          itemCount: _routes.length,
                          itemBuilder: (context, index) => _buildRouteCard(_routes[index]),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: AppSpacing.paddingLg,
      child: Row(
        children: [
          IconButton(onPressed: () => context.pop(), icon: const Icon(Icons.arrow_back, color: Colors.white)),
          const SizedBox(width: 8),
          Expanded(child: Text('Kelola Rute', style: context.textStyles.headlineSmall?.copyWith(color: Colors.white, fontWeight: FontWeight.bold))),
        ],
      ),
    );
  }

  Widget _buildRouteCard(TravelRoute route) {
    final formatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    
    double discountAmount = route.pricePerPerson * (route.discount / 100);
    double finalPrice = route.pricePerPerson - discountAmount;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface, 
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withAlpha(15), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(route.origin, style: context.textStyles.titleLarge?.semiBold),
                  const Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: Icon(Icons.arrow_forward, size: 16)),
                  Text(route.destination, style: context.textStyles.titleLarge?.semiBold),
                ],
              ),
              Row(
                children: [
                  if (route.discount > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(6)),
                      child: Text("${route.discount.toInt()}%", style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                  IconButton(
                    onPressed: () => _deleteRoute(route.id), 
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                  ),
                ],
              ),
            ],
          ),
          const Divider(),
          _buildInfoRow('Jarak', '${route.distanceKm} km'),
          _buildInfoRow('Durasi', '${(route.durationMinutes / 60).toStringAsFixed(1)} jam'),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Harga', style: TextStyle(color: Colors.grey)),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (route.discount > 0)
                    Text(
                      formatter.format(route.pricePerPerson),
                      style: const TextStyle(color: Colors.grey, decoration: TextDecoration.lineThrough, fontSize: 12),
                    ),
                  Text(
                    formatter.format(finalPrice),
                    style: TextStyle(fontWeight: FontWeight.bold, color: route.discount > 0 ? Colors.green : null),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}