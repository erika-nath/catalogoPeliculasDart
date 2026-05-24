import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // Root
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Movie App',
      theme: ThemeData(useMaterial3: true),
      debugShowCheckedModeBanner: false,
      home: Welcome(),
    );
  }
}

//layout
class Welcome extends StatelessWidget {
  const Welcome({super.key});

  Widget welcomeText() {
    return const Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Buenas pelis',
          style: TextStyle(
            fontSize: 38,
            color: Color.fromARGB(255, 64, 128, 255),
            letterSpacing: 2,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 12),
        Text(
          'El lugar donde estan las mejores pelis',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 20,
            color: Color.fromARGB(253, 255, 255, 255),
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    const String urlBackgroundCine =
        'https://images.pexels.com/photos/18501410/pexels-photo-18501410.jpeg?_gl=1*3ua68b*_ga*NjI1NTgxNzQ5LjE3NzkwNDEwMDY.*_ga_8JE65Q40S6*czE3Nzk2NTM1NjQkbzQkZzEkdDE3Nzk2NTM5OTgkajYwJGwwJGgw';
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(urlBackgroundCine),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Container(color: Colors.white.withOpacity(0.6)),

          Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  welcomeText(),
                  const SizedBox(height: 40),

                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 68, 87, 255),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 15
                      ),
                      ),
                      onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const HomeMovieScreen()),
                      );
                    },
                    child: const Text('Ver Catálogo', style: TextStyle(color: Colors.white, fontSize: 18)),
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

  @override
  void initState() {
    super.initState();
    requestMovie();
  }
Future<void> requestMovie() async {
    const String urlApi = 'https://www.omdbapi.com/?t=Batman&apikey=21957d09';

    try {
      final respuesta = await http.get(Uri.parse(urlApi));

      if (respuesta.statusCode == 200) {
        final datosContestados = jsonDecode(respuesta.body);
//Debugueo
        print('Cuerpo completo de la API: ${respuesta.body}');
        print('Título recuperado: ${datosContestados['Title']}');
        print('Link del póster: ${datosContestados['Poster']}');

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
                Stack(
                  alignment: Alignment.topRight,
                  children: [
                    Container(width: 100, height: 150, color: Colors.grey[300]),
                    Container(
                      color: Colors.blue,
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: const Text(
                        'Nuevo',
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ),
                  ],
                ),
                Container(width: 100, height: 150, color: Colors.grey[300]),
                Container(width: 100, height: 150, color: Colors.grey[300]),
              ],
            ),
          ],
        ),
      ),
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
    );
  }
}
