import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

void main() {
  runApp(const MaterialApp(
    home: QualityApp(),
    debugShowCheckedModeBanner: false,
  ));
}

class QualityApp extends StatefulWidget {
  const QualityApp({super.key});

  @override
  State<QualityApp> createState() => _QualityAppState();
}

class _QualityAppState extends State<QualityApp> {
  late final WebViewController controller;

  @override
  void initState() {
    super.initState();
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse('https://qualitysweet.vercel.app/'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: WebViewWidget(controller: controller),
      ),
    );
  }
}
