import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';

class ProgresoScreen extends StatefulWidget {
  const ProgresoScreen({super.key});

  @override
  _ProgresoScreenState createState() => _ProgresoScreenState();
}

class _ProgresoScreenState extends State<ProgresoScreen> {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  List<Map<String, dynamic>> _progreso = [];

  @override
  void initState() {
    super.initState();
    _cargarProgreso();
  }

  Future<void> _cargarProgreso() async {
    String? progresoString = await _storage.read(key: 'user_progress');
    if (progresoString != null) {
      setState(() {
        _progreso = List<Map<String, dynamic>>.from(jsonDecode(progresoString));
      });
    }
  }

  Future<void> _borrarProgreso() async {
    await _storage.delete(key: 'user_progress');
    setState(() {
      _progreso = [];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mi Progreso')),
      body: _progreso.isEmpty
          ? const Center(child: Text('No hay progreso registrado'))
          : Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                children: [
                  Expanded(
                    child: ListView(
                      children: _progreso.map((partida) {
                        return Card(
                          child: ListTile(
                            title: Text('Fecha: ${partida['fecha']}'),
                            subtitle: Text(
                                'Modo: ${partida['modo']} - Aciertos: ${partida['aciertos']} - Tiempo: ${partida['tiempo']}'),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _borrarProgreso,
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    child: const Text('Borrar Progreso'),
                  ),
                ],
              ),
            ),
    );
  }
}
