
import 'package:cateringmid/Hreservas/consts.dart';
import 'package:cateringmid/Hreservas/pagoreserva.dart';
import 'package:cateringmid/Reservas/reservamodelo.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'login/login.dart'; 
import 'login/apinewaccoutn.dart'; 
import 'login/Createaccount.dart'; 
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
      home: MyHomePage1(),
      debugShowCheckedModeBanner: false,
  locale: const Locale('es', ''), 
    );
  }
}

class MyHomePage1 extends StatefulWidget {

  @override
  State<MyHomePage1> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage1> {
  int _backPressedCount = 0; // Contador para el número de intentos de retroceso
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _backPressedCount++;
        if (_backPressedCount == 1) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Presione nuevamente para salir', style: TextStyle(color: Color(0xFF670A0A), )) , backgroundColor: Color.fromARGB(255, 255, 255, 255),),
          );

          Future.delayed(const Duration(seconds: 2), () {
            setState(() {
              _backPressedCount = 0;
            });
          });
          return Future.value(false);
        } else {
          SystemNavigator.pop();
          return Future.value(true);
        }
      },
      child: Scaffold(

      backgroundColor: const Color(0xFF670A0A),
      body:  SingleChildScrollView(
        child: Padding(
         padding: const EdgeInsets.symmetric(
                          horizontal: 0, vertical: 50),
        child: Form(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
                Image.asset(
                'assets/logo.png',
                height: 300, // Ajusta la altura de la imagen
                width: 400, // Ajusta el ancho de la imagen
                ),
                const SizedBox(height: 200),
              ElevatedButton(
                onPressed: () {
                    Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => Login()),
                  );
                  },
                  style: ElevatedButton.styleFrom(
                    fixedSize: const Size(350, 50), // Ancho fijo de 250 y alto de 50
                    foregroundColor: const Color(0xFF670A0A),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Iniciar sesión '),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    print("Botón 1 presionado");
                  },
                  style: ElevatedButton.styleFrom(
                    fixedSize: const Size(350, 50), // Ancho fijo de 250 y alto de 50
                    foregroundColor: Colors.black,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/google_logo.png', // Ruta de tu logo de Google
                        height: 24, // Altura del logo
                        width: 24, // Ancho del logo
                      ),
                      const SizedBox(width: 10), // Espacio entre el logo y el texto
                      const Text('Iniciar sesión con Google'),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => Createaccount()));
                  },
                 style: ElevatedButton.styleFrom(
                    fixedSize: const Size(350, 50), // Ancho fijo de 250 y alto de 50
                    backgroundColor: const Color(0xFF670A0A), // Fondo blanco para parecerse a los botones de Google
                    foregroundColor: const Color.fromARGB(255, 255, 255, 255),
                  side: const BorderSide(
                  color: Color.fromARGB(255, 255, 255, 255), // Color del borde
                  width: 2, // Ancho del borde
                ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Registrarme'),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                TextButton(
                  onPressed: () {
                     Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MercadoPagoScreen(),
                ));
                  },
                 style: TextButton.styleFrom(
                  fixedSize: const Size(350, 50), // Ancho fijo de 350 y alto de 50
                  backgroundColor: Colors.transparent, // Fondo transparente
                  foregroundColor: const Color.fromARGB(255, 255, 255, 255), // Color del texto (blanco)
                  side: BorderSide.none, // Eliminar el borde
                  padding: EdgeInsets.zero, // Eliminar cualquier padding extra
                ),
                child: const Text('SEGUIR SIN REGISTRARME'),
                ),
              ],
            )
        )
        )
      )
        )
    );
  }
}


