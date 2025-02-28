import 'package:cateringmid/Hreservas/hreservas.dart';
import 'package:cateringmid/home/apicliente.dart';
import 'package:flutter/material.dart';
import '../Ubicaciones/ubicacion.dart';
import '../home/home.dart';
import '../main.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Apiclienteclass apicliente = Apiclienteclass(); // Instanciamos el servicio de cliente
    return Drawer(
      child: FutureBuilder<void>(
        future: apicliente.fetchclienteData(), 
        builder: (context, snapshot) {
            if (apicliente.cliente.isNotEmpty) {
              var apiclienteData = apicliente.cliente; // Accedemos a los datos del cliente
              return ListView(
                padding: EdgeInsets.zero,
                children: [
                  DrawerHeader(
                    decoration: BoxDecoration(
                      color: Color(0xFF670A0A),
                    ),
                    child: Column(
                      children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(120),
                        child: SizedBox(
                          width: 80,
                          height: 80,
                          child: Image.network(
                            apiclienteData[0].linkImagen,
                            fit: BoxFit.cover,
                            loadingBuilder: (BuildContext context, Widget child,
                                ImageChunkEvent? loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Center(
                                child: CircularProgressIndicator(
                                  value: loadingProgress.expectedTotalBytes != null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes!
                                      : null,
                                ),
                              );
                            },
                            errorBuilder: (context, object, stackTrace) {
                              return const Icon(Icons.error); // O una imagen de error
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                      'Hola ${apiclienteData[0].nombre}', // Mostramos el nombre del cliente
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                      ),
                      
                    ),
                    ]
                    ),
                  ),
                  ListTile(
                    title: Container(
                      alignment: Alignment.topLeft,
                      child: Row(
                        children: [
                          Icon(
                            Icons.home,
                            color: const Color.fromARGB(255, 80, 79, 79),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'Home',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                    onTap: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => MyHomePage()),
                        (Route<dynamic> route) => false, // Elimina todas las pantallas anteriores
                      );
                    },
                  ),
                  ListTile(
                    title: Container(
                      alignment: Alignment.topLeft,
                      child: Row(
                        children: [
                          Icon(
                            Icons.room_service,
                            color: const Color.fromARGB(255, 80, 79, 79),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'Mis reservas',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => HreservaPage()),
                      );
                    },
                  ),
                  ListTile(
                    title: Container(
                      alignment: Alignment.topLeft,
                      child: Row(
                        children: [
                          Icon(
                            Icons.logout_rounded,
                            color: const Color.fromARGB(255, 80, 79, 79),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'Cerrar sesión',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                    onTap: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => MyHomePage1()),
                        (Route<dynamic> route) => false, // Elimina todas las pantallas anteriores
                      );
                    },
                  ),
                ],
              );
            } else {
              return Center(child: Text(''));
            }
        })
    );
     
  }
}

