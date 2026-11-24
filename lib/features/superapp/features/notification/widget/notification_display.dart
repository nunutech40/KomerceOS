import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Title/status split for notification titles such as
/// "Penarikan Saldo Kompay - Diterima" (Figma: status shown as a coloured
/// label next to the title).
class NotificationTitleParts {
  const NotificationTitleParts(this.title, this.status, this.statusColor);

  final String title;
  final String? status;
  final Color? statusColor;

  static const success = Color(0xFF34A853);
  static const danger = Color(0xFFE53935);
  static const progress = Color(0xFFF95E16);

  static const _tones = {
    'disetujui': success,
    'diterima': success,
    'berhasil': success,
    'sukses': success,
    'selesai': success,
    'ditolak': danger,
    'gagal': danger,
    'dibatalkan': danger,
    'diproses': progress,
    'menunggu': progress,
    'diajukan': progress,
  };

  static NotificationTitleParts parse(String? raw) {
    final title = (raw ?? '').trim();
    final match = RegExp(r'^(.*\S)\s+-\s+(\S[^-]*)$').firstMatch(title);
    if (match != null) {
      final status = match.group(2)!.trim();
      final color = _tones[status.toLowerCase()];
      if (color != null) {
        return NotificationTitleParts(
            match.group(1)!.trim(), _capitalize(status), color);
      }
    }
    return NotificationTitleParts(title, null, null);
  }

  static String _capitalize(String value) => value.isEmpty
      ? value
      : value[0].toUpperCase() + value.substring(1).toLowerCase();
}

/// Notification icon following Figma ("Logo Product" exports): product logo per notification
/// type/service. Server `image_path` SVGs draw their artwork through
/// `<pattern>` (not supported by flutter_svg), so only raster URLs from the
/// API are used; everything else falls back to the bell.
class NotificationLeadingImage extends StatelessWidget {
  const NotificationLeadingImage({
    super.key,
    this.notificationType,
    this.service,
    this.imagePath,
    this.logoPath,
  });

  final String? notificationType;
  final String? service;
  final String? imagePath;
  final String? logoPath;

  static const _size = 28.0;
  static const _fallback =
      Icon(Icons.notifications_none, color: Color(0xFFF95E16), size: 24);

  static String? assetFor(String? type, String? service) {
    switch (type) {
      case 'withdrawal':
      case 'verificationKTPRejected':
      case 'verificationKTPApproved':
        return 'assets/images/superapp/home/ic_logo_kompay.svg';
    }
    switch (service?.toLowerCase()) {
      case 'komship':
        return 'assets/images/superapp/home/ic_logo_product_komship.svg';
      case 'kompack':
        return 'assets/images/superapp/home/ic_logo_product_kompack.svg';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final asset = assetFor(notificationType, service);
    if (asset != null) {
      return SvgPicture.asset(asset, width: _size, height: _size);
    }
    final url = [imagePath, logoPath]
        .map((value) => value?.trim() ?? '')
        .firstWhere(
            (value) =>
                value.startsWith('http') &&
                !value.toLowerCase().split('?').first.endsWith('.svg'),
            orElse: () => '');
    if (url.isEmpty) return _fallback;
    return Image.network(url,
        width: _size,
        height: _size,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => _fallback);
  }
}
