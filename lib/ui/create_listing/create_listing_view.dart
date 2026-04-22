import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:marketplace_flutter_application/ui/connectivity/connectivity_model.dart';
import 'package:marketplace_flutter_application/ui/connectivity/connectivity_view.dart';
import 'package:marketplace_flutter_application/ui/create_listing/widgets/listing_basic_details_section.dart';
import 'package:marketplace_flutter_application/ui/create_listing/widgets/listing_condition_section.dart';
import 'package:marketplace_flutter_application/ui/create_listing/widgets/listing_description_section.dart';
import 'package:marketplace_flutter_application/ui/create_listing/widgets/listing_image_picker_section.dart';
import 'package:marketplace_flutter_application/ui/create_listing/widgets/listing_location_section.dart';
import 'package:marketplace_flutter_application/ui/create_listing/widgets/listing_submit_section.dart';
import 'package:provider/provider.dart';

import '../shared/widgets/app_bottom_nav_bar.dart';

class CreateListingView extends StatelessWidget {
  const CreateListingView({super.key});

  void _onNavTap(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go('/Home');
        break;
      case 2:
        context.go('/Sell');
        break;
            case 3:
        break;
      case 4:
        context.go('/profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final connectivityModel = context.watch<ConnectivityModel>();

    return Scaffold(
      backgroundColor: const Color(0xFFEEF2F7),
      appBar: AppBar(
        backgroundColor: const Color(0xFFEEF2F7),
        elevation: 0,
        centerTitle: false,
        automaticallyImplyLeading: false,
        title: const Text(
          'Create Listing',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1F1F1F),
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            if (!connectivityModel.isOnline)
              const ConnectivityView(),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    SizedBox(height: 8),
                    ListingImagePickerSection(),
                    SizedBox(height: 24),
                    ListingBasicDetailsSection(),
                    SizedBox(height: 24),
                    ListingConditionSection(),
                    SizedBox(height: 24),
                    ListingLocationSection(),
                    SizedBox(height: 24),
                    ListingDescriptionSection(),
                    SizedBox(height: 24),
                    ListingSubmitSection(),
                    SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: AppBottomNavBar(
        selectedIndex: 2,
        onTap: (index) => _onNavTap(context, index),
      ),
    );
  }
}