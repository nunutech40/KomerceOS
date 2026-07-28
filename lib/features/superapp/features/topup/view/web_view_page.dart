import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewPage extends StatefulWidget {
  final String url;

  const WebViewPage({Key? key, required this.url}) : super(key: key);

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
            // Update loading bar.
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
    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).popUntil((route) => route.isFirst);
        return false;
      },
      child: Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
            ),
            title: const Text('Pembayaran Top Up'),
          ),
          body: WebViewWidget(
            controller: _controller,
          )
          // WebView(
          //   initialUrl: widget.url,
          //   ..javascriptMode: JavascriptMode.unrestricted,
          //   onWebViewCreated: (WebViewController webViewController) {
          //     _controller = webViewController;
          //   },
          //   navigationDelegate: (NavigationRequest request) {
          //     if (request.url.startsWith('https://www.youtube.com/')) {
          //       return NavigationDecision.prevent;
          //     }
          //     return NavigationDecision.navigate;
          //   },
          // ),
          ),
    );
  }
}
