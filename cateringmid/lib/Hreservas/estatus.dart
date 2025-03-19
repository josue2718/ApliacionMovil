import 'package:cateringmid/Hreservas/hreservas.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Apiestatus {
  String preferenceId = "";

  Future<void> cancelar(
      {required String id_reserva,
      required String id_estatus,
      required String fecha,
      required bool pagado,
      required BuildContext context}) async {
    print('eliminando');
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final urlCliente = Uri.parse(
        'https://cateringmid.azurewebsites.net/api/Reservas/Estatus/${id_reserva}');
    final responseCliente = await http.put(
      urlCliente,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode({
        "id_reserva": id_reserva,
        "estatus_Reservas": [
          {
            "id_estatus": id_reserva,
            "id_reserva": id_reserva,
            "enviado": true,
            "aceptado": true,
            "pago": true,
            "preparando": false,
            "enviando": false,
            "entregado": false,
            "confirmado": false,
            "completado": false,
            "cancelado": true,
          }
        ],
      }),
    );
    print(responseCliente.body);
    if (responseCliente.statusCode == 204) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => HreservaPage(),
        ),
      );
    } else {}
  }

  Future<void> eliminar(
      {required String id_reserva, required BuildContext context}) async {
    print('eliminando  ${id_reserva}');
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final urlCliente = Uri.parse(
        'https://cateringmid.azurewebsites.net/api/Reservas/${id_reserva}');
    final responseCliente = await http.delete(
      urlCliente,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );
    print(responseCliente.body);
    if (responseCliente.statusCode == 204) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => HreservaPage(),
        ),
      );
    } else {}
  }
}
