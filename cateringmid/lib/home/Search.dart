import 'package:cateringmid/Empresa/empresa.dart';
import 'package:cateringmid/home/Search_api.dart';
import 'package:cateringmid/menu%20despegable/CustomDrawer.dart';
import 'package:flutter/material.dart';
import 'package:keyboard_dismisser/keyboard_dismisser.dart';

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  ApiclassSearch empresasSearch = ApiclassSearch();
  List<EmpresasSearch> nombresFiltrados =
      []; // Cambié el tipo de lista a List<EmpresasSearch>
  TextEditingController searchController = TextEditingController();
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    await empresasSearch
        .fetchEmpresaData(); // Espera a que los datos se carguen

    setState(() {
      // Mantén los objetos completos de las empresas en nombresFiltrados
      nombresFiltrados = empresasSearch
          .empresassearch; // Ahora nombresFiltrados contiene los objetos completos
      isLoading =
          false; // Cambia el estado a false una vez que los datos están cargados
    });
  }

  void filtrarNombres(String query) {
    setState(() {
      // Filtra las empresas por nombre, manteniendo los objetos completos
      nombresFiltrados = empresasSearch.empresassearch
          .where((empresa) =>
              empresa.nombre.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardDismisser(
      child: Scaffold(
        drawer: const CustomDrawer(),
        appBar: AppBar(
          title: const Text('HOME'),
          backgroundColor: const Color(0xFF670A0A),
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          toolbarHeight: 90,
          actions: [
            IconButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Notificaciones')),
                );
              },
              icon: const Icon(Icons.notifications,
                  color: Colors.white, size: 30),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              const SizedBox(height: 20),
              TextField(
                controller: searchController,
                autofocus: true,
                onChanged: filtrarNombres,
                decoration: InputDecoration(
                  labelText: "Buscar",
                  labelStyle: TextStyle(
                      color: Color(
                          0xFF670A0A)), // Color del texto cuando no está enfocado
                  prefixIcon: Icon(Icons.search, color: Color(0xFF670A0A)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide(
                        color: Color(0xFF670A0A)), // Color del borde inactivo
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide(
                        color: Color(
                            0xFF670A0A)), // Color del borde cuando está inactivo
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide(
                        color: Color(0xFF670A0A),
                        width: 2), // Borde cuando está activo
                  ),
                ),
                cursorColor: const Color.fromARGB(
                    255, 0, 0, 0), // Color del cursor cuando se escribe
              ),
              const SizedBox(height: 10),
              isLoading
                  ? Center(
                      child:
                          CircularProgressIndicator()) // Loader mientras se cargan datos
                  : nombresFiltrados.isEmpty
                      ? const Center(
                          child: Text("No se encontraron resultados"))
                      : Expanded(
                          child: ListView.builder(
                            itemCount: nombresFiltrados.length,
                            itemBuilder: (context, index) {
                              final empresa = nombresFiltrados[
                                  index]; // Accede a un solo objeto empresa
                              return CustomerCart(
                                empresa: empresa.nombre,
                                id_empresa: empresa
                                    .id_empresa, // Pasa los datos completos de la empresa
                                link: empresa
                                    .link_logo, // Pasa el enlace o una cadena vacía si no existe
                              );
                            },
                          ),
                        ),
            ],
          ),
        ),
      ),
    );
  }
}

class CustomerCart extends StatelessWidget {
  const CustomerCart({
    required this.id_empresa,
    required this.link,
    required this.empresa,
  });

  final String link;
  final String empresa;
  final String id_empresa;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(1),
        ),
        color: const Color.fromARGB(255, 255, 255, 255),
        margin: const EdgeInsets.symmetric(vertical: 1, horizontal: 0),
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CompanyPage(id_empresa: id_empresa),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(100),
                  child: SizedBox(
                    width: 60,
                    height: 60,
                    child: Image.network(
                      link,
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
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              empresa,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
