import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle, StandardMessageCodec;

class WallpaperLoader {
  WallpaperLoader._();

  static List<String>? _cache;

  static Future<List<String>> loadWallpapers() async {
    if (_cache != null) {
      return _cache!;
    }

    try {
      final manifestContent = await rootBundle.loadString('AssetManifest.json');
      final Map<String, dynamic> manifestMap = jsonDecode(manifestContent);
      final wallpapers = _extractWallpapers(manifestMap);
      if (wallpapers.isNotEmpty) {
        _cache = wallpapers;
        return wallpapers;
      }
    } catch (_) {
      // Ignore and fall back to binary manifest parsing below.
    }

    try {
      final byteData = await rootBundle.load('AssetManifest.bin');
      final manifestData =
          const StandardMessageCodec().decodeMessage(byteData)
              as Map<dynamic, dynamic>?;
      if (manifestData != null) {
        final wallpapers = _extractWallpapers(manifestData);
        if (wallpapers.isNotEmpty) {
          _cache = wallpapers;
          return wallpapers;
        }
      }
    } catch (_) {
      // Ignore; we'll fall through to returning an empty list.
    }

    return const [];
  }

  static void clearCache() {
    _cache = null;
  }

  static List<String> _extractWallpapers(Map<dynamic, dynamic> manifestMap) {
    final assetKeys = <String>{};

    final dynamic filesSection = manifestMap['files'];
    if (filesSection is Map) {
      assetKeys.addAll(filesSection.keys.cast<String>());
    } else if (filesSection is List) {
      for (final entry in filesSection) {
        if (entry is Map) {
          final asset = entry['asset'];
          if (asset is String && asset.isNotEmpty) {
            assetKeys.add(asset);
          }
        }
      }
    }

    if (assetKeys.isEmpty && manifestMap.isNotEmpty) {
      for (final key in manifestMap.keys) {
        if (key is String) {
          assetKeys.add(key);
        }
      }
    }

    final wallpapers =
        assetKeys
            .where(
              (key) =>
                  key.startsWith('assets/wallpaper_backgrund/') &&
                  (key.endsWith('.jpg') ||
                      key.endsWith('.jpeg') ||
                      key.endsWith('.png') ||
                      key.endsWith('.webp')),
            )
            .toList()
          ..sort();

    return wallpapers;
  }
}
