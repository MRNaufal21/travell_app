import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:travell_app/models/vehicle.dart';
import 'package:travell_app/services/vehicle_service.dart';
import 'package:travell_app/theme.dart';

class ManageVehiclesScreen extends StatefulWidget {
  const ManageVehiclesScreen({super.key});

  @override
  State<ManageVehiclesScreen> createState() => _ManageVehiclesScreenState();
}

class _ManageVehiclesScreenState extends State<ManageVehiclesScreen> {
  final VehicleService _vehicleService = VehicleService();
  List<Vehicle> _vehicles = [];
  bool _isLoading = true;

  // Controller untuk Input Dialog
  final _brandController = TextEditingController();
  final _modelController = TextEditingController();
  final _plateController = TextEditingController();
  final _capacityController = TextEditingController();
  final _yearController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadVehicles();
  }

  Future<void> _loadVehicles() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      _vehicles = await _vehicleService.getAllVehicles();
    } catch (e) {
      debugPrint("Error: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Fungsi Hapus
  Future<void> _deleteVehicle(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Kendaraan'),
        content: const Text('Yakin ingin menghapus armada ini?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Hapus', style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirm == true) {
      await _vehicleService.deleteVehicle(id);
      _loadVehicles();
    }
  }

  // Dialog Tambah (UI Form)
  void _showAddDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tambah Kendaraan'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: _brandController, decoration: const InputDecoration(labelText: 'Merk')),
              TextField(controller: _modelController, decoration: const InputDecoration(labelText: 'Model')),
              TextField(controller: _plateController, decoration: const InputDecoration(labelText: 'Plat Nomor')),
              TextField(controller: _capacityController, decoration: const InputDecoration(labelText: 'Kapasitas'), keyboardType: TextInputType.number),
              TextField(controller: _yearController, decoration: const InputDecoration(labelText: 'Tahun'), keyboardType: TextInputType.number),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () async {
              final v = Vehicle(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                brand: _brandController.text,
                model: _modelController.text,
                plateNumber: _plateController.text,
                capacity: int.tryParse(_capacityController.text) ?? 0,
                year: int.tryParse(_yearController.text) ?? 2024,
                status: VehicleStatus.available,
                createdAt: DateTime.now(), // Wajib ada
                updatedAt: DateTime.now(),
              );
              await _vehicleService.createVehicle(v);
              if (mounted) Navigator.pop(context);
              _loadVehicles();
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
        child: const Icon(Icons.add, color: LightModeColors.lightPrimary),
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
                        onRefresh: _loadVehicles,
                        child: ListView.builder(
                          padding: AppSpacing.paddingLg,
                          itemCount: _vehicles.length,
                          itemBuilder: (context, index) => _buildVehicleCard(_vehicles[index]),
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
          Expanded(child: Text('Kelola Kendaraan', style: context.textStyles.headlineSmall?.copyWith(color: Colors.white, fontWeight: FontWeight.bold))),
        ],
      ),
    );
  }

  Widget _buildVehicleCard(Vehicle vehicle) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withAlpha(12), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: LightModeColors.lightPrimary.withAlpha(25), borderRadius: BorderRadius.circular(16)),
              child: const Icon(Icons.directions_car, color: LightModeColors.lightPrimary, size: 32),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${vehicle.brand} ${vehicle.model}', style: context.textStyles.titleMedium?.semiBold),
                  Text(vehicle.plateNumber, style: context.textStyles.bodyMedium?.copyWith(color: Colors.grey)),
                ],
              ),
            ),
            IconButton(
              onPressed: () => _deleteVehicle(vehicle.id),
              icon: const Icon(Icons.delete_outline, color: Colors.red),
            ),
          ],
        ),
      ),
    );
  }
}