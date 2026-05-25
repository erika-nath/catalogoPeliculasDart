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
    const String urlFondoCine = 'https://images.pexels.com/photos/18501410/pexels-photo-18501410.jpeg';

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
                    style: TextStyle(fontSize: 38, color: Color.fromARGB(255, 64, 128, 255), fontWeight: FontWeight.bold, letterSpacing: 2),
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
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('¡Usuario registrado!')));
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
  List<dynamic> listaPeliculasFirebase = [];

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

  Future<void> readFirebase() async {
    const String urlFirebase = 'https://apppeliculas-7c157-default-rtdb.firebaseio.com/favoritas.json';
    try {
      final respuesta = await http.get(Uri.parse(urlFirebase));

      if (respuesta.body == 'null' || respuesta.body.isEmpty) {
        setState(() {
          listaPeliculasFirebase = [];
        });
        return;
      }

      final Map<String, dynamic> datosDeNube = jsonDecode(respuesta.body);
      List<Map<String, dynamic>> listaTemporal = [];

      datosDeNube.forEach((id, datos) {
        if (datos != null) {
          String img = datos['imagen'] ?? '';
          if (img.isEmpty || !img.startsWith('http')) {
            img = 'https://m.media-amazon.com/images/M/MV_BYThjYzM3Y2UtZTE1Yi00MDMwLWI3MTQtYmFmNzNlMGQ2N2I1XkEyXkFqcGc@._V1_SX300.jpg';
          }

          listaTemporal.add({
            'id': id,
            'titulo': datos['titulo'] ?? 'Sin título',
            'imagen': img,
          });
        }
      });

      setState(() {
        listaPeliculasFirebase = listaTemporal;
      });
    } catch (error) {
      print('Error al leer: $error');
    }
  }

  Future<void> guardarEnFirebase() async {
    const String urlFirebase = 'https://apppeliculas-7c157-default-rtdb.firebaseio.com/favoritas.json';

    String imgFinal = (urlPosterPelicula.isEmpty || !urlPosterPelicula.startsWith('http'))
        ? 'https://m.media-amazon.com/images/M/MV_BYThjYzM3Y2UtZTE1Yi00MDMwLWI3MTQtYmFmNzNlMGQ2N2I1XkEyXkFqcGc@._V1_SX300.jpg'
        : urlPosterPelicula;

    try {
      await http.post(
        Uri.parse(urlFirebase),
        body: jsonEncode({
          'titulo': tituloPelicula,
          'imagen': imgFinal,
        }),
      );
      setState(() {
        mensajeFirebase = '¡Película guardada!';
      });
      readFirebase();
    } catch (error) {
      print('Error al guardar: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Movies Home', style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.blueAccent),
            onPressed: () async {
              await Navigator.push(context, MaterialPageRoute(builder: (context) => const PantallaAdmin()));
              readFirebase();
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16.0),
              child: const Text('Estrenos', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const PantallaDescripcion()));
                  },
                  child: cargando
                      ? const SizedBox(width: 100, height: 150, child: Center(child: CircularProgressIndicator()))
                      : Container(
                          width: 100,
                          height: 150,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            image: DecorationImage(image: NetworkImage(urlPosterPelicula), fit: BoxFit.cover),
                          ),
                        ),
                ),
                Container(width: 100, height: 150, color: Colors.grey[300]),
                Container(width: 100, height: 150, color: Colors.grey[300]),
              ],
            ),
            const Padding(
              padding: EdgeInsets.only(left: 16.0, top: 4),
              child: Text('(Toca el póster de Batman para ver detalles)', style: TextStyle(fontSize: 11, color: Colors.grey)),
            ),
            const SizedBox(height: 30),

            Center(
              child: Column(
                children: [
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.amber[700]),
                    onPressed: guardarEnFirebase,
                    icon: const Icon(Icons.cloud_upload, color: Colors.white),
                    label: const Text('Guardar en Firebase', style: TextStyle(color: Colors.white)),
                  ),
                  const SizedBox(height: 10),
                  Text(mensajeFirebase, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
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

                  if (listaPeliculasFirebase.isEmpty)
                    const Text('Base de datos vacía. ¡Dale guardar arriba!', style: TextStyle(color: Colors.grey)),

                  for (var peli in listaPeliculasFirebase)
                    Card(
                      elevation: 1,
                      margin: const EdgeInsets.symmetric(vertical: 4.0),
                      child: ListTile(
                        leading: Image.network(peli['imagen'], width: 45, height: 60, fit: BoxFit.cover, errorBuilder: (context, error, stackTrace) => const Icon(Icons.movie, size: 45)),
                        title: Text(peli['titulo'], style: const TextStyle(fontWeight: FontWeight.bold)),
                        trailing: const Icon(Icons.check_circle, color: Colors.green, size: 18),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.blueAccent,
        currentIndex: 1,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'Favoritos'),
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Buscador'),
        ],
      ),
    );
  }
}

class PantallaDescripcion extends StatelessWidget {
  const PantallaDescripcion({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detalle de la Película')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 120,
                height: 180,
                color: Colors.grey[300],
                child: const Image(
                  image: NetworkImage('https://m.media-amazon.com/images/M/MV_BYThjYzM3Y2UtZTE1Yi00MDMwLWI3MTQtYmFmNzNlMGQ2N2I1XkEyXkFqcGc@._V1_SX300.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text('Título: Batman', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const Text('Año: 1989', style: TextStyle(fontSize: 16)),
            const Text('Director: Tim Burton', style: TextStyle(fontSize: 16)),
            const Text('Género: Acción, Aventura', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 15),
            const Text('Sinopsis:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const Text('El caballero de la noche de Gotham City comienza su guerra contra el crimen con su primer gran enemigo: el Joker.', style: TextStyle(fontSize: 14)),
          ],
        ),
      ),
    );
  }
}

class PantallaAdmin extends StatefulWidget {
  const PantallaAdmin({super.key});

  @override
  State<PantallaAdmin> createState() => _PantallaAdminState();
}

class _PantallaAdminState extends State<PantallaAdmin> {
  final TextEditingController _tituloController = TextEditingController();
  final TextEditingController _imagenController = TextEditingController();
  List<dynamic> listaAdminFirebase = [];

  @override
  void initState() {
    super.initState();
    readAdminFirebase();
  }

  Future<void> readAdminFirebase() async {
    const String urlFirebase = 'https://apppeliculas-7c157-default-rtdb.firebaseio.com/favoritas.json';
    try {
      final respuesta = await http.get(Uri.parse(urlFirebase));
      if (respuesta.body == 'null' || respuesta.body.isEmpty) {
        setState(() { listaAdminFirebase = []; });
        return;
      }

      final Map<String, dynamic> datosDeNube = jsonDecode(respuesta.body);
      List<Map<String, dynamic>> listaTemporal = [];

      datosDeNube.forEach((id, datos) {
        if (datos != null) {
          String img = datos['imagen'] ?? '';
          if (img.isEmpty || !img.startsWith('http')) {
            img = 'https://m.media-amazon.com/images/M/MV_BYThjYzM3Y2UtZTE1Yi00MDMwLWI3MTQtYmFmNzNlMGQ2N2I1XkEyXkFqcGc@._V1_SX300.jpg';
          }

          listaTemporal.add({
            'id': id,
            'titulo': datos['titulo'] ?? 'Sin título',
            'imagen': img,
          });
        }
      });

      setState(() { listaAdminFirebase = listaTemporal; });
    } catch (error) {
      print('Error al leer en admin: $error');
    }
  }

  Future<void> subirPeliculaManual() async {
    const String urlFirebase = 'https://apppeliculas-7c157-default-rtdb.firebaseio.com/favoritas.json';
    if (_tituloController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Escribe el título primero.')));
      return;
    }
    String urlTexto = _imagenController.text.trim();
    String fotoFinal = (urlTexto.isEmpty || !urlTexto.startsWith('http'))
        ? 'https://m.media-amazon.com/images/M/MV_BYThjYzM3Y2UtZTE1Yi00MDMwLWI3MTQtYmFmNzNlMGQ2N2I1XkEyXkFqcGc@._V1_SX300.jpg'
        : urlTexto;

    try {
      await http.post(
        Uri.parse(urlFirebase),
        body: jsonEncode({
          'titulo': _tituloController.text,
          'imagen': fotoFinal,
        }),
      );

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('¡Película dada de alta con éxito!')));
      _tituloController.clear();
      _imagenController.clear();
      readAdminFirebase();
    } catch (e) {
      print('Error al guardar: $e');
    }
  }

  Future<void> borrarPeliculaEspecifica(String id) async {
    final String urlBorrar = 'https://apppeliculas-7c157-default-rtdb.firebaseio.com/favoritas/$id.json';
    try {
      await http.delete(Uri.parse(urlBorrar));
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Película eliminada correctamente.')));
      readAdminFirebase();
    } catch (e) {
      print('Error al borrar: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Panel de Administración')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Formulario de Altas', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blueAccent)),
            const SizedBox(height: 15),
            TextField(controller: _tituloController, decoration: const InputDecoration(labelText: 'Título de la película', border: OutlineInputBorder())),
            const SizedBox(height: 10),
            TextField(controller: _imagenController, decoration: const InputDecoration(labelText: 'URL de la Imagen (http://...)', border: OutlineInputBorder())),
            const SizedBox(height: 10),
            const TextField(decoration: InputDecoration(labelText: 'Año (Opcional)', border: OutlineInputBorder())),
            const SizedBox(height: 10),
            const TextField(decoration: InputDecoration(labelText: 'Director (Opcional)', border: OutlineInputBorder())),
            const SizedBox(height: 10),
            const TextField(decoration: InputDecoration(labelText: 'Género (Opcional)', border: OutlineInputBorder())),
            const SizedBox(height: 10),
            const TextField(decoration: InputDecoration(labelText: 'Sinopsis (Opcional)', border: OutlineInputBorder())),
            const SizedBox(height: 20),

            Center(
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green, padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12)),
                onPressed: subirPeliculaManual,
                icon: const Icon(Icons.add, color: Colors.white),
                label: const Text('Dar de Alta', style: TextStyle(color: Colors.white, fontSize: 16)),
              ),
            ),

            const Divider(height: 40),

            const Text('Películas Recién Agregadas / Control de Bajas:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.redAccent)),
            const SizedBox(height: 12),

            if (listaAdminFirebase.isEmpty)
              const Text('No hay películas en Firebase.', style: TextStyle(color: Colors.grey)),

            for (var peli in listaAdminFirebase)
              Card(
                elevation: 1,
                margin: const EdgeInsets.symmetric(vertical: 4.0),
                child: ListTile(
                  leading: Image.network(peli['imagen'], width: 45, height: 60, fit: BoxFit.cover, errorBuilder: (context, error, stackTrace) => const Icon(Icons.movie, size: 45)),
                  title: Text(peli['titulo'], style: const TextStyle(fontWeight: FontWeight.bold)),
                  // Bote de basura rojo exclusivo para dar de baja registros individuales
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => borrarPeliculaEspecifica(peli['id']),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}