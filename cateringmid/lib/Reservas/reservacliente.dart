
import 'package:cateringmid/Reservas/reservaubicacion.dart';
import 'package:flutter/material.dart';
import 'dart:convert'; // Para trabajar con JSON
import 'package:keyboard_dismisser/keyboard_dismisser.dart';
import 'dart:async';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:cateringmid/Reservas/reservamodelo.dart';
import 'package:cateringmid/Empresa/date.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CateringMID',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 255, 255, 255)),
        useMaterial3: true,
      ),
      home: Reserva(id_empresa: '',),
      debugShowCheckedModeBanner: false,
        locale: const Locale('es', ''), 
    );
  }
}


class Reserva extends StatefulWidget  {
  const Reserva({super.key, required this.id_empresa});
  final String id_empresa;
  @override
  _ReservaState createState() => _ReservaState();


  
}


class _ReservaState extends State<Reserva> {
  final _formKey = GlobalKey<FormState>(); // Clave para el formulario
  final _usernameController = TextEditingController();
  final _userphoneController = TextEditingController();
  final _username2Controller =TextEditingController();
  final _userphone2Controller =TextEditingController();
  final _timeController = TextEditingController();
  ReservasProvider reserva =ReservasProvider();
   final Apidateempresaclass  apidate = Apidateempresaclass();
  TextEditingController _userdateController = TextEditingController();
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  bool isLoading = false;


  void _login() async {
    if (_formKey.currentState?.validate() ?? false) {
    Provider.of<ReservasProvider>(context, listen: false)
    .actualizardatosclienter(
      _usernameController.text, 
      _username2Controller.text,
      _userphoneController.text, 
      _userphone2Controller.text,
      _userdateController.text,
      _timeController.text,
      
    );

    
    Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => Reservaubicacion(id_empresa:widget.id_empresa ))); // Reemplaza `YourPage` con la página actual
    
  }
  }
  
  void fetchMoreData() async {
    if (isLoading) return; // Si ya estamos cargando, no hacer nada más

    setState(() {
      isLoading = true;
    });

    try {} catch (e) {
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _showCalendarDialog(BuildContext context) async {
  await showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog( // Usa un AlertDialog para el diálogo
        content: SizedBox( // Ajusta el tamaño del calendario
          width: 300,
          height: 400,
          child: TableCalendar(
            calendarFormat: _calendarFormat,
            focusedDay: _focusedDay,
            firstDay: DateTime.utc(2010, 1, 1),
            lastDay: DateTime.utc(2030, 12, 30),
            selectedDayPredicate: (day) {
              return apidate.date
                  .map((dateObj) => DateTime.parse(dateObj.fecha)) // Convierte el String a DateTime
                  .any((date) => isSameDay(date, day)); // Compara si alguna fecha coincide con 'day'// Verifica si alguna fecha coincide con 'day'

            },
            calendarStyle: CalendarStyle(
              // Estilo general para todos los días
              todayDecoration: BoxDecoration(
                color:  Color(0xFF670A0A), // Color para el día de hoy
                shape: BoxShape.circle,
              ),
              selectedDecoration: BoxDecoration(
                color:  Color.fromARGB(255, 241, 184, 184), // Color para los días seleccionados
                shape: BoxShape.circle,
              ),
            ),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
                _userdateController.text = DateFormat('yyyy-MM-dd').format(selectedDay); // Formatea la fecha
              });
              Navigator.pop(context); // Cierra el diálogo al seleccionar una fecha
            }, 
            onFormatChanged: (format) {
              setState(() {
                _calendarFormat = format;
              });
            },
            onPageChanged: (focusedDay) {
              _focusedDay = focusedDay;
            },
          ),
          
        ),
      );
    },
  );
}
  
  Future<void> _selectTime(BuildContext context) async {
  final TimeOfDay? picked = await showTimePicker(
    context: context,
    initialTime: TimeOfDay.now(),
    builder: (BuildContext context, Widget? child) {
      return MediaQuery(
        data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
        child: child!,
      );
    },
  );

  if (picked != null) {
    setState(() {
       _timeController.text = '${picked.hour}:${picked.minute.toString().padLeft(2, '0')}';
      });

  }


}
  void initState() {
    super.initState();
    apidate.fetchEmpresaIDData(widget.id_empresa); 
  }

  @override
  Widget build(BuildContext context) {
    final reservasProvider = Provider.of<ReservasProvider>(context, listen: false);
    
     if (reservasProvider.primerNombre != null && reservasProvider.primerNombre!.isNotEmpty) {
  _usernameController.text = reservasProvider.primerNombre!;
}

if (reservasProvider.segundoNombre != null && reservasProvider.segundoNombre!.isNotEmpty) {
  _username2Controller.text = reservasProvider.segundoNombre!;
}

if (reservasProvider.primerTelefono != null && reservasProvider.primerTelefono!.isNotEmpty) {
  _userphoneController.text = reservasProvider.primerTelefono!;
}

if (reservasProvider.segundoTelefono != null && reservasProvider.segundoTelefono!.isNotEmpty) {
  _userphone2Controller.text = reservasProvider.segundoTelefono!;
}



    return KeyboardDismisser(
      child: Scaffold(
      appBar: AppBar(
            title: const Text('Reservacion'),
            backgroundColor: const Color(0xFF670A0A),
            foregroundColor: Colors.white,
            elevation: 0,
            centerTitle: true,
            toolbarHeight: 90,
            
          ),
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
     resizeToAvoidBottomInset: true, 
      body:  SingleChildScrollView(
        child: Padding(
        padding: const EdgeInsets.all(30),
        child: Form(
          key: _formKey,
          child: Column(
              children: [
                _bar(),
                 const SizedBox(height: 30),
                _paso(),
                const SizedBox(height: 30),
                _datosentrega(),
                const SizedBox(height: 30),
                _datoshora(),
              const SizedBox(height: 70),
              // Botón de login
              _button(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
      )
    )
  ); 
}
Widget _button()
{
  return ElevatedButton(
    onPressed: ()
    {
      
       if (_userdateController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Por favor seleccione una fecha'),backgroundColor: const Color(0xFF670A0A)));
      } 
      else
      if (_timeController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Por favor seleccione una hora'),backgroundColor: const Color(0xFF670A0A)));
      }
      else
      {
        _login();
      } 
      
    },
    style: ElevatedButton.styleFrom(
        fixedSize: const Size(300, 50), // Ancho fijo de 250 y alto de 50
        backgroundColor:  const Color(0xFF670A0A),
        foregroundColor: const Color.fromARGB(255, 240, 239, 239),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('Siguiente'),
        ],
      ),
  );
}

Widget _paso()
  {
  return Padding(
  padding: const EdgeInsets.symmetric(horizontal: 20, vertical:0 ),
      child: Column(
        children: [
          Container(
            alignment: Alignment.center,
            child: Column(
              children: [
                Text(
                  'Paso 2 de 4', // Usamos la variable que corresponde a la empresa
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontSize: 23,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF670A0A),
                      ),
                
              ),
              const SizedBox(width: 10),
            ]),
          ),
        ],
      ),
    );
  }

Widget _bar()
{
  return Padding(
  padding: const EdgeInsets.symmetric(horizontal: 40, vertical:0 ),
  child:  
    Row(
      children: [
        Column(
          children: [
            Row(
              children: [
                Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFF670A0A), // Estado actual
                ),
                ),
                Container(
                  width: 60,
                  height: 2,
                  color: Color(0xFF670A0A), // Estado actual
                ),
              ],
            ),
           
          ],
        ),
        Column(
          children: [
            Row(
              children: [
                Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFF670A0A), // Estado actual
                ),
                ),
                Container(
                  width: 60,
                  height: 2,
                  color:  Colors.grey, // Estado actual
                ),
              ],
            ),
           
          
          ],
        ),
         Column(
          children: [
            Row(
              children: [
                Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey, // Estado actual
                ),
                ),
                Container(
                  width: 60,
                  height: 2,
                  color: Colors.grey, // Estado actual
                ),
              ],
            ),
           
          ],
        ),
         Column(
          children: [
            Row(
              children: [
                Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey, // Estado actual
                ),
                ),
               
              ],
            ),
            
          ],
        ),
    
      ]
    )
  );
}

Widget _datosentrega()
  {
    return Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
        Container(
          alignment: Alignment.topLeft,
          child: Column(
            children: [
            Text(
              'Datos de Cliente', // Usamos la variable que corresponde a la empresa
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF670A0A),
                  ),
            ), 
            
          ]),
        ), 
      const SizedBox(height: 20),
      TextFormField(
        controller: _usernameController,
        decoration: const InputDecoration(
          labelText: 'Nombre del destinatario',
          border: UnderlineInputBorder(),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.grey), // Cambia el color de la línea inferior al enfocar
          ),
            suffixIcon: Icon(
            Icons.person,
            color :Color.fromARGB(255, 112, 110, 110), // Cambia el color si está enfocado
          ),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Por favor ingrese un nombre ';
          }
          return null;
        },
      ),
      const SizedBox(height: 20),
      TextFormField(
        controller: _userphoneController,
        keyboardType: TextInputType.phone,
        decoration: const InputDecoration(
          labelText: 'Teléfono del destinatario',
          border: UnderlineInputBorder(),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.grey), // Cambia el color de la línea inferior al enfocar
          ),
            suffixIcon: Icon(
            Icons.phone,
            color :Color.fromARGB(255, 112, 110, 110), // Cambia el color si está enfocado
          ),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Por favor ingrese un telefono';
          }
          if (!RegExp(r'^\d{10}$').hasMatch(value)) {
            return 'El teléfono debe tener exactamente 10 dígitos';
          }
    return null;
        },
      ),
      const SizedBox(height: 20),
      TextFormField(
        controller: _username2Controller,
        decoration: const InputDecoration(
          labelText: 'Nombre del contacto adicional',
          border: UnderlineInputBorder(),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.grey), // Cambia el color de la línea inferior al enfocar
          ),
            suffixIcon: Icon(
            Icons.person,
            color :Color.fromARGB(255, 112, 110, 110), // Cambia el color si está enfocado
          ),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Por favor ingrese un nombre';
          }
          return null;
        },
      ),
      const SizedBox(height: 20),
      TextFormField(
        controller:  _userphone2Controller,
        keyboardType: TextInputType.phone,
        decoration: const InputDecoration(
          labelText: 'Teléfono alternativo',
          border: UnderlineInputBorder(),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.grey), // Cambia el color de la línea inferior al enfocar
          ),
            suffixIcon: Icon(
            Icons.phone,
            color :Color.fromARGB(255, 112, 110, 110), // Cambia el color si está enfocado
          ),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Por favor ingrese un telefono';
          }
          if (!RegExp(r'^\d{10}$').hasMatch(value)) {
            return 'El teléfono debe tener exactamente 10 dígitos';
          }
          return null;
        },
      )
    ]
    );
  }
  
  Widget _datoshora()
  {
    return Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
        Container(
          alignment: Alignment.topLeft,
          child: Column(
            children: [
            Text(
              'Fecha y hora', // Usamos la variable que corresponde a la empresa
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF670A0A),
                  ),
            ), 
            
          ]),
        ), 
      const SizedBox(height: 20),
      InkWell( // Widget interactivo para mostrar la fecha
            onTap: () => _showCalendarDialog(context),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
              border: Border(
              bottom: BorderSide(color: Colors.grey), // Solo borde inferior
        ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                _userdateController.text.isEmpty // Muestra un texto si no hay fecha seleccionada
                    ? 'Seleccionar fecha'
                    : _userdateController.text,
              ),
              
            ),
            const Icon(Icons.calendar_today,color :Color.fromARGB(255, 112, 110, 110)), // Cambia el color si está enfocado),
          ],
        ),
      ),
      ),
        const SizedBox(height: 20),
      InkWell( // Widget interactivo para mostrar la fecha
      onTap: () => _selectTime(context),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          border: Border(
          bottom: BorderSide(color: Colors.grey), // Solo borde inferior
        ),
        
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                _timeController.text.isEmpty // Muestra un texto si no hay fecha seleccionada
                    ? 'Seleccionar hora'
                    : _timeController.text,
              ),
              
            ),
            const Icon(Icons.access_time_outlined,color :Color.fromARGB(255, 112, 110, 110)), // Cambia el color si está enfocado),
          ],
        ),
      ),
      ),

    ]
    );
  }

}




