import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:geomasters/servicios/storage_service.dart';
import 'package:http/http.dart' as http;
import 'dart:async';

class BanderasScreen extends StatefulWidget {
  const BanderasScreen({super.key});

  @override
  _BanderasScreenState createState() => _BanderasScreenState();
}

class _BanderasScreenState extends State<BanderasScreen> {
  final StorageService _storageService = StorageService();
  List<Map<String, String>> countries = [];
  List<Map<String, String>> selectedCountries = []; // Lista de 20 países únicos
  int currentIndex = 0; // Índice de la pregunta actual
  String currentFlag = '';
  String correctCountry = '';
  List<String> options = [];
  int score = 0;
  int elapsedSeconds = 0;
  Timer? timer;
  String? selectedOption;

  @override
  void initState() {
    super.initState();
    fetchCountries();
    startTimer();
  }

  Future<void> fetchCountries() async {
    final url = Uri.parse(
        'https://countriesnow.space/api/v0.1/countries/info?returns=iso2');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      List<dynamic> countryData = data['data'];

      List<Map<String, String>> fetchedCountries = [];

      for (var country in countryData) {
        if (country['iso2'] != null && country['iso2'].toString().isNotEmpty) {
          fetchedCountries.add({
            'country': country['name'],
            'iso2': country['iso2'],
          });
        }
      }

      setState(() {
        countries = fetchedCountries..shuffle(); // Mezcla la lista
        selectedCountries = countries.take(20).toList(); // Toma 20 países únicos
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
      Navigator.pop(context);
      await _storageService.saveGameResult('banderas', score, elapsedSeconds);
      return;
    }

    final selectedCountry = selectedCountries[currentIndex];

    setState(() {
      currentFlag = countryCodeToEmoji(selectedCountry['iso2']!);
      correctCountry = selectedCountry['country']!;
      options = generateOptions(correctCountry);
      selectedOption = null;
      currentIndex++; // Avanzar al siguiente país
    });
  }

  List<String> generateOptions(String correctCountry) {
    final random = Random();
    Set<String> wrongOptions = {};

    while (wrongOptions.length < 3) {
      String randomCountry =
          countries[random.nextInt(countries.length)]['country']!;
      if (randomCountry != correctCountry && !wrongOptions.contains(randomCountry)) {
        wrongOptions.add(randomCountry);
      }
    }

    List<String> allOptions = [correctCountry, ...wrongOptions];
    allOptions.shuffle();
    return allOptions;
  }

  void checkAnswer(String selectedCountry) {
    setState(() {
      selectedOption = selectedCountry;
      if (selectedCountry == correctCountry) {
        score++;
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

  /// Convierte un código de país ISO 3166-1 a un emoji de bandera
  String countryCodeToEmoji(String countryCode) {
    return countryCode
        .toUpperCase()
        .codeUnits
        .map((c) => String.fromCharCode(c + 127397))
        .join();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Juego de Banderas')),
      body: countries.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
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

                // Bandera en Unicode centrada
                const SizedBox(height: 40),
                Text(
                  currentFlag,
                  style: const TextStyle(
                      fontSize: 120), // Tamaño grande para la bandera
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 100),

                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: ListView(
                      shrinkWrap: true,
                      children: options.map((option) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 10), // Espacio entre botones
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
                              minimumSize: const Size(double.infinity, 50), // Ancho completo
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

  Color getButtonColor(String option) {
    if (selectedOption == null) {
      return const Color(0xFF8CACA4);
    } else if (option == correctCountry) {
      return Colors.green;
    } else if (option == selectedOption && selectedOption != correctCountry) {
      return Colors.red;
    } else {
      return const Color(0xFF8CACA4);
    }
  }
}
