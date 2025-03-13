
import 'package:cateringmid/Reservas/reservamodelo.dart';
import 'package:cateringmid/home/home.dart';
import 'package:cateringmid/home/options.dart';
import 'package:cateringmid/login/loginid.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'login/apinewaccoutn.dart';
import 'package:flutter/services.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Fijar orientación a solo vertical
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp, // Solo orientación vertical hacia arriba
  ]).then((_) async {
    await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (context) => ReservasProvider()),
          ChangeNotifierProvider(create: (context) => CrearcuentaProvider()),
        ],
        child: MyApp(),
      ),
    );
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Catering',
      theme: ThemeData(
        useMaterial3: true,
      ),
      home:  SplashScreen(),
      debugShowCheckedModeBanner: false,
      locale: const Locale('es', ''),
    );
  }
}


class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  double _opacity = 0.0;
  final Logincuenta  login = Logincuenta();

  @override
  void initState() {
    super.initState();
    _startAnimation();
  }

  void _startAnimation() async {
    await Future.delayed(const Duration(milliseconds: 1000));
    if (mounted) {
      setState(() => _opacity = 1.0);
    }
    await Future.delayed(const Duration(seconds: 2));
    _checkUser();
  }

  Future<void> _checkUser() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getString('id');
    if (mounted && (id == null || id.isEmpty)) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) =>  Myoptions()),
      );
    }
    else
    {
      login.login(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF670A0A),
      body: Center(
        child: AnimatedOpacity(
          duration: const Duration(seconds: 2),
          opacity: _opacity,
          child: Image.asset('assets/logo.png', width: 200),
        ),
      ),
    );
  }
}