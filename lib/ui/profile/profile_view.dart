import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:marketplace_flutter_application/data/repositories/auth_repository.dart';
import 'package:marketplace_flutter_application/ui/connectivity/connectivity_model.dart';
import 'package:marketplace_flutter_application/ui/connectivity/connectivity_view.dart';
import 'package:marketplace_flutter_application/ui/profile/profile_viewmodel.dart';
import 'package:marketplace_flutter_application/ui/shared/widgets/app_bottom_nav_bar.dart';
import 'package:marketplace_flutter_application/models/ratings/user_ratings.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  static const Color background = Color(0xFFEEF2F7);
  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF6E6E6E);
  static const Color cardColor = Colors.white;
  static const Color accent = Color(0xFFFFD700);
  static const Color borderColor = Color(0xFFE5E7EB);

  bool _checkingAuth = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAuthAndLoadProfile();
    });
  }

  Future<void> _checkAuthAndLoadProfile() async {
    final authRepository = context.read<AuthRepository>();
    final token = await authRepository.getAccessToken();

    if (!mounted) return;

    if (token == null || token.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please log in to view your profile.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      context.go('/login');
      return;
    }

    setState(() {
      _checkingAuth = false;
    });

    await context.read<ProfileViewModel>().loadProfile();
    if (!mounted) return;
    context.read<ProfileViewModel>().startConnectivityListener();
  }

  String _formatCachedAt(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  void _onBottomNavTap(int index) {
    switch (index) {
      case 0: context.go('/Home'); break;
      case 1: context.go('/Sell'); break;
      case 2: context.go('/cart'); break;
      case 3: context.go('/messages'); break;
      case 4: context.go('/profile'); break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<ProfileViewModel>();
    final connectivityModel = context.watch<ConnectivityModel>();

    if (_checkingAuth) {
      return const Scaffold(
        backgroundColor: background,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: background,
        elevation: 0,
        centerTitle: false,
        title: const Text(
          'My Profile',
          style: TextStyle(
            color: textPrimary,
            fontWeight: FontWeight.w700,
            fontSize: 22,
          ),
        ),
      ),
      body: Column(
        children: [
          if (!connectivityModel.isOnline) const ConnectivityView(),
          Expanded(
            child: viewModel.isLoading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: () => context.read<ProfileViewModel>().refresh(),
                    color: accent,
                    child: SafeArea(
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                        child: Column(
                          children: [
                            // Banner offline / stale
                            if (viewModel.isStale && viewModel.cachedAt != null)
                              Container(
                                width: double.infinity,
                                margin: const EdgeInsets.only(bottom: 12),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 10),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFF8C5),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                      color: const Color(0xFFFFE600)),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.wifi_off_rounded,
                                        size: 16, color: Color(0xFF92400E)),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Sin conexión — datos del ${_formatCachedAt(viewModel.cachedAt!)}',
                                      style: const TextStyle(
                                          fontSize: 13,
                                          color: Color(0xFF92400E)),
                                    ),
                                  ],
                                ),
                              ),

                            // Barra de progreso sutil mientras refresca
                            if (viewModel.isRefreshing)
                              const Padding(
                                padding: EdgeInsets.only(bottom: 12),
                                child: LinearProgressIndicator(
                                  minHeight: 2,
                                  backgroundColor: Colors.transparent,
                                  color: accent,
                                ),
                              ),

                            // Tarjeta de perfil
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: cardColor,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: borderColor),
                              ),
                              child: Column(
                                children: [
                                  CircleAvatar(
                                    radius: 38,
                                    backgroundColor: accent.withOpacity(0.25),
                                    child: const Icon(
                                      Icons.person,
                                      size: 40,
                                      color: textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 14),
                                  Text(
                                    viewModel.currentUser?.name ?? 'Usuario',
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w700,
                                      color: textPrimary,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    viewModel.currentUser?.email ?? 'Sin correo',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: textSecondary,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),

                            // Tarjeta de ratings
                            if (viewModel.ratings != null) ...[
                              const SizedBox(height: 16),
                              _RatingsCard(ratings: viewModel.ratings!),
                            ],

                            const SizedBox(height: 16),
                            _ProfileOptionTile(
                              icon: Icons.person_outline,
                              title: 'Información personal',
                              subtitle: 'Ver los detalles básicos de tu cuenta',
                              onTap: () =>
                                  context.push('/personal-information'),
                            ),
                            const SizedBox(height: 12),
                            _ProfileOptionTile(
                              icon: Icons.shopping_bag_outlined,
                              title: 'Mis productos',
                              subtitle: 'Ver los productos que has publicado',
                              onTap: () => context.push('/my-listings'),
                            ),
                            const SizedBox(height: 12),
                            _ProfileOptionTile(
                              icon: Icons.star_outline_rounded,
                              title: 'Productos Favoritos',
                              subtitle:
                                  'Productos que has marcado como favoritos',
                              onTap: () =>
                                  context.push('/favorite-listings'),
                            ),
                            const SizedBox(height: 12),
                            _ProfileOptionTile(
                              icon: Icons.help_outline,
                              title: 'Ayuda y soporte',
                              subtitle: 'Soporte y preguntas frecuentes',
                              onTap: () => context.push('/help'),
                            ),
                            const SizedBox(height: 24),
                            SizedBox(
                              width: double.infinity,
                              height: 52,
                              child: ElevatedButton.icon(
                                onPressed: () async {
                                  await context
                                      .read<ProfileViewModel>()
                                      .logout();
                                  if (!context.mounted) return;
                                  context.go('/login');
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.redAccent,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  elevation: 0,
                                ),
                                icon: const Icon(Icons.logout),
                                label: const Text(
                                  'Log out',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                            if (viewModel.errorMessage != null) ...[
                              const SizedBox(height: 12),
                              Text(
                                viewModel.errorMessage!,
                                style: const TextStyle(color: Colors.red),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
          ),
        ],
      ),
      bottomNavigationBar: AppBottomNavBar(
        selectedIndex: 4,
        onTap: _onBottomNavTap,
      ),
    );
  }
}

class _ProfileOptionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ProfileOptionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF6E6E6E);
  static const Color borderColor = Color(0xFFE5E7EB);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: borderColor),
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF4BF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: textPrimary),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 13,
                        color: textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: textSecondary),
            ],
          ),
        ),
      ),
    );
  }
}

class _RatingsCard extends StatelessWidget {
  final UserRatings ratings;

  const _RatingsCard({required this.ratings});

  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF6E6E6E);
  static const Color borderColor = Color(0xFFE5E7EB);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Mi reputación como vendedor',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                ratings.average.toStringAsFixed(1),
                style: const TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.w700,
                  color: textPrimary,
                  height: 1,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _StarRow(score: ratings.average),
                  const SizedBox(height: 4),
                  Text(
                    '${ratings.total} ${ratings.total == 1 ? 'calificación' : 'calificaciones'}',
                    style: const TextStyle(
                        fontSize: 13, color: textSecondary),
                  ),
                ],
              ),
            ],
          ),
          if (ratings.total > 0) ...[
            const SizedBox(height: 16),
            const Divider(height: 1),
            const SizedBox(height: 16),
            for (int star = 5; star >= 1; star--)
              _DistributionRow(
                star: star,
                count: ratings.distribution[star] ?? 0,
                total: ratings.total,
              ),
          ],
          if (ratings.total == 0) ...[
            const SizedBox(height: 12),
            const Text(
              'Aún no tienes calificaciones como vendedor.',
              style: TextStyle(fontSize: 13, color: textSecondary),
            ),
          ],
        ],
      ),
    );
  }
}

class _StarRow extends StatelessWidget {
  final double score;
  const _StarRow({required this.score});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(5, (i) {
        final fill = (score - i).clamp(0.0, 1.0);
        if (fill >= 1.0) {
          return const Icon(Icons.star_rounded,
              color: Color(0xFFFFD700), size: 20);
        } else if (fill > 0.0) {
          return const Icon(Icons.star_half_rounded,
              color: Color(0xFFFFD700), size: 20);
        } else {
          return const Icon(Icons.star_outline_rounded,
              color: Color(0xFFD1D5DB), size: 20);
        }
      }),
    );
  }
}

class _DistributionRow extends StatelessWidget {
  final int star;
  final int count;
  final int total;

  const _DistributionRow({
    required this.star,
    required this.count,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final fraction = total > 0 ? count / total : 0.0;

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Text('$star',
              style: const TextStyle(
                  fontSize: 12, color: Color(0xFF6E6E6E))),
          const SizedBox(width: 4),
          const Icon(Icons.star_rounded,
              color: Color(0xFFFFD700), size: 14),
          const SizedBox(width: 8),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: fraction,
                minHeight: 8,
                backgroundColor: const Color(0xFFF3F4F6),
                valueColor: const AlwaysStoppedAnimation<Color>(
                    Color(0xFFFFD700)),
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 24,
            child: Text(
              '$count',
              textAlign: TextAlign.end,
              style: const TextStyle(
                  fontSize: 12, color: Color(0xFF6E6E6E)),
            ),
          ),
        ],
      ),
    );
  }
}