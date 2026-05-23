import 'dart:collection';
import 'package:flutter/services.dart';

class BertTokenizer {
  final Map<String, int> _vocab;
  final String unkToken;
  final String clsToken;
  final String sepToken;
  final String padToken;
  final int maxInputCharsPerWord;

  BertTokenizer._(
    this._vocab, {
    this.unkToken = '[UNK]',
    this.clsToken = '[CLS]',
    this.sepToken = '[SEP]',
    this.padToken = '[PAD]',
    this.maxInputCharsPerWord = 200,
  });

  static Future<BertTokenizer> fromAsset(String assetPath) async {
    final raw = await rootBundle.loadString(assetPath);
    final lines = raw.split('\n');
    final vocab = LinkedHashMap<String, int>();
    for (var i = 0; i < lines.length; i++) {
      final token = lines[i].trim();
      if (token.isEmpty) continue;
      vocab[token] = i;
    }
    return BertTokenizer._(vocab);
  }

  ({List<int> inputIds, List<int> attentionMask}) encode(
    String text, {
    required int maxLen,
  }) {
    final tokens = _tokenize(text);
    final wordPieces = <String>[clsToken, ...tokens, sepToken];
    final inputIds = List<int>.filled(maxLen, _vocab[padToken] ?? 0);
    final attentionMask = List<int>.filled(maxLen, 0);

    final limited = wordPieces.take(maxLen).toList(growable: false);
    for (var i = 0; i < limited.length; i++) {
      inputIds[i] = _vocab[limited[i]] ?? _vocab[unkToken] ?? 0;
      attentionMask[i] = 1;
    }

    return (inputIds: inputIds, attentionMask: attentionMask);
  }

  List<String> _tokenize(String text) {
    final cleaned = _cleanText(text);
    final words = cleaned.split(RegExp(r'\s+'));
    final tokens = <String>[];
    for (final word in words) {
      if (word.isEmpty) continue;
      tokens.addAll(_wordPieceTokenize(word));
    }
    return tokens;
  }

  List<String> _wordPieceTokenize(String word) {
    if (word.length > maxInputCharsPerWord) {
      return [unkToken];
    }

    final chars = word.toLowerCase().split('');
    final subTokens = <String>[];
    var start = 0;
    while (start < chars.length) {
      var end = chars.length;
      String? curSub;
      while (start < end) {
        var piece = chars.sublist(start, end).join();
        if (start > 0) {
          piece = '##$piece';
        }
        if (_vocab.containsKey(piece)) {
          curSub = piece;
          break;
        }
        end--;
      }
      if (curSub == null) {
        return [unkToken];
      }
      subTokens.add(curSub);
      start = end;
    }
    return subTokens;
  }

  String _cleanText(String text) {
    final buffer = StringBuffer();
    for (final rune in text.runes) {
      final char = String.fromCharCode(rune);
      if (_isControl(char)) continue;
      if (_isWhitespace(char)) {
        buffer.write(' ');
      } else if (_isPunctuation(char)) {
        buffer.write(' ');
        buffer.write(char);
        buffer.write(' ');
      } else {
        buffer.write(char);
      }
    }
    return buffer.toString().trim();
  }

  bool _isWhitespace(String char) {
    return char == ' ' || char == '\t' || char == '\n' || char == '\r';
  }

  bool _isControl(String char) {
    final code = char.codeUnitAt(0);
    return (code >= 0 && code <= 31) || (code >= 127 && code <= 159);
  }

  bool _isPunctuation(String char) {
    final code = char.codeUnitAt(0);
    if ((code >= 33 && code <= 47) ||
        (code >= 58 && code <= 64) ||
        (code >= 91 && code <= 96) ||
        (code >= 123 && code <= 126)) {
      return true;
    }
    return false;
  }
}

