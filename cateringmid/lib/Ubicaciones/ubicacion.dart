import 'package:flutter/material.dart';
import 'package:http/http.dart' as http; // Importar el paquete http
import 'package:keyboard_dismisser/keyboard_dismisser.dart';
import 'dart:convert'; // Para trabajar con JSON
import '../home/home.dart';

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
        useMaterial3: true,
      ),
      home: Createdireccion(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class Createdireccion extends StatefulWidget {

  @override
  _CreatecomentarioState createState() => _CreatecomentarioState();
}

class _CreatecomentarioState extends State<Createdireccion> {
  final _formKey = GlobalKey<FormState>(); // Clave para el formulario
  final _usercalle = TextEditingController(); // Controlador para el comentario
  final _usernamelugar= TextEditingController(); // Controlador para el comentario
  final _usernumcasa = TextEditingController(); // Controlador para el comentario
  final _userrefrencias = TextEditingController(); // Controlador para el comentario
  int rating = 0; // Controlador para la calificación de estrellas

  // Método para verificar los campos y hacer login
  void _login() async {
  if (_formKey.currentState?.validate() ?? false) {
    // Mostrar un indicador de carga mientras se hace la solicitud
   

    try {
      // Realizar la solicitud POST
      final response = await http.post(
        Uri.parse('https://cateringmid.azurewebsites.net/api/ReservaDirecciones'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          "id_cliente":"",
          "latitud": 0,
          "longitud": 0,
          "calle": _usercalle.text,
          "nombre_lugar": _usernamelugar.text,
          "num_casa": _usernumcasa.text,
          "referencias": _userrefrencias.text
        }),
      );

      // Cerrar el indicador de carga
      Navigator.pop(context); 

      // Verificar la respuesta de la API
      if (response.statusCode == 201) {
        final data = json.decode(response.body);

        if (data != null && data['id_direccion'] != null) {
          // Asegurarse de cerrar el diálogo antes de la navegación
          Future.delayed(Duration.zero, () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => MyHomePage(),
              ),
            );
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error al registrar comentario')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al intentar crear cuenta')),
        );
      }
    } catch (e) {
      Navigator.pop(context); // Cerrar el indicador de carga
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error de conexión')),
      );
    }
  }
}


  @override
  Widget build(BuildContext context) {
    return KeyboardDismisser(
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Ubicaciones',
            textAlign: TextAlign.center, // Asegura que el texto esté centrado
          ),
        backgroundColor: const Color(0xFF670A0A),
        foregroundColor: Colors.white,
        elevation: 0,
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
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Campo de texto para el comentario
                  TextFormField(
                    controller: _usercalle,
                    decoration: const InputDecoration(
                      labelText: 'Dirección o Calle',
                      border: UnderlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingrese un comentario';
                      }
                      return null;
                    },
                  ),

                const SizedBox(height: 20),
                  TextFormField(
                    controller: _usernamelugar,
                    decoration: const InputDecoration(
                      labelText: 'Nombre del lugar',
                      border: UnderlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingrese un nombre';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _usernumcasa,
                    decoration: const InputDecoration(
                      labelText: 'Numero de casa',
                      border: UnderlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingrese el Numero de casa';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _userrefrencias,
                    decoration: const InputDecoration(
                      labelText: 'Referencias',
                      border: UnderlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingrese un su referencia';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 200),
                  // Botón de comentar
                  ElevatedButton(
                    onPressed: _login,
                    style: ElevatedButton.styleFrom(
                       fixedSize: const Size(250, 50), // Ancho fijo de 250 y alto de 50
                      backgroundColor: const Color(0xFF670A0A), // Fondo blanco para parecerse a los botones de Google
                      foregroundColor: const Color.fromARGB(255, 255, 255, 255),
                    ),
                    child: const Text('Guardar'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
