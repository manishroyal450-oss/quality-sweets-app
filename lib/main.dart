import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:image_picker/image_picker.dart';
import 'package:share_plus/share_plus.dart';

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
  bool isOffline = false;
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;
  final String targetUrl = 'https://qualitysweet.vercel.app/';
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();

    // 1. Request GPS Permission on launch
    _requestLocationPermission();

    // 2. Controller Setup
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onWebResourceError: (WebResourceError error) {
            if (error.isForMainFrame ?? true) {
              setState(() {
                isOffline = true;
              });
              controller.loadHtmlString(
                '<html><body style="background-color: #ffffff;"></body></html>',
              );
            }
          },
          onPageFinished: (String url) {
            if (url.startsWith('http')) {
              setState(() {
                isOffline = false;
              });
            }
          },
          onNavigationRequest: (NavigationRequest request) async {
            final String url = request.url;

            // WhatsApp link handle karein: Details read karein + Gallery kholein
            if (url.startsWith('whatsapp://') || url.startsWith('https://wa.me/')) {
              final Uri uri = Uri.parse(url);
              
              // Website se aaya hua order details text nikalein
              String messageText = uri.queryParameters['text'] ?? "New Order Details & Payment Proof";

              // Gallery kholein aur Screenshot pick karwayein
              final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

              if (image != null) {
                // Image + Order Details dono ek sath WhatsApp par share karein
                await Share.shareXFiles(
                  [XFile(image.path)],
                  text: messageText,
                );
              } else {
                // Agar user screenshot select na kare to direct WhatsApp link open kar dein
                try {
                  await launchUrl(
                    uri,
                    mode: LaunchMode.externalNonBrowserApplication,
                  );
                } catch (_) {}
              }

              return NavigationDecision.prevent;
            }

            // Tel, Mailto aur baki Intent Handlers
            if (url.startsWith('intent://') ||
                url.startsWith('tel:') ||
                url.startsWith('mailto:')) {
              
              final Uri uri = Uri.parse(url);

              try {
                await launchUrl(
                  uri,
                  mode: LaunchMode.externalNonBrowserApplication,
                );
              } catch (e) {
                try {
                  await launchUrl(
                    uri,
                    mode: LaunchMode.externalApplication,
                  );
                } catch (_) {}
              }

              return NavigationDecision.prevent;
            }

            return NavigationDecision.navigate;
          },
        ),
      );

    _checkInitialConnectivity();

    _connectivitySubscription = Connectivity()
        .onConnectivityChanged
        .listen((List<ConnectivityResult> results) {
      final bool hasNoConnection = results.contains(ConnectivityResult.none);

      if (hasNoConnection) {
        setState(() {
          isOffline = true;
        });
      } else {
        if (isOffline) {
          setState(() {
            isOffline = false;
          });
          controller.loadRequest(Uri.parse(targetUrl));
        }
      }
    });
  }

  Future<void> _requestLocationPermission() async {
    var status = await Permission.location.status;
    if (!status.isGranted) {
      await Permission.location.request();
    }
  }

  Future<void> _checkInitialConnectivity() async {
    final results = await Connectivity().checkConnectivity();
    if (results.contains(ConnectivityResult.none)) {
      setState(() {
        isOffline = true;
      });
    } else {
      controller.loadRequest(Uri.parse(targetUrl));
    }
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            WebViewWidget(controller: controller),
            if (isOffline)
              Positioned.fill(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                  child: Container(
                    color: Colors.black.withOpacity(0.40),
                    child: Center(
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 28.0),
                        padding: const EdgeInsets.all(24.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20.0),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 15,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: const BoxDecoration(
                                color: Color(0xFFFFF8E7),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.wifi_off_rounded,
                                size: 40,
                                color: Color(0xFFD97706),
                              ),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'No Internet Connection',
                              style: TextStyle(
                                fontSize: 19,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Please check your network settings',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.black54,
                              ),
                            ),
                            const SizedBox(height: 20),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF3F4F6),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    height: 16,
                                    width: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.black45,
                                    ),
                                  ),
                                  SizedBox(width: 10),
                                  Text(
                                    'Reconnecting...',
                                    style: TextStyle(
                                      color: Colors.black54,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
