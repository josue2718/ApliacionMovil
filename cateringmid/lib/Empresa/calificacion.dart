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
      home: Createcomentario(id_empresa: '1'),
      debugShowCheckedModeBanner: false,
    );
  }
}

class Createcomentario extends StatefulWidget {
  final String id_empresa;


  // Constructor con ambos parámetros
  const Createcomentario({
    Key? key,
    required this.id_empresa,
  }) : super(key: key);

  @override
  _CreatecomentarioState createState() => _CreatecomentarioState();
}

class _CreatecomentarioState extends State<Createcomentario> {
  final _formKey = GlobalKey<FormState>(); // Clave para el formulario
  final _usercomentario = TextEditingController(); // Controlador para el comentario
  int rating = 0; // Controlador para la calificación de estrellas

  // Método para verificar los campos y hacer login
  void _login() async {
  if (_formKey.currentState?.validate() ?? false) {
    // Mostrar un indicador de carga mientras se hace la solicitud
   

    try {
      // Realizar la solicitud POST
      final response = await http.post(
        Uri.parse('https://cateringmid.azurewebsites.net/api/Calificacion'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          "id_empresa": widget.id_empresa,
          "id_cliente":" widget.id_cliente",
          "comentario": _usercomentario.text,
          "estrellas": rating,
          "link_imagen": "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSVIaS8X0-wnzCXcXLAyrohjSaBBBtcETZSzFsbYafKzXFty-Du4be2dW6X6EHI5jjTMWZjsQ&s"
        }),
      );

      // Cerrar el indicador de carga
      Navigator.pop(context); 

      // Verificar la respuesta de la API
      if (response.statusCode == 201) {
        final data = json.decode(response.body);

        if (data != null && data['id_calificacion'] != null) {
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
          title: const Text('Calificacion'),
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
                    controller: _usercomentario,
                    decoration: const InputDecoration(
                      labelText: 'Comentario',
                      border: UnderlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingrese un comentario';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 30),
                  
                  // Estrellas para la calificación
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return IconButton(
                        icon: Icon(
                          index < rating ? Icons.star : Icons.star_border,
                          color:  const Color(0xFF670A0A),
                          size: 40.0,
                        ),
                        onPressed: () {
                          setState(() {
                            rating = index + 1; // Asignar el número de la estrella seleccionada al controlador
                          });
                        },
                      );
                    }),
                  ),
                  Text('Calificación: $rating'), // Muestra el valor actual de la calificación

                  const SizedBox(height: 100),
                  // Botón de comentar
                  ElevatedButton(
                    onPressed: _login,
                    style: ElevatedButton.styleFrom(
                       fixedSize: const Size(250, 50), // Ancho fijo de 250 y alto de 50
                      backgroundColor: const Color(0xFF670A0A), // Fondo blanco para parecerse a los botones de Google
                      foregroundColor: const Color.fromARGB(255, 255, 255, 255),
                    ),
                    child: const Text('Calificar'),
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
