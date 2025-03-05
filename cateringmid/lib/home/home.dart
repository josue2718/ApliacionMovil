import 'package:carousel_slider/carousel_slider.dart';
import 'package:cateringmid/home/Search.dart';
import 'package:cateringmid/home/afertas.dart';
import 'package:cateringmid/home/api_service.dart';
import 'package:cateringmid/home/apicliente.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:keyboard_dismisser/keyboard_dismisser.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Empresa/empresa.dart';
import '../menu despegable/CustomDrawer.dart';

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
  @override
  void initState() {
    super.initState();
    api.fetchEmpresaData(pageNumber);
    apicliente.fetchclienteData();  
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
                return const Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFF670A0A),
                    backgroundColor: Color.fromARGB(255, 255, 255, 255),
                  ),
                );
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
                    TextButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Notificaciones')),
                        );
                      },
                      icon: const Icon(
                        Icons.notifications,
                        color: Colors.white,
                        size: 30,
                      ),
                      label: Text(''),
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
        InkWell(
          onTap: () => onEspecialidadSelected(1),
          child: Padding(
            padding: const EdgeInsets.only(right: 0),
            child: Column(
              children: [
                ClipOval(
                  child: Image.asset(
                    'assets/incono.png',
                    fit: BoxFit.cover,
                    width: 70, // Ajusta el ancho según tus necesidades
                    height: 70, //
                  ),
                ),
                const SizedBox(
                    height: 20), // Espacio entre la imagen y el texto
                Text('Bodas'),
              ],
            ),
          ),
        ),
        SizedBox(
          width: 20,
        ),
        InkWell(
          onTap: () => onEspecialidadSelected(2),
          child: Padding(
            padding: const EdgeInsets.only(right: 0),
            child: Column(
              children: [
                ClipOval(
                  child: Image.asset(
                    'assets/incono.png',
                    fit: BoxFit.cover,
                    width: 70, // Ajusta el ancho según tus necesidades
                    height: 70, //
                  ),
                ),
                const SizedBox(
                    height: 20), // Espacio entre la imagen y el texto
                Text('XV años'),
              ],
            ),
          ),
        ),
        SizedBox(
          width: 20,
        ),
        InkWell(
          onTap: () => onEspecialidadSelected(3),
          child: Padding(
            padding: const EdgeInsets.only(right: 0),
            child: Column(
              children: [
                ClipOval(
                  child: Image.asset(
                    'assets/incono.png',
                    fit: BoxFit.cover,
                    width: 70, // Ajusta el ancho según tus necesidades
                    height: 70, //
                  ),
                ),
                const SizedBox(
                    height: 20), // Espacio entre la imagen y el texto
                Text('Eventos'),
              ],
            ),
          ),
        ),
        SizedBox(
          width: 20,
        ),
        InkWell(
          onTap: () => onEspecialidadSelected(4),
          child: Padding(
            padding: const EdgeInsets.only(right: 0),
            child: Column(
              children: [
                ClipOval(
                  child: Image.asset(
                    'assets/incono.png',
                    fit: BoxFit.cover,
                    width: 70, // Ajusta el ancho según tus necesidades
                    height: 70, //
                  ),
                ),
                const SizedBox(
                    height: 20), // Espacio entre la imagen y el texto
                Text('Cumpleaños'),
              ],
            ),
          ),
        ),
        SizedBox(
          width: 20,
        ),
        InkWell(
          onTap: () => onEspecialidadSelected(5),
          child: Padding(
            padding: const EdgeInsets.only(right: 0),
            child: Column(
              children: [
                ClipOval(
                  child: Image.asset(
                    'assets/incono.png',
                    fit: BoxFit.cover,
                    width: 70, // Ajusta el ancho según tus necesidades
                    height: 70, //
                  ),
                ),
                const SizedBox(
                    height: 20), // Espacio entre la imagen y el texto
                Text('Otros'),
              ],
            ),
          ),
        ),
      ]),
    );
  }
}
