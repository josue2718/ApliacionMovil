import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http; // Importar el paquete http
import 'dart:convert'; // Para trabajar con JSON

class P {
  String idGastronomia;
  String idMenuEmpresa;
  int idTipoGastronomia;
  String nombre;
  double costo;
  String descripcion;
  String linkImagen;

  P({
    required this.idGastronomia,
    required this.idMenuEmpresa,
    required this.idTipoGastronomia,
    required this.nombre,
    required this.costo,
    required this.descripcion,
    required this.linkImagen,
  });

  factory P.fromJson(Map<String, dynamic> json) {
    return P(
      idGastronomia: json['id_gastronomia'],
      idMenuEmpresa: json['id_menu_empresa'],
      idTipoGastronomia: json['id_tipo_gastronomia'],
      nombre: json['nombre'],
      costo: json['costo'],
      descripcion: json['descripcion'],
      linkImagen: json['link_imagen'],
    );
  }
  @override
  String toString() {
    return 'gastronomia(nombre: $nombre, costo: $costo, imagen: $linkImagen';
  }
}

class Misreservas {
  String fecha;
  String hora;
  String Nempresa;
  String idreserva;

  Misreservas({
    required this.fecha,
    required this.hora,
    required this.Nempresa,
    required this.idreserva,
   
  });

  // Convertir JSON a un objeto Menus
  factory Misreservas.fromJson(Map<String, dynamic> json) {
    return Misreservas(
      fecha: json['fecha'],
      hora: json['hora'],
      Nempresa: json['empresaNombre'],
      idreserva : json['id_reserva']
     
    );
  }

  // Convertir un objeto Menus a JSON
  Map<String, dynamic> toJson() {
    return {
      'id_reserva' : idreserva,
      'fecha': fecha,
      'hora': hora,
      'empresaNombre':Nempresa
    };
  }

  @override
  String toString() {
    return 'Menu(nombre: $hora, id_empresa: $fecha)';
  }
}


class Apimireserva {
  //List<Menusinfo> menuinfo = [];  // Lista de empresas
  List<Misreservas> misreservas =[]; 
  int pageNumber = 1;
  bool isLoading = false;
  bool hasMore = true;

  var inforeservas;

  Future<void> fetchMenuinfoData() async {
  if (isLoading || !hasMore) return;

  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('token');
  final id_cliente = prefs.getString('id');
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
        'https://cateringmidd.azurewebsites.net/api/Reservas/Cliente/$id_cliente',
      ),
      headers: headers,
    );

    if (response.statusCode == 200) {

      final List<dynamic> jsonResponse = json.decode(response.body);
      misreservas.clear(); 
      misreservas.addAll(jsonResponse.map((item) => Misreservas.fromJson(item)).toList());


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