import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';

class BanderasScreen extends StatefulWidget {
  const BanderasScreen({super.key});

  @override
  _BanderasScreenState createState() => _BanderasScreenState();
}

class _BanderasScreenState extends State<BanderasScreen> {
  List<Map<String, String>> countries = [];
  String currentFlag = ''; // Bandera en Unicode
  String correctCountry = '';
  List<String> options = [];
  int score = 0;
  int questionCount = 0;
  Timer? timer;
  int elapsedSeconds = 0;
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
            'iso2': country['iso2'], // Código de país en ISO 3166-1 alpha-2
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
      currentFlag = countryCodeToEmoji(selectedCountry['iso2']!);
      correctCountry = selectedCountry['country']!;
      options = generateOptions(correctCountry);
      questionCount++;
      selectedOption = null;
    });
  }

  List<String> generateOptions(String correctCountry) {
    final random = Random();
    Set<String> wrongOptions = {};

    while (wrongOptions.length < 3) {
      String randomCountry =
          countries[random.nextInt(countries.length)]['country']!;
      if (randomCountry != correctCountry) {
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

                // Bandera en Unicode centrada
                const SizedBox(height: 40),
                Text(
                  currentFlag,
                  style: const TextStyle(
                      fontSize: 80), // Tamaño grande para la bandera
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 60),

                // Opciones en 2x2 (Grid)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: GridView.builder(
                      shrinkWrap: true,
                      itemCount: options.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 20,
                        mainAxisSpacing: 20,
                        childAspectRatio: 2.5,
                      ),
                      itemBuilder: (context, index) {
                        String option = options[index];
                        return ElevatedButton(
                          onPressed: selectedOption == null
                              ? () => checkAnswer(option)
                              : null,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.all(15),
                            textStyle: const TextStyle(fontSize: 18),
                            backgroundColor: getButtonColor(option),
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

  Color getButtonColor(String option) {
    if (selectedOption == null) {
      return Colors.blue;
    } else if (option == correctCountry) {
      return Colors.green;
    } else if (option == selectedOption && selectedOption != correctCountry) {
      return Colors.red;
    } else {
      return Colors.blue;
    }
  }
}
