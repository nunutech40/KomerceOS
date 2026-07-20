import 'dart:convert';
import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_svg/flutter_svg.dart';

class DsAppImage extends StatelessWidget {
  final String source;
  final double width;
  final double height;
  final BoxFit fit;
  final Widget? placeholder;
  final Widget? errorWidget;
  final BaseCacheManager? cacheManager;

  const DsAppImage({
    super.key,
    required this.source,
    this.width = 32,
    this.height = 32,
    this.fit = BoxFit.contain,
    this.placeholder,
    this.errorWidget,
    this.cacheManager,
  });

  bool get _isNetwork =>
      source.startsWith('http://') || source.startsWith('https://');

  bool get _isSvg {
    final path =
        Uri.tryParse(source)?.path.toLowerCase() ?? source.toLowerCase();
    return path.endsWith('.svg');
  }

  @override
  Widget build(BuildContext context) {
    if (_isSvg) {
      return _SvgImage(
        source: source,
        isNetwork: _isNetwork,
        width: width,
        height: height,
        fit: fit,
        placeholder: placeholder,
        errorWidget: errorWidget,
        cacheManager: cacheManager,
      );
    }

    if (_isNetwork) {
      return CachedNetworkImage(
        imageUrl: source,
        width: width,
        height: height,
        fit: fit,
        cacheManager: cacheManager,
        placeholder: (_, __) =>
            placeholder ??
            SizedBox(
              width: width,
              height: height,
              child: const Center(
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
        errorWidget: (_, __, ___) =>
            errorWidget ??
            Icon(Icons.broken_image, size: width),
      );
    }

    return Image.asset(
      source,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (_, __, ___) =>
          errorWidget ??
          Icon(Icons.broken_image, size: width),
    );
  }
}

class _SvgImage extends StatefulWidget {
  final String source;
  final bool isNetwork;
  final double width;
  final double height;
  final BoxFit fit;
  final Widget? placeholder;
  final Widget? errorWidget;
  final BaseCacheManager? cacheManager;

  const _SvgImage({
    required this.source,
    required this.isNetwork,
    required this.width,
    required this.height,
    required this.fit,
    this.placeholder,
    this.errorWidget,
    this.cacheManager,
  });

  @override
  State<_SvgImage> createState() => _SvgImageState();
}

class _SvgImageState extends State<_SvgImage> {
  static final _base64Regex = RegExp(
    r'data:image\/(?:png|jpeg|jpg|gif|webp);base64,([A-Za-z0-9+/=\s]+)',
    caseSensitive: false,
  );
  static final _whitespaceRegex = RegExp(r'\s+');

  Widget? _child;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(covariant _SvgImage oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.source != widget.source) {
      _load();
    }
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
    });

    try {
      final String svg;
      if (widget.isNetwork) {
        final cacheManager = widget.cacheManager ?? DefaultCacheManager();
        final file = await cacheManager.getSingleFile(widget.source);
        svg = await file.readAsString();
      } else {
        svg = await rootBundle.loadString(widget.source);
      }

      final match = _base64Regex.firstMatch(svg);

      if (match != null) {
        final Uint8List bytes = base64Decode(
          match.group(1)!.replaceAll(_whitespaceRegex, ''),
        );

        if (!mounted) return;

        setState(() {
          _child = Image.memory(
            bytes,
            width: widget.width,
            height: widget.height,
            fit: widget.fit,
            errorBuilder: (_, __, ___) =>
                widget.errorWidget ??
                Icon(Icons.broken_image, size: widget.width),
          );

          _loading = false;
        });

        return;
      }

      if (!mounted) return;

      setState(() {
        _child = SvgPicture.string(
          svg,
          width: widget.width,
          height: widget.height,
          fit: widget.fit,
          placeholderBuilder: (_) =>
              widget.placeholder ??
              Icon(Icons.image, size: widget.width),
        );

        _loading = false;
      });
    } catch (e) {
      debugPrint('SVG Error : ${widget.source}');
      debugPrint(e.toString());

      if (!mounted) return;

      setState(() {
        _child =
            widget.errorWidget ??
            Icon(Icons.broken_image, size: widget.width);

        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return widget.placeholder ??
          SizedBox(
            width: widget.width,
            height: widget.height,
            child: const Center(
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
    }

    return _child ??
        widget.errorWidget ??
        Icon(Icons.broken_image, size: widget.width);
  }
}