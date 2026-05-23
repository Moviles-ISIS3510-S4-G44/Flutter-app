import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:marketplace_flutter_application/data/repositories/ratings_repository.dart';

class RatePurchasesView extends StatefulWidget {
  /// Lista de compras completadas: [{purchaseId, listingTitle, sellerName}]
  final List<Map<String, String>> purchases;

  const RatePurchasesView({super.key, required this.purchases});

  @override
  State<RatePurchasesView> createState() => _RatePurchasesViewState();
}

class _RatePurchasesViewState extends State<RatePurchasesView> {
  static const Color background = Color(0xFFEEF2F7);
  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF6E6E6E);
  static const Color borderColor = Color(0xFFE5E7EB);
  static const Color accent = Color(0xFFFFD700);

  // purchaseId → score seleccionado (null = sin calificar)
  late final Map<String, int?> _scores;
  final Map<String, bool> _submitted = {};
  final Map<String, String?> _errors = {};
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _scores = {for (final p in widget.purchases) p['purchaseId']!: null};
  }

  Future<void> _submitAll() async {
    final toRate = _scores.entries
        .where((e) => e.value != null && _submitted[e.key] != true)
        .toList();

    if (toRate.isEmpty) {
      context.go('/Home');
      return;
    }

    setState(() => _isSubmitting = true);

    final repo = context.read<RatingsRepository>();

    for (final entry in toRate) {
      try {
        await repo.rateSeller(
          purchaseId: entry.key,
          score: entry.value!,
        );
        setState(() => _submitted[entry.key] = true);
      } catch (e) {
        setState(() => _errors[entry.key] = 'No se pudo enviar. Intenta de nuevo.');
      }
    }

    setState(() => _isSubmitting = false);

    if (!mounted) return;

    final allDone = _scores.keys.every((id) => _submitted[id] == true);
    if (allDone) context.go('/Home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: background,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          '¡Compra exitosa!',
          style: TextStyle(
            color: textPrimary,
            fontWeight: FontWeight.w700,
            fontSize: 22,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: borderColor),
                      ),
                      child: Column(
                        children: [
                          Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              color: const Color(0xFFD1FAE5),
                              borderRadius: BorderRadius.circular(28),
                            ),
                            child: const Icon(
                              Icons.check_circle_outline_rounded,
                              color: Color(0xFF059669),
                              size: 32,
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Tus compras se realizaron con éxito',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: textPrimary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Califica a los vendedores para ayudar a la comunidad',
                            style: TextStyle(
                              fontSize: 13,
                              color: textSecondary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Una card por compra
                    ...widget.purchases.map((purchase) {
                      final purchaseId = purchase['purchaseId']!;
                      final isDone = _submitted[purchaseId] == true;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _RatingCard(
                          listingTitle: purchase['listingTitle'] ?? 'Producto',
                          sellerName: purchase['sellerName'] ?? 'Vendedor',
                          selectedScore: _scores[purchaseId],
                          isSubmitted: isDone,
                          errorMessage: _errors[purchaseId],
                          onScoreSelected: isDone
                              ? null
                              : (score) => setState(
                                    () => _scores[purchaseId] = score,
                                  ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),

            // Botones
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : _submitAll,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3483FA),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isSubmitting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'Enviar calificaciones',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: TextButton(
                      onPressed: () => context.go('/Home'),
                      child: const Text(
                        'Omitir por ahora',
                        style: TextStyle(
                          color: textSecondary,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RatingCard extends StatelessWidget {
  final String listingTitle;
  final String sellerName;
  final int? selectedScore;
  final bool isSubmitted;
  final String? errorMessage;
  final void Function(int)? onScoreSelected;

  const _RatingCard({
    required this.listingTitle,
    required this.sellerName,
    required this.selectedScore,
    required this.isSubmitted,
    this.errorMessage,
    this.onScoreSelected,
  });

  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF6E6E6E);
  static const Color borderColor = Color(0xFFE5E7EB);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSubmitted ? const Color(0xFF059669) : borderColor,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      listingTitle,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Vendedor: $sellerName',
                      style: const TextStyle(
                        fontSize: 13,
                        color: textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              if (isSubmitted)
                const Icon(Icons.check_circle_rounded,
                    color: Color(0xFF059669), size: 22),
            ],
          ),
          const SizedBox(height: 14),
          if (!isSubmitted) ...[
            const Text(
              '¿Cómo fue tu experiencia con este vendedor?',
              style: TextStyle(fontSize: 13, color: textSecondary),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (i) {
                final star = i + 1;
                final filled = selectedScore != null && star <= selectedScore!;
                return GestureDetector(
                  onTap: () => onScoreSelected?.call(star),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: Icon(
                      filled ? Icons.star_rounded : Icons.star_outline_rounded,
                      color: filled
                          ? const Color(0xFFFFD700)
                          : const Color(0xFFD1D5DB),
                      size: 36,
                    ),
                  ),
                );
              }),
            ),
            if (errorMessage != null) ...[
              const SizedBox(height: 8),
              Text(
                errorMessage!,
                style:
                    const TextStyle(fontSize: 12, color: Colors.redAccent),
              ),
            ],
          ] else ...[
            Row(
              children: [
                ...List.generate(
                  selectedScore ?? 0,
                  (_) => const Icon(Icons.star_rounded,
                      color: Color(0xFFFFD700), size: 22),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Calificación enviada',
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF059669),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}