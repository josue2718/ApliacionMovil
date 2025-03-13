import 'package:cateringmid/Favoritos/misfavoritos.dart';
import 'package:cateringmid/Hreservas/hreservas.dart';
import 'package:cateringmid/cache.dart';
import 'package:cateringmid/home/apicliente.dart';
import 'package:cateringmid/home/empresasmap.dart';
import 'package:cateringmid/login/Createaccount.dart';
import 'package:cateringmid/login/login.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Ubicaciones/ubicacion.dart';
import '../home/home.dart';
import '../main.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({Key? key}) : super(key: key);

  Future<Map<String, String?>> _getUserData() async {
       final Apiclienteclass apicliente = Apiclienteclass();
    final prefs = await SharedPreferences.getInstance();
    print(prefs.getString('inicio'));
apicliente.fetchclienteData();    
    return {
      'nombre': prefs.getString('nombre'),
      'imagen': prefs.getString('imagen'),
      'inicio' : prefs.getString('inicio')
      
    };
  }


  @override
  Widget build(BuildContext context) {
    final Apiclienteclass apicliente = Apiclienteclass(); // Instanciamos el servicio de cliente

    return Drawer(
      child: FutureBuilder<Map<String, String?>>(
        future: _getUserData(),
        builder: (context, snapshot) {
          final nombre = snapshot.data?['nombre'] ?? "Usuario";
          final imagen = snapshot.data?['imagen'];
          final String? inicioString = snapshot.data?['inicio'];
          final bool isLoggedIn = inicioString == 'true'; // Convierte el valor String a bool
          print(inicioString);

          return ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                decoration: const BoxDecoration(
                  color: Color(0xFF670A0A),
                ),
                child: Column(
                  children: [
                    if (isLoggedIn)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(120),
                      child: SizedBox(
                        width: 80,
                        height: 80,
                        child:
                             Image.network(
                                imagen!,
                                fit: BoxFit.cover,
                                loadingBuilder: (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return Center(
                                    child: CircularProgressIndicator(
                                      value: loadingProgress.expectedTotalBytes != null
                                          ? loadingProgress.cumulativeBytesLoaded /
                                              (loadingProgress.expectedTotalBytes ?? 1)
                                          : null,
                                    ),
                                  );
                                },
                                errorBuilder: (context, error, stackTrace) {
                                  return const Icon(Icons.account_circle, size: 80, color: Colors.white);
                                },
                              )
                            
                      ),
                    ),
                     if (isLoggedIn==false)
                   const Icon(Icons.account_circle, size: 80, color: Colors.white),
                    const SizedBox(height: 10),
                     Text(
                      isLoggedIn ? 'Hola, $nombre' : 'Hola',
                      style: const TextStyle(color: Colors.white, fontSize: 24),
                    ),
                  ],
                ),
              ),
              if (isLoggedIn) ...[
              _buildDrawerItem(
                icon: Icons.home,
                text: "Home",
                onTap: () => _navigateTo(context, MyHomePage()),
              ),
              _buildDrawerItem(
                icon: Icons.location_on,
                text: "Mapa de empresas",
                onTap: () => _navigateTo(context,LocationMap()),
              ),
              _buildDrawerItem(
                icon: Icons.room_service,
                text: "Mis reservas",
                onTap: () => _navigateTo(context, HreservaPage()),
              ),
              _buildDrawerItem(
                icon: Icons.favorite_rounded,
                text: "Mis Favoritos",
                onTap: () => _navigateTo(context, Misfavoritospage()),
              ),
              ],
               if (isLoggedIn==false) ...[
               _buildDrawerItem(
                  icon: Icons.account_circle_rounded,
                  text: "iniciar sesion",
                  onTap: () => _navigateTo(context, Login()),
                ),
                   _buildDrawerItem(
                  icon: Icons.account_circle_rounded,
                  text: "Crear cuenta",
                  onTap: () => _navigateTo(context, Createaccount()),
                ),
               ],
              _buildDrawerItem(
                icon: Icons.logout_rounded,
                text: isLoggedIn ? "Cerrar sesión" : "Salir",
                onTap: () => _navigateToAndRemove(context, SplashScreen()),
              ),

            ],
          );
        },
      ),
    );
  }

  Widget _buildDrawerItem({required IconData icon, required String text, required VoidCallback onTap}) {
    return ListTile(
      title: Row(
        children: [
          Icon(icon, color: const Color.fromARGB(255, 80, 79, 79)),
          const SizedBox(width: 10),
          Text(text, style: const TextStyle(color: Colors.black)),
        ],
      ),
      onTap: onTap,
    );
  }

  void _navigateTo(BuildContext context, Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => page));
  }

  void _navigateToAndRemove(BuildContext context, Widget page) {
        final PreferencesService _preferencesService = PreferencesService();
    _preferencesService.clearPreferences();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => page),
      (route) => false,
    );
  }
}
