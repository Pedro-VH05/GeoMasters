import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';

class CapitalesScreen extends StatefulWidget {
  const CapitalesScreen({super.key});

  @override
  _CapitalesScreenState createState() => _CapitalesScreenState();
}

class _CapitalesScreenState extends State<CapitalesScreen> {
  List<Map<String, String>> countries = [];
  String currentCountry = '';
  String correctCapital = '';
  List<String> options = [];
  int score = 0;
  int questionCount = 0;
  Timer? timer;
  int elapsedSeconds = 0;
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
        countries = fetchedCountries;
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

  void nextQuestion() {
    if (questionCount >= 20) {
      stopTimer();
      Navigator.pop(context);
      return;
    }

    final random = Random();
    final selectedCountry = countries[random.nextInt(countries.length)];

    setState(() {
      currentCountry = selectedCountry['country']!;
      correctCapital = selectedCountry['capital']!;
      options = generateOptions(correctCapital);
      questionCount++;
      selectedOption = null; // Resetear selección
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
                      Text('Ronda: $questionCount / 20',
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      Text(formatTime(elapsedSeconds),
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),

                // Espaciado extra para centrar mejor
                const SizedBox(height: 40),

                // Nombre del país más arriba
                Text(
                  currentCountry,
                  style: const TextStyle(
                      fontSize: 30, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 60), // Más espacio debajo del país

                // Opciones en 2x2 (Grid)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: GridView.builder(
                      shrinkWrap: true, // Ajustar al contenido
                      itemCount: options.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2, // 2 columnas
                        crossAxisSpacing: 20,
                        mainAxisSpacing: 20,
                        childAspectRatio: 2.5, // Tamaño de los botones
                      ),
                      itemBuilder: (context, index) {
                        String option = options[index];
                        return ElevatedButton(
                          onPressed: selectedOption == null
                              ? () => checkAnswer(option)
                              : null, // Deshabilitar botones después de seleccionar
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.all(15),
                            textStyle: const TextStyle(fontSize: 18),
                            backgroundColor: getButtonColor(option),
                            // Evitar que el botón se vuelva gris al deshabilitarse
                            disabledBackgroundColor: getButtonColor(option),
                          ),
                          child: Text(option),
                        );
                      },
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
      return Colors.blue; // Color original
    } else if (option == correctCapital) {
      return Colors.green; // La opción correcta se vuelve verde
    } else if (option == selectedOption && selectedOption != correctCapital) {
      return Colors.red; // La opción incorrecta elegida se vuelve roja
    } else {
      return Colors.blue; // Las demás se mantienen igual
    }
  }
}
