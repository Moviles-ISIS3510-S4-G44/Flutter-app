import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:marketplace_flutter_application/ui/drafts/drafts_viewmodel.dart';

class DraftsView extends StatefulWidget {
  const DraftsView({super.key});

  @override
  State<DraftsView> createState() => _DraftsViewState();
}

class _DraftsViewState extends State<DraftsView> {
  static const Color bgColor = Color(0xFFEEF2F7);
  static const Color textPrimary = Color(0xFF1F1F1F);
  static const Color textSecondary = Color(0xFF6E6E6E);
  static const Color accentGold = Color(0xFFF3E39A);

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<DraftsViewModel>().loadDrafts();
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<DraftsViewModel>();

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Drafts',
          style: TextStyle(
            fontFamily: 'PlusJakartaSans',
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: textPrimary,
          ),
        ),
      ),
      body: vm.isLoading
          ? const Center(child: CircularProgressIndicator())
          : vm.drafts.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.drafts_outlined, size: 64, color: Color(0xFFAEB7C2)),
                      SizedBox(height: 16),
                      Text(
                        'No drafts saved yet',
                        style: TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFAEB7C2),
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: vm.drafts.length,
                  itemBuilder: (context, i) {
                    final draft = vm.drafts[i];
                    return Dismissible(
                      key: ValueKey('draft_$i'),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Colors.red[400],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      onDismissed: (_) => vm.deleteDraft(i),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            // gold icon circle
                            Container(
                              width: 44,
                              height: 44,
                              decoration: const BoxDecoration(
                                color: accentGold,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.description_outlined,
                                  size: 22, color: textPrimary),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    draft['title']?.isNotEmpty == true
                                        ? draft['title']!
                                        : 'Untitled',
                                    style: const TextStyle(
                                      fontFamily: 'PlusJakartaSans',
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      color: textPrimary,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      if (draft['price']?.isNotEmpty == true)
                                        Text(
                                          '\$${draft['price']}',
                                          style: const TextStyle(
                                            fontFamily: 'PlusJakartaSans',
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xFF6A5A00),
                                          ),
                                        ),
                                      if (draft['price']?.isNotEmpty == true &&
                                          draft['category']?.isNotEmpty == true)
                                        const Text('  ·  ',
                                            style: TextStyle(color: textSecondary)),
                                      if (draft['category']?.isNotEmpty == true)
                                        Text(
                                          draft['category']!,
                                          style: const TextStyle(
                                            fontFamily: 'PlusJakartaSans',
                                            fontSize: 13,
                                            color: textSecondary,
                                          ),
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const Icon(Icons.chevron_right, color: textSecondary, size: 22),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
