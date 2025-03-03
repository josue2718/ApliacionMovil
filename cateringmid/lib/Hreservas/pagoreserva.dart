import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:stripe_payment/stripe_payment.dart';

void main() {
  runApp(MyApp());
  initStripe();
}

void initStripe() {
  StripePayment.setOptions(StripeOptions(
    publishableKey: 'pk_test_51QyhK8Fb8qYvObz7viMNWKSjHycljmPPZ7khhFPT0hWMYciV1HEgwRa9eMFh3FPQhpsgvB5AFeeRWcPLXTLxeSk400W4zvlNat', // Tu clave pública de Stripe
    merchantId: 'Test',
    androidPayMode: 'test', // Configura 'test' para pruebas y 'production' para producción
  ));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Stripe Payment',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: PaymentPage(),
    );
  }
}

class PaymentPage extends StatefulWidget {
  @override
  _PaymentPageState createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pago con Stripe'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            await makePayment();
          },
          child: Text('Realizar pago'),
        ),
      ),
    );
  }

  Future<String> createPaymentIntent(int amount, String currency) async {
    final response = await http.post(
      Uri.parse('https://cateringmidd.azurewebsites.net/api/Payment/create-payment-intent'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'amount': amount,
        'currency': currency,
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      // Asegurarse de que clientSecret no sea nulo
      if (data['clientSecret'] != null) {
        return data['clientSecret']; // Extraer el clientSecret
      } else {
        throw Exception('ClientSecret es nulo');
      }
    } else {
      throw Exception('Error al crear PaymentIntent');
    }
  }

  Future<void> makePayment() async {
    try {
      // Paso 1: Crear PaymentIntent en el backend
      String clientSecret = await createPaymentIntent(1000, 'mxn'); // 1000 = $10 MXN

      // Paso 2: Solicitar detalles de la tarjeta del cliente
      StripePayment.paymentRequestWithCardForm(CardFormPaymentRequest()).then((paymentMethod) async {
        // Verificar que paymentMethod.id no sea nulo
        if (paymentMethod.id != null) {
          // Paso 3: Confirmar el pago con el PaymentMethod y clientSecret
          PaymentIntentResult result = await confirmPayment(clientSecret, paymentMethod.id!);

          if (result.status == 'succeeded') {
            print('Pago exitoso!');
            // Mostrar un mensaje de éxito o hacer cualquier otra lógica
          } else {
            print('Pago fallido: ${result.status}');
            // Manejar el fallo de pago
          }
        } else {
          print('Error: paymentMethod.id es nulo');
        }
      }).catchError((error) {
        print('Error al obtener los detalles de la tarjeta: $error');
      });
    } catch (e) {
      print('Error al hacer el pago: $e');
    }
  }

  // Paso 3: Confirmar el pago con clientSecret y paymentMethodId
  Future<PaymentIntentResult> confirmPayment(String clientSecret, String paymentMethodId) async {
    return await StripePayment.confirmPaymentIntent(
      PaymentIntent(
        clientSecret: clientSecret,
        paymentMethodId: paymentMethodId,
      ),
    );
  }
}