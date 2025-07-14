import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simple/Reusable/color.dart';
import 'package:simple/Reusable/image.dart';
import 'package:simple/UI/Authentication/login_screen.dart';
import 'package:simple/UI/DashBoard/custom_tabbar.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation _animation;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  dynamic token;

  getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      token = prefs.getString("token");
    });
    debugPrint("SplashToken:$token");
  }

  callApis() async {
    await getToken();
  }

  void onTimerFinished() {
    if (mounted) {
      token == null
          ? Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const LoginScreen(),
              ))
          : Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                  builder: (context) => const DashBoardScreen(
                        selectTab: 0,
                      )),
              (Route<dynamic> route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
        backgroundColor: whiteColor,
        body: Stack(
          children: [
            Container(
              height: size.height,
              width: size.width,
              decoration: const BoxDecoration(
                color: whiteColor,
              ),
            ),
            Center(
                child: AnimatedBuilder(
              animation: _controller,
              child: Container(
                width: 10,
                height: 10,
                color: Colors.transparent,
                child: Center(
                  child: Image.asset(
                    Images.logoWithName,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              builder: (BuildContext context, Widget? child) {
                return Transform.scale(
                  scale: _animation.value,
                  child: Transform.rotate(
                    origin: Offset.zero,
                    angle: _controller.value * 8,
                    child: child,
                  ),
                );
              },
            )),
          ],
        ));
  }

  @override
  void initState() {
    callApis();
    super.initState();

    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 2000));
    _animation = Tween<double>(
      begin: 500,
      end: 0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.ease,
      ),
    );
    _controller.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Timer(const Duration(seconds: 2), () => onTimerFinished());
    });
  }
}
