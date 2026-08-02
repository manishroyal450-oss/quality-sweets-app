import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

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
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (NavigationRequest request) async {
            final String url = request.url;

            // WhatsApp, Phone, Mail ya External Links ko bahar WhatsApp App me kholo
            if (url.startsWith('whatsapp://') ||
                url.startsWith('intent://') ||
                url.startsWith('https://wa.me/') ||
                url.startsWith('tel:') ||
                url.startsWith('mailto:')) {
              
              final Uri uri = Uri.parse(url);
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              }
              return NavigationDecision.prevent; // WebView me Error mat aane do
            }

            return NavigationDecision.navigate; // Baaki normal pages WebView me dikhao
          },
        ),
      )
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
