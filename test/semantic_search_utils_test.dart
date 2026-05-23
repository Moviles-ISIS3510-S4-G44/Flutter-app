import 'package:flutter_test/flutter_test.dart';
import 'package:marketplace_flutter_application/data/services/semantic_similarity.dart';
import 'package:marketplace_flutter_application/data/storage/lru_cache.dart';

void main() {
  test('LruCache evicts least recently used', () {
    final cache = LruCache<String, int>(capacity: 2);
    cache.put('a', 1);
    cache.put('b', 2);
    cache.get('a');
    cache.put('c', 3);

    expect(cache.containsKey('a'), true);
    expect(cache.containsKey('b'), false);
    expect(cache.containsKey('c'), true);
  });

  test('scoreEmbeddings returns sorted matches', () {
    final matches = scoreEmbeddings(
      query: [1, 0],
      ids: ['x', 'y'],
      embeddings: [
        [0.9, 0.1],
        [0.1, 0.9],
      ],
      minScore: 0.0,
    );

    expect(matches.first.id, 'x');
    expect(matches.first.score > matches.last.score, true);
  });
}

