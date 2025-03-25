import 'package:cateringmid/Reservas/reservamodelo.dart';
import 'package:cateringmid/home/home.dart';
import 'package:cateringmid/home/options.dart';
import 'package:cateringmid/login/loginid.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'login/apinewaccoutn.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

Future<void> backgroundHandler(RemoteMessage message) async {
  // Este es el método que se ejecuta cuando la aplicación está en segundo plano o cerrada.
  print("Mensaje en segundo plano: ${message.notification?.title}");
  showNotification(message);
}

void showNotification(RemoteMessage message) {
  final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  const AndroidNotificationDetails androidPlatformChannelSpecifics =
      AndroidNotificationDetails(
    'your_channel_id',
    'your_channel_name',
    importance: Importance.max,
    priority: Priority.high,
    ticker: 'ticker',
  );

  const NotificationDetails platformChannelSpecifics =
      NotificationDetails(android: androidPlatformChannelSpecifics);

  flutterLocalNotificationsPlugin.show(
    0,
    message.notification?.title,
    message.notification?.body,
    platformChannelSpecifics,
    payload: 'item x',
  );
}

void main() async {
  // Inicializa los widgets de Flutter y espera que Firebase se inicialice
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Inicializa la notificación local
  final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');
  final InitializationSettings initializationSettings =
      InitializationSettings(android: initializationSettingsAndroid);
  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  // Registra el background handler para cuando la aplicación está en segundo plano o cerrada
  FirebaseMessaging.onBackgroundMessage(backgroundHandler);

  // Establece la orientación del dispositivo a solo vertical
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  // Ejecuta la app con los providers necesarios para gestionar el estado
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ReservasProvider()),
        ChangeNotifierProvider(create: (context) => CrearcuentaProvider()),
      ],
      child: MyApp(),
    ),
  );
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
      home: SplashScreen(), // Pantalla de inicio (Splash)
      debugShowCheckedModeBanner: false,
      locale: const Locale('es', ''), // Establece el idioma a español
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
  final Logincuenta login = Logincuenta();
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    _startAnimation();

    // Solicita permisos para recibir notificaciones
    _firebaseMessaging.requestPermission();

    // Obtiene el token FCM para el dispositivo
    _firebaseMessaging.getToken().then((token) {
      print("Token FCM: $token");
    });

    // Escucha mensajes cuando la app está en primer plano
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("Mensaje recibido en primer plano: ${message.notification?.title}");
      showNotification(message); // Muestra la notificación en primer plano
    });

    // Escucha mensajes cuando la app está en segundo plano o cerrada
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print("Mensaje abierto desde notificación");
      showNotification(message); // Muestra la notificación al abrir la app
    });
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
        MaterialPageRoute(builder: (context) => Myoptions()), // Navegar a la pantalla de opciones
      );
    } else {
      login.login(context); // Si el usuario está autenticado, loguearse
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
          child: Image.asset('assets/logo.png', width: 200), // Imagen de la app
        ),
      ),
    );
  }
}
