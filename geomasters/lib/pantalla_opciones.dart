import 'package:flutter/material.dart';
import 'package:geomasters/credenciales/inicio_sesion.dart';
import 'package:geomasters/credenciales/progreso_screen.dart';
import 'package:geomasters/modos/banderas.dart';
import 'package:geomasters/modos/capitales.dart';
import 'package:geomasters/servicios/storage_service.dart';

class PantallaOpciones extends StatefulWidget {
  const PantallaOpciones({super.key});

  @override
  _PantallaOpcionesState createState() => _PantallaOpcionesState();
}

class _PantallaOpcionesState extends State<PantallaOpciones>
    with SingleTickerProviderStateMixin {
  final StorageService _storageService = StorageService();
  bool isLoggedIn = false;

  late AnimationController _controller;
  late Animation<Alignment> _logoPositionAnimation;

  @override
  void initState() {
    super.initState();
    checkLoginStatus();

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

  Future<void> checkLoginStatus() async {
    bool loggedIn = await _storageService.isLoggedIn();
    setState(() {
      isLoggedIn = loggedIn;
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
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Espacio para empujar los botones hacia el centro
                      const Spacer(flex: 5),
                      // Botón "Jugar con banderas"
                      ElevatedButton(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const BanderasScreen()),
                        ),
                        child: const Text('Jugar con banderas'),
                      ),
                      const SizedBox(height: 20),
                      // Botón "Jugar con capitales"
                      ElevatedButton(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const CapitalesScreen()),
                        ),
                        child: const Text('Jugar con capitales'),
                      ),
                      // Espacio para empujar el botón de progreso hacia abajo
                      const Spacer(flex: 2),
                      // Botón de inicio de sesión y progreso según el estado de login
                      ElevatedButton(
                        onPressed: () async {
                          if (isLoggedIn) {
                            // Si ya está logueado, ir a la pantalla de progreso
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const ProgresoScreen()),
                            );
                          } else {
                            // Si no está logueado, ir a la pantalla de inicio de sesión
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const InicioSesionScreen()),
                            );
                          }

                          // Después de regresar, verificar el estado de inicio de sesión
                          await checkLoginStatus();
                        },
                        child: Text(
                            isLoggedIn ? 'Ver Progreso' : 'Iniciar Sesión'),
                      ),
                      const SizedBox(height: 20), // Espacio adicional en la parte inferior
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