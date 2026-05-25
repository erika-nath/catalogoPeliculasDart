import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Movie App',
      theme: ThemeData(useMaterial3: true),
      debugShowCheckedModeBanner: false,
      home: const PantallaInicio(),
    );
  }
}


class PantallaInicio extends StatelessWidget {
  const PantallaInicio({super.key});

  @override
  Widget build(BuildContext context) {
    const String urlFondoCine = 'https://images.pexels.com/photos/18501410/pexels-photo-18501410.jpeg?_gl=1*3ua68b*_ga*NjI1NTgxNzQ5LjE3NzkwNDEwMDY.*_ga_8JE65Q40S6*czE3Nzk2NTM1NjQkbzQkZzEkdDE3Nzk2NTM9OTgkajYwJGwwJGgw';

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(urlFondoCine),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Container(color: Colors.black.withOpacity(0.6)),

          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Buenas pelis',
                    style: TextStyle(
                      fontSize: 38,
                      color: Color.fromARGB(255, 64, 128, 255),
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'El lugar donde estan las mejores pelis',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18, color: Colors.white, fontStyle: FontStyle.italic),
                  ),
                  const SizedBox(height: 40),

                  TextField(
                    decoration: InputDecoration(
                      labelText: 'Correo electrónico',
                      labelStyle: const TextStyle(color: Colors.black87),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.9),
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Contraseña',
                      labelStyle: const TextStyle(color: Colors.black87),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.9),
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 30),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: const Color.fromARGB(255, 68, 87, 255)),
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => const HomeMovieScreen()));
                        },
                        child: const Text('Ingresar', style: TextStyle(color: Colors.white)),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.grey[800]),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('¡Usuario registrado!')),
                          );
                        },
                        child: const Text('Registrarse', style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

//HOME widgets
class HomeMovieScreen extends StatefulWidget {
  const HomeMovieScreen({super.key});

  @override
  State<HomeMovieScreen> createState() => _HomeMovieScreenState();
}

class _HomeMovieScreenState extends State<HomeMovieScreen> {
  String urlPosterPelicula = '';
  String tituloPelicula = 'Cargando...';
  bool cargando = true;
  String mensajeFirebase = '';
  List<String> listaPeliculasFirebase = [];

  @override
  void initState() {
    super.initState();
    requestMovie();
    readFirebase();
  }

  Future<void> requestMovie() async {
    const String urlApi = 'https://www.omdbapi.com/?t=Batman&apikey=21957d09';

    try {
      final respuesta = await http.get(Uri.parse(urlApi));

      if (respuesta.statusCode == 200) {
        final datosContestados = jsonDecode(respuesta.body);

        setState(() {
          urlPosterPelicula = datosContestados['Poster'];
          tituloPelicula = datosContestados['Title'];
          cargando = false;
        });
      }
    } catch (error) {
      setState(() {
        tituloPelicula = 'Error en servidor';
        cargando = false;
      });
    }
  }

  //Funcion Firebase
Future<void> readFirebase() async {
    const String urlFirebase = 'https://apppeliculas-7c157-default-rtdb.firebaseio.com/favoritas.json';
final respuesta = await http.get(Uri.parse(urlFirebase));
if (respuesta.body == 'null') {
      return;
    }

    final Map<String, dynamic> datosDeNube = jsonDecode(respuesta.body);

    List<String> listaTemporal = [];

    for (var pelicula in datosDeNube.values) {
      listaTemporal.add(pelicula['titulo']);
    }

    // Actualizamos la pantalla con los nuevos títulos
    setState(() {
      listaPeliculasFirebase = listaTemporal;
    });
  }

  Future<void> guardarEnFirebase() async {
 const String urlFirebase = 'https://apppeliculas-7c157-default-rtdb.firebaseio.com/favoritas.json';
    await http.post(
      Uri.parse(urlFirebase),
      body: jsonEncode({
        'titulo': tituloPelicula,
      }),
    );

    setState(() {
      mensajeFirebase = 'Película guardada';
    });
    readFirebase();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Movies Home',
          style: TextStyle(
            color: Colors.blueAccent,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16.0),
              child: const Text(
                'Estrenos',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                cargando
                    ? const SizedBox(
                        width: 100,
                        height: 150,
                        child: Center(child: CircularProgressIndicator()),
                      )
                    : Stack(
                        alignment: Alignment.topRight,
                        children: [
                          Container(
                            width: 100,
                            height: 150,
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              image: DecorationImage(
                                image: NetworkImage(urlPosterPelicula),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Container(
                            color: Colors.blue,
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: const Text(
                              'Nuevo',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                Container(width: 100, height: 150, color: Colors.grey[300]),
                Container(width: 100, height: 150, color: Colors.grey[300]),
              ],
            ),

  const SizedBox(height: 30),

            // btn firebase
            Center(
              child: Column(
                children: [
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.amber[700]),
                    onPressed: guardarEnFirebase, // Llama a la función de Firebase
                    icon: const Icon(Icons.cloud_upload, color: Colors.white),
                    label: const Text('Guardar en Firebase', style: TextStyle(color: Colors.white)),
                  ),
                  const SizedBox(height: 10),

            Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Text(
                      mensajeFirebase,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
                    ),
              ),

          ],
        ),
            ),
const Divider(height: 30),
Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Películas en mi Base de Datos:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                                    for (var nombre in listaPeliculasFirebase)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Text('• $nombre', style: const TextStyle(fontSize: 16, color: Colors.black87)),
                    ),
                ],
              ),
            ),
          ], // Cierre del children de la Column principal
        ), // Cierre de la Column principal
      ), // Cierre

      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.blueAccent,
        currentIndex: 0, //deja prendido el icono de home
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Favoritos',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Buscador'),
        ],
      ),
 ); // Cierre del Scaffold
  } // Cierre del método Widget build
} // Cie
