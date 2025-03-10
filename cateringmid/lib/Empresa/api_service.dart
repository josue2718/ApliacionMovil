import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http; // Importar el paquete http
import 'dart:convert'; // Para trabajar con JSON

class Servicios 
{
  int id_tipo;

  Servicios({
    required this.id_tipo
  });

  factory Servicios.fromJson(Map<String, dynamic> json) {
    return Servicios(
      id_tipo: json['id_tipo_servicio']
    );
  }

   @override
  String toString() {
    return 'Empresa(tipo: $id_tipo)';
  }
}

class Empresa {
  String idEmpresa;
  String idPropietario;
  String nombre;
  String email;
  String telefono;
  String direccion;
  double latitud;
  double longitud;
  bool mobiliario;
  bool blancos;
  bool personal;
  bool cristaleria;
  bool chef;
  bool meseros;
  bool vyl;
  int minPersonas;
  int maxPersonas;
  String informacion;
  String horainicio;
  String horafin;
  String diainicio;
  String diafin;
  String linkLogo;
  int premin;
  int estrellas;
  String nombrepropietario;
  String apellidopropietario;
  String zona;
  String ciudad;

  Empresa({
    required this.idEmpresa,
    required this.idPropietario,
    required this.nombre,
    required this.email,
    required this.telefono,
    required this.direccion,
    required this.latitud,
    required this.longitud,
    required this.mobiliario,
    required this.blancos,
    required this.personal,
    required this.cristaleria,
    required this.chef,
    required this.meseros,
    required this.vyl,
    required this.minPersonas,
    required this.maxPersonas,
    required this.informacion,
    required this.horainicio,
    required this.horafin ,
    required this.diainicio,
    required this.diafin,
    required this.linkLogo,
    required this.premin,
    required this.estrellas,
    required this.nombrepropietario,
    required this.apellidopropietario,
    required this.zona,
    required this.ciudad,
  });

  factory Empresa.fromJson(Map<String, dynamic> json) {
    return Empresa(
      idEmpresa: json['id_empresa'],
      idPropietario: json['id_propietario'],
      nombre: json['nombre'],
      email: json['email'],
      telefono: json['telefono'],
      direccion: json['direccion'],
      latitud: json['latitud'].toDouble(),
      longitud: json['longitud'].toDouble(),
      mobiliario: json['mobiliario'],
      blancos: json['blancos'],
      personal: json['personal'],
      cristaleria: json['cristaleria'],
      chef: json['chef'],
      meseros: json['meseros'],
      vyl: json['vyl'],
      minPersonas: json['min_personas'],
      maxPersonas: json['max_personas'],
      informacion: json['informacion'],
      horainicio: json['horainicio'],
      horafin: json['horafin'],
      diainicio: json['diainicio'],
      diafin: json['diafin'],
      linkLogo: json['link_logo'],
      premin: json['premin'],
      estrellas: json['estrellas'],
      nombrepropietario: json['nombrepropietario'],
      apellidopropietario: json['apellidopropietario'],
      zona:json['zona'],
      ciudad: json['ciudad']
    );
  }

  @override
  String toString() {
    return 'Empresa(nombre: $nombre, direccion: $direccion, telefono: $telefono, max_personas: $maxPersonas, min_personas: $minPersonas, id_empresa: $idEmpresa)';
  }
}



class Apiempresaclass {
  List<Empresa> empresas = [];  // Lista de empresas
  List <Servicios> servicios =[];
  int pageNumber = 1;
  bool isLoading = false;
  bool hasMore = true;

  Future<void> fetchEmpresaIDData(String id_empresa) async {
  if (isLoading || !hasMore) return;

  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('token');

  if (token == null || token.isEmpty) {
    return;
  }

  final headers = {
    'Authorization': 'Bearer $token',
  };

  try {
    isLoading = true;
    final response = await http.get(
      Uri.parse(
        'https://cateringmidd.azurewebsites.net/api/Empresa/${id_empresa}',
      ),
      headers: headers,
    );

    if (response.statusCode == 200) {

      final jsonResponse = json.decode(response.body);
      empresas.clear();
      servicios.clear();
      empresas.add(Empresa.fromJson(jsonResponse)); // Solo una empresa
        final List<dynamic> data = jsonResponse['empresaTipoServicios'] ?? [];

        servicios.addAll(data.map((item) => Servicios.fromJson(item)).toList());

    } else if (response.statusCode == 401) {

     
    } else {
      throw Exception('Error al cargar datos: ${response.statusCode}');
    }
  } catch (e) {

  } finally {
    isLoading = false;
  }
}


}



