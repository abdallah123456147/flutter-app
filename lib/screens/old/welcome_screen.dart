import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  final VoidCallback onAnimationComplete;

  const SplashScreen({Key? key, required this.onAnimationComplete})
    : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _moveController;
  late AnimationController _finalFadeController;
  late AnimationController _img3Controller;
  late AnimationController _img4Controller;
  late AnimationController _img5Controller;
  late AnimationController _img1FadeInController;

  late AnimationController _progressController;
  late Animation<double> _progressAnimation;

  late Animation<double> _fadeAnimation;
  late Animation<Offset> _moveAnimation;
  late Animation<double> _finalFadeAnimation;
  late Animation<double> _img3FadeAnimation;
  late Animation<double> _img4FadeAnimation;
  late Animation<double> _img5FadeAnimation;
  late Animation<double> _img1FadeInAnimation;

  int _currentPhase = 0;
  final int _totalPhases = 10;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _moveController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _finalFadeController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _img3Controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _img4Controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _img5Controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _img1FadeInController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _progressController = AnimationController(
      duration: const Duration(milliseconds: 20000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeOut));

    _moveAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0, -2.0),
    ).animate(
      CurvedAnimation(parent: _moveController, curve: Curves.easeInOut),
    );

    _finalFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _finalFadeController, curve: Curves.easeIn),
    );

    _img3FadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _img3Controller, curve: Curves.easeInOut),
    );

    _img4FadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _img4Controller, curve: Curves.easeInOut),
    );

    _img5FadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _img5Controller, curve: Curves.easeInOut),
    );

    _img1FadeInAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _img1FadeInController, curve: Curves.easeIn),
    );

    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.linear),
    );

    _startAnimation();
  }

  void _updateProgress(int phase) {
    setState(() {
      _currentPhase = phase;
    });
  }

  Future<void> _startAnimation() async {
    _progressController.forward();

    _updateProgress(1);
    await Future.delayed(const Duration(milliseconds: 500));

    // Fade in img1
    _updateProgress(2);
    await _img1FadeInController.forward();

    // Wait a bit while img1 is visible
    await Future.delayed(const Duration(milliseconds: 1000));

    // Fade out img1
    _updateProgress(3);
    await _fadeController.forward();

    // Move logo to top
    _updateProgress(4);
    await _moveController.forward();

    // Fade in img2
    _updateProgress(5);
    await _finalFadeController.forward();

    // Continue rest of animations
    _updateProgress(6);
    await Future.delayed(const Duration(milliseconds: 800));
    await Future.wait([_finalFadeController.reverse()]);
    await _img3Controller.forward();

    _updateProgress(7);
    await Future.delayed(const Duration(milliseconds: 1000));
    await _img3Controller.reverse();
    await _img4Controller.forward();

    _updateProgress(8);
    await Future.delayed(const Duration(milliseconds: 1000));
    await _img4Controller.reverse();
    await _img5Controller.forward();

    _updateProgress(9);
    await Future.delayed(const Duration(milliseconds: 1000));

    widget.onAnimationComplete();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _moveController.dispose();
    _finalFadeController.dispose();
    _img3Controller.dispose();
    _img4Controller.dispose();
    _img5Controller.dispose();
    _img1FadeInController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final padding = mediaQuery.padding;

    return Scaffold(
      backgroundColor: Colors.white,
      body: AnimatedBuilder(
        animation: Listenable.merge([
          _fadeController,
          _moveController,
          _finalFadeController,
          _img3Controller,
          _img4Controller,
          _img5Controller,
          _img1FadeInController,
          _progressController,
        ]),
        builder: (context, child) {
          return Container(
            color: Colors.white,
            child: Column(
              children: [
                Container(color: Colors.white, height: padding.top),
                Expanded(
                  child: Stack(
                    children: [
                      Container(color: Colors.white),

                      // img2–img5 sequence (unchanged)
                      if (_finalFadeController.value > 0)
                        Center(
                          child: Opacity(
                            opacity: _finalFadeAnimation.value,
                            child: Image.asset('images/splash/img2.png'),
                          ),
                        ),
                      AnimatedOpacity(
                        opacity: _img3FadeAnimation.value,
                        duration: Duration.zero,
                        child: Image.asset(
                          'images/splash/img3.png',
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                        ),
                      ),
                      AnimatedOpacity(
                        opacity: _img4FadeAnimation.value,
                        duration: Duration.zero,
                        child: Image.asset(
                          'images/splash/img4.png',
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                        ),
                      ),
                      AnimatedOpacity(
                        opacity: _img5FadeAnimation.value,
                        duration: Duration.zero,
                        child: Image.asset(
                          'images/splash/img5.png',
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                        ),
                      ),

                      // img1: fade in → wait → fade out (no rotation)
                      if (_img1FadeInController.value > 0 &&
                          _fadeController.value < 1.0)
                        Center(
                          child: Opacity(
                            opacity:
                                _img1FadeInAnimation.value *
                                _fadeAnimation.value,
                            child: Image.asset('images/splash/img1.png'),
                          ),
                        ),

                      // Logo: stays then moves up
                      Center(
                        child: SlideTransition(
                          position: _moveAnimation,
                          child: Image.asset(
                            'images/splash/logo.webp',
                            width: 150,
                            height: 150,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 10,
                  ),
                  child: Column(
                    children: [
                      LinearProgressIndicator(
                        value: _progressAnimation.value,
                        backgroundColor: Colors.grey[300],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          const Color(0xFF7FB636),
                        ),
                        minHeight: 6,
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'veuillez patienter',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF7FB636),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Container(color: Colors.white, height: padding.bottom),
              ],
            ),
          );
        },
      ),
    );
  }
}
