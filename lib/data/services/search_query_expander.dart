class SearchQueryExpander {
  final Map<String, Set<String>> _synonyms;
  final List<String> _phraseTokens;

  static final Map<String, Set<String>> _defaultSynonyms = {
    'computador': {'pc', 'laptop', 'portatil', 'notebook'},
    'portatil': {'laptop', 'notebook', 'computador'},
    'audifonos': {'auriculares', 'headphones', 'airpods'},
    'camara': {'fotografia', 'dslr', 'canon', 'sony'},
    'teclado': {'keyboard', 'keychron', 'mecanico'},
    'libro': {'book', 'texto', 'novela'},
    'mueble': {'escritorio', 'silla', 'mesa'},
    'celular': {'movil', 'telefono', 'smartphone'},
    'nuevo': {'new', 'sin uso'},
    'usado': {'used', 'segunda mano', 'preowned'},
  };

  SearchQueryExpander({Map<String, Set<String>>? synonyms})
      : _synonyms = _normalizeMap(synonyms ?? _defaultSynonyms),
        _phraseTokens = _extractPhraseTokens(synonyms ?? _defaultSynonyms);

  List<String> expandTokens(Iterable<String> tokens) {
    final expanded = <String>{};
    final normalized = tokens
        .map((t) => t.trim().toLowerCase())
        .where((t) => t.isNotEmpty)
        .toList(growable: false);

    for (final token in normalized) {
      _expandToken(token, expanded);
    }

    return expanded.toList(growable: false);
  }

  String expandText(String text) {
    final normalizedText = _normalize(text);
    final tokens = _splitTokens(normalizedText);
    final expanded = expandTokens(tokens).toSet();

    for (final phrase in _phraseTokens) {
      if (normalizedText.contains(phrase)) {
        _expandToken(phrase, expanded);
      }
    }

    return expanded.toList(growable: false).join(' ');
  }

  void _expandToken(String token, Set<String> out) {
    final normalized = _normalize(token);
    if (out.contains(normalized)) return;
    out.add(normalized);

    // Step 1: token as key
    final direct = _synonyms[normalized];
    if (direct != null && direct.isNotEmpty) {
      for (final synonym in direct) {
        _expandToken(synonym, out);
      }
    }

    // Step 2: token as value
    for (final entry in _synonyms.entries) {
      if (entry.value.any((v) => v == normalized)) {
        _expandToken(entry.key, out);
      }
    }
  }

  List<String> _splitTokens(String text) {
    return text
        .split(RegExp(r"\s+"))
        .where((t) => t.isNotEmpty)
        .toList(growable: false);
  }

  static Map<String, Set<String>> _normalizeMap(
    Map<String, Set<String>> raw,
  ) {
    final normalized = <String, Set<String>>{};
    for (final entry in raw.entries) {
      final key = _normalize(entry.key);
      if (key.isEmpty) continue;
      final values = <String>{};
      for (final value in entry.value) {
        final v = _normalize(value);
        if (v.isNotEmpty) values.add(v);
      }
      if (values.isNotEmpty) normalized[key] = values;
    }
    return normalized;
  }

  static List<String> _extractPhraseTokens(Map<String, Set<String>> raw) {
    final phrases = <String>{};
    for (final entry in raw.entries) {
      final key = _normalize(entry.key);
      if (key.contains(' ')) phrases.add(key);
      for (final value in entry.value) {
        final v = _normalize(value);
        if (v.contains(' ')) phrases.add(v);
      }
    }
    return phrases.toList(growable: false);
  }

  static String _normalize(String input) {
    final lower = input.trim().toLowerCase();
    return lower
        .replaceAll('á', 'a')
        .replaceAll('é', 'e')
        .replaceAll('í', 'i')
        .replaceAll('ó', 'o')
        .replaceAll('ú', 'u')
        .replaceAll('ü', 'u')
        .replaceAll('ñ', 'n');
  }
}
