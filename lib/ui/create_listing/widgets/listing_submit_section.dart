import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:marketplace_flutter_application/ui/connectivity/connectivity_model.dart';
import 'package:marketplace_flutter_application/ui/create_listing/create_listing_viewmodel.dart';
import 'package:provider/provider.dart';

class ListingSubmitSection extends StatelessWidget {
  const ListingSubmitSection({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<CreateListingViewModel>();
    final connectivityModel = context.watch<ConnectivityModel>();

    final canPressSubmit = viewModel.canSubmit && connectivityModel.isOnline;
    print('BUTTON DEBUG');
    print('canSubmit: ${viewModel.canSubmit}');
    print('isOnline: ${connectivityModel.isOnline}');
    print('isSubmitting: ${viewModel.isSubmitting}');
    print('currentUser: ${viewModel.currentUser}');        // <-- agrega este
    print('selectedCategory: ${viewModel.selectedCategory}'); // <-- y este
    print('title.length: ${viewModel.title.trim().length}');
    print('price: ${viewModel.price}');
    print('description.length: ${viewModel.description.trim().length}');
    print('location: ${viewModel.location}');
    print('selectedImages: ${viewModel.selectedImages.length}');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (viewModel.submitErrorMessage != null) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFFFEBEE),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFEF9A9A)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.warning_amber_rounded,
                  size: 18,
                  color: Color(0xFFD32F2F),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    viewModel.submitErrorMessage!,
                    style: const TextStyle(
                      color: Color(0xFFD32F2F),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],

        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: !canPressSubmit
                ? null
                : () async {
                    final success = await context
                        .read<CreateListingViewModel>()
                        .submitListing();

                    if (!context.mounted) return;

                    if (success) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: Colors.green.shade700,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          duration: const Duration(milliseconds: 1600),
                          content: const Row(
                            children: [
                              Icon(
                                Icons.check_circle_outline,
                                color: Colors.white,
                                size: 18,
                              ),
                              SizedBox(width: 10),
                              Text(
                                '¡Listing publicado exitosamente!',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );

                      await Future.delayed(const Duration(milliseconds: 1200));

                      if (!context.mounted) return;
                      context.go('/Home');
                    }
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF3E39A),
              foregroundColor: const Color(0xFF1F1F1F),
              disabledBackgroundColor: const Color(0xFFF3E39A).withOpacity(0.45),
              disabledForegroundColor: const Color(0xFF1F1F1F).withOpacity(0.45),
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
            child: viewModel.isSubmitting
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Color(0xFF1F1F1F),
                    ),
                  )
                : const Text(
                    'Publicar Listing',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}