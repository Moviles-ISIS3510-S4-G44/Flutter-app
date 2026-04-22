import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:marketplace_flutter_application/ui/profile/profile_viewmodel.dart';
import 'package:marketplace_flutter_application/ui/shared/widgets/app_bottom_nav_bar.dart';

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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProfileViewModel>().loadProfile();
    });
  }

  void _onBottomNavTap(int index) {
    switch (index) {
    case 0:
      context.go('/Home');
      break;
    case 1:
      context.go('/Sell');
      break;
    case 2:
      break; // carrito
    case 3:
      break; // messages
    case 4:
      context.go('/profile');
      break;
  }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<ProfileViewModel>();

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
      body: viewModel.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                child: Column(
                  children: [
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
                    const SizedBox(height: 16),
                    _ProfileOptionTile(
                      icon: Icons.person_outline,
                      title: 'Personal information',
                      subtitle: 'View your basic account details',
                      onTap: () {},
                    ),
                    const SizedBox(height: 12),
                    _ProfileOptionTile(
                      icon: Icons.shopping_bag_outlined,
                      title: 'My listings',
                      subtitle: 'See the products you have published',
                      onTap: () {},
                    ),
                    const SizedBox(height: 12),
                    _ProfileOptionTile(
                      icon: Icons.settings_outlined,
                      title: 'Settings',
                      subtitle: 'Manage your preferences',
                      onTap: () {},
                    ),
                    const SizedBox(height: 12),
                    _ProfileOptionTile(
                      icon: Icons.help_outline,
                      title: 'Help',
                      subtitle: 'Support and FAQs',
                      onTap: () {},
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          await context.read<ProfileViewModel>().logout();
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