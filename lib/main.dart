import 'package:flutter/material.dart';
import 'dart:convert' as convert;
import 'package:http/http.dart' as http;
import 'package:confetti/confetti.dart';

Future<void> main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Did Flutter repo passed 100k stargazers on Github ?',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  ConfettiController _controllerCenter;
  int stargazers = 0;
  bool isLoading = false;
  bool didFail = false;

  @override
  void initState() {
    _controllerCenter =
        ConfettiController(duration: const Duration(seconds: 3));
    fetchStargazers();
    super.initState();
  }

  @override
  void dispose() {
    _controllerCenter.dispose();
    super.dispose();
  }

  void fetchStargazers() async {
    var url = 'https://api.github.com/repos/flutter/flutter';
    var response = await http.get(url);
    if (response.statusCode == 200) {
      var jsonResponse = convert.jsonDecode(response.body);
      var itemCount = jsonResponse['stargazers_count'];
      int oldStargazer = stargazers;
      setState(() {
        stargazers = itemCount;
        didFail = false;
      });
      itemCount > oldStargazer ? _controllerCenter.play() : null;
    } else {
      print('Request failed with status: ${response.statusCode}.');
      setState(() {
        didFail = true;
      });
    }
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade300,
      body: Stack(
        children: <Widget>[
          Align(
            alignment: Alignment.center,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(30)),
                color: Colors.white,
              ),
              height: 600,
              width: 600,
              padding: EdgeInsets.all(50),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  InkWell(
                    onTap: () {
                      setState(() {
                        isLoading = true;
                      });
                      fetchStargazers();
                    },
                    child: isLoading
                        ? CircularProgressIndicator()
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircleAvatar(child: Icon(Icons.sync)),
                              didFail
                                  ? Text("API rate limit exceeded")
                                  : Container(),
                            ],
                          ),
                  ),
                  FittedBox(
                    fit: BoxFit.fitWidth,
                    child: Text(
                      'Has Flutter passed 100k stargazers on Github yet ?',
                      style: Theme.of(context).textTheme.headline6,
                    ),
                  ),
                  Text(
                    stargazers > 50000 ? "🎉 YES 🎉" : "😢 NOT YET 😢",
                    style: TextStyle(fontSize: 45.0),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        stargazers.toString(),
                        style: Theme.of(context).textTheme.headline5,
                      ),
                      Icon(Icons.star)
                    ],
                  ),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: ConfettiWidget(
              confettiController: _controllerCenter,
              blastDirectionality: BlastDirectionality
                  .explosive, // don't specify a direction, blast randomly
              shouldLoop:
                  false, // start again as soon as the animation is finished
              colors: const [
                Colors.blue,
              ], // manually specify the colors to be used
            ),
          ),
        ],
      ),
    );
  }
}
