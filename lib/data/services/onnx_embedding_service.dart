import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:onnxruntime/onnxruntime.dart';
import 'dart:io';

import 'package:marketplace_flutter_application/data/services/bert_tokenizer.dart';
import 'package:marketplace_flutter_application/data/services/embedding_service.dart';
import 'package:marketplace_flutter_application/data/services/semantic_similarity.dart';

class OnnxEmbeddingService implements EmbeddingService {
  final String modelFilePath;
  final String vocabAssetPath;
  final int maxLen;

  OrtSession? _session;
  BertTokenizer? _tokenizer;
  bool _initialized = false;
  List<String> _inputNames = const [];
  List<String> _outputNames = const [];

  OnnxEmbeddingService({
    required this.modelFilePath,
    required this.vocabAssetPath,
    this.maxLen = 32,
  });

  Future<void> _ensureInitialized() async {
    if (_initialized) return;

    if (modelFilePath.isEmpty) {
      throw Exception('Ruta del modelo ONNX vacía');
    }

    final bytes = await File(modelFilePath).readAsBytes();
    final options = OrtSessionOptions();
    _session = OrtSession.fromBuffer(bytes, options);
    _tokenizer = await BertTokenizer.fromAsset(vocabAssetPath);

    _inputNames = _safeStringList(() => (_session as dynamic).inputNames);
    _outputNames = _safeStringList(() => (_session as dynamic).outputNames);

    _initialized = true;
  }

  @override
  Future<List<double>> embed(String text) async {
    await _ensureInitialized();
    final tokenizer = _tokenizer!;
    final session = _session!;

    final encoded = tokenizer.encode(text, maxLen: maxLen);
    final inputIds = Int64List.fromList(encoded.inputIds);
    final attentionMask = Int64List.fromList(encoded.attentionMask);
    final tokenTypeIds = Int64List(maxLen);

    final inputs = _buildInputs(
      inputIds: inputIds,
      attentionMask: attentionMask,
      tokenTypeIds: tokenTypeIds,
    );

    final outputs = session.run(OrtRunOptions(), inputs);
    final outputValue = _extractPreferredOutput(outputs);
    if (outputValue == null) {
      debugPrint('OnnxEmbeddingService: no outputs from model');
      return [];
    }

    final embedding = _extractEmbedding(
      output: outputValue,
      attentionMask: encoded.attentionMask,
    );

    if (embedding.isEmpty) {
      debugPrint('OnnxEmbeddingService: empty embedding');
    }

    return l2Normalize(embedding);
  }

  @override
  Future<void> dispose() async {
    try {
      (_session as dynamic)?.release();
    } catch (_) {
      try {
        (_session as dynamic)?.close();
      } catch (_) {}
    }
  }

  Object? _extractFirstOutput(Object outputs) {
    if (outputs is Map) {
      final first = outputs.values.first;
      return (first as dynamic).value ?? first;
    }
    if (outputs is List) {
      final first = outputs.first;
      return (first as dynamic).value ?? first;
    }
    return outputs;
  }

  List<double> _extractEmbedding({
    required Object output,
    required List<int> attentionMask,
  }) {
    if (output is List<List<double>>) {
      return output.first;
    }

    if (output is List<List<List<double>>>) {
      final tokenEmbeddings = output.first;
      return _meanPool(tokenEmbeddings, attentionMask);
    }

    if (output is List<List<List<num>>>) {
      final tokenEmbeddings = output.first
          .map((row) => row.map((v) => v.toDouble()).toList())
          .toList(growable: false);
      return _meanPool(tokenEmbeddings, attentionMask);
    }

    if (output is Float32List) {
      final pooled = _meanPoolFlat(output, attentionMask);
      return pooled ?? output.toList(growable: false);
    }

    if (output is List<double>) {
      return output;
    }

    debugPrint('OnnxEmbeddingService: unexpected output type ${output.runtimeType}');
    return [];
  }

  List<double>? _meanPoolFlat(
    Float32List flat,
    List<int> attentionMask,
  ) {
    if (attentionMask.isEmpty || flat.isEmpty) return null;
    if (flat.length % attentionMask.length != 0) return null;

    final hiddenSize = flat.length ~/ attentionMask.length;
    final pooled = Float32List(hiddenSize);

    var count = 0;
    for (var i = 0; i < attentionMask.length; i++) {
      if (attentionMask[i] == 0) continue;
      final offset = i * hiddenSize;
      for (var j = 0; j < hiddenSize; j++) {
        pooled[j] += flat[offset + j];
      }
      count++;
    }

    if (count == 0) return pooled.toList(growable: false);
    for (var j = 0; j < hiddenSize; j++) {
      pooled[j] = pooled[j] / count;
    }
    return pooled.toList(growable: false);
  }

  List<double> _meanPool(
    List<List<double>> tokenEmbeddings,
    List<int> attentionMask,
  ) {
    if (tokenEmbeddings.isEmpty) return [];
    final hiddenSize = tokenEmbeddings[0].length;
    final pooled = Float32List(hiddenSize);

    var count = 0;
    for (var i = 0; i < tokenEmbeddings.length && i < attentionMask.length; i++) {
      if (attentionMask[i] == 0) continue;
      final token = tokenEmbeddings[i];
      for (var j = 0; j < hiddenSize; j++) {
        pooled[j] += token[j];
      }
      count++;
    }

    if (count == 0) return pooled.toList(growable: false);
    for (var j = 0; j < hiddenSize; j++) {
      pooled[j] = pooled[j] / count;
    }
    return pooled.toList(growable: false);
  }

  Object? _extractPreferredOutput(Object outputs) {
    if (outputs is Map) {
      for (final key in _preferredOutputKeys()) {
        if (outputs.containsKey(key)) {
          return _unwrapValue(outputs[key]);
        }
      }
      return _unwrapValue(outputs.values.first);
    }
    if (outputs is List) {
      return _unwrapValue(outputs.first);
    }
    return _unwrapValue(outputs);
  }

  OrtValue _maybeValue(Object value) => value as OrtValue;

  Object? _unwrapValue(Object? value) {
    if (value == null) return null;
    return (value as dynamic).value ?? value;
  }

  List<String> _preferredOutputKeys() {
    final dynamicNames = _outputNames.whereType<String>();
    if (dynamicNames.isNotEmpty) {
      return dynamicNames.toList(growable: false);
    }
    return const [
      'last_hidden_state',
      'sentence_embedding',
      'pooler_output',
      'embeddings',
      'output_0',
    ];
  }

  List<String> _safeStringList(Object Function() getter) {
    try {
      final value = getter();
      if (value is List) {
        return value.map((e) => e.toString()).toList(growable: false);
      }
    } catch (_) {}
    return const [];
  }

  Map<String, OrtValue> _buildInputs({
    required Int64List inputIds,
    required Int64List attentionMask,
    required Int64List tokenTypeIds,
  }) {
    final byName = <String, OrtValue>{
      'input_ids': OrtValueTensor.createTensorWithDataList(
        inputIds,
        [1, maxLen],
      ),
      'attention_mask': OrtValueTensor.createTensorWithDataList(
        attentionMask,
        [1, maxLen],
      ),
      'token_type_ids': OrtValueTensor.createTensorWithDataList(
        tokenTypeIds,
        [1, maxLen],
      ),
    };

    if (_inputNames.isEmpty) return byName;

    final filtered = <String, OrtValue>{};
    for (final name in _inputNames) {
      final value = byName[name];
      if (value != null) filtered[name] = value;
    }
    return filtered.isEmpty ? byName : filtered;
  }
}
