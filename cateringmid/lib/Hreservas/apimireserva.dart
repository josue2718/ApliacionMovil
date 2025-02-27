import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http; // Importar el paquete http
import 'dart:convert'; // Para trabajar con JSON

class InfoClienteClass {
  String idInfo;
  String idReserva;
  String primerNombre;
  String segundoNombre;
  String primerTelefono;
  String segundoTelefono;

  InfoClienteClass({
    required this.idInfo,
    required this.idReserva,
    required this.primerNombre,
    required this.segundoNombre,
    required this.primerTelefono,
    required this.segundoTelefono,
  });

  // Convertir JSON a un objeto InfoClienteClass
  factory InfoClienteClass.fromJson(Map<String, dynamic> json) {
    return InfoClienteClass(
      idInfo: json['id_info'],
      idReserva: json['id_reserva'],
      primerNombre: json['primer_nombre'],
      segundoNombre: json['segundo_nombre'],
      primerTelefono: json['primer_telefono'],
      segundoTelefono: json['segundo_telefono'],
    );
  }

  // Convertir un objeto InfoClienteClass a JSON
  Map<String, dynamic> toJson() {
    return {
      'id_info': idInfo,
      'id_reserva': idReserva,
      'primer_nombre': primerNombre,
      'segundo_nombre': segundoNombre,
      'primer_telefono': primerTelefono,
      'segundo_telefono': segundoTelefono,
    };
  }

  @override
  String toString() {
    return 'InfoClienteClass(idInfo: $idInfo, primerNombre: $primerNombre, primerTelefono: $primerTelefono)';
  }
}

class StatusClass {
  bool enviado;
  bool aceptado;
  bool pago;
  bool preparando;
  bool enviando;
  bool completado;
  bool cancelado;

  StatusClass({
    required this.enviado,
    required this.aceptado,
    required this.pago,
    required this.preparando,
    required this.enviando,
    required this.completado,
    required this.cancelado,
  });

  // Convertir JSON a un objeto StatusClass
  factory StatusClass.fromJson(Map<String, dynamic> json) {
    return StatusClass(
      enviado: json['enviado'],
      aceptado: json['aceptado'],
      pago: json['pago'],
      preparando: json['preparando'],
      enviando: json['enviando'],
      completado: json['completado'],
      cancelado: json['cancelado'],
    );
  }

  // Convertir un objeto StatusClass a JSON
  Map<String, dynamic> toJson() {
    return {
      'enviado': enviado,
      'aceptado': aceptado,
      'pago': pago,
      'preparando': preparando,
      'enviando': enviando,
      'completado': completado,
      'cancelado': cancelado,
    };
  }

  @override
  String toString() {
    return 'StatusClass( enviado: $enviado)';
  }
}
class DireccionClass {
  String idDireccion;
  String idReserva;
  double latitud;
  double longitud;
  String direccion;
  String nombreLugar;
  String numCasa;
  String referencias;

  DireccionClass({
    required this.idDireccion,
    required this.idReserva,
    required this.latitud,
    required this.longitud,
    required this.direccion,
    required this.nombreLugar,
    required this.numCasa,
    required this.referencias,
  });

  // Convertir JSON a un objeto DireccionClass
  factory DireccionClass.fromJson(Map<String, dynamic> json) {
    return DireccionClass(
      idDireccion: json['id_direccion'],
      idReserva: json['id_reserva'],
      latitud: json['latitud'].toDouble(),
      longitud: json['longitud'].toDouble(),
      direccion: json['direccion'],
      nombreLugar: json['nombre_lugar'],
      numCasa: json['num_casa'],
      referencias: json['referencias'],
    );
  }

  // Convertir un objeto DireccionClass a JSON
  Map<String, dynamic> toJson() {
    return {
      'id_direccion': idDireccion,
      'id_reserva': idReserva,
      'latitud': latitud,
      'longitud': longitud,
      'direccion': direccion,
      'nombre_lugar': nombreLugar,
      'num_casa': numCasa,
      'referencias': referencias,
    };
  }

  @override
  String toString() {
    return 'DireccionClass(idDireccion: $idDireccion, calle: $direccion, nombreLugar: $nombreLugar)';
  }
}

class MenuClass {
  String menuNombre;
  int menuCantidad;

  MenuClass({
    required this.menuNombre,
    required this.menuCantidad,
  });

  // Convertir JSON a un objeto MenuClass
  factory MenuClass.fromJson(Map<String, dynamic> json) {
    return MenuClass(
      menuNombre: json['menuNombre'],
      menuCantidad: json['menucantidad'],
    );
  }

  // Convertir un objeto MenuClass a JSON
  Map<String, dynamic> toJson() {
    return {
      'menuNombre': menuNombre,
      'menucantidad': menuCantidad,
    };
  }

  @override
  String toString() {
    return 'MenuClass(menuNombre: $menuNombre, menuCantidad: $menuCantidad)';
  }
}


class Mireservas {
  String idReserva;
  String idCliente;
  String idEmpresa;
  String empresaNombre;
  String empresaLogo;
  String fecha;
  String hora;
  double costo;
  double anticipo;
  String horas;
  String contrato;
  bool mobiliario;
  bool blancos;
  bool personal;
  bool cristaleria;
  bool chef;
  bool meseros;
  int cantidadmeseros;
  Mireservas({
    required this.idReserva,
    required this.idCliente,
    required this.idEmpresa,
    required this.empresaNombre,
    required this.empresaLogo,
    required this.fecha,
    required this.hora,
    required this.costo,
    required this.anticipo,
    required this.horas,
    required this.contrato,
    required this.mobiliario,
    required this.blancos,
    required this.personal,
    required this.cristaleria,
    required this.chef,
    required this.meseros,
    required this.cantidadmeseros
  });

  // Convertir JSON a un objeto Mireservas
  factory Mireservas.fromJson(Map<String, dynamic> json) {
    return Mireservas(
      idReserva: json['id_reserva'],
      idCliente: json['id_cliente'],
      idEmpresa: json['id_empresa'],
      empresaNombre: json['empresaNombre'],
      empresaLogo: json['empresalogo'],
      fecha: json['fecha'],
      hora: json['hora'],
      costo: json['costo'],
      anticipo:json['anticipo'],
      horas: json['horas'],
      contrato: json['contrato'],
      mobiliario: json['mobiliario'],
      blancos: json['blancos'],
      personal: json['personal'],
      cristaleria: json['cristaleria'],
      chef: json['chef'],
      meseros: json['meseros'],
      cantidadmeseros:json['cantidadmeseros']
    );
  }

  // Convertir un objeto Mireservas a JSON
  Map<String, dynamic> toJson() {
    return {
      'id_reserva': idReserva,
      'id_cliente': idCliente,
      'id_empresa': idEmpresa,
      'empresaNombre': empresaNombre,
      'empresalogo': empresaLogo,
      'fecha': fecha,
      'hora': hora,
      'costo': costo,
      'anticipo': anticipo,
      'horas': horas,
      'contrato': contrato,
      'mobiliario': mobiliario,
      'blancos': blancos,
      'personal': personal,
      'cristaleria': cristaleria,
      'chef': chef,
      'meseros': meseros,
      "cantidadmeseros":cantidadmeseros
    };
  }

  @override
  String toString() {
    return 'Mireservas(idReserva: $idReserva, empresaNombre: $empresaNombre, fecha: $fecha, hora: $hora)';
  }
}


class Apimireserva {
  //List<Menusinfo> menuinfo = [];  // Lista de empresas
  List<Mireservas> inforeserva =[]; 
   List<InfoClienteClass> infocliente =[]; 
   List<DireccionClass> infodireccion =[]; 
   List<StatusClass> infoestatus =[];
    List<MenuClass> infomenu =[]; 
  int pageNumber = 1;
  bool isLoading = false;
  bool hasMore = true;

  Future<void> fetchMenuinfoData(String id_reserva) async {
  if (isLoading || !hasMore) return;

  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('token');

  final headers = {
    'Authorization': 'Bearer $token',
  };

  try {
    isLoading = true;
    final response = await http.get(
      Uri.parse(
        'https://cateringmidd.azurewebsites.net/api/Reservas/Id/$id_reserva',
      ),
      headers: headers,
    );


    if (response.statusCode == 200) {

       final jsonResponse = json.decode(response.body);

        inforeserva.clear();
        infocliente.clear();
        infodireccion.clear();
        infomenu.clear();
        inforeserva.add(Mireservas.fromJson(jsonResponse));
        //infocliente.add(InfoClienteClass.fromJson(jsonResponse['reserva_Info_Cliente']));
        infodireccion.add(DireccionClass.fromJson(jsonResponse['reserva_direccions'][0]));
        infocliente.add(InfoClienteClass.fromJson(jsonResponse['reserva_Info_Clientes'][0]));
        infoestatus.add(StatusClass.fromJson(jsonResponse['estatus_Reservas'][0]));
        
      final List<dynamic> data = jsonResponse['hMenu_Reservas'] ?? [];

        // Agregar las imágenes filtradas a la lista
        infomenu.addAll(data.map((item) => MenuClass.fromJson(item)).toList());

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


