import 'package:flutter/material.dart';
import 'pantalla_opciones.dart';
import 'package:geomasters/modos/banderas.dart';
import 'package:geomasters/modos/capitales.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const BanderasCapitalesApp());
}

class BanderasCapitalesApp extends StatelessWidget {
  const BanderasCapitalesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Banderas y Capitales',
      theme: ThemeData(
        // Colores principales
        primaryColor: const Color(0xFF8CACA4), // Verde suave
        colorScheme: ColorScheme.light(
          primary: const Color(0xFF8CACA4), // Verde suave
          secondary: const Color(0xFFB4A4AC), // Morado suave
          surface: const Color.fromARGB(255, 227, 234, 241), // Gris azulado claro (reemplaza background por surface)
        ),

        // Fuente personalizada
        fontFamily: 'Roboto', // Puedes cambiar 'Roboto' por la fuente que prefieras
        textTheme: const TextTheme(
          titleLarge: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black), // Reemplaza headline6 por titleLarge
          bodyLarge: TextStyle(fontSize: 18, color: Colors.black87), // Reemplaza bodyText1 por bodyLarge
          bodyMedium: TextStyle(fontSize: 16, color: Colors.black87), // Reemplaza bodyText2 por bodyMedium
          labelLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white), // Reemplaza button por labelLarge
        ),

        // Estilo de los botones
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF8CACA4), // Reemplaza primary por backgroundColor
            foregroundColor: Colors.white, // Color del texto del botón
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8), // Bordes redondeados
            ),
          ),
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const PantallaInicial(),
        '/banderas': (context) => const BanderasScreen(),
        '/capitales': (context) => const CapitalesScreen(),
      },
    );
  }
}

class PantallaInicial extends StatelessWidget {
  const PantallaInicial({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface, // Usa el color de fondo del tema
      body: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            PageRouteBuilder(
              transitionDuration: const Duration(milliseconds: 1000),
              pageBuilder: (context, animation, secondaryAnimation) =>
                  const PantallaOpciones(),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                return FadeTransition(opacity: animation, child: child);
              },
            ),
          );
        },
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Logo centrado
                  Image.asset(
                    'assets/logo.png',
                    width: 300,
                    height: 300,
                  ),
                  const SizedBox(height: 20),
                  // Texto "Pulsa para iniciar"
                  const Text(
                    'Pulsa para iniciar',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}