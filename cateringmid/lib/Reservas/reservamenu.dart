
import 'dart:ffi';

import 'package:flutter/material.dart';
import 'dart:convert';

class Menus {
  String idMenuEmpresa;
  String idEmpresa;
  String nombre;
  String linkImagen;
  double precio;
  int minPersonas;
  int maxPersonas;
  int cantidad;

  Menus({
    required this.idMenuEmpresa,
    required this.idEmpresa,
    required this.nombre,
    required this.linkImagen,
    required this.precio,
    required this.minPersonas,
    required this.maxPersonas,
    required this.cantidad,
  });

  @override
  String toString() {
    return 'Menus(idMenuEmpresa: $idMenuEmpresa, idEmpresa: $idEmpresa, nombre: $nombre, precio: $precio, minPersonas: $minPersonas, maxPersonas: $maxPersonas)';
  }
}

class Menusreservas {
  String idMenuEmpresa;
  int cantidadt;
  double costo;
  Menusreservas({
    required this.idMenuEmpresa,
    required this.cantidadt,
    required this.costo
  });
   Map<String, dynamic> toJson() => {"id_menu_empresa": idMenuEmpresa, "cantidad": cantidadt};
  @override
  String toString() {
    return 'Menusreserva(idMenuEmpresa: $idMenuEmpresa, cantidad: $cantidadt)';
  }
}
class MenusR
{
  static final MenusR _instance = MenusR._internal();
  factory MenusR() {
    return _instance;
  }
  MenusR._internal();
  final List<Menusreservas> _menureserva = [];
  List<Menusreservas> get menureserva => _menureserva;

  void eliminarPorId(BuildContext context, String idMenuEmpresa) {
    int index = _menureserva.indexWhere((menu) => menu.idMenuEmpresa == idMenuEmpresa);

    if (index != -1) {
      _menureserva.removeAt(index);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Menú eliminado'),
          backgroundColor: Color(0xFF670A0A),
          duration: const Duration(seconds: 1),
        ),
      );

    } else {
     
    }
  }
  // Agregar menú, ahora recibe el contexto para mostrar el SnackBar
  void add({
    required BuildContext context, // Agregar parámetro de contexto
    required String idMenuEmpresa,
    required int cantidad,
    required double costo

  }) {
    if (_menureserva.any((m) => m.idMenuEmpresa == idMenuEmpresa)) {
       final index = _menureserva.indexWhere((m) => m.idMenuEmpresa == idMenuEmpresa);
       _menureserva[index].cantidadt = cantidad;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ya está añadido'),
          duration: const Duration(seconds: 1),
          backgroundColor: Color(0xFF670A0A),
        ),
      );
      return;
    }


final newMenureserva = Menusreservas(
      idMenuEmpresa: idMenuEmpresa,
      cantidadt: cantidad,
      costo: costo,

    );
    _menureserva.add(newMenureserva);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Menú agregado'),
        backgroundColor: Color(0xFF670A0A),
        duration: const Duration(seconds: 1),
      ),
    );

  }

  // Eliminar menú por ID, también recibe el contexto para mostrar el SnackBar

  void limpiar()
  {
    _menureserva.clear();
  }

}

class ReservaMenu  with ChangeNotifier {
  static final ReservaMenu _instance = ReservaMenu._internal();
  factory ReservaMenu() {
    return _instance;
  }
  ReservaMenu._internal();
  final List<Menus> _menu = [];
  List<Menus> get menu => _menu;




  // Agregar menú, ahora recibe el contexto para mostrar el SnackBar
  void add({
    required BuildContext context, // Agregar parámetro de contexto
    required String idMenuEmpresa,
    required String idEmpresa,
    required String nombre,
    required String linkImagen,
    required double precio,
    required int minPersonas,
    required int maxPersonas,
    required int cantidad,
    
    
  }) {
    if (_menu.any((m) => m.idMenuEmpresa == idMenuEmpresa)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ya está añadido'),
          duration: const Duration(seconds: 1), 
          backgroundColor: Color(0xFF670A0A),
        ),
      );
   
      return;
    }

    final newMenu = Menus(
      idMenuEmpresa: idMenuEmpresa,
      idEmpresa: idEmpresa,
      nombre: nombre,
      linkImagen: linkImagen,
      precio: precio,
      minPersonas: minPersonas,
      maxPersonas: maxPersonas,
      cantidad: cantidad,
      
    );

    _menu.add(newMenu);
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Menú agregado'),
        backgroundColor: Color(0xFF670A0A),
        duration: const Duration(seconds: 1), 
        
      ),
    );
   notifyListeners(); 
  }

  // Eliminar menú por ID, también recibe el contexto para mostrar el SnackBar
  void eliminarPorId(BuildContext context, String idMenuEmpresa) {
    int index = _menu.indexWhere((menu) => menu.idMenuEmpresa == idMenuEmpresa);

    if (index != -1) {
      _menu.removeAt(index);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Menú eliminado'),
          backgroundColor: Color(0xFF670A0A),
          duration: const Duration(seconds: 1), 
        ),
      );

    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Menú no encontrado'),
          backgroundColor: Color(0xFF670A0A),
        ),
      );

    }
  }
  void limpiar()
  {
    _menu.clear();
  }
}
