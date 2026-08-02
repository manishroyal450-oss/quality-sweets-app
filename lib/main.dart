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

            // WhatsApp, Calls, Mails aur UPI Links ko external apps me launch karo
            if (url.startsWith('whatsapp://') ||
                url.startsWith('intent://') ||
                url.startsWith('https://wa.me/') ||
                url.startsWith('tel:') ||
                url.startsWith('mailto:')) {
              
              final Uri uri = Uri.parse(url);

              try {
                await launchUrl(
                  uri,
                  mode: LaunchMode.externalApplication,
                );
              } catch (e) {
                debugPrint('Could not launch $url: $e');
              }

              return NavigationDecision.prevent; // WebView me blank error mat hone do
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
