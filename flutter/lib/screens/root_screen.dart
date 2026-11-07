import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import '../theme.dart';
import 'list_screen.dart';
import 'login_screen.dart';

// Выбирает экран: загрузка, вход или список
class RootScreen extends StatefulWidget {
  const RootScreen({super.key});

  @override
  State<RootScreen> createState() => _RootScreenState();
}

class _RootScreenState extends State<RootScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<AppState>().init();
    });
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final Widget child;
    if (s.booting) {
      child = const _Splash(key: ValueKey('splash'));
    } else if (!s.loggedIn) {
      child = const LoginScreen(key: ValueKey('login'));
    } else {
      child = const ListScreen(key: ValueKey('list'));
    }
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 450),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      transitionBuilder: (c, animation) => FadeTransition(
        opacity: animation,
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.98, end: 1).animate(animation),
          child: c,
        ),
      ),
      child: child,
    );
  }
}

class _Splash extends StatelessWidget {
  const _Splash({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator(color: Brand.amber)),
    );
  }
}
