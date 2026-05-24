import 'package:flutter/material.dart';

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
      home:  Welcome(),
    );
  }
}

//layout
class Welcome extends StatelessWidget{
const Welcome({super.key});
@override
Widget build(BuildContext context){
  return const Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Text(
        'Buenas pelis',
        style: TextStyle(
          fontSize: 38,
          color: Colors.amberAccent,
          letterSpacing: 2,
        ),
        ),
        SizedBox(height: 12),
        Text(
'El lugar donde estan las mejores pelis',
textAlign: TextAlign.center,
style: TextStyle(
  fontSize: 16,
            color: Colors.white70,
            fontStyle: FontStyle.italic,
),

        )

  ],
  );

}

}

//HOME widgets
class HomeMovieScreen extends StatelessWidget {
  const HomeMovieScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Movies Home',
        style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold),
        ),
      backgroundColor: Colors.white,
      elevation: 0,
      ),
      body: SingleChildScrollView(
       child:Column(
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
                  Container(
                    width:100,
                    height: 150,
                    color: Colors.grey[300],
                  ),
                  Container(
                    color:Colors.blue,
                     padding: const EdgeInsets.symmetric(horizontal:4),
                     child: const Text(
                      'Nuevo',
                      style: TextStyle(color: Colors.white, fontSize: 12)
                     ),
                  ),
                ],
              ),
              Container(width: 100, height: 150, color: Colors.grey[300]),
              Container(width: 100, height: 150, color: Colors.grey[300]),
          ],)
       ],)
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.blueAccent,
        currentIndex: 0, //deja prendido el icono de home
        items: const [
           BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Favoritos',
          ),
         BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Buscador',
          ),

        ],
      ),

    );

  }
}

