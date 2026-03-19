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
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<ProfileViewModel>().loadProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ProfileViewModel>();

    return Scaffold(
      backgroundColor: const Color(0xFFEEF2F7),
      appBar: AppBar(
        backgroundColor: const Color(0xFFEEF2F7),
        elevation: 0,
        title: const Text(
          'Profile',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1F1F1F),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Color(0xFF1F1F1F)),
            onPressed: () async {
              await vm.logout();
              if (context.mounted) context.go('/login');
            },
          ),
        ],
      ),
      body: vm.isLoading
          ? const Center(child: CircularProgressIndicator())
          : vm.user == null
              ? const Center(child: Text('Not logged in'))
              : _ProfileContent(vm: vm),
      bottomNavigationBar: AppBottomNavBar(
        selectedIndex: 4,
        onTap: (idx) => _onNavTap(context, idx),
      ),
    );
  }

  void _onNavTap(BuildContext context, int idx) {
    switch (idx) {
      case 0:
        context.go('/');
      case 1:
        context.push('/search');
      case 2:
        context.push('/create');
      // case 3 is inbox - not implemented yet
    }
  }
}

class _ProfileContent extends StatelessWidget {
  final ProfileViewModel vm;
  const _ProfileContent({required this.vm});

  @override
  Widget build(BuildContext context) {
    final user = vm.user!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // profile photo with camra button
          Stack(
            children: [
              CircleAvatar(
                radius: 60,
                backgroundColor: const Color(0xFFF3E39A),
                backgroundImage:
                    user.photoUrl != null ? NetworkImage(user.photoUrl!) : null,
                child: user.photoUrl == null
                    ? const Icon(Icons.person, size: 60, color: Color(0xFF1F1F1F))
                    : null,
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: () => _showPhotoOptions(context),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: Color(0xFFFFD700),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.camera_alt, color: Color(0xFF1F1F1F), size: 20),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            user.name,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1F1F1F),
              fontFamily: 'PlusJakartaSans',
            ),
          ),
          const SizedBox(height: 8),
          Text(
            user.email,
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xFF6E6E6E),
              fontFamily: 'PlusJakartaSans',
            ),
          ),
          const SizedBox(height: 32),
          _InfoCard(
            icon: Icons.calendar_today,
            label: 'Member since',
            value: '${user.createdAt.day}/${user.createdAt.month}/${user.createdAt.year}',
          ),
          if (vm.error != null) ...[
            const SizedBox(height: 16),
            Text(vm.error!, style: const TextStyle(color: Colors.red)),
          ],
        ],
      ),
    );
  }

  void _showPhotoOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take Photo'),
              onTap: () {
                Navigator.pop(context);
                vm.pickAndUploadPhoto(fromCamera: true);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Navigator.pop(context);
                vm.pickAndUploadPhoto(fromCamera: false);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoCard({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFF1F1F1F)),
        title: Text(label, style: const TextStyle(fontFamily: 'PlusJakartaSans')),
        subtitle: Text(value, style: const TextStyle(fontFamily: 'PlusJakartaSans')),
      ),
    );
  }
}
