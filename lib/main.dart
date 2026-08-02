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

            // Agar WhatsApp, Call, Mail ya External Links hain
            if (url.startsWith('whatsapp://') ||
                url.startsWith('intent://') ||
                url.startsWith('https://wa.me/') ||
                url.startsWith('tel:') ||
                url.startsWith('mailto:')) {
              
              final Uri uri = Uri.parse(url);

              try {
                // Force external app without manifest query requirement
                await launchUrl(
                  uri,
                  mode: LaunchMode.externalNonBrowserApplication,
                );
              } catch (e) {
                // Fallback launch attempt
                try {
                  await launchUrl(
                    uri,
                    mode: LaunchMode.externalApplication,
                  );
                } catch (_) {}
              }

              return NavigationDecision.prevent; // WebView me error mat aane do
            }

            return NavigationDecision.navigate;
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
