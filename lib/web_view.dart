import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:screen_protector/screen_protector.dart';
import 'dart:io';

class FlexiQuizWebView extends StatefulWidget {
  final String url;

  const FlexiQuizWebView({super.key, required this.url});

  @override
  State<FlexiQuizWebView> createState() => _FlexiQuizWebViewState();
}

class _FlexiQuizWebViewState extends State<FlexiQuizWebView>
    with WidgetsBindingObserver {
  late final WebViewController controller;
  bool _showSecurityOverlay = false;

  Future<void> _enableScreenProtection() async {
    try {
      // Prevent screenshots on Android
      if (Platform.isAndroid) {
        await ScreenProtector.preventScreenshotOn();
      }

      // Protect data leakage (blurs app in app switcher on iOS/Android)
      await ScreenProtector.protectDataLeakageOn();

      // iOS: Enable screenshot detection
      if (Platform.isIOS) {
        print("screenshot in ios");
        // screenshotCallback.addListener(() {
        //   _showScreenshotWarning();
      }
    } catch (e) {
      print('Error enabling screen protection: $e');
    }
  }

  void _onScreenshotDetected() {
    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Screenshot Detected'),
        content: const Text('Screenshots are not allowed on this screen.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);
    _initializeWebView();
    _enableScreenProtection();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    setState(() {
      // Show black overlay on iOS when app is inactive (screenshot/app switcher)
      _showSecurityOverlay = state != AppLifecycleState.resumed;
    });
  }

  Future<void> _initializeWebView() async {
    // Enable screenshot protection
    if (Platform.isAndroid) {
      // await FlutterWindowManager.addFlags(FlutterWindowManager.FLAG_SECURE);
    }
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse(widget.url));
  }

  // Future<void> _enableScreenProtection() async {
  //   try {
  //     // Prevent screenshots on Android
  //     if (Platform.isAndroid) {
  //       await ScreenProtector.preventScreenshotOn();
  //     }
  //
  //     // Protect data leakage (blurs app in app switcher on iOS/Android)
  //     await ScreenProtector.protectDataLeakageOn();
  //
  //     // iOS: Enable screenshot detection
  //     if (Platform.isIOS) {
  //       ScreenProtector.addScreenshotObserver(() {
  //         _onScreenshotDetected();
  //       });
  //     }
  //   } catch (e) {
  //     print('Error enabling screen protection: $e');
  //   }
  // }

  // void _onScreenshotDetected() {
  //   if (!mounted) return;
  //
  //   showDialog(
  //     context: context,
  //     builder: (context) => AlertDialog(
  //       title: const Text('Screenshot Detected'),
  //       content: const Text('Screenshots are not allowed on this screen.'),
  //       actions: [
  //         TextButton(
  //           onPressed: () => Navigator.pop(context),
  //           child: const Text('OK'),
  //         ),
  //       ],
  //     ),
  //   );
  // }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(
          child: Text(
            'Preparing Servants',
            style: TextStyle(color: Colors.white),
          ),
        ),

        backgroundColor: Colors.deepPurple,
        elevation: 0,
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: controller),
          if (_showSecurityOverlay)
            Container(
              color: Colors.black,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.security, size: 100, color: Colors.white),
                    const SizedBox(height: 20),
                    const Text(
                      'Secure Content Protected',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      Platform.isAndroid
                          ? 'Screenshots are blocked'
                          : 'Content hidden during screenshot',
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
