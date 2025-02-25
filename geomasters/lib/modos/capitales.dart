import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'package:geomasters/servicios/storage_service.dart';

class CapitalesScreen extends StatefulWidget {
  const CapitalesScreen({super.key});

  @override
  _CapitalesScreenState createState() => _CapitalesScreenState();
}

class _CapitalesScreenState extends State<CapitalesScreen> {
  final StorageService _storageService = StorageService();
  List<Map<String, String>> countries = [];
  List<Map<String, String>> selectedCountries = []; // Lista de 20 países únicos
  int currentIndex = 0; // Índice de la pregunta actual
  String currentCountry = '';
  String correctCapital = '';
  List<String> options = [];
  int score = 0;
  int elapsedSeconds = 0;
  Timer? timer;
  String? selectedOption; // Opción seleccionada por el usuario

  @override
  void initState() {
    super.initState();
    fetchCountries();
    startTimer();
  }

  Future<void> fetchCountries() async {
    final url =
        Uri.parse('https://countriesnow.space/api/v0.1/countries/capital');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      List<dynamic> countryData = data['data'];

      List<Map<String, String>> fetchedCountries = [];

      for (var country in countryData) {
        if (country['capital'] != null &&
            country['capital'].toString().isNotEmpty) {
          fetchedCountries.add({
            'country': country['name'],
            'capital': country['capital'],
          });
        }
      }

      setState(() {
        countries = fetchedCountries..shuffle(); // Mezclar la lista
        selectedCountries = countries.take(20).toList(); // Tomar 20 países únicos
        nextQuestion();
      });
    } else {
      throw Exception('Error al obtener datos de la API');
    }
  }

  void startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        elapsedSeconds++;
      });
    });
  }

  void stopTimer() {
    timer?.cancel();
  }

  String formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  void nextQuestion() async {
    if (currentIndex >= selectedCountries.length) {
      stopTimer();
      await _storageService.saveGameResult('capitales', score, elapsedSeconds);
      Navigator.pop(context);
      return;
    }

    final selectedCountry = selectedCountries[currentIndex];

    setState(() {
      currentCountry = selectedCountry['country']!;
      correctCapital = selectedCountry['capital']!;
      options = generateOptions(correctCapital);
      selectedOption = null; // Resetear selección
      currentIndex++; // Avanzar al siguiente país
    });
  }

  List<String> generateOptions(String correctCapital) {
    final random = Random();
    Set<String> wrongOptions = {};

    while (wrongOptions.length < 3) {
      String randomCapital =
          countries[random.nextInt(countries.length)]['capital']!;
      if (randomCapital != correctCapital) {
        wrongOptions.add(randomCapital);
      }
    }

    List<String> allOptions = [correctCapital, ...wrongOptions];
    allOptions.shuffle();
    return allOptions;
  }

  void checkAnswer(String selectedCapital) {
    setState(() {
      selectedOption = selectedCapital; // Guarda la selección del usuario
      if (selectedCapital == correctCapital) {
        score++; // Aumentar puntaje si es correcto
      }
    });

    Future.delayed(const Duration(seconds: 1), () {
      nextQuestion();
    });
  }

  @override
  void dispose() {
    stopTimer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Juego de Capitales')),
      body: countries.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Encabezado
                Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text('Aciertos: $score',
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      Text('Ronda: $currentIndex / 20',
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      Text(formatTime(elapsedSeconds),
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),

                // Espaciado extra para centrar mejor
                const SizedBox(height: 80),

                // Nombre del país más arriba
                Text(
                  currentCountry,
                  style: const TextStyle(
                      fontSize: 34, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 110), // Más espacio debajo del país

                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: ListView(
                      shrinkWrap: true,
                      children: options.map((option) {
                        return Container(
                          margin: const EdgeInsets.only(
                              bottom: 10), // Espacio entre botones
                          child: ElevatedButton(
                            onPressed: selectedOption == null
                                ? () => checkAnswer(option)
                                : null,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.all(15),
                              textStyle: const TextStyle(fontSize: 18),
                              backgroundColor: getButtonColor(option),
                              disabledBackgroundColor: getButtonColor(option),
                              foregroundColor: Colors.white,
                              minimumSize: const Size(
                                  double.infinity, 50), // Ancho completo
                            ),
                            child: Text(option, style: const TextStyle(color: Colors.white)),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),

                const SizedBox(height: 40),
              ],
            ),
    );
  }

  // Función para obtener el color del botón
  Color getButtonColor(String option) {
    if (selectedOption == null) {
      return const Color(0xFF8CACA4); // Color original
    } else if (option == correctCapital) {
      return Colors.green; // La opción correcta se vuelve verde
    } else if (option == selectedOption && selectedOption != correctCapital) {
      return Colors.red; // La opción incorrecta elegida se vuelve roja
    } else {
      return const Color(0xFF8CACA4); // Las demás se mantienen igual
    }
  }
}
