import 'dart:math' as math;

class SemanticMatch {
  final String id;
  final double score;

  const SemanticMatch({required this.id, required this.score});
}

List<SemanticMatch> scoreEmbeddings({
  required List<double> query,
  required List<String> ids,
  required List<List<double>> embeddings,
  double minScore = 0.2,
}) {
  final results = <SemanticMatch>[];
  for (var i = 0; i < ids.length; i++) {
    final score = _dot(query, embeddings[i]);
    if (score >= minScore) {
      results.add(SemanticMatch(id: ids[i], score: score));
    }
  }
  results.sort((a, b) => b.score.compareTo(a.score));
  return results;
}

List<Map<String, Object>> scoreEmbeddingsIsolate(Map<String, Object> payload) {
  final query = (payload['query'] as List).cast<double>();
  final ids = (payload['ids'] as List).cast<String>();
  final embeddings = (payload['embeddings'] as List)
      .map((item) => (item as List).cast<double>())
      .toList(growable: false);
  final minScore = payload['minScore'] as double? ?? 0.2;

  final matches = scoreEmbeddings(
    query: query,
    ids: ids,
    embeddings: embeddings,
    minScore: minScore,
  );

  return matches
      .map((match) => {
            'id': match.id,
            'score': match.score,
          })
      .toList(growable: false);
}

List<double> l2Normalize(List<double> vector) {
  var sum = 0.0;
  for (final v in vector) {
    sum += v * v;
  }
  final norm = sum == 0.0 ? 1.0 : math.sqrt(sum);
  return vector.map((v) => v / norm).toList(growable: false);
}

double _dot(List<double> a, List<double> b) {
  var sum = 0.0;
  for (var i = 0; i < a.length; i++) {
    sum += a[i] * b[i];
  }
  return sum;
}
