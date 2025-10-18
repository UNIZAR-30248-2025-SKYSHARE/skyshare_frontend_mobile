import 'dart:math';
import 'package:flutter/material.dart';
import '../../../core/widgets/star_background.dart';
import './widgets/sun_moon_header.dart';
import './widgets/login_form.dart';
import './widgets/register_form.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController();
  double _page = 0.0;
  late final AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      setState(() {
        _page = _pageController.hasClients && _pageController.page != null ? _pageController.page! : 0.0;
      });
    });
    _pulseController = AnimationController(vsync: this, duration: const Duration(seconds: 3))..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _goToRegister() => _pageController.animateToPage(1, duration: const Duration(milliseconds: 700), curve: Curves.easeInOut);
  void _goToLogin() => _pageController.animateToPage(0, duration: const Duration(milliseconds: 700), curve: Curves.easeInOut);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StarBackground(
        child: SafeArea(
          child: LayoutBuilder(builder: (context, constraints) {
            final headerHeight = min(260.0, constraints.maxHeight * 0.32);
            return Column(
              children: [
                SizedBox(
                  height: headerHeight,
                  child: SunMoonHeader(
                    page: _page,
                    pulse: _pulseController,
                  ),
                ),
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 28.0),
                        child: LoginForm(
                          onRegisterTap: _goToRegister,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 28.0),
                        child: RegisterForm(
                          onLoginTap: _goToLogin,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}