import 'package:flutter/foundation.dart';
import 'package:marketplace_flutter_application/data/dtos/search/intent_filters.dart';
import 'package:marketplace_flutter_application/data/services/embedding_service.dart';
import 'package:marketplace_flutter_application/data/services/intent_parser.dart';
import 'package:marketplace_flutter_application/data/services/search_query_expander.dart';
import 'package:marketplace_flutter_application/data/services/semantic_similarity.dart';
import 'package:marketplace_flutter_application/data/storage/lru_cache.dart';
import 'package:marketplace_flutter_application/models/listings/listing_summary.dart';

class SemanticSearchService {
  final EmbeddingService _embeddingService;
  final IntentParser _intentParser;
  final SearchQueryExpander _queryExpander;

  final LruCache<String, List<double>> _queryEmbeddingCache;
  final LruCache<String, IntentFilters> _intentCache;

  final Map<String, List<double>> _listingEmbeddings = {};
  final Map<String, ListingSummary> _listingById = {};

  SemanticSearchService({
    required EmbeddingService embeddingService,
    required IntentParser intentParser,
    SearchQueryExpander? queryExpander,
    int queryCacheSize = 64,
    int intentCacheSize = 64,
  })  : _embeddingService = embeddingService,
        _intentParser = intentParser,
        _queryExpander = queryExpander ?? SearchQueryExpander(),
        _queryEmbeddingCache = LruCache(capacity: queryCacheSize),
        _intentCache = LruCache(capacity: intentCacheSize);

  Future<void> rebuildIndex(List<ListingSummary> listings) async {
    _listingEmbeddings.clear();
    _listingById.clear();

    for (final listing in listings) {
      final text = _listingToText(listing);
      final expanded = _queryExpander.expandText(text);
      final embedding = await _embeddingService.embed(expanded);
      if (embedding.isEmpty) continue;
      _listingEmbeddings[listing.id] = embedding;
      _listingById[listing.id] = listing;
    }
  }

  Future<List<SemanticMatch>> semanticSearch(
    String query, {
    Iterable<ListingSummary>? candidates,
    double minScore = 0.2,
  }) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return [];

    final expanded = _queryExpander.expandText(trimmed);
    final cached = _queryEmbeddingCache.get(expanded);
    final queryEmbedding = cached ?? await _embeddingService.embed(expanded);
    if (queryEmbedding.isEmpty) return [];
    _queryEmbeddingCache.put(expanded, queryEmbedding);

    final candidateIds = <String>[];
    final candidateEmbeddings = <List<double>>[];

    final source = candidates ?? _listingById.values;
    for (final listing in source) {
      final embedding = _listingEmbeddings[listing.id];
      if (embedding == null) continue;
      candidateIds.add(listing.id);
      candidateEmbeddings.add(embedding);
    }

    if (candidateIds.isEmpty) return [];

    final matches = await compute(scoreEmbeddingsIsolate, {
      'query': queryEmbedding,
      'ids': candidateIds,
      'embeddings': candidateEmbeddings,
      'minScore': minScore,
    });

    return matches
        .map((match) => SemanticMatch(
              id: match['id'] as String,
              score: match['score'] as double,
            ))
        .toList(growable: false);
  }

  Future<IntentFilters> parseIntent(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return IntentFilters.empty;
    final cached = _intentCache.get(trimmed);
    if (cached != null) return cached;

    final parsed = await _intentParser.parseIntent(trimmed);
    _intentCache.put(trimmed, parsed);
    return parsed;
  }

  ListingSummary? getListingById(String id) => _listingById[id];

  void clearCaches() {
    _queryEmbeddingCache.clear();
    _intentCache.clear();
  }

  String _listingToText(ListingSummary listing) {
    final buffer = StringBuffer();
    buffer.write(listing.title);
    if (listing.description != null && listing.description!.isNotEmpty) {
      buffer.write(' ');
      buffer.write(listing.description);
    }
    buffer.write(' ');
    buffer.write(listing.category);
    if (listing.condition != null && listing.condition!.isNotEmpty) {
      buffer.write(' ');
      buffer.write(listing.condition);
    }
    buffer.write(' precio ${listing.price}');
    return buffer.toString();
  }
}
