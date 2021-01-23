import 'dart:async';
import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  //For AnimationController/Animation is used to start the time as soon as we press a box.
  static const duration = const Duration(seconds: 1);
  int count;
  int nextNum;
  int curNum;
  int secondsPassed;
  int minsPassed;
  int hoursPassed;
  int bestTime;
  String timeShow = '';
  int totalsecondsPassed;

  List<int> data = List<int>();
  AnimationController controller;
  Animation<Color> animation;
  Timer timer;
  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      vsync: this, //Animation Controller Constructor
      duration: Duration(milliseconds: 250),
    );
    init(25);
  }

  void init(int count) {
    timer?.cancel();
    this.count = count;
    nextNum = 0;
    curNum = 0;
    secondsPassed = 0;
    minsPassed = 0;
    hoursPassed = 0;

    animation = ColorTween(
      begin: Colors.white,
      end: Colors.purple,
    ).animate(controller);

    data = List.generate(count, (index) => index + 1)..shuffle();
  }

  void startTick() {
    timer = Timer.periodic(duration, (Timer t) {
      ++secondsPassed;
      if (secondsPassed == 60) {
        secondsPassed = 0;
        ++minsPassed;
      }
      if (minsPassed == 60) {
        minsPassed = 0;
        ++hoursPassed;
      }
      setState(() {});
    });
  }

  timerParse(int secondsPassed) {
    int seconds, minutes, hours;
    String text;
    seconds = secondsPassed % 60;
    minutes = secondsPassed ~/ 60;
    hours = secondsPassed ~/ (60 * 60);

    text = hours.toString().padLeft(2, '0') +
        " : " +
        minutes.toString().padLeft(2, '0') +
        " : " +
        seconds.toString().padLeft(2, '0');
    return text;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Schulte Table Game",
          style: TextStyle(
              color: Colors.white, fontSize: 22, fontStyle: FontStyle.italic),
        ),
        backgroundColor: Colors.red[900],
        centerTitle: true,
      ),
      body: Builder(builder: (context) {
        return Column(
          children: <Widget>[
            Expanded(
              child: GridView.count(
                crossAxisCount: count == 16 ? 4 : 5,
                children: List.generate(count, (index) {
                  return InkWell(
                    //Responds to Touch
                    onTap: () async {
                      if (nextNum == 0 && (timer == null || !timer.isActive)) {
                        startTick();
                      }
                      curNum = data[index];
                      if (nextNum + 1 == curNum) {
                        ++nextNum;
                        animation = ColorTween(
                          begin: Colors.white,
                          end: Colors.blueAccent[700],
                        ).animate(controller)
                          ..addListener(() {
                            setState(() {});
                          });
                      } else {
                        animation = ColorTween(
                          begin: Colors.white,
                          end: Colors.red,
                        ).animate(controller)
                          ..addListener(() {
                            setState(() {});
                          });
                      }
                      await controller.forward();
                      await controller.reverse();
                      if (nextNum == count) {
                        // It is like a pop-up that appears when game finishes.
                        nextNum++;
                        Scaffold.of(context).showSnackBar(SnackBar(
                          content: Text(
                              'Yes! IT IS FINISHED!\n Total Time: $hoursPassed hours $minsPassed minutes $secondsPassed seconds',
                              style: TextStyle(
                                fontSize: 15.0,
                                color: Colors.white,
                                fontStyle: FontStyle.italic,
                                fontWeight: FontWeight.w600,
                              )),
                        ));

                        if (bestTime == null) {
                          int s = secondsPassed;
                          int m = 60 * minsPassed;
                          int h = 3600 * hoursPassed;
                          totalsecondsPassed = h + m + s;

                          bestTime = totalsecondsPassed;
                          timeShow = timerParse(bestTime);
                        } else if (secondsPassed < bestTime) {
                          bestTime = secondsPassed;
                          timeShow = timerParse(bestTime);
                        }
                        timer.cancel();
                      }
                    },
                    child: Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        //Box
                        border: Border.all(
                          width: 1,
                          color: Colors.red[900],
                        ),
                        color: curNum == data[index]
                            ? animation.value
                            : Colors.white,
                      ),
                      child: Text(
                        '${data[index]}', // Prints numbers onto boxes.
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.indigoAccent,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
            new Text(
                'Last Pressed Number: $nextNum', // Displays last pressed correct number
                style: TextStyle(
                  fontSize: 17.0,
                  color: Colors.black,
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.w600,
                )),
            SizedBox(height: 100),
            Text(
              'Time: $hoursPassed:$minsPassed:$secondsPassed', // Displaying chronometer
              style: TextStyle(
                fontSize: 30.0,
              ),
            ),
            SizedBox(height: 60),
            Text(
              'Best Time: $timeShow', // Displaying best score
              style: TextStyle(
                fontSize: 20.0,
              ),
            ),
            SizedBox(height: 20),
            FlatButton(
              // RESET AND PLAY AGAIN Button.
              color: Colors.red[900],
              child: Text(
                'RESET AND PLAY AGAIN!',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 17.0,
                ),
              ),
              padding: const EdgeInsets.all(20.0),
              onPressed: () {
                init(count);
                setState(() {});
              },
            ),
          ],
        );
      }),
    );
  }
}
