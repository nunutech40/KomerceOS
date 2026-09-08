import 'package:flutter/material.dart';
import 'package:komtim_partner/common/global/widgets/confirmation_dialog_exit_xendit.dart';
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
            const Center(
              child: CircularProgressIndicator(),
            );
          },
          onWebResourceError: (WebResourceError error) {},
          onNavigationRequest: (NavigationRequest request) {
            if (request.url.startsWith('https://www.youtube.com/')) {
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
    Future<bool> exitConfirm() async {
      return await showDialog(
              context: context,
              builder: (BuildContext context) => WillPopScope(
                  onWillPop: () async => true,
                  child: const ConfirmationDilaogExitXendit())) ??
          false;
    }

    return WillPopScope(
      onWillPop: () async {
        return exitConfirm();
      },
      child: Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                exitConfirm();
                // Navigator.of(context).popUntil((route) => route.isFirst);
              },
            ),
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
