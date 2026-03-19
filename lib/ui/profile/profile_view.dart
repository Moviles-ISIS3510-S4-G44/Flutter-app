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
    }
  }
}

class _ProfileContent extends StatelessWidget {
  final ProfileViewModel vm;
  const _ProfileContent({required this.vm});

  @override
  Widget build(BuildContext context) {
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
                    vm.photoUrl != null ? NetworkImage(vm.photoUrl!) : null,
                child: vm.photoUrl == null
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
          // the team can wire user.name here when their user model is ready
          Text(
            vm.user?.name ?? 'Student',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1F1F1F),
              fontFamily: 'PlusJakartaSans',
            ),
          ),
          const SizedBox(height: 8),
          Text(
            vm.user?.email ?? '',
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xFF6E6E6E),
              fontFamily: 'PlusJakartaSans',
            ),
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
