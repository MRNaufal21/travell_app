import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:travell_app/models/booking.dart';
import 'package:travell_app/models/route.dart';
import 'package:travell_app/providers/auth_provider.dart';
import 'package:travell_app/services/booking_service.dart';
import 'package:travell_app/services/route_service.dart';
import 'package:travell_app/theme.dart';

class NewBookingScreen extends StatefulWidget {
  final TravelRoute? selectedRoute;

  const NewBookingScreen({super.key, this.selectedRoute});

  @override
  State<NewBookingScreen> createState() => _NewBookingScreenState();
}

class _NewBookingScreenState extends State<NewBookingScreen> {
  final _formKey = GlobalKey<FormState>();
  final RouteService _routeService = RouteService();
  final BookingService _bookingService = BookingService();
  
  List<TravelRoute> _routes = [];
  TravelRoute? _selectedRoute;
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  int _passengers = 1;
  final _notesController = TextEditingController();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _selectedRoute = widget.selectedRoute;
    _loadRoutes();
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  // PERBAIKAN: Gunakan try-catch-finally agar loading tidak macet
  Future<void> _loadRoutes() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    
    try {
      _routes = await _routeService.getAllRoutes();

      if (widget.selectedRoute != null) {
        final matched = _routes.where((r) => r.id == widget.selectedRoute!.id).firstOrNull;
        _selectedRoute = matched;
      }
    } catch (e) {
      debugPrint("Error load routes: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // PERBAIKAN: Gunakan finalPrice (harga diskon) untuk total harga
  double get _totalPrice => (_selectedRoute?.finalPrice ?? 0) * _passengers;

  Future<void> _submitBooking() async {
    if (!_formKey.currentState!.validate() || _selectedRoute == null) return;

    final authProvider = context.read<AuthProvider>();
    final userId = authProvider.currentUser?.id;

    if (userId == null) return;

    final now = DateTime.now();
    final booking = Booking(
      id: 'booking_${now.millisecondsSinceEpoch}',
      userId: userId,
      routeId: _selectedRoute!.id,
      origin: _selectedRoute!.origin,
      destination: _selectedRoute!.destination,
      travelDate: _selectedDate,
      passengers: _passengers,
      totalPrice: _totalPrice, // Harga yang disimpan sudah harga diskon
      status: BookingStatus.pending,
      notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
      createdAt: now,
      updatedAt: now,
    );

    await _bookingService.createBooking(booking);

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Booking Berhasil'),
        content: const Text('Booking Anda berhasil dibuat. Silakan tunggu konfirmasi dari admin.'),
        actions: [
          TextButton(
            onPressed: () {
              context.pop();
              context.go('/client/home');
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
              _buildHeader(),
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator(color: Colors.white))
                    : SingleChildScrollView(
                        padding: AppSpacing.paddingLg,
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _buildRouteSelection(),
                              const SizedBox(height: 20),
                              _buildDateSelection(),
                              const SizedBox(height: 20),
                              _buildPassengerSelection(),
                              const SizedBox(height: 20),
                              _buildNotesField(),
                              const SizedBox(height: 32),
                              _buildPriceSummary(),
                              const SizedBox(height: 24),
                              _buildSubmitButton(),
                            ],
                          ),
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
          IconButton(
            onPressed: () => context.pop(),
            icon: const Icon(Icons.arrow_back, color: Colors.white),
          ),
          const SizedBox(width: 8),
          Text(
            'Booking Baru',
            style: context.textStyles.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRouteSelection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: LightModeColors.lightPrimary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.route, color: LightModeColors.lightPrimary),
              ),
              const SizedBox(width: 12),
              Text('Pilih Rute', style: context.textStyles.titleLarge?.semiBold),
            ],
          ),
          const SizedBox(height: 20),
          DropdownButtonFormField<TravelRoute>(
            value: _selectedRoute,
            decoration: const InputDecoration(labelText: 'Rute Perjalanan'),
            isExpanded: true,
            items: _routes.map((route) {
              return DropdownMenuItem(
                value: route,
                child: Text('${route.origin} → ${route.destination}'),
              );
            }).toList(),
            onChanged: (value) => setState(() => _selectedRoute = value),
            validator: (value) => value == null ? 'Pilih rute perjalanan' : null,
          ),
          if (_selectedRoute != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: LightModeColors.lightPrimaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Jarak:', style: context.textStyles.bodyMedium),
                      Text('${_selectedRoute!.distanceKm} km', style: context.textStyles.bodyMedium?.semiBold),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Durasi:', style: context.textStyles.bodyMedium),
                      Text('${(_selectedRoute!.durationMinutes / 60).toStringAsFixed(1)} jam', style: context.textStyles.bodyMedium?.semiBold),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDateSelection() {
    final formatter = DateFormat('EEEE, d MMMM yyyy', 'id_ID');

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: LightModeColors.lightSecondary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.calendar_today, color: LightModeColors.lightSecondary),
              ),
              const SizedBox(width: 12),
              Text('Tanggal Keberangkatan', style: context.textStyles.titleLarge?.semiBold),
            ],
          ),
          const SizedBox(height: 20),
          InkWell(
            onTap: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: _selectedDate,
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 365)),
              );
              if (date != null) {
                setState(() => _selectedDate = date);
              }
            },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      formatter.format(_selectedDate),
                      style: context.textStyles.bodyLarge?.semiBold,
                    ),
                  ),
                  const Icon(Icons.edit_calendar),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPassengerSelection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: LightModeColors.lightTertiary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.people, color: LightModeColors.lightTertiary),
              ),
              const SizedBox(width: 12),
              Text('Jumlah Penumpang', style: context.textStyles.titleLarge?.semiBold),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: _passengers > 1 ? () => setState(() => _passengers--) : null,
                icon: const Icon(Icons.remove_circle_outline),
                iconSize: 40,
                color: LightModeColors.lightPrimary,
              ),
              const SizedBox(width: 32),
              Text(
                '$_passengers',
                style: context.textStyles.displayMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: LightModeColors.lightPrimary,
                ),
              ),
              const SizedBox(width: 32),
              IconButton(
                onPressed: _passengers < 7 ? () => setState(() => _passengers++) : null,
                icon: const Icon(Icons.add_circle_outline),
                iconSize: 40,
                color: LightModeColors.lightPrimary,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              'Maksimal 7 penumpang per booking',
              style: context.textStyles.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotesField() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.notes, color: Theme.of(context).colorScheme.onSurface),
              ),
              const SizedBox(width: 12),
              Text('Catatan (Opsional)', style: context.textStyles.titleLarge?.semiBold),
            ],
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: _notesController,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Catatan tambahan',
              hintText: 'Contoh: Jemput di stasiun',
            ),
          ),
        ],
      ),
    );
  }

  // PERBAIKAN: Ringkasan harga dengan rincian diskon (Harga Coret & Hemat)
  Widget _buildPriceSummary() {
    if (_selectedRoute == null) return const SizedBox.shrink();

    final formatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            LightModeColors.lightPrimary,
            LightModeColors.gradientEnd,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: LightModeColors.lightPrimary.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Harga per orang',
                style: context.textStyles.bodyMedium?.copyWith(color: Colors.white),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (_selectedRoute!.discount > 0)
                    Text(
                      formatter.format(_selectedRoute!.pricePerPerson),
                      style: const TextStyle(
                        color: Colors.white70, 
                        decoration: TextDecoration.lineThrough, 
                        fontSize: 12
                      ),
                    ),
                  Text(
                    formatter.format(_selectedRoute!.finalPrice),
                    style: context.textStyles.bodyMedium?.copyWith(
                      color: Colors.white, 
                      fontWeight: FontWeight.bold
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Jumlah penumpang',
                style: context.textStyles.bodyMedium?.copyWith(color: Colors.white),
              ),
              Text(
                'x$_passengers',
                style: context.textStyles.bodyMedium?.copyWith(color: Colors.white),
              ),
            ],
          ),
          // INFO HEMAT (Muncul hanya jika ada diskon)
          if (_selectedRoute!.discount > 0) ...[
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Hemat', style: context.textStyles.bodySmall?.copyWith(color: Colors.white)),
                Text(
                  '- ${formatter.format((_selectedRoute!.pricePerPerson - _selectedRoute!.finalPrice) * _passengers)}',
                  style: context.textStyles.bodySmall?.copyWith(
                    color: Colors.yellowAccent, 
                    fontWeight: FontWeight.bold
                  ),
                ),
              ],
            ),
          ],
          const Divider(height: 24, color: Colors.white),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Bayar',
                style: context.textStyles.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                formatter.format(_totalPrice),
                style: context.textStyles.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return ElevatedButton(
      onPressed: _selectedRoute == null ? null : _submitBooking,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: LightModeColors.lightPrimary,
        minimumSize: const Size(double.infinity, 56),
      ),
      child: Text('Buat Booking', style: context.textStyles.titleMedium?.semiBold),
    );
  }
}