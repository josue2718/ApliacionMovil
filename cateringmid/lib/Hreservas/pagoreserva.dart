import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MercadoPagoScreen extends StatefulWidget {
  @override
  _MercadoPagoScreenState createState() => _MercadoPagoScreenState();
}

class _MercadoPagoScreenState extends State<MercadoPagoScreen> {
  String preferenceId = "";

  Future<void> crearPreferencia() async {
    var url = Uri.parse("https://cateringmidd.azurewebsites.net/api/pagos/crear-preferencia");
    var response = await http.post(url);

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      setState(() {
        preferenceId = data["id"];
      });

     String urlPago = "$preferenceId";
print(urlPago);
        await launch(urlPago, forceSafariVC: false, forceWebView: false);



    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Pago con Mercado Pago")),
      body: Center(
        child: ElevatedButton(
          onPressed: crearPreferencia,
          child: Text("Pagar con Mercado Pago"),
        ),
      ),
    );
  }
}
