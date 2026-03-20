import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../shared/widgets/app_bottom_nav_bar.dart';

class CreateListingView extends StatelessWidget {
  const CreateListingView({super.key});

  void _onNavTap(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go('/');
        break;
      case 2:
        context.go('/sell');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: const SafeArea(
        child: Center(
          child: Text('Create Listing View'),
        ),
      ),
      bottomNavigationBar: AppBottomNavBar(
        selectedIndex: 2,
        onTap: (index) => _onNavTap(context, index),
      ),
    );
  }
}