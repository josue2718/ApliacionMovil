import 'package:cateringmid/Hreservas/consts.dart';
import 'package:cateringmid/Hreservas/stripe_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http; 
import 'dart:convert';

void main() async {
  
  Stripe.publishableKey = stripePublishableKey;
  await _setup();
  runApp(MyApp());

}

Future<void> _setup() async
{
  WidgetsFlutterBinding.ensureInitialized();
  Stripe.publishableKey= stripePublishableKey;
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
            StripeService.instance.makePayment();
          },
          child: Text('Realizar pago'),
        ),
      ),
    );
  }
}