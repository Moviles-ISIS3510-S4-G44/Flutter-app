import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:marketplace_flutter_application/ui/listing-detail/listing_detail_viewmodel.dart';
import 'package:marketplace_flutter_application/ui/listing-detail/widgets/listing_detail_body.dart';

class ListingDetailView extends StatefulWidget {
  final String listingId;

  const ListingDetailView({
    super.key,
    required this.listingId,
  });

  @override
  State<ListingDetailView> createState() => _ListingDetailViewState();
}

class _ListingDetailViewState extends State<ListingDetailView> {
  late final ListingDetailViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = ListingDetailViewModel();
    _viewModel.loadListing(widget.listingId);
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _viewModel,
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => context.pop(),
            ),
            title: const Text('Product Details'),
          ),
          body: _buildBody(),
        );
      },
    );
  }

  Widget _buildBody() {
    if (_viewModel.isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_viewModel.errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            _viewModel.errorMessage!,
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    final listing = _viewModel.listing;
    if (listing == null) {
      return const Center(
        child: Text('Listing not found'),
      );
    }

    return SingleChildScrollView(
      child: Column(
        children: [
          ListingDetailBody(listing: listing),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Contact Seller próximamente'),
                    ),
                  );
                },
                icon: const Icon(Icons.chat_bubble_outline),
                label: const Text('Contact Seller'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}