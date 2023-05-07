import 'dart:ui';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';


/*Future<void> _fetchMyPosts() async {
  final storage = FlutterSecureStorage();
  final token = await storage.read(key: 'token');

  if (token == null) {
    return;
  }
  final response = await http.get(
    Uri.parse('http://3.39.88.187:3000/user'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': token,
    },
  );
  if (response.statusCode == 200) {
    final data = json.decode(response.body) as List<dynamic>;
    final allScore = data
        .map((e) => e['graduation_score'] as int)
        .reduce((value, element) => value + element);
    print('All score: $allScore');
  }
}
*/
class MyScorePage extends StatefulWidget {
  @override
  State<MyScorePage> createState() => _MyScorePage();
}

class _MyScorePage extends State<MyScorePage> with TickerProviderStateMixin {
  double percentage = 0.0;
  double newPercentage = 0.0;

  late AnimationController percentageAnimationController;

  @override
  void initState() {
    super.initState();

    percentageAnimationController =  AnimationController(
        vsync: this,
        duration: new Duration(milliseconds: 2000)
    )
      ..addListener((){
        setState(() {
          percentage=lerpDouble(percentage,newPercentage,percentageAnimationController.value)!;
        });
      });

    setState(() {
      percentage = newPercentage;
      newPercentage=0.8;
      percentageAnimationController.forward();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      bottom: false,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new,
                color: Colors.black, size: 18),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          title: Text('내 졸업인증점수'),
          centerTitle: true,
        ),
        body: Center(
          child:
          Container(
            padding: EdgeInsets.all(16),
            constraints: BoxConstraints(maxWidth: 370, maxHeight: 550),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16.0),
              color: Colors.white,
              border: Border.all(
                width: 2,
                color: Colors.black.withOpacity(1),
              ),
            ),
            child: Column(children: [
              Text(
                "총점수",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 10,),
              Text(
                "600 / 1000",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 10,),
              Row(
                mainAxisAlignment: MainAxisAlignment.center, // 가운데 정렬
                children: [
                  gScore_check(percent: percentage, color: Color(0xffC1D3FF)),
                  SizedBox(width: 30),
                  gScore_check(percent: percentage, color: Color(0xffC1D3FF)),
                  SizedBox(width: 30),
                  gScore_check(percent: percentage, color: Color(0xffC1D3FF)),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center, // 가운데 정렬
                children: [
                  gScore_check(percent: percentage, color: Color(0xffC1D3FF)),
                  SizedBox(width: 30),
                  gScore_check(percent: percentage, color: Color(0xffC1D3FF)),
                  SizedBox(width: 30),
                  gScore_check(percent: percentage, color: Color(0xffC1D3FF)),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center, // 가운데 정렬
                children: [
                  gScore_check(percent: percentage, color: Color(0xffC1D3FF)),
                  SizedBox(width: 30),
                  gScore_check(percent: percentage, color: Color(0xffC1D3FF)),
                  SizedBox(width: 30),
                  gScore_check(percent: percentage, color: Color(0xffC1D3FF)),
                ],
              ),
              SizedBox(height: 10,),
              Text(
                "N점 남았어요 화이팅",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
            ),

          ),
        ),
      ),
    );
  }
}
//floating border
class gScore_check extends StatelessWidget {
  const gScore_check({Key? key, required this.percent, required this.color})
      : super(key: key);
  final percent;
  final color;

  @override
  Widget build(BuildContext context) {
    return
      Container(
          padding: EdgeInsets.fromLTRB(8, 8, 8, 8),
          height: 110,
          width: 90,
          decoration: BoxDecoration(
            color: Colors.white,
          ),
          alignment: Alignment.center,
          child:
          Column(
            children: [
              Container(
                child: Text(
                    "항목명",
                    style: TextStyle(fontSize: 15, color: Colors.black, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center
                ),
              ),
              SizedBox(height: 10),
              Container(
                color: Colors.white,
                child: Text(
                    "10/800",
                    style: TextStyle(fontSize: 15, color: Colors.black, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center
                ),
              )
            ],
          )
      );
  }
}