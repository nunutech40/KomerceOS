import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:webview_flutter/webview_flutter.dart';

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
  _WebViewPageState createState() => _WebViewPageState();
}

class _WebViewPageState extends State<WebViewPage> {
  late WebViewController _controller;

  @override
  void initState() {
    _initializeController();
    super.initState();
  }

  _initializeController() async {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            Center(
              child: Lottie.asset(
                'assets/json/loading-superapp.json',
                width: 80,
                height: 80,
              ),
            );
          },
          onWebResourceError: (WebResourceError error) {},
          onNavigationRequest: (NavigationRequest request) {
            if (request.url.startsWith('https://www.google.com/')) {
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && widget.returnToPaymentMethod) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
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
          )
          ),
    );
  }
}