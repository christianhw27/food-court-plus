import 'package:flutter/material.dart';
import '../core/theme.dart';

/// Widget gambar yang mendukung URL dari Firebase Storage.
/// Otomatis tampil placeholder jika URL kosong atau gagal load.
class AppNetworkImage extends StatelessWidget {
  final String? imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final Widget? placeholder; // Widget pengganti jika tidak ada foto

  const AppNetworkImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.placeholder,
  });

  @override
  Widget build(BuildContext context) {
    Widget imageWidget;

    if (imageUrl != null && imageUrl!.isNotEmpty) {
      imageWidget = Image.network(
        imageUrl!,
        width: width,
        height: height,
        fit: fit,
        loadingBuilder: (_, child, progress) {
          if (progress == null) return child;
          return _buildLoadingIndicator();
        },
        errorBuilder: (_, __, ___) => placeholder ?? _buildDefaultPlaceholder(),
      );
    } else {
      imageWidget = placeholder ?? _buildDefaultPlaceholder();
    }

    if (borderRadius != null) {
      return ClipRRect(borderRadius: borderRadius!, child: imageWidget);
    }
    return imageWidget;
  }

  Widget _buildLoadingIndicator() {
    return Container(
      width: width,
      height: height,
      color: const Color(0xFFE2E8F0),
      child: const Center(
        child: CircularProgressIndicator(color: AppTheme.primaryColor, strokeWidth: 2),
      ),
    );
  }

  Widget _buildDefaultPlaceholder() {
    return Container(
      width: width,
      height: height,
      color: const Color(0xFFE2E8F0),
      child: const Center(
        child: Icon(Icons.image_not_supported_outlined, color: Colors.grey, size: 32),
      ),
    );
  }
}
