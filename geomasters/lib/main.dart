import 'package:flutter/material.dart';
import 'package:geomasters/banderas.dart';
import 'package:geomasters/capitales.dart';


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
      theme: ThemeData(primarySwatch: Colors.blue),
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
      backgroundColor: Colors.white,
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

class PantallaOpciones extends StatefulWidget {
  const PantallaOpciones({super.key});

  @override
  _PantallaOpcionesState createState() => _PantallaOpcionesState();
}

class _PantallaOpcionesState extends State<PantallaOpciones>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Alignment> _logoPositionAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 700),
      vsync: this,
    );

    // Configuración de la animación de posición del logo
    _logoPositionAnimation = AlignmentTween(
      begin: Alignment.center,
      end: const Alignment(0, -0.8),
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    // Inicia la animación del logo
    _controller.forward().then((_) {
      setState(() {}); // Refresca para mostrar los botones tras la animación
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Stack(
            children: [
              // Logo animado
              Align(
                alignment: _logoPositionAnimation.value,
                child: Image.asset(
                  'assets/logo.png',
                  width: 300, // Mantiene el tamaño constante
                  height: 300, // Mantiene el tamaño constante
                ),
              ),
              if (_controller.isCompleted)
                Align(
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Botón "Jugar con banderas"
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/banderas');
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 20),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                          textStyle: const TextStyle(fontSize: 18),
                        ),
                        child: const Text('Banderas'),
                      ),
                      const SizedBox(width: 20),
                      // Botón "Jugar con capitales"
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/capitales');
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 20),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                          textStyle: const TextStyle(fontSize: 18),
                        ),
                        child: const Text('Capitales'),
                      ),
                    ],
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
