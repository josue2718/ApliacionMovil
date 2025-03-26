import 'package:carousel_slider/carousel_slider.dart';
import 'package:cateringmid/home/Search.dart';
import 'package:cateringmid/home/afertas.dart';
import 'package:cateringmid/home/api_service.dart';
import 'package:cateringmid/home/apicliente.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:keyboard_dismisser/keyboard_dismisser.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Empresa/empresa.dart';
import '../menu despegable/CustomDrawer.dart';
import 'package:shimmer/shimmer.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fetch Data with Infinite Scroll',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
            seedColor: const Color.fromARGB(255, 255, 255, 255)),
      ),
      home: MyHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageScreenState createState() => _MyHomePageScreenState();
}

class _MyHomePageScreenState extends State<MyHomePage> {
  int _backPressedCount = 0; // Contador para el número de intentos de retroceso
  final Apiclass api = Apiclass(); // Instancia de Apiclass
  final Apiclassdesucuentos apides = Apiclassdesucuentos();
  final ScrollController _scrollController = ScrollController();
  final ValueNotifier<int> _currentIndexNotifier = ValueNotifier<int>(0);
  bool isLoading = false;
  bool hasMore = true;
  int pageNumber = 1;
  bool inicio = true;
 final Apiclienteclass apicliente = Apiclienteclass();
   final ValueNotifier<bool> _hasNotification = ValueNotifier<bool>(false);
  @override
  void initState() {
    super.initState();
    api.fetchEmpresaData(pageNumber);
    apicliente.fetchclienteData();  
     FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _hasNotification.value = true; // Marcar que hay una nueva notificación
    });
  }
 
  void checkAndReload() async {
    if (api.empresas.isEmpty) {
      pageNumber = 1;
      print('Recargando datos porque la lista está vacía');
      await api.fetchEmpresaData(pageNumber);
      if (mounted) {
        setState(() {});
      }
    }
  }

  Future<void> _espetial(int tipo) async {
    try {
      await api.fetchEmpresatipo(tipo, 1);
      setState(() {
        api.loading = false; // Finaliza la carga
      });
    } catch (e) {
      print("Error al cargar empresas del tipo: $e");
      setState(() {
        api.loading = false; // Finaliza la carga incluso si hay error
      });
    }
  }

  void _llamarEspetial(int tipo) {
    _espetial(tipo);
  }

  @override
  void dispose() {
    _currentIndexNotifier.dispose(); // Libera el recurso
    _scrollController.dispose(); // Libera el controlador de scroll
    super.dispose();
  }

  Future<void> _onRefresh() async {
    setState(() {
      print('Actualizando datos...');

      api.fetchEmpresaData(pageNumber);
      hasMore = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _backPressedCount++;
        if (_backPressedCount == 1) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Presione nuevamente para salir'),
                backgroundColor: Color(0xFF670A0A)),
          );

          Future.delayed(const Duration(seconds: 2), () {
            setState(() {
              _backPressedCount = 0;
            });
          });
          return Future.value(false);
        } else {
          SystemNavigator.pop();
          return Future.value(true);
        }
      },
      child: KeyboardDismisser(
        child: Scaffold(
          backgroundColor: const Color.fromARGB(255, 255, 255, 255),
          body: FutureBuilder(
            future: Future.wait([
              apides.fetchDescuentosData(),
            ]),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
               
                 return _buildLoadingShimmer(); 
                
              }
              if (snapshot.hasError) {
                return Center(child: Text('Error: \${snapshot.error}'));
              }
              if (api.empresas.isEmpty) {
                Center(child: Text(''));
                print('recargando home');
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Recargando'),
                      backgroundColor: Color(0xFF670A0A),
                      duration: const Duration(seconds: 1),
                    ),
                  );
                });
                checkAndReload();
                return Center(child: Text(''));
              }
             
              return Scaffold(
                drawer: const CustomDrawer(),
                appBar: AppBar(
                  title: const Text('HOME'),
                  backgroundColor: const Color(0xFF670A0A),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  centerTitle: true,
                  toolbarHeight: 90,
                   actions: [
            ValueListenableBuilder<bool>(
              valueListenable: _hasNotification,
              builder: (context, hasNotification, child) {
                return Stack(
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.notifications,
                        color: Colors.white,
                        size: 30,
                      ),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Notificaciones')),
                        );
                        _hasNotification.value = false; // Marcar como leído
                      },
                    ),
                    if (hasNotification) // Si hay notificación, mostrar punto rojo
                      Positioned(
                        right: 8,
                        top: 1,
                        child: Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(255, 255, 255, 255),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
                  ],
                ),
                backgroundColor: const Color.fromARGB(255, 255, 255, 255),
                body: RefreshIndicator(
                  onRefresh: _onRefresh,
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 0),
                      child: Column(
                        children: [
                          const SizedBox(height: 20),
                          TextField(
                            readOnly:
                                true, // Evita que el teclado se abra directamente
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => SearchPage()),
                              );
                            },
                          decoration: InputDecoration(
                            labelText: "Buscar",
                            prefixIcon: Icon(Icons.search),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30), // Ajusta el radio según necesites
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: BorderSide(color: Colors.grey), // Color del borde cuando está inactivo
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: BorderSide(color:  Color(0xFF670A0A), width: 2), // Borde cuando está activo
                            ),
                          ),

                          ),
                          const SizedBox(height: 16),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Container(
                              alignment: Alignment.topLeft,
                              child: const Text(
                                'Ofertas de Hoy',
                                style: TextStyle(
                                  fontSize: 25,
                                  color: Color(0xFF670A0A),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: 400,
                            child: Column(
                              children: [
                                if (apides.descuentos.isNotEmpty)
                                  CarouselSlider.builder(
                                    itemCount: apides.descuentos.length,
                                    itemBuilder: (context, index, realIndex) {
                                      final descuento =
                                          apides.descuentos[index];
                                      return Container(
                                        width: 360,
                                        child: cardsofertas(
                                            link_imagen: descuento.linkImagen),
                                      );
                                    },
                                    options: CarouselOptions(
                                      height: 150,
                                      viewportFraction: 1.0,
                                      enlargeCenterPage: true,
                                      enableInfiniteScroll: true,
                                      autoPlay: true,
                                      autoPlayInterval:
                                          const Duration(seconds: 2),
                                      autoPlayAnimationDuration:
                                          const Duration(milliseconds: 800),
                                      scrollDirection: Axis.horizontal,
                                      onPageChanged: (index, reason) {
                                        _currentIndexNotifier.value = index;
                                      },
                                    ),
                                  ),
                                const SizedBox(height: 30),
                                ValueListenableBuilder<int>(
                                  valueListenable: _currentIndexNotifier,
                                  builder: (context, currentIndex, child) {
                                    return Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: List.generate(
                                        apides.descuentos.length,
                                        (index) => AnimatedContainer(
                                          duration:
                                              const Duration(milliseconds: 300),
                                          margin: const EdgeInsets.symmetric(
                                              horizontal: 2),
                                          width: currentIndex == index ? 16 : 8,
                                          height:
                                              currentIndex == index ? 16 : 8,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: currentIndex == index
                                                ? const Color(0xFF670A0A)
                                                : Colors.grey,
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 10),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Container(
                              alignment: Alignment.center,
                              child: const Text(
                                'Especialidades',
                                style: TextStyle(
                                  fontSize: 25,
                                  color: Color(0xFF670A0A),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          Options(onEspecialidadSelected: _llamarEspetial),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Container(
                              alignment: Alignment.topLeft,
                              child: const Text(
                                'Caterings',
                                style: TextStyle(
                                  fontSize: 25,
                                  color: Color(0xFF670A0A),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 0),
                          ListView.builder(
                            controller: _scrollController,
                            itemCount:
                                api.empresas.length + (isLoading ? 1 : 0),
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemBuilder: (context, index) {
                              if (index < api.empresas.length) {
                                final empresa = api.empresas[index];
                                return CardsEmpresa(
                                  link_logo: empresa.link_logo,
                                  nombre: empresa.nombre,
                                  min: empresa.min_personas,
                                  max: empresa.max_personas,
                                  id_emp: empresa.id_empresa,
                                  premin: empresa.premin,
                                  estrella: empresa.estrellas,
                                );
                              } else {
                                return const Padding(
                                  padding: EdgeInsets.all(16),
                                  child: Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                );
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingShimmer() {
  return SingleChildScrollView(
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
      child: Column(
        children: [
           Padding(
            padding: const EdgeInsets.symmetric(horizontal: 0),
            child: Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Container(
                height: 105,
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: 
          Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
              ),
            ),
          ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Container(
                height: 25,
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              width: 370,
              height: 140,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              5,
              (index) => Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[100]!,
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  width: 16,
                  height: 16,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Container(
                height: 25,
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.white,
                ),
              ),
            ),
          ),
           Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              4,
              (index) => 
          Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 20),
              width: 90,
              height: 70,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
          ),
            )
           ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Container(
                height: 25,
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: 0),
          ListView.builder(
            itemCount: 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                child: Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: Card(
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    color: Colors.white,
                    margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
                    child: Padding(
                      padding: const EdgeInsets.all(0),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          ClipRRect(
                            borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(20.0),
                              topLeft: Radius.circular(20.0),
                            ),
                            child: Container(
                              width: 130,
                              height: 130,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 25),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(height: 30, width: 100, color: Colors.white),
                                const SizedBox(height: 10),
                                Row(children: [
                                  const Icon(Icons.groups_sharp, color: Colors.grey, size: 25),
                                  const SizedBox(width: 10),
                                  Container(height: 15, width: 100, color: Colors.white),
                                ]),
                                const SizedBox(height: 2),
                                Row(children: [
                                  const Icon(Icons.room_service, color: Colors.grey, size: 25),
                                  const SizedBox(width: 10),
                                  Container(height: 15, width: 100, color: Colors.white),
                                ]),
                                const SizedBox(height: 2),
                                Row(children: [
                                  const Icon(Icons.star_rounded, color: Colors.grey, size: 23),
                                  const SizedBox(width: 10),
                                  Container(height: 15, width: 100, color: Colors.white),
                                ]),
                                const SizedBox(height: 5),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    ),
  );
}
}

class CardsEmpresa extends StatelessWidget {
  CardsEmpresa(
      {required this.link_logo,
      required this.nombre,
      required this.min,
      required this.max,
      required this.id_emp,
      required this.estrella,
      required this.premin});
  final String link_logo;
  final String nombre;
  final int min;
  final int max;
  final String id_emp;
  final int premin;
  final int estrella;

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
        child: Card(
          elevation: 5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          color: const Color.fromARGB(255, 255, 255, 255),
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CompanyPage(id_empresa: id_emp),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(0),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(20.0),
                        topLeft: Radius.circular(20.0)),
                    child: SizedBox(
                      width: 130,
                      height: 130,
                      child: Image.network(
                        link_logo,
                        fit: BoxFit.cover,
                        loadingBuilder: (BuildContext context, Widget child,
                            ImageChunkEvent? loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                  : null,
                              color: Color(0xFF670A0A),
                            ),
                          );
                        },
                        errorBuilder: (context, object, stackTrace) {
                          return const Icon(
                              Icons.error); // O una imagen de error
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 25),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                            nombre, // Usamos la variable que corresponde a la empresa
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                            maxLines: 1, // Limita el texto a una sola línea
                            overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 10),
                        Row(children: [
                          Icon(
                            Icons.groups_sharp,
                            color: Color.fromARGB(197, 112, 103, 103),
                            size: 25,
                          ),
                          SizedBox(width: 10),
                          Text(
                            '$min a $max Personas',
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color.fromARGB(197, 112, 103, 103),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ]),
                        SizedBox(height: 2),
                        Row(children: [
                          Icon(
                            Icons.room_service,
                            color: Color.fromARGB(197, 112, 103, 103),
                            size: 25,
                          ),
                          SizedBox(width: 10),
                          Text(
                            ' Menús desde \$$premin',
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color.fromARGB(197, 112, 103, 103),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ]),
                        SizedBox(height: 2),
                        Row(children: [
                          Icon(
                            Icons.star_rounded,
                            color: Color.fromARGB(197, 184, 166, 3),
                            size: 23,
                          ),
                          SizedBox(width: 10),
                          Text(
                            '$estrella Estrellas',
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color.fromARGB(197, 112, 103, 103),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ]),
                        SizedBox(height: 5),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ));
  }
}

class cardsofertas extends StatelessWidget {
  cardsofertas({required this.link_imagen});
  final String link_imagen;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        child: Image.network(
          link_imagen,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}

class Options extends StatelessWidget {
  final Function(int) onEspecialidadSelected;

  Options({required this.onEspecialidadSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 20),
      width: 355,
      height: 120,
      decoration: const BoxDecoration(
        color: Color.fromARGB(255, 255, 255, 255),
        shape: BoxShape.circle,
      ),
      child: ListView(scrollDirection: Axis.horizontal, children: <Widget>[

         Padding(
  padding: const EdgeInsets.only(right: 0),
  child: Column(
    children: [
      InkWell(
        onTap: () => onEspecialidadSelected(1), // Acción solo al presionar el círculo
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF670A0A), // Color de fondo rojo
            shape: BoxShape.circle, // Hace que el contenedor tenga forma circular
          ),
          padding: const EdgeInsets.all(15.0), // Espaciado interno para que el ícono no esté pegado al borde
          child: Icon(
            Icons.room_service, // Ícono de cumpleaños
            size: 38, // Ajusta el tamaño del ícono según tus necesidades
            color: Colors.white, // Color del ícono (blanco para que contraste con el rojo)
          ),
        ),
      ),
      const SizedBox(
        height: 20, // Espacio entre el ícono y el texto
      ),
      Text('Bodas'), // El texto no está envuelto en InkWell, no se activa con el toque
    ],
  ),
),

        SizedBox(
          width: 20,
        ),
        
         Padding(
  padding: const EdgeInsets.only(right: 0),
  child: Column(
    children: [
      InkWell(
        onTap: () => onEspecialidadSelected(2), // Acción solo al presionar el círculo
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF670A0A), // Color de fondo rojo
            shape: BoxShape.circle, // Hace que el contenedor tenga forma circular
          ),
          padding: const EdgeInsets.all(15.0), // Espaciado interno para que el ícono no esté pegado al borde
          child: Icon(
            Icons.room_service, // Ícono de cumpleaños
            size: 38, // Ajusta el tamaño del ícono según tus necesidades
            color: Colors.white, // Color del ícono (blanco para que contraste con el rojo)
          ),
        ),
      ),
      const SizedBox(
        height: 20, // Espacio entre el ícono y el texto
      ),
      Text('XV años'), // El texto no está envuelto en InkWell, no se activa con el toque
    ],
  ),
),

        SizedBox(
          width: 20,
        ),
         Padding(
  padding: const EdgeInsets.only(right: 0),
  child: Column(
    children: [
      InkWell(
        onTap: () => onEspecialidadSelected(3), // Acción solo al presionar el círculo
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF670A0A), // Color de fondo rojo
            shape: BoxShape.circle, // Hace que el contenedor tenga forma circular
          ),
          padding: const EdgeInsets.all(15.0), // Espaciado interno para que el ícono no esté pegado al borde
          child: Icon(
            Icons.room_service, // Ícono de cumpleaños
            size: 38, // Ajusta el tamaño del ícono según tus necesidades
            color: Colors.white, // Color del ícono (blanco para que contraste con el rojo)
          ),
        ),
      ),
      const SizedBox(
        height: 20, // Espacio entre el ícono y el texto
      ),
      Text('Eventos'), // El texto no está envuelto en InkWell, no se activa con el toque
    ],
  ),
),

       
        SizedBox(
          width: 20,
        ),
    Padding(
  padding: const EdgeInsets.only(right: 0),
  child: Column(
    children: [
      InkWell(
        onTap: () => onEspecialidadSelected(4), // Acción solo al presionar el círculo
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF670A0A), // Color de fondo rojo
            shape: BoxShape.circle, // Hace que el contenedor tenga forma circular
          ),
          padding: const EdgeInsets.all(15.0), // Espaciado interno para que el ícono no esté pegado al borde
          child: Icon(
            Icons.room_service, // Ícono de cumpleaños
            size: 38, // Ajusta el tamaño del ícono según tus necesidades
            color: Colors.white, // Color del ícono (blanco para que contraste con el rojo)
          ),
        ),
      ),
      const SizedBox(
        height: 20, // Espacio entre el ícono y el texto
      ),
      Text('Cumpleaños'), // El texto no está envuelto en InkWell, no se activa con el toque
    ],
  ),
),

        SizedBox(
          width: 20,
        ),
         Padding(
  padding: const EdgeInsets.only(right: 0),
  child: Column(
    children: [
      InkWell(
        onTap: () => onEspecialidadSelected(5), // Acción solo al presionar el círculo
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF670A0A), // Color de fondo rojo
            shape: BoxShape.circle, // Hace que el contenedor tenga forma circular
          ),
          padding: const EdgeInsets.all(15.0), // Espaciado interno para que el ícono no esté pegado al borde
          child: Icon(
            Icons.room_service, // Ícono de cumpleaños
            size: 38, // Ajusta el tamaño del ícono según tus necesidades
            color: Colors.white, // Color del ícono (blanco para que contraste con el rojo)
          ),
        ),
      ),
      const SizedBox(
        height: 20, // Espacio entre el ícono y el texto
      ),
      Text('Otros'), // El texto no está envuelto en InkWell, no se activa con el toque
    ],
  ),
),

      ]),
    );
  }
}
