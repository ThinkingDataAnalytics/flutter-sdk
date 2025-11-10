import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:thinking_analytics/td_analytics.dart';

class MyWebView extends StatefulWidget {

  @override
  State<MyWebView> createState() => _MyWebViewState();
}

class _MyWebViewState extends State<MyWebView> {
  late final WebViewController controller;
  double height = 0;
  @override
  void initState() {
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            // 可以显示加载进度
            print("加载进度: $progress%");
          },
          onPageStarted: (String url) {
            print("页面开始加载: $url");
          },
          onPageFinished: (String url) {
            print("页面加载完成: $url");
          },
          onWebResourceError: (WebResourceError error) {
            print("Web资源错误: ${error.description}");
          },
          onNavigationRequest: (NavigationRequest request) {
            print("导航请求: ${request.url}");
            return NavigationDecision.navigate;
          },
        ),
      )
      ..addJavaScriptChannel(
        "ConsoleLog",
        onMessageReceived: (JavaScriptMessage message) {
          print("JS Console: ${message.message}");
        },
      )
      ..loadFlutterAsset('html/home.html');
    // controller.addJavaScriptChannel("ThinkingData_APP_Flutter_Bridge", onMessageReceived: (JavaScriptMessage message){
    //   print("${message.toString()},  ${message.hashCode}, message: ${message.message}") ;
    //   TDAnalytics.h5ClickHandler(message.message);
    // });
    TDAnalytics.setJsBridge(controller);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // return Column(
    //   children: [Expanded(child: WebViewWidget(controller: controller))],
    // );
    return Scaffold(
      appBar: AppBar(
        title: const Text('WebView'),
      ),
      body: Container(
        // 添加明确的约束
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: WebViewWidget(controller: controller),
      ),
    );
  }
}
