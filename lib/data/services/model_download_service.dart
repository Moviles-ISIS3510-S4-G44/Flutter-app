import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class ModelDownloadService {
  final String url;
  final String fileName;
  final int minBytes;

  ModelDownloadService({
    required this.url,
    this.fileName = 'model.onnx',
    this.minBytes = 1024 * 1024,
  });

  Future<File> ensureModelFile() async {
    if (url.isEmpty) {
      throw Exception('MODEL_ONNX_URL no configurada');
    }

    final dir = await getApplicationSupportDirectory();
    final target = File('${dir.path}${Platform.pathSeparator}$fileName');

    if (await _isValidFile(target)) {
      return target;
    }

    await _downloadTo(target);

    if (!await _isValidFile(target)) {
      throw Exception('Descarga incompleta del modelo ONNX');
    }

    return target;
  }

  Future<bool> _isValidFile(File file) async {
    if (!await file.exists()) return false;
    final size = await file.length();
    return size >= minBytes;
  }

  Future<void> _downloadTo(File target) async {
    final tmp = File('${target.path}.download');
    if (await tmp.exists()) {
      await tmp.delete();
    }

    debugPrint('Descargando modelo ONNX desde $url');
    final response = await http.Client().send(http.Request('GET', Uri.parse(url)));
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Error descargando modelo: ${response.statusCode}');
    }

    final sink = tmp.openWrite();
    await response.stream.pipe(sink);
    await sink.flush();
    await sink.close();

    if (await target.exists()) {
      await target.delete();
    }
    await tmp.rename(target.path);
  }
}

