import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

import 'package:marketplace_flutter_application/data/services/bert_tokenizer.dart';
import 'package:marketplace_flutter_application/data/services/embedding_service.dart';
import 'package:marketplace_flutter_application/data/services/semantic_similarity.dart';

class TfliteEmbeddingService implements EmbeddingService {
  final String modelAssetPath;
  final String vocabAssetPath;
  final int maxLen;
  final int threads;

  Interpreter? _interpreter;
  BertTokenizer? _tokenizer;
  bool _initialized = false;

  TfliteEmbeddingService({
    required this.modelAssetPath,
    required this.vocabAssetPath,
    this.maxLen = 128,
    this.threads = 2,
  });

  Future<void> _ensureInitialized() async {
    if (_initialized) return;
    final options = InterpreterOptions()..threads = threads;
    _interpreter = await Interpreter.fromAsset(modelAssetPath, options: options);
    _interpreter!.allocateTensors();
    _tokenizer = await BertTokenizer.fromAsset(vocabAssetPath);
    _initialized = true;
  }

  @override
  Future<List<double>> embed(String text) async {
    await _ensureInitialized();
    final tokenizer = _tokenizer!;
    final interpreter = _interpreter!;

    final encoded = tokenizer.encode(text, maxLen: maxLen);
    final inputIds = [encoded.inputIds];
    final attentionMask = [encoded.attentionMask];

    final outputs = <int, Object>{};
    final outputTensor = interpreter.getOutputTensors().first;
    outputs[0] = _createOutputBuffer(outputTensor.shape);

    interpreter.runForMultipleInputs([inputIds, attentionMask], outputs);

    final output = outputs[0]!;
    final embedding = _extractEmbedding(
      output: output,
      attentionMask: encoded.attentionMask,
    );
    return l2Normalize(embedding);
  }

  @override
  Future<void> dispose() async {
    _interpreter?.close();
  }

  Object _createOutputBuffer(List<int> shape) {
    if (shape.isEmpty) return 0.0;
    if (shape.length == 1) {
      return List<double>.filled(shape[0], 0.0);
    }
    if (shape.length == 2) {
      return List.generate(
        shape[0],
        (_) => List<double>.filled(shape[1], 0.0),
      );
    }
    if (shape.length == 3) {
      return List.generate(
        shape[0],
        (_) => List.generate(
          shape[1],
          (_) => List<double>.filled(shape[2], 0.0),
        ),
      );
    }
    return List<double>.filled(shape.reduce((a, b) => a * b), 0.0);
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

    if (output is Float32List) {
      return output.toList(growable: false);
    }

    if (output is List<double>) {
      return output;
    }

    debugPrint('TfliteEmbeddingService: unexpected output type ${output.runtimeType}');
    return [];
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
}

