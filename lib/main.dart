import 'package:capstone/screens/post/notice.dart';
import 'package:flutter/material.dart';
import 'package:capstone/screens/post/party_board.dart';
import 'package:capstone/screens/post/free_board.dart';
import 'package:capstone/screens/login/login_form.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:capstone/screens/login/profile.dart';
import 'package:capstone/screens/gScore/gscore_list_screen.dart';
import 'package:capstone/screens/gScore/gscore_self_calc_screen.dart';
import 'package:capstone/screens/gScore/gscore_myscore.dart';
import 'package:capstone/screens/gScore/gscore_admin_editor.dart';
import 'package:capstone/screens/gScore/gscore_admin_regist_screen.dart';
import 'package:capstone/screens/gScore/gscore_admin_list.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:ui';
import 'dart:math';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Capstone',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}



class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();

}

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin{
  final FlutterSecureStorage storage = FlutterSecureStorage();
  double percentage = 0.0;
  double newPercentage = 0.0;
  int sumScore = 0;
  double chartScore = 0;
  int i =0;

  late AnimationController percentageAnimationController;

  void logout() async {
    final storage = new FlutterSecureStorage();
    await storage.delete(key: 'token');
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => MyHomePage()),
          (Route<dynamic> route) => false,
    );
  }

  Future<List<Map<String, dynamic>>> _getMaxScores() async {
    final response = await http.get(Uri.parse('http://3.39.88.187:3000/gScore/maxScore'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as List<dynamic>;
      List<Map<String, dynamic>> maxScores = [];
      data.forEach((item) {
        final maxCategory = item['max_category'] as String;
        final maxScore = item['max_score'] as int;
        maxScores.add({
          maxCategory: maxScore,
        });
      });
      return maxScores;
    } else {
      throw Exception('Failed to load max scores');
    }
  }

  Future<void> _getUserInfo() async {
    final token = await storage.read(key: 'token');
    sumScore = 0;

    if (token == null) {
      return;
    }

    final maxScores = await _getMaxScores();
    final response = await http.get(
      Uri.parse('http://3.39.88.187:3000/gScore/user'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': token,
      },
    );

    if (response.statusCode == 200) {
      final user = jsonDecode(response.body);
      final allScoreTemp = user['graduation_score'];
      final allScore = jsonDecode(allScoreTemp);

      allScore.forEach((key, value) {
        if (maxScores.any((score) => score.containsKey(key))) {
          final maxScore = maxScores.firstWhere((score) => score.containsKey(key))[key] as int;
          if (value > maxScore) {
            allScore[key] = maxScore;
          }
        }
      });
      allScore.forEach((key, value){
        sumScore += value as int;
      });
      chartScore = (sumScore / 1000) as double;
    }
    setState(() {
      sumScore;
    });
    percentage = newPercentage;
    newPercentage= chartScore;
    percentageAnimationController.forward();
  }

  @override
  void initState() {
    super.initState();
    _getUserInfo();

    percentageAnimationController =  AnimationController(
        vsync: this,
        duration: new Duration(milliseconds: 2000)
    )
      ..addListener((){
        setState(() {
          percentage=lerpDouble(percentage,newPercentage,percentageAnimationController.value)!;
        });
      });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Capstone'),
          backgroundColor:
          Color(0xffC1D3FF),
          actions: [
            IconButton(
              icon: Icon(Icons.person),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Profile()),
                );
              },
            ),
            IconButton(
              icon: Icon(Icons.logout),
              onPressed: () => logout(),
            ),
          ],
        ),
        body:  RefreshIndicator(
          onRefresh: () async {
            setState(() async {
              await _getUserInfo();
            });
          },
          child:
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Notice()),
                      );
                    },
                    child: Text(
                      '공지 알림톡',
                      style: TextStyle(fontSize: 20),
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 20.0),
                      backgroundColor: Color(0xffC1D3FF),
                    ),
                  ),
                  SizedBox(height: 20.0),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => PartyBoardScreen()),
                      );
                    },
                    child: Text(
                      '구인구직 게시판',
                      style: TextStyle(fontSize: 20),
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 20.0),
                      backgroundColor: Color(0xffC1D3FF),
                    ),
                  ),
                  SizedBox(height: 20.0),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => FreeBoardScreen()),
                      );
                    },
                    child: Text(
                      '자유게시판',
                      style: TextStyle(fontSize: 20),
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 20.0),
                      backgroundColor: Color(0xffC1D3FF),
                    ),
                  ),
                  SizedBox(height: 20.0),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => GScoreForm()),
                      );
                    },
                    child: Text(
                      '졸업점수 신청및 내역',
                      style: TextStyle(fontSize: 20),
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 20.0),
                      backgroundColor: Color(0xffC1D3FF),
                    ),
                  ),
                  SizedBox(height: 20.0),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => SelfCalcScreen()),
                      );
                    },
                    child: Text(
                      '졸업점수 셀프 계산기',
                      style: TextStyle(fontSize: 20),
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 20.0),
                      backgroundColor: Color(0xffC1D3FF),
                    ),
                  ),
                  SizedBox(height: 20.0),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => GScoreEditor()),
                      );
                    },
                    child: Text(
                      '관리자 목록 편집',
                      style: TextStyle(fontSize: 20),
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 20.0),
                      backgroundColor: Color(0xffC1D3FF),
                    ),
                  ),
                  SizedBox(height: 20.0),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => GScoreAdminRegist()),
                      );
                    },
                    child: Text(
                      '관리자 신청 페이지',
                      style: TextStyle(fontSize: 20),
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 20.0),
                      backgroundColor: Color(0xffC1D3FF),
                    ),
                  ),
                  SizedBox(height: 20.0),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => AdminGScoreForm()),
                      );
                    },
                    child: Text(
                      '관리자 리스트 페이지',
                      style: TextStyle(fontSize: 20),
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 20.0),
                      backgroundColor: Color(0xffC1D3FF),
                    ),
                  ),
                  SizedBox(height: 20.0),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => LoginPage()),
                      );
                    },
                    child: Text(
                      '로그인',
                      style: TextStyle(fontSize: 20),
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 20.0),
                      backgroundColor: Color(0xffC1D3FF),
                    ),
                  ),
                  SizedBox(height: 20.0),
                  PercentDonut(percent: percentage, color: Color(0xffC1D3FF)),
                ],
              ),
            ),
          ),
        )
    );
  }
}

class PercentDonut extends StatefulWidget {
  const PercentDonut({Key? key, required this.percent, required this.color})
      : super(key: key);
  final percent;
  final color;

  @override
  _PercentDonutState createState() => _PercentDonutState();
}

class _PercentDonutState extends State<PercentDonut> {
  late Future<Map<String, dynamic>> _maxScoreFuture;

  @override
  void initState() {
    super.initState();
    _maxScoreFuture = _getMaxScore();
  }

  Future<Map<String, dynamic>> _getMaxScore() async {
    final response = await http.get(
      Uri.parse('http://3.39.88.187:3000/gScore/maxScore'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    if (response.statusCode == 200) {
      final maxScoreTemp = jsonDecode(response.body);
      Map<String, dynamic> maxScore = {};
      for (var item in maxScoreTemp) {
        String categoryName = item['max_category'];
        int categoryScore = item['max_score'];
        maxScore[categoryName] = categoryScore;
      }
      return maxScore;
    } else {
      throw Exception('예외 발생');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(16, 10, 16, 16),
      height: 380,
      width: 380,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: Colors.black,
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 80,
              ),
              Text(
                '졸업인증점수',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => MyScorePage()),
                  );
                },
                child: Text(
                  '자세히',
                  style: TextStyle(
                    color: Colors.black45,
                    fontSize: 16,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  primary: Colors.white,
                  onPrimary: Colors.black,
                  elevation: 0,
                ),
              ),
            ],
          ),
          Container(
            width: 300,
            height: 300,
            color: Colors.white,
            child: FutureBuilder<Map<String, dynamic>>(
              future: _maxScoreFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else {
                  Map<String, dynamic> maxScore = snapshot.data!;

                  return CustomPaint(
                    painter: PercentDonutPaint(
                      percentage: widget.percent,
                      activeColor: widget.color,
                      maxScore: maxScore,
                    ),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

class PercentDonutPaint extends CustomPainter {
  final double percentage;
  final double textScaleFactor;
  final Color activeColor;
  final Map<String, dynamic> maxScore;

  PercentDonutPaint({
    required this.percentage,
    required this.activeColor,
    required this.maxScore,
    this.textScaleFactor = 1.0,
  }) : super();

  @override
  void paint(Canvas canvas, Size size) {
    if (maxScore.isEmpty) {
      return;
    }

    Paint paint = Paint()
      ..color = Color(0xfff3f3f3)
      ..strokeWidth = 15.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    double radius = min(
      size.width / 2 - paint.strokeWidth / 2,
      size.height / 2 - paint.strokeWidth / 2,
    );
    Offset center = Offset(size.width / 2, size.height / 2);
    canvas.drawCircle(center, radius, paint);

    double arcAngle = 2 * pi * percentage;
    paint.color = activeColor;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      arcAngle,
      false,
      paint,
    );

    int maxScores = maxScore['총점'] ?? 0;
    drawText(
      canvas,
      size,
      "${(percentage * 1000).round()} / $maxScores",
    );
  }

  void drawText(Canvas canvas, Size size, String text) {
    double fontSize = getFontSize(size, text);

    TextSpan sp = TextSpan(
      style: TextStyle(
        fontSize: fontSize,
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
      text: text,
    );
    TextPainter tp = TextPainter(text: sp, textDirection: TextDirection.ltr);

    tp.layout();
    double dx = size.width / 2 - tp.width / 2;
    double dy = size.height / 2 - tp.height / 2;

    Offset offset = Offset(dx, dy);
    tp.paint(canvas, offset);
  }

  double getFontSize(Size size, String text) {
    return size.width / text.length * textScaleFactor;
  }

  @override
  bool shouldRepaint(PercentDonutPaint oldDelegate) {
    return true;
  }
}