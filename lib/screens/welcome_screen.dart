import 'package:flutter/material.dart';
import 'package:bennasafi/screens/firstpage.dart';
import 'package:another_flutter_splash_screen/another_flutter_splash_screen.dart';

class SplashScreen extends StatefulWidget {
  final VoidCallback onAnimationComplete;

  const SplashScreen({Key? key, required this.onAnimationComplete})
    : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: FlutterSplashScreen.gif(
          gifPath: 'images/loading.gif',
          backgroundColor: Colors.white,

          gifWidth: double.infinity,
          gifHeight: double.infinity,
          nextScreen: const Firstpage(),
          duration: const Duration(milliseconds: 11000),
          onInit: () async {
            debugPrint("onInit");
          },
          onEnd: () async {
            debugPrint("onEnd 1");
            // widget.onAnimationComplete();
          },
        ),
      ),
    );
  }
}
