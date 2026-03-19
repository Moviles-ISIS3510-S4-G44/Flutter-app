import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:marketplace_flutter_application/ui/search/search_viewmodel.dart';

class SearchView extends StatelessWidget {
  const SearchView({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<SearchViewModel>();

    return Scaffold(
      backgroundColor: const Color(0xFFEEF2F7),
      appBar: AppBar(
        backgroundColor: const Color(0xFFEEF2F7),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1F1F1F)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Search',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1F1F1F),
            fontFamily: 'PlusJakartaSans',
          ),
        ),
        actions: [
          // map icon to search nearby
          IconButton(
            icon: const Icon(Icons.map_outlined, color: Color(0xFF1F1F1F)),
            tooltip: 'Search nearby on map',
            onPressed: () => context.push('/map'),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              style: const TextStyle(fontSize: 14, color: Color(0xFF1F1F1F)),
              decoration: InputDecoration(
                hintText: 'Search products...',
                hintStyle: const TextStyle(fontSize: 14, color: Color(0xFFAEB7C2)),
                filled: true,
                fillColor: Colors.white,
                prefixIcon: const Icon(Icons.search, size: 20, color: Color(0xFFAEB7C2)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (val) => vm.search(val),
            ),
          ),
          // quick access to map
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: GestureDetector(
              onTap: () => context.push('/map'),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF0B8),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.location_on, size: 18, color: Color(0xFF6A5A00)),
                    SizedBox(width: 8),
                    Text(
                      'Search nearby on map',
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF6A5A00),
                      ),
                    ),
                    Spacer(),
                    Icon(Icons.arrow_forward_ios, size: 14, color: Color(0xFF6A5A00)),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          if (vm.isLoading)
            const Padding(
              padding: EdgeInsets.only(top: 40),
              child: Center(child: CircularProgressIndicator()),
            )
          else
            Expanded(
              child: vm.results.isEmpty
                  ? Center(
                      child: Text(
                        vm.query.isEmpty ? 'Start typing to search' : 'No results found',
                        style: const TextStyle(color: Color(0xFFAEB7C2)),
                      ),
                    )
                  : ListView.builder(
                      itemCount: vm.results.length,
                      itemBuilder: (context, i) {
                        final p = vm.results[i];
                        return ListTile(
                          leading: p.imageUrl.isNotEmpty
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    p.imageUrl,
                                    width: 50,
                                    height: 50,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) =>
                                        const Icon(Icons.image_not_supported),
                                  ),
                                )
                              : const Icon(Icons.shopping_bag),
                          title: Text(p.title, style: const TextStyle(fontWeight: FontWeight.w600)),
                          subtitle: Text(p.price),
                          onTap: () => context.push('/product/${p.id}'),
                        );
                      },
                    ),
            ),
        ],
      ),
    );
  }
}
