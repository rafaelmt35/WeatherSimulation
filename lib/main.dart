import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import 'package:intl/intl.dart';

void main() {
  runApp(MyApp());
}

class Weather {
  String weather;
  String dateTime;
  String image;

  Weather({required this.weather, required this.dateTime, required this.image});
}

class WeatherSimulation {
  int curState = 1;
  DateTime datetimeNow = DateTime.now();
  final List<String> _states = ['Sunny', 'Cloudy', 'Rainy'];
  final List<List<double>> _transitionMatrix = [
    [-0.6, 0.3, 0.3], // Transition probabilities from sunny
    [0.4, -0.5, 0.1], // Transition probabilities from cloudy
    [0.3, 0.4, -0.7], // Transition probabilities from rainy
  ];
  Random _random = Random();

  Weather markovProcess() {
    double prob = _transitionMatrix[curState - 1][curState - 1];
    var probabilitiesArray =
        _transitionMatrix[curState - 1].map((value) => -value / prob).toList();
    probabilitiesArray[curState - 1] = 0.0;
    int dtime = log(_random.nextDouble() * (1 - 0) + 0) ~/ prob;
    print(dtime);

    datetimeNow = datetimeNow.add(Duration(hours: dtime < 1 ? 1 : dtime));
    print(datetimeNow);
    String dateNow = DateFormat('d/MMM/yyyy kk:mm').format(datetimeNow);
    // print(curState);
    // print(probabilitiesArray);
    double randnumber = _random.nextDouble() * (1 - 0) + 0;
    // print(randnumber);
    int i = 0;
    do {
      randnumber -= probabilitiesArray[i];
      i += 1;
    } while (randnumber > 0.0);
    curState = i;
    // print(i);
    if (i == 1) {
      return Weather(
          weather: 'Sunny', dateTime: dateNow, image: 'assets/Sunny.png');
    } else if (i == 2) {
      return Weather(
          weather: 'Cloudy', dateTime: dateNow, image: 'assets/Cloudy.png');
    } else {
      return Weather(
          weather: 'Rainy', dateTime: dateNow, image: 'assets/Rainy.png');
    }
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Weather Simulation',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Weather Simulation'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final String title;

  MyHomePage({required this.title});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Weather> listweather = [];
  WeatherSimulation simulation = WeatherSimulation();

  List<Weather> weatherList = [];
  Timer? timer;
  int interval = 1000; // Timer interval in milliseconds

  void startTimer() {
    DateTime datetimenow = DateTime.now();
    timer = Timer.periodic(Duration(milliseconds: interval), (_) {
      setState(() {
        weatherList.add(simulation.markovProcess());
      });
    });
  }

  void stopTimer() {
    timer?.cancel();
  }

  @override
  void dispose() {
    stopTimer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              for (int index = 0; index < weatherList.length; index++)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    height: 200,
                    width: 120,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.black, width: 1)),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          weatherList[index].weather,
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          weatherList[index].dateTime,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                        Container(
                          height: 90,
                          width: 90,
                          decoration: BoxDecoration(
                              image: DecorationImage(
                                  image: AssetImage(weatherList[index].image),
                                  fit: BoxFit.contain)),
                        )
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (timer != null && timer!.isActive) {
            stopTimer();
          } else {
            startTimer();
          }
        },
        child: Icon(
            timer != null && timer!.isActive ? Icons.pause : Icons.play_arrow),
      ),
    );
  }
}
