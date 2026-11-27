import 'dart:convert';
import 'dart:typed_data';

import 'package:app_flutter/shared/platform/file_gateway.dart';
import 'package:file_selector/file_selector.dart';

/// Implementação desktop com `file_selector` (diálogos nativos).
class DesktopFileGateway implements FileGateway {
  @override
  Future<String?> saveFile({
    required String fileName,
    required String content,
  }) async {
    final location = await getSaveLocation(suggestedName: fileName);
    if (location == null) {
      return null;
    }
    final bytes = Uint8List.fromList(utf8.encode(content));
    final file = XFile.fromData(
      bytes,
      mimeType: 'application/json',
      name: fileName,
    );
    await file.saveTo(location.path);
    return location.path;
  }
}
