import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:travell_app/theme.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  // Fungsi untuk membuka link YouTube demo aplikasi
  Future<void> _launchYoutube() async {
    // Ganti URL ini dengan link video demo kelompok Anda
    final Uri url = Uri.parse('https://youtu.be/u7zuu_6gDSI');
    if (!await launchUrl(url)) {
      throw Exception('Could not launch $url');
    }
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
              Padding(
                padding: AppSpacing.paddingMd,
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => context.pop(),
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                    ),
                    Text(
                      'Tentang Aplikasi',
                      style: context.textStyles.titleLarge
                          ?.copyWith(color: Colors.white),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: AppSpacing.paddingXl,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Logo Section (Tetap dipertahankan)
                      Container(
                        padding: AppSpacing.paddingXl,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: const Icon(
                          Icons.directions_car_rounded,
                          size: 80,
                          color: LightModeColors.lightPrimary,
                        ),
                      ),
                      const SizedBox(height: 32),
                      Text(
                        'GoRoute',
                        style: context.textStyles.displaySmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Travel Management System',
                        style: context.textStyles.bodyLarge?.copyWith(
                          color: Colors.white.withOpacity(0.9),
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 40),

                      // 1. DESKRIPSI APLIKASI (Poin 1)
                      _buildInfoCard(
                        context,
                        title: 'Deskripsi Aplikasi',
                        content:
                            'GoRoute adalah sistem informasi pariwisata berbasis manajemen travel. Aplikasi ini dikembangkan untuk memudahkan transaksi perdataan rute, armada kendaraan, dan pemesanan tiket dengan integrasi data cuaca publik dari BMKG.',
                        icon: Icons.description_outlined,
                      ),
                      const SizedBox(height: 20),

                      // 2. DATA DEVELOPER (Poin 1 - Nama & NPM)
                      _buildInfoCard(
                        context,
                        title: 'Tim Pengembang',
                        content: '• Sandyningtias. P. Putri (152019040)\n'
                            '• Muhammad Rizqi Naufal (152019043)\n'
                            '• Dhevan Fasya Revangga (152021030)',
                        icon: Icons.groups_outlined,
                      ),
                      const SizedBox(height: 20),

                      // 3. LINK DEMO YOUTUBE (Poin 2)
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          children: [
                            Text(
                              'Demo Aplikasi',
                              style: context.textStyles.titleLarge?.semiBold,
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              onPressed: _launchYoutube,
                              icon: const Icon(Icons.play_circle_fill,
                                  color: Colors.red),
                              label: const Text('Tonton Demo di YouTube'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: Colors.black,
                                elevation: 2,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 24, vertical: 12),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Informasi Teknologi (Opsional - dari kode lama Anda)
                      _buildInfoCard(
                        context,
                        title: 'Teknologi & Fitur Utama',
                        content: '• Sisi Client & Admin (Role Based)\n'
                            '• Database Firebase Firestore\n'
                            '• Registrasi dengan Approval Admin\n'
                            '• Integrasi API Publik BMKG\n'
                            '• Integrasi Maps\n'
                            '• Dashboard Statistik Admin',
                        icon: Icons.code_outlined,
                      ),

                      const SizedBox(height: 40),

                      // Footer
                      Text(
                        '© 2026 OneHeart Team\nVersion 1.0.0',
                        style: context.textStyles.bodySmall?.copyWith(
                          color: Colors.white.withOpacity(0.7),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget pembantu kartu informasi (UI Lama Anda)
  Widget _buildInfoCard(
    BuildContext context, {
    required String title,
    required String content,
    required IconData icon,
    Color? iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: (iconColor ?? LightModeColors.lightPrimary)
                      .withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: iconColor ?? LightModeColors.lightPrimary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: context.textStyles.titleLarge?.semiBold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            content,
            style: context.textStyles.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
