import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:komtim_partner/DI/injection.dart';
import 'package:komtim_partner/core/data/repositories/superapp_profile_repository_impl.dart';

class WebViewPage extends StatefulWidget {
  final String url;
  final bool returnToPaymentMethod;

  /// Callback dipanggil ketika user selesai dari webview pada flow shopping.
  /// Diisi hanya dari TopupPage yang dibuka via DetailShoppingPage.
  final VoidCallback? onTopupSuccess;

  const WebViewPage({
    Key? key,
    required this.url,
    this.returnToPaymentMethod = false,
    this.onTopupSuccess,
  }) : super(key: key);

  @override
  State<WebViewPage> createState() => _WebViewPageState();
}

class _WebViewPageState extends State<WebViewPage> {
  static const _standardWebSchemes = <String>{
    'http',
    'https',
    'about',
    'data',
    'blob',
    'javascript',
  };

  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _initializeController();
  }

  void _initializeController() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..addJavaScriptChannel(
        'FlutterBackChannel',
        onMessageReceived: (JavaScriptMessage message) {
          if (message.message == 'back_to_komerce') {
            _navigateBackToHome();
          }
        },
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {},
          onPageFinished: (String url) {
            _injectBackToKomerceDetector();
          },
          onUrlChange: (UrlChange change) {
            _injectBackToKomerceDetector();
          },
          onWebResourceError: (WebResourceError error) {},
          onNavigationRequest: (NavigationRequest request) {
            if (request.url.startsWith('https://www.google.com/')) {
              return NavigationDecision.prevent;
            }
            return _handleNavigationRequest(request.url);
          },
        ),
      );
    _configureAndLoad();
  }

  void _navigateBackToHome() {
    if (!mounted) return;
    _triggerProfileRefresh();
    if (widget.returnToPaymentMethod) {
      Navigator.of(context).pop();
    } else if (widget.onTopupSuccess != null) {
      widget.onTopupSuccess!();
    } else {
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }

  void _injectBackToKomerceDetector() {
    const js = '''
      (function() {
        if (window.__backToKomerceAttached) return;
        window.__backToKomerceAttached = true;

        function isBackToKomerce(el) {
          if (!el) return false;
          var text = (el.innerText || el.textContent || '').trim().toLowerCase();
          return text.includes('back to komerce') || text.includes('kembali ke komerce');
        }

        document.addEventListener('click', function(e) {
          var target = e.target;
          var btn = (target && target.closest) ? target.closest('button, lib-button, .download-button-mobile, a') : null;
          if (isBackToKomerce(btn) || isBackToKomerce(target)) {
            if (window.FlutterBackChannel) {
              window.FlutterBackChannel.postMessage('back_to_komerce');
            }
          }
        }, true);
      })();
    ''';
    _controller.runJavaScript(js).catchError((_) {});
  }

  Future<void> _configureAndLoad() async {
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      try {
        final currentUserAgent = await _controller.getUserAgent() ?? '';
        final chromeVersion =
            RegExp(r'Chrome/[\d.]+').firstMatch(currentUserAgent)?.group(0) ??
                'Chrome/120.0.0.0';
        await _controller.setUserAgent(
          'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) $chromeVersion Safari/537.36',
        );
      } catch (_) {}
    }

    if (!mounted) return;
    await _controller.loadRequest(Uri.parse(widget.url));
  }

  NavigationDecision _handleNavigationRequest(String url) {
    final scheme = _extractScheme(url);
    if (scheme == null || _standardWebSchemes.contains(scheme)) {
      return NavigationDecision.navigate;
    }

    if (scheme == 'intent') {
      _loadIntentWebFallbackIfAny(url);
    }
    return NavigationDecision.prevent;
  }

  String? _extractScheme(String url) {
    final uri = Uri.tryParse(url);
    if (uri != null && uri.scheme.isNotEmpty) {
      return uri.scheme.toLowerCase();
    }
    return RegExp(r'^([a-zA-Z][a-zA-Z0-9+.-]*):')
        .firstMatch(url)
        ?.group(1)
        ?.toLowerCase();
  }

  Future<void> _loadIntentWebFallbackIfAny(String rawUrl) async {
    final intentMarkerIndex = rawUrl.indexOf('#Intent;');
    if (intentMarkerIndex < 0) return;

    final rawTarget = rawUrl.substring(0, intentMarkerIndex);
    final targetBody = rawTarget.replaceFirst(
      RegExp(r'^intent:(?://)?', caseSensitive: false),
      '',
    );

    String? intentScheme;
    String? fallbackUrl;
    final paramsSection =
        rawUrl.substring(intentMarkerIndex + '#Intent;'.length);
    for (final token in paramsSection.split(';')) {
      if (token == 'end' || token.isEmpty) continue;
      final eqIndex = token.indexOf('=');
      if (eqIndex <= 0) continue;
      final key = token.substring(0, eqIndex);
      final value = token.substring(eqIndex + 1);

      if (key == 'scheme' && value.isNotEmpty) {
        intentScheme = value.toLowerCase();
      } else if (key == 'S.browser_fallback_url' && value.isNotEmpty) {
        try {
          fallbackUrl = Uri.decodeComponent(value);
        } catch (_) {
          fallbackUrl = value;
        }
      }
    }

    final fallbackUri =
        fallbackUrl != null ? Uri.tryParse(fallbackUrl) : null;
    if (fallbackUri != null &&
        (fallbackUri.scheme == 'http' || fallbackUri.scheme == 'https')) {
      if (mounted) {
        await _controller.loadRequest(fallbackUri);
      }
      return;
    }

    if (intentScheme == 'http' || intentScheme == 'https') {
      final webUri = Uri.tryParse('$intentScheme://$targetBody');
      if (webUri != null && mounted) {
        await _controller.loadRequest(webUri);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          _triggerProfileRefresh();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              _triggerProfileRefresh();
              if (widget.returnToPaymentMethod) {
                Navigator.of(context).pop();
              } else if (widget.onTopupSuccess != null) {
                // Flow dari shopping: panggil callback agar kembali ke
                // detail shopping page setelah user selesai di webview.
                widget.onTopupSuccess!();
              } else {
                Navigator.of(context).popUntil((route) => route.isFirst);
              }
            },
          ),
          title: const Text('Pembayaran Top Up'),
        ),
        body: WebViewWidget(
          controller: _controller,
        ),
      ),
    );
  }

  void _triggerProfileRefresh() {
    try {
      if (locator.isRegistered<SuperappProfileRepositoryImpl>()) {
        locator<SuperappProfileRepositoryImpl>().notifyProfileRefresh();
      }
    } catch (e) {
      debugPrint('[WebViewPage] Error notifying profile refresh: $e');
    }
  }
}