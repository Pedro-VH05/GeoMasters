import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geomasters/servicios/storage_service.dart';

class ProgresoScreen extends StatefulWidget {
  const ProgresoScreen({super.key});

  @override
  _ProgresoScreenState createState() => _ProgresoScreenState();
}

class _ProgresoScreenState extends State<ProgresoScreen> {
  final StorageService _storageService = StorageService();
  List<Map<String, dynamic>> gameHistory = [];

  @override
  void initState() {
    super.initState();
    cargarHistorial();
  }

  Future<void> cargarHistorial() async {
    var user = await _storageService.getLoggedInUser();
    setState(() {
      gameHistory = user?['games'] != null
          ? List<Map<String, dynamic>>.from(
              jsonDecode(jsonEncode(user!['games'])))
          : [];
    });
  }

  Future<void> cerrarSesion() async {
    await _storageService.logout();
    Navigator.pop(context);
  }

  // Función para formatear la fecha
  String formatDate(String isoDate) {
    DateTime date = DateTime.parse(isoDate).toLocal();
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    // Filtrar partidas por tipo de juego
    List<Map<String, dynamic>> capitalesGames = gameHistory
        .where((game) => game['game'] == 'capitales')
        .toList();
    List<Map<String, dynamic>> banderasGames = gameHistory
        .where((game) => game['game'] == 'banderas')
        .toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Mi progreso')),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween, // Distribuir elementos
        children: [
          Expanded(
            child: gameHistory.isEmpty
                ? const Center(child: Text('No hay partidas registradas'))
                : ListView(
                    padding: const EdgeInsets.all(16.0),
                    children: [
                      // Sección de Capitales
                      const Text(
                        'Capitales',
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      ...capitalesGames.map((game) {
                        return Card(
                          elevation: 2,
                          margin: const EdgeInsets.only(bottom: 10),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${game['score']} aciertos',
                                  style: const TextStyle(
                                      fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  'Tiempo: ${game['time']} segundos',
                                  style: const TextStyle(fontSize: 14),
                                ),
                                Text(
                                  'Fecha: ${formatDate(game['date'])}',
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),

                      const SizedBox(height: 20), // Espacio entre secciones

                      // Sección de Banderas
                      const Text(
                        'Banderas',
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      ...banderasGames.map((game) {
                        return Card(
                          elevation: 2,
                          margin: const EdgeInsets.only(bottom: 10),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${game['score']} aciertos',
                                  style: const TextStyle(
                                      fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  'Tiempo: ${game['time']} segundos',
                                  style: const TextStyle(fontSize: 14),
                                ),
                                Text(
                                  'Fecha: ${formatDate(game['date'])}',
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ],
                            ),
                          ),
                        );
                      })
                    ],
                  ),
          ),

          // Footer con créditos
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
            color: const Color.fromARGB(255, 227, 234, 241), // Color de fondo del footer
            child: const Column(
              children: [
                Text(
                  'Creado por Pedro Vigara Haro',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 5),
                Text(
                  'Versión 1.0 | Derechos reservados',
                  style: TextStyle(fontSize: 14, color: Colors.black54),
                ),
              ],
            ),
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: cerrarSesion,
        child: const Icon(Icons.logout),
      ),
    );
  }
}
