abstract class EmbeddingService {
  Future<List<double>> embed(String text);
  Future<void> dispose();
}

