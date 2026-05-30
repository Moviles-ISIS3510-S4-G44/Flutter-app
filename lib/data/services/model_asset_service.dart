import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

class ModelAssetService {
  final String assetPath;
  final String fileName;
  final int minBytes;

  ModelAssetService({
    required this.assetPath,
    this.fileName = 'model.onnx',
    this.minBytes = 10 * 1024 * 1024,
  });

  Future<File> ensureModelFile() async {
    final dir = await getApplicationSupportDirectory();
    final target = File('${dir.path}${Platform.pathSeparator}$fileName');

    if (await _isValidFile(target)) {
      return target;
    }

    await _copyFromAsset(target);

    if (!await _isValidFile(target)) {
      throw Exception('Modelo ONNX local incompleto');
    }

    return target;
  }

  Future<bool> _isValidFile(File file) async {
    if (!await file.exists()) return false;
    final size = await file.length();
    return size >= minBytes;
  }

  Future<void> _copyFromAsset(File target) async {
    debugPrint('Copiando modelo ONNX desde assets');
    final bytes = await rootBundle.load(assetPath);

    final tmp = File('${target.path}.copy');
    if (await tmp.exists()) {
      await tmp.delete();
    }

    await tmp.writeAsBytes(bytes.buffer.asUint8List(), flush: true);

    if (await target.exists()) {
      await target.delete();
    }
    await tmp.rename(target.path);
  }
}

