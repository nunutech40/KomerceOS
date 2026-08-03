import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:komtim_partner/common/enum_status.dart';
import 'package:komtim_partner/common/styles.dart';
import 'package:komtim_partner/common/time_convert.dart';
import 'package:komtim_partner/features/superapp/features/team/feed/bloc/feed_bloc.dart';
import 'package:webview_flutter/webview_flutter.dart';

class FeedDetailPages extends StatefulWidget {
  final int id;
  const FeedDetailPages({super.key, required this.id});

  @override
  State<FeedDetailPages> createState() => _FeedDetailPagesState();
}

class _FeedDetailPagesState extends State<FeedDetailPages> {
  var _bloc;
  late WebViewController _controller;
  double _webViewHeight = 1; // Default height (minimal)

  @override
  void initState() {
    _initializeController();
    _initializeBloc();
    loadData();
    super.initState();
  }

  _initializeController() async {
    _controller = WebViewController()
      ..setJavaScriptMode(
        JavaScriptMode.unrestricted,
      )
      ..addJavaScriptChannel(
        'ResizeChannel',
        onMessageReceived: (JavaScriptMessage message) {
          final newHeight = double.tryParse(message.message);
          if (newHeight != null && newHeight != _webViewHeight) {
            setState(() {
              _webViewHeight = newHeight;
            });
          }
        },
      )
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
      ..enableZoom(false);
  }

  void _initializeBloc() {
    _bloc = context.read<FeedBloc>();
  }

  Future<void> loadData() async {
    await _bloc.add(GetFeedDetailEvent(id: widget.id));
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<FeedBloc, FeedState>(
      listener: (context, state) {
        if (state.status == RequestStatus.success) {
          if (state.status == RequestStatus.success) {
            final htmlContent = '''
          <!DOCTYPE html>
          <html>
          <head>
            <meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1, minimum-scale=1, user-scalable=no">
            <style>
              body {
                margin: 0;
                padding: 0;
                overflow: hidden;
                color: #626262;
                font-weight: normal;
                font-size:14px
              }
              ::-webkit-scrollbar {
                display: none;
              }
            </style>
          </head>
          <body>
            ${state.feedDetail?.body ?? ""}
            <script>
              function resize() {
                ResizeChannel.postMessage(document.body.scrollHeight.toString());
              }
              window.onload = resize;
              window.onresize = resize;
            </script>
          </body>
          </html>
          ''';
            _controller.loadHtmlString(htmlContent);
          }
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Berita Terkini'),
          ),
          body: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(
                  height: 251,
                  width: MediaQuery.of(context).size.width,
                  child: CachedNetworkImage(
                    fit: BoxFit.cover,
                    imageUrl: state.feedDetail?.image ?? "",
                    placeholder: (context, url) => const Center(
                      child: SizedBox(
                          height: 20,
                          width: 20,
                          child:
                              CircularProgressIndicator(color: primaryColor)),
                    ),
                    errorWidget: (context, url, error) => Image.asset(
                      "assets/images/default_banner_feed.png",
                      height: 251,
                      width: MediaQuery.of(context).size.width,
                      fit: BoxFit.cover, // Sesuaikan agar gambar memenuhi area
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      Text(
                        state.feedDetail?.title ?? "",
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                        style: AppTypography.regular20
                            .copyWith(color: blackColors33),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Text(
                            dateConvertWithT(state.feedDetail?.publishedAt),
                            style: AppTypography.regular10
                                .copyWith(color: darkGray),
                          ),
                          const SizedBox(
                            width: 8,
                          ),
                          Text(
                            "|",
                            style: AppTypography.regular10
                                .copyWith(color: darkGray),
                          ),
                          const SizedBox(
                            width: 8,
                          ),
                          Text(
                            state.feedDetail?.trainingCenterName ?? "",
                            style: AppTypography.regular10
                                .copyWith(color: darkGray),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: _webViewHeight,
                        child: WebViewWidget(controller: _controller),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }
}
