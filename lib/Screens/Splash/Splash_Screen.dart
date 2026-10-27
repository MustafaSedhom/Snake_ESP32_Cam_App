import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:gap/gap.dart';
import 'package:lottie/lottie.dart';
import 'package:snake_esp_cam_app/Constants/App_Animation.dart';
import 'package:snake_esp_cam_app/Constants/App_Config.dart';
import 'package:snake_esp_cam_app/Constants/App_Images.dart';
import 'package:snake_esp_cam_app/Screens/Home/Home_Screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(seconds: 5), () {
      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) =>  HomeScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final orientation = MediaQuery.orientationOf(context);
            final shortestSide = MediaQuery.sizeOf(context).shortestSide;
            final isTablet = shortestSide >= 600;
            final isLandscape = orientation == Orientation.landscape;

            final horizontalPadding = isTablet ? 48.0 : 24.0;
            final animationSize = isTablet
                ? (isLandscape ? 240.0 : 340.0)
                : (isLandscape ? 150.0 : 260.0);

            if (isLandscape) {
              return Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: horizontalPadding,
                    vertical: 16,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _title(isTablet),
                            const Gap(20),
                            _poweredBy(isTablet),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: animationSize,
                              height: animationSize,
                              child: _animation(),
                            ),
                            const Gap(12),
                            _loader(isTablet),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            return Center(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: horizontalPadding,
                  vertical: 20,
                ),
                child: Column(
                  children: [
                    const Gap(24),
                    _title(isTablet),
                    const Spacer(),
                    SizedBox(
                      width: animationSize,
                      height: animationSize,
                      child: _animation(),
                    ),
                    const Spacer(),
                    _loader(isTablet),
                    const Spacer(),
                    _poweredBy(isTablet),
                    const Gap(16),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _title(bool isTablet) {
    return Text(
      AppConfig.App_Name,
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: isTablet ? 36 : 28,
        color: Colors.deepPurpleAccent,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _animation() {
    return Lottie.asset(
      AppAnimation.Splash_Animation,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) => const Icon(
        Icons.animation,
        size: 100,
        color: Colors.deepPurpleAccent,
      ),
    );
  }

  Widget _loader(bool isTablet) {
    return LoadingAnimationWidget.fourRotatingDots(
      color: Colors.deepPurpleAccent,
      size: isTablet ? 80 : 65,
    );
  }

  Widget _poweredBy(bool isTablet) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Powered by',
          style: TextStyle(
            fontSize: isTablet ? 22 : 18,
            color: Colors.deepPurpleAccent,
            fontWeight: FontWeight.bold,
          ),
        ),
        const Gap(14),
        CircleAvatar(
          radius: isTablet ? 30 : 25,
          backgroundColor: Colors.transparent,
          foregroundImage: const AssetImage(AppImages.Robotics_Image),
        ),
      ],
    );
  }
}
