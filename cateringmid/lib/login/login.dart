import 'package:cateringmid/login/Createaccount.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http; // Importar el paquete http
import 'dart:convert'; // Para trabajar con JSON
import 'package:keyboard_dismisser/keyboard_dismisser.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../cache.dart';
import '../home/home.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:async';
import 'dart:io';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CateringMID',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 255, 255, 255)),
        useMaterial3: false,
      ),
      home: Login(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _formKey = GlobalKey<FormState>(); // Clave para el formulario
  final _usernameController = TextEditingController(); // Controlador para el nombre de usuario
  final _passwordController = TextEditingController(); // Controlador para la contraseña
  bool _isObscured = true; // Estado para alternar visibilidad de contraseña
  final PreferencesService _preferencesService = PreferencesService(); // Instancia del servicio
  String? _token;
  bool? _inicio;
  String? _id;

  Future<void> _saveToken(String token, bool inicio, String id) async {
    await _preferencesService.savePreferences(token, inicio, id);
    setState(() {
      _token = token;
      _inicio = inicio;
      _id = id;
    });
  }

  // Método para verificar los campos y hacer login
  void _login() async {
  if (_formKey.currentState?.validate() ?? false) {
    showDialog(
      context: context,
      barrierDismissible: false, // Evita que el usuario cierre el diálogo manualmente
      builder: (context) {
        return const Center(
          child: CircularProgressIndicator(
            color: Color(0xFF670A0A),
            backgroundColor: Color.fromARGB(255, 255, 255, 255),
          ),
        );
      },
    );

    int attempts = 0;
    const int maxAttempts = 15;
    http.Response? response;

    while (attempts < maxAttempts) {
      try {
        response = await http
            .post(
              Uri.parse('https://cateringmidd.azurewebsites.net/api/AuthClient/login'),
              headers: {'Content-Type': 'application/json'},
              body: json.encode({
                'email': _usernameController.text,
                'password': _passwordController.text,
              }),
            )
            .timeout(Duration(seconds: 30)); // Aumentamos el timeout a 30s

        if (response.statusCode == 200) {
          break; // Éxito, salir del bucle
        }

        if (response.statusCode == 401) {
          final data = jsonDecode(response.body);
          String errorMessage = data['message'];
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(errorMessage), backgroundColor: const Color(0xFF670A0A)),
          );
          break;
        }
      } on TimeoutException {
        print('Error: Tiempo de espera agotado en la solicitud.');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tiempo de espera agotado. Intente de nuevo'), backgroundColor: Color(0xFF670A0A)),
        );
        break; // No seguir reintentando si el servidor no responde
      } on SocketException {
        print('Error: Sin conexión a internet.');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No hay conexión a Internet'), backgroundColor: Color(0xFF670A0A)),
        );
        break;
      } catch (e) {
        print('Error inesperado: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ocurrió un error inesperado'), backgroundColor: Color(0xFF670A0A)),
        );
        break;
      }

      attempts++;
      if (attempts < maxAttempts) {
        await Future.delayed(Duration(seconds: 2)); // Espera antes de reintentar
      }
    }

    Navigator.pop(context); // Cerrar el indicador de carga

    if (response != null && response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data != null && data['token'] != null) {
        await _saveToken(data['token'], true, data['idCliente']);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MyHomePage()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Credenciales incorrectas'), backgroundColor: Color(0xFF670A0A)),
        );
      }
    }
  }
}


  @override
  Widget build(BuildContext context) {
    return KeyboardDismisser(
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Iniciar sesión',
            textAlign: TextAlign.center,
          ),
          backgroundColor: const Color.fromARGB(255, 255, 255, 255),
          centerTitle: true,
          toolbarHeight: 70,
          flexibleSpace: Container(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Colors.grey.shade300, // Color de la sombra
                  width: 3.0, // Grosor de la línea
                ),
              ),
            ),
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        resizeToAvoidBottomInset: true,
        body: SingleChildScrollView(
          child: AutofillGroup(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/LOGOROJO.png',
                      height: 250, // Ajusta la altura de la imagen
                      width: 410, // Ajusta el ancho de la imagen
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _usernameController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'Correo',
                        border: UnderlineInputBorder(),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey),
                        ),
                        suffixIcon: Icon(
                          Icons.email,
                          color: Color.fromARGB(255, 112, 110, 110),
                        ),
                      ),
                      autofillHints: [AutofillHints.email],
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor ingrese un correo';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _isObscured,
                      decoration: InputDecoration(
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey),
                        ),
                        labelText: 'Contraseña',
                        border: const UnderlineInputBorder(),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isObscured ? Icons.visibility : Icons.visibility_off,
                            color: Color.fromARGB(255, 83, 81, 81),
                          ),
                          onPressed: () {
                            setState(() {
                              _isObscured = !_isObscured;
                            });
                          },
                        ),
                      ),
                      autofillHints: [AutofillHints.password],
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor ingrese una contraseña';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 70),
                    ElevatedButton(
                      onPressed: _login,
                      style: ElevatedButton.styleFrom(
                        fixedSize: const Size(300, 50),
                        backgroundColor: const Color(0xFF670A0A),
                        foregroundColor: const Color.fromARGB(255, 240, 239, 239),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Text('Iniciar sesión'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => Createaccount()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: const Color(0xFF670A0A),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Text('¿No tienes cuenta? Regístrate'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
