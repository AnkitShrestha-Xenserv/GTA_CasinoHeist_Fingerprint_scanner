import 'package:flutter/material.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

class FingerPrintHack extends StatefulWidget {
    createState() => FingerPrintHackState();    
}

class FingerPrintHackState extends State<FingerPrintHack> with SingleTickerProviderStateMixin{

  AnimationController backgroundIncorrectController;
  Animation<Color> incorrectAnimation;
  var firstChoice;
  var listFirst = ['A','B','C','D'];
  var game = 0;
  var game2 = 0;
  var secondChoice = ['off','off','off','off','off','off','off','off'];
  var picks = 0;
  var list = [0,1,2,3,4,5,6,7];
  Dependencies dependencies = new Dependencies();
  String time;
  int fastestTime = 0;
  String fastestTimeStr;
  final intKey = 'time_int_key';
  final stringKey = 'time_string_key';

  read() async{
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      fastestTime = prefs.getInt(intKey) ?? 0; 
      fastestTimeStr = prefs.getString(stringKey) ?? '00:00.00';  
    });
    print('r : $fastestTime');
    print('r : $fastestTimeStr');
  }

  save() async{
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt(intKey,fastestTime);
    prefs.setString(stringKey,fastestTimeStr);
    print('s : $fastestTime');
    print('s : $fastestTimeStr');
  }

  @override
  void initState() {
    super.initState();
    firstChoice = randomizeChoice();
    backgroundIncorrectController = AnimationController(vsync: this,duration: Duration(milliseconds: 200));
    CurvedAnimation curve = CurvedAnimation(parent: backgroundIncorrectController, curve: Curves.easeInOut);
    incorrectAnimation = ColorTween(begin: Colors.black, end: Colors.red).animate(curve);
    read();
    time = timerValues();
  }

  Widget build(buildContext){
    return Scaffold(
      appBar: AppBar(title: Text('Fingerprint Hack Practice')),
      body: AnimatedBuilder(
          animation: incorrectAnimation,
          builder: (context, child){
            return  Container(
                child: child,
                decoration: BoxDecoration(color:  incorrectAnimation.value),
                height: double.infinity,
              );
          },
          child: mainContainer(),
      ),
    );
  }

  Widget mainContainer(){
    return Column(
        children: <Widget>[ 
            lastRun('false'),
            fastestRun(),
            timeContainer(),
            fingerPrintImages(),
            confirmButton(),
        ],
        mainAxisAlignment: MainAxisAlignment.center,
      );
  }

  String timerValues(){
    int milliseconds = dependencies.stopwatch.elapsedMilliseconds;
    String time2;

    final int hundreds = (milliseconds / 10).truncate();
    final int seconds = (hundreds / 100).truncate();
    final int minutes = (seconds / 60).truncate();
    String minutesStr = (minutes % 60).toString().padLeft(2, '0');
    String secondsStr = (seconds % 60).toString().padLeft(2, '0');
    String hundredsStr = (hundreds % 100).toString().padLeft(2, '0');
     
    time2 = '$minutesStr:$secondsStr.$hundredsStr'; 
    if(milliseconds < fastestTime || fastestTime == 0 && game2 == 1){
      setState(() {
        fastestTime = milliseconds;
        fastestTimeStr = time2;  
        save();
      });      
    }
    return time2;
  }

  Widget lastRun(go){
    if(go == 'true'){
      time = timerValues();
    }
    return Container(
      child: Text('Last Run :      $time ', style: TextStyle(color: Colors.blue, fontSize: 30)),
      width: double.infinity,
      height: 40,
      alignment: Alignment.centerLeft,
      padding: EdgeInsets.all(0.0),
    );
  }

  Widget fastestRun(){
    return Container(
      child: Text('Fastest Run :   $fastestTimeStr ', style: TextStyle(color: Colors.blue, fontSize: 30)),
      width: double.infinity,
      height: 50,
      alignment: Alignment.centerLeft,
      padding: EdgeInsets.all(0.0),
      );
  }

  Widget timeContainer(){
    return Container( 
      child: new TimerText(dependencies: dependencies),
      width: double.infinity,
      height:100,
    );
  }

  Widget fingerPrintImages(){
      return Container(  
            child: Stack(
              children: <Widget>[
                Positioned(
                  child:Image.asset('assets/$firstChoice/off/main.PNG',height:320,width:235),  
                  right:0,
                  top:0,
                ),       
              optionImages(),         
              ],
              ),
               height: 320,
               width: double.infinity,
               padding: EdgeInsets.all(0.0),
               color: Colors.black,
            );
  }

   Widget optionImages(){
      if(game == 0 ){
        list.shuffle();
        setState(() {
          game = 1;  
        });
      }
      return Row(
        children: <Widget>[
          Column(
            children: <Widget>[
              button(list[0]),
              button(list[1]),
              button(list[2]),
              button(list[3]),
            ],
          ),
          Column(
            children: <Widget>[
              button(list[4]),
              button(list[5]),
              button(list[6]),
              button(list[7]),
            ],
            ),
        ],
      );
  }

  Widget confirmButton(){
    return Container(
              width: 400,
              height: 70,
              padding: EdgeInsets.only(top: 10),
              child: RaisedButton(
                child: Text('CONFIRM',
                        style: TextStyle(fontSize: 50)),
                onPressed: (){ 
                  game2 = 1;
                  checkImages();
                  },
                color: Colors.white,
                textColor: Colors.black,
                shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18.0)
              ),
              )
            );
  }
  
  Widget button(int num){
      var choice = secondChoice[num];
      return  Container(
          child: FlatButton(
            child: Image.asset('assets/$firstChoice/$choice/$num.PNG',width:80,height:80,),
            onPressed: (){
              setState(() {
                     if(choice == 'off'){
                        if(picks<4){
                          secondChoice[num] = 'on';
                          picks++;
                        }
                      }else {
                        secondChoice[num] = 'off';
                        picks--;
                      }
              });    
            },
            padding: EdgeInsets.all(0.0),
          ),
          width:80,
          height:80, 
          color: Colors.black,
        );
  }

  checkImages(){
    if(picks==4 && secondChoice[1] == 'on' && secondChoice[3] == 'on' && secondChoice[4] == 'on' && secondChoice[6] == 'on'){
        lastRun('true');
    }else{
      backgroundIncorrectController.forward();
      backgroundIncorrectController.addStatusListener((status){
        if(status == AnimationStatus.completed){
          backgroundIncorrectController.reverse();
        }
      });  
    }
    dependencies.stopwatch.reset();
    setState(() {
      resetChoice();
      picks=0;
      game = 0;
      firstChoice = randomizeChoice();
    });
  }

  String randomizeChoice(){
    listFirst.shuffle();
    return listFirst[0];
  }

  resetChoice(){
      secondChoice[0] = 'off';
      secondChoice[1] = 'off'; 
      secondChoice[2] = 'off'; 
      secondChoice[3] = 'off';
      secondChoice[4] = 'off'; 
      secondChoice[5] = 'off'; 
      secondChoice[6] = 'off';
      secondChoice[7] = 'off';
  } 
}

class Dependencies {
  final List<ValueChanged<ElapsedTime>> timerListeners = <ValueChanged<ElapsedTime>>[];
  final TextStyle textStyle = const TextStyle(fontSize: 90.0,color: Colors.blue);
  final Stopwatch stopwatch = new Stopwatch();
  final int timerMillisecondsRefreshRate = 30;
}

class ElapsedTime {
  final int hundreds;
  final int seconds;
  final int minutes;

  ElapsedTime({
    this.hundreds,
    this.seconds,
    this.minutes,
  });
}

class TimerText extends StatefulWidget {
  TimerText({this.dependencies});
  final Dependencies dependencies;

  TimerTextState createState() => new TimerTextState(dependencies: dependencies);
}

class TimerTextState extends State<TimerText> {
  TimerTextState({this.dependencies});
  final Dependencies dependencies;
  Timer timer;
  int milliseconds;

  @override
  void initState() {
    timer = new Timer.periodic(new Duration(milliseconds: dependencies.timerMillisecondsRefreshRate), callback);
    dependencies.stopwatch.start();
    super.initState();
  }

  @override
  void dispose() {
    timer?.cancel();
    timer = null;
    super.dispose();
  }

  void callback(Timer timer) {
    if (milliseconds != dependencies.stopwatch.elapsedMilliseconds) {
      milliseconds = dependencies.stopwatch.elapsedMilliseconds;
      final int hundreds = (milliseconds / 10).truncate();
      final int seconds = (hundreds / 100).truncate();
      final int minutes = (seconds / 60).truncate();
      final ElapsedTime elapsedTime = new ElapsedTime(
        hundreds: hundreds,
        seconds: seconds,
        minutes: minutes,
      );
      for (final listener in dependencies.timerListeners) {
        listener(elapsedTime);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return new Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
          new RepaintBoundary(
            child: new SizedBox(
              height: 100.0,
              child: new MinutesAndSeconds(dependencies: dependencies),
            ),
          ),
      ],
    );
  }
}

class MinutesAndSeconds extends StatefulWidget {
  MinutesAndSeconds({this.dependencies});
  final Dependencies dependencies;

  MinutesAndSecondsState createState() => new MinutesAndSecondsState(dependencies: dependencies);
}

class MinutesAndSecondsState extends State<MinutesAndSeconds> {
  MinutesAndSecondsState({this.dependencies});
  final Dependencies dependencies;

  int minutes = 0;
  int seconds = 0;
  int hundreds = 0;

  @override
  void initState() {
    dependencies.timerListeners.add(onTick);
    super.initState();
  }

  void onTick(ElapsedTime elapsed) {
    if (elapsed.minutes != minutes || elapsed.seconds != seconds || elapsed.hundreds != hundreds) {
      setState(() {
        minutes = elapsed.minutes;
        seconds = elapsed.seconds;
        hundreds = elapsed.hundreds;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    String minutesStr = (minutes % 60).toString().padLeft(2, '0');
    String secondsStr = (seconds % 60).toString().padLeft(2, '0');
    String hundredsStr = (hundreds % 100).toString().padLeft(2, '0');
    return new Text('$minutesStr:$secondsStr.$hundredsStr', style: dependencies.textStyle);
  }
}

