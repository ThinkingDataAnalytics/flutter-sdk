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
    ..loadFlutterAsset('html/index.html')
    ..setNavigationDelegate(NavigationDelegate(
      onNavigationRequest: (request) {
        print(request.url);
        
        return NavigationDecision.navigate;
      },
    ));
    controller.addJavaScriptChannel("ThinkingData_APP_Flutter_Bridge", onMessageReceived: (JavaScriptMessage message){
      print("${message.toString()},  ${message.hashCode}, message: ${message.message}") ;
      TDAnalytics.h5ClickHandler(message.message);
    });

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
      body: Column(
        children: [
          Expanded(
              child: WebViewWidget(controller: controller)
            )
          ],
      ),
    );
  }
}
