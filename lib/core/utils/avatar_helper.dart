import 'package:flutter/material.dart';

/// Utility class for handling avatar assets
class AvatarHelper {
  /// Converts an avatar URL/path to the correct ImageProvider
  /// Handles:
  /// - HTTP URLs (returns NetworkImage)
  /// - Old paths without 'assets/' prefix (fixes them)
  /// - Correct asset paths (uses them as-is)
  static ImageProvider getAvatarImage(String url) {
    // If it's a network URL, use NetworkImage
    if (url.startsWith('http')) {
      return NetworkImage(url);
    }
    
    // Fix old avatar paths that don't have 'assets/' prefix
    String assetPath = url;
    if (url.startsWith('images/avatars/')) {
      // Old format: images/avatars/cat1.jpg -> assets/images/avatars/cat1.jpg
      assetPath = 'assets/$url';
    } else if (!url.startsWith('assets/')) {
      // Unknown format, assume it's just the filename
      assetPath = 'assets/images/avatars/${url.split('/').last}';
    }
    
    return AssetImage(assetPath);
  }
  
  /// Safely gets an ImageProvider or returns null if url is null/empty
  static ImageProvider? getAvatarImageOrNull(String? url) {
    if (url == null || url.isEmpty) return null;
    return getAvatarImage(url);
  }
}
