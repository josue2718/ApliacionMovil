import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import '../Empresa/empresa.dart';
import '../Ubicaciones/ubicacion.dart';
import '../main.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fetch Data with Infinite Scroll',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 255, 255, 255)),
      ),
      home: MyHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatefulWidget {

  @override
  State<MyHomePage> createState() => _HomeState();
}



class _HomeState extends State<MyHomePage> {
  final ScrollController _scrollController = ScrollController();
  List<Map<String, dynamic>> empresas = [];
  int pageNumber = 1;
  bool isLoading = false;
  bool hasMore = true;
@override
  void initState() {
    super.initState();
    fetchEmpresaData(pageNumber);  // Llamamos la API al inicio
  }

Future<void> fetchEmpresaData(int pageNumber) async {
  if (isLoading || !hasMore) return;
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('token');
  print('Token: $token');
  setState(() {
    isLoading = true;
  });

  final headers = {
    
    'Authorization': 'Bearer $token',
  };

  final response = await http.get(
    Uri.parse('https://cateringmid.azurewebsites.net/api/Empresa?pageNumber=$pageNumber&pageSize=8'),
    headers: headers,
  );

  if (response.statusCode == 200) {
    final Map<String, dynamic> jsonResponse = json.decode(response.body);
    final List<Map<String, dynamic>> newEmpresas = List<Map<String, dynamic>>.from(jsonResponse['data']);

    setState(() {
      empresas.addAll(newEmpresas);
      isLoading = false;
      if (newEmpresas.isEmpty) {
        hasMore = false;
      }
    });
  } else {
    setState(() {
      isLoading = false;
    });
    throw Exception('Failed to load data');
  }
}


  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      if (!isLoading && hasMore) {
        pageNumber++;
        fetchEmpresaData(pageNumber);
      }
    }
  }

  Future<void> _onRefresh() async {
    setState(() {
      empresas.clear();
      pageNumber ++;
      hasMore = true;
    });
    await fetchEmpresaData(pageNumber);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: const Text('HOME'),
          backgroundColor: const Color(0xFF670A0A),
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          toolbarHeight: 70,
        ),
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        body: RefreshIndicator(
          onRefresh: _onRefresh,
          color: const Color(0xFF670A0A),
          child: ListView.builder(
            controller: _scrollController,
            itemCount: empresas.length + (isLoading ? 1 : 0),
            itemBuilder: (context, index) {
              if (index < empresas.length) {
                final empresa = empresas[index];
                return ItemWidget(
                  text: '${empresa['nombre']}',
                  details: [
                    'Correo: ${empresa['email']}',
                    'Teléfono: ${empresa['telefono']}',
                    'Dirección: ${empresa['direccion']}',
                  ],
                  id: '${empresa['id_empresa']}'

                );
              } else {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: CircularProgressIndicator(
                      color: Color(0xFF670A0A),
                    ),
                  ),
                );
              }
            },
          ),
        ),
      
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: const Color(0xFF670A0A),
              ),
              child: Text(
                'Hola',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              title: Text(
                'Home',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.black,
                    ),
              ),
              onTap: () {
                Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MyHomePage(), // Usa id_cliente aquí
            ),
          );}
            ),
            ListTile(
              title: Text(
                'Añadir Ubicacion',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.black,
                      
                    ),
              ),
              onTap: () {

               Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Createdireccion (), // Usa id_cliente aquí
            ),
          );
              },
            ),
            ListTile(
              title: Text(
                'Cerrar Sesión',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.black,
                    ),
              ),
              onTap: () {
                Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MyHomePage1(), // Usa id_cliente aquí
            ),
          );
              },
            ),
          ],
        ),
      ),
      ));
  }
}

class ItemWidget extends StatelessWidget {
  final String text;
  final List<String> details;
  final String id;


  const ItemWidget({
    super.key,
    required this.text,
    required this.details,
    required this.id,

  });
  @override
  Widget build(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  CompanyPage(id_empresa: id),
            ),
          );
        },
        child: Card(
          color: const Color.fromARGB(255, 255, 255, 255),
          child: SizedBox(
            height: 200,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    text,
                    style: const TextStyle(
                      color: Color.fromARGB(255, 255, 0, 0),
                      fontSize: 20,
                    ),
                  ),
                ),
                ...details.map((detail) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 50.0),
                    child: Text(
                      detail,
                      style: const TextStyle(
                        color: Color.fromARGB(255, 0, 0, 0),
                        fontSize: 15,
                      ),
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
