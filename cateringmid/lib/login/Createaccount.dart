import 'package:cateringmid/Reservas/reservamap.dart';
import 'package:cateringmid/login/apinewaccoutn.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http; // Importar el paquete http
import 'package:keyboard_dismisser/keyboard_dismisser.dart';
import 'package:provider/provider.dart';
import 'dart:convert'; // Para trabajar con JSON
import '../cache.dart';
import '../home/home.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:async';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget  {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CateringMID',
      theme: ThemeData(
        useMaterial3: true,
      ),
      home: Createaccount(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class Createaccount extends StatefulWidget {
  const Createaccount({super.key});

  @override
  _AcocountState createState() => _AcocountState();
}

class _AcocountState extends State<Createaccount> {
   File? _image;
  String? _imageBase64;
  String? _imageName;

   Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      File imageFile = File(pickedFile.path);
      List<int> imageBytes = await imageFile.readAsBytes();
      String base64Image = base64Encode(imageBytes);
      String imageName = pickedFile.path.split('/').last; // Obtiene el nombre real del archivo

      if (_isValidBase64(base64Image)) {
        setState(() {
          _image = imageFile;
          _imageBase64 = base64Image;
          _imageName = imageName;
        });

      } else {
      }
    }
  }

  bool _isValidBase64(String base64String) {
    return base64String.isNotEmpty && base64String.length % 4 == 0;
  }

  void _login() async {
    if (_formKey.currentState?.validate() ?? false) {
      if (_imageBase64 == null || _imageName == null) {
        _imageBase64 = "";
        _imageName ="";
      }
      Provider.of<CrearcuentaProvider>(context, listen: false).actualizardato(
        _usernameController.text,
        _userfirtsnameController.text,
        _usercelphoneController.text,
        _useremailController.text,
        _passwordController.text,
        _confirmPasswordControlle.text,
        _imageName!,
        _imageBase64!,
      );

      await crearcuentaProvider.enviarcuenta(context);
    }
  }

  
    // Ahora puedes usar _imageBase64 en tu aplicación
  final _formKey = GlobalKey<FormState>(); // Clave para el formulario
  final _usernameController = TextEditingController(); // Controlador para el nombre de usuario
  final _userfirtsnameController = TextEditingController(); // Controlador para el nombre de usuario
  final _passwordController = TextEditingController(); // Controlador para la contraseña
  final _confirmPasswordControlle = TextEditingController();
  final _usercelphoneController = TextEditingController();
  final _useremailController= TextEditingController();
  final CrearcuentaProvider crearcuentaProvider = CrearcuentaProvider();
  bool _isObscured = true; // Estado para alternar visibilidad de contraseña
  bool _isObscured2 = true; // Estado para alternar visibilidad de contraseña
  // Método para verificar los campos y hacer login

 

  @override
  Widget build(BuildContext context) {
    return KeyboardDismisser(
      child: Scaffold(
      appBar: AppBar(
        title: const Text(
          'Registrarse',
          textAlign: TextAlign.center, // Asegura que el texto esté centrado
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
      body:  SingleChildScrollView(
        child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [ 
              Container(
              decoration: BoxDecoration(
              color:  Color.fromARGB(0, 103, 10, 10),
              borderRadius: BorderRadius.circular(50)),
              width: 250,
              height: 270,
              child:  Column(
              children: [
                _image == null
                ?  Container(
                    decoration: BoxDecoration(
                    color:  Color.fromARGB(255, 177, 177, 177),
                    borderRadius: BorderRadius.circular(100)),
                    width: 200,
                    height: 200,
                   child:  IconButton(
                    onPressed: () {
                    },
                    icon: const Icon(Icons.person ), // Usa un icono de calendario
                    color: const Color.fromARGB(255, 255, 255, 255),
                    iconSize: 65,
                  ),
                )
                :  ClipOval(
                child: Image.file(_image!, height: 200, fit: BoxFit.cover), // Ajusta la imagen al círculo
                ),
                SizedBox(height: 20),
                Transform.translate(
                offset: Offset(60, -70), // Desplaza 50 píxeles hacia arriba (ajusta el valor)
                child: 
                Container(
                  decoration: BoxDecoration(
                  color: Color.fromARGB(255, 103, 10, 10),
                  borderRadius: BorderRadius.circular(50)),
                  width: 50,
                  height: 50,
                  child: 
                  IconButton(
                    onPressed: () {
                    _pickImage();
                    },
                    icon: const Icon(Icons.add_a_photo_outlined ), // Usa un icono de calendario
                    color: const Color.fromARGB(255, 255, 255, 255),
                    iconSize: 25,
                  ),
                )
                )
              ],
              )
            ),
              TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  labelText: 'Nombre',
                  border: UnderlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese un nombre de usuario';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller:  _userfirtsnameController,
                decoration: const InputDecoration(
                  labelText: 'Apellido',
                  border: UnderlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese un Apellido de usuario';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _usercelphoneController,
                decoration: const InputDecoration(
                  labelText: 'Telefono',
                  border: UnderlineInputBorder(),
                ),
                 keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese un Telefono de usuario';
                  }
                  if (!RegExp(r'^\d{10}$').hasMatch(value)) {
                    return 'El teléfono debe tener exactamente 10 dígitos';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _useremailController,
                decoration: const InputDecoration(
                  labelText: 'Correo',
                  border: UnderlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese un Correo de usuario';
                  }
                   if (!RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(value)) {
                  return 'El correo no es válido';
                }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              // Campo de texto para la contraseña
              TextFormField(
                controller: _passwordController,
                obscureText: _isObscured, // Usa el estado para alternar visibilidad
                decoration: InputDecoration(
                  labelText: 'Contraseña',
                  border: const UnderlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isObscured ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _isObscured = !_isObscured; // Cambia el estado al presionar el ícono
                      });
                    },
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese una contraseña';
                  }
                  if (!RegExp(r'^(?=.*[A-Z])(?=.*\d)(?=.*[\W_]).{8,}$').hasMatch(value)) {
                    return 'La contraseña debe tener al menos 8 caracteres, incluir una mayúscula, un número y un símbolo.';
                  }
                  
                  return null;
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _confirmPasswordControlle,
                obscureText: _isObscured2, // Usa el estado para alternar visibilidad
                decoration: InputDecoration(
                  labelText: 'Confirmar contraseña',
                  border: const UnderlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isObscured2 ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _isObscured2 = !_isObscured2; // Cambia el estado al presionar el ícono
                      });
                    },
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor confirme su contraseña';
                  } else if (value != _passwordController.text) {
                    return 'Las contraseñas no coinciden';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 40),
             /*TextButton.icon(
              onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>LocationPickerScreen(), // Usa id_cliente aquí si es necesario
                    ),
                  );
                },
              icon: Icon(
                 Icons.location_on ,
                 size: 20,
                color: const Color(0xFF670A0A), // Color del ícono
              ),
              label: const Text(
                'Ubicacion',
                style: TextStyle(
                  fontSize: 17,
                  color: const Color(0xFF670A0A), // Color del texto
                ),
              ),
            ),*/

              const SizedBox(height: 30),
              // Botón de login
              ElevatedButton(
                onPressed:  _login, // Usa id_cliente aquí si es necesari
                style: ElevatedButton.styleFrom(
                    fixedSize: const Size(300, 50), // Ancho fijo de 250 y alto de 50
                    backgroundColor:  const Color(0xFF670A0A),
                    foregroundColor: const Color.fromARGB(255, 240, 239, 239),
                  
                ),
                child: const Text('Registrarme'),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
      ),
      ),
    );
  }
}

