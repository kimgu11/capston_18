import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import 'package:capstone/screens/gScore/gscore_list_screen.dart';
import 'package:capstone/screens/gScore/gscore_self_calc_screen.dart';


class MyScorePage extends StatefulWidget {
  @override
  State<MyScorePage> createState() => _MyScorePage();
}

class _MyScorePage extends State<MyScorePage> with TickerProviderStateMixin {
  final FlutterSecureStorage storage = FlutterSecureStorage();
  int sumScore = 0;
  String leftScore = '';
  int totalScore = 0;
  int a = 0;
  int i = 0;
  List<Map<String, dynamic>> maxScores = [];
  Map<String,int> Maxscore = {};
  Map<String, dynamic> allScore = {};
  int student_id = 0;
  int? score = 0;
  Map<String, Map<String, int>>? details;
  bool capstone = true;

  Future<List<Map<String, dynamic>>> _getMaxScores() async {
    final response = await http.get(
        Uri.parse('http://3.39.88.187:3000/gScore/maxScore'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as List<dynamic>;
      data.forEach((item) {
        final maxCategory = item['max_category'] as String;
        final maxScore = item['max_score'] as int;
        maxScores.add({
          maxCategory: maxScore,
        });
        Maxscore[maxCategory] = maxScore;
      });
      return maxScores;
    } else {
      throw Exception('Failed to load max scores');
    }
  }


  Future<void> _getUserInfo() async {
    final token = await storage.read(key: 'token');

    if (token == null) {
      return;
    }

    final maxScores = await _getMaxScores(); // _getMaxScores 호출하여 결과를 maxScores 변수에 할당
    print(maxScores);
    for (var scoreMap in maxScores) {
      if (scoreMap.containsKey('총점')) {
        totalScore = scoreMap['총점'];
        break;
      }
    }
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
      final decodedAllScore = jsonDecode(allScoreTemp);
      student_id = user['student_id'];

      allScore.clear(); // 이전 값들을 제거하고 새로운 값을 저장
      allScore.addAll(decodedAllScore);
      print(allScore);

      allScore.forEach((key, value) {
        if (maxScores.any((score) => score.containsKey(key))) {
          final maxScore = maxScores.firstWhere((score) =>
              score.containsKey(key))[key] as int;
          if (value > maxScore) {
            allScore[key] = maxScore;
          }
        }
      });
      allScore.forEach((key, value) {
        sumScore += value as int;
      });

      _getdetails();
    }

    a = (Maxscore ["총점"] ?? 0) - sumScore;

    if (a < 0) {
      leftScore = '졸업인증점수 완료';
    } else {
      leftScore = '${a}점 남음';
    }
    setState(() {
      sumScore;
      leftScore;
    });
  }
  Future<void> _getdetails() async {
    final token = await storage.read(key: 'token');

    if (token == null) {
      return;
    }

    if (details == null) {
      final postData = {
        'userId': student_id,
      };

      print(postData);
      final detailsResponse = await http.post(
        Uri.parse('http://3.39.88.187:3000/gScore/detail'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': token,
        },
        body: jsonEncode(postData),
      );

      if (detailsResponse.statusCode == 200) {
        final detailsList = jsonDecode(detailsResponse.body);
        print(detailsList);
        details = {};
        for (final detail in detailsList) {
          final category = detail['gspost_category'];
          final item = detail['gspost_item'];
          final score = detail['gspost_score'];

          if (details![category] == null) {
            details![category] = {};
          }

          details![category]![item] = score;

        }
      }
      print("디테일 출력");
      print(details);

    }
    capstone = isCapstoneDesignExists();


    if (mounted) {
      setState(() {
        details;
        capstone;
      });
    }
  }
  bool isCapstoneDesignExists() {
    if (details != null) {
      for (final category in details!.keys) {
        final items = details![category];
        if (items != null &&
            (items.containsKey("캡스톤디자인") || items.containsKey("캡스톤 필수 이수"))) {
          return true;
        }
      }
    }
    return false;
  }
  @override
  void initState() {
    super.initState();
    _getUserInfo();
  }


  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      bottom: false,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white, size: 23),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          title: Text(
            '내 졸업인증점수',
            style: TextStyle(color: Colors.white),
          ),
          centerTitle: true,
          backgroundColor: Color(0xffC1D3FF),
        ),
        body: SingleChildScrollView(
          child: Center(
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.only(
                    top: MediaQuery
                        .of(context)
                        .size
                        .height * 0.013,
                    right: MediaQuery
                        .of(context)
                        .size
                        .width * 0.035,
                    bottom: MediaQuery
                        .of(context)
                        .size
                        .height * 0.01,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => SelfCalcScreen()),
                          );
                        },
                        child: Text(
                          '셀프 계산기',
                          style: TextStyle(fontSize: 20),
                        ),
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 8.0),
                          backgroundColor: Color(0xffC1D3FF),
                        ),
                      ),
                      SizedBox(width: 10),
                      // Add a space between the two buttons
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => GScoreForm()),
                          );
                        },
                        child: Text(
                          '신청 목록',
                          style: TextStyle(fontSize: 20),
                        ),
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 8.0),
                          backgroundColor: Color(0xffC1D3FF),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 5),
                Container(
                  constraints: BoxConstraints(maxWidth: 370),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16.0),
                    color: Colors.white,
                    border: Border.all(
                      width: 2,
                      color: Colors.black.withOpacity(1),
                    ),
                  ),
                  child: Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Text(
                              "나의 졸업인증점수",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            Text(
                              "${sumScore} / ${totalScore}",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            SizedBox(height: 10,),
                            if (capstone)
                              Text(
                                "${leftScore+ " / " + "캡스톤 이수 : O"}",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                            if (!capstone)
                              Text(
                                "${leftScore + " / " + "캡스톤 이수 : X"}",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                          ],
                        ),
                      ),
                      Divider(),
                      Column(
                        children: [
                          for (int i = 0; i < maxScores.length; i += 3)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                for (int j = i; j < i + 3 &&
                                    j < maxScores.length; j++)
                                  if (maxScores[j].keys.first != '총점' && maxScores[j].keys.first != '캡스톤디자인')
                                    Expanded(
                                      child: Padding(
                                        padding: EdgeInsets.all(8),
                                        child: gScore_check(
                                          name: maxScores[j].keys.first,
                                          maxScore: maxScores[j].values.first,
                                          studentid: student_id,
                                          allScore: allScore,
                                          score: score,
                                          details: details,
                                        ),
                                      ),
                                    ),
                              ],
                            ),
                        ],
                      ),
                    ],
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
class gScore_check extends StatefulWidget {
  const gScore_check({
    Key? key,
    required this.name,
    required this.maxScore,
    required this.studentid,
    required this.allScore,
    required this.score,
    required this.details,
  }) : super(key: key);

  final dynamic name;
  final dynamic maxScore;
  final int studentid;
  final Map<String, dynamic> allScore;
  final int? score;
  final Map<String, Map<String, int>>? details;

  @override
  _gScoreCheckState createState() => _gScoreCheckState();
}

class _gScoreCheckState extends State<gScore_check> {
  final FlutterSecureStorage storage = FlutterSecureStorage();

  dynamic myscore;
  dynamic maxscore;
  @override
  void initState() {
    super.initState();
    myscore = widget.allScore[widget.name];
    maxscore = widget.maxScore;
  }





  void _showScoreDetails() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          elevation: 0.0,
          child: Container(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '졸업점수 상세보기',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 10),
                SizedBox(
                  width: double.maxFinite,
                  height: 130,
                  child: Scrollbar(
                    child: ListView.builder(
                      itemCount: 1,
                      itemBuilder: (BuildContext context, int index) {
                        final category = widget.details!.keys.firstWhere(
                              (key) => key == widget.name,
                          orElse: () => '',
                        );
                        final items = widget.details![category] ?? {};

                        if (category.isNotEmpty && items.isNotEmpty) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '카테고리: $category',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 10),
                              for (final item in items.keys)
                                if (items[item] != null)
                                  Text(
                                    '$item: ${items[item]}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.black,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                            ],
                          );
                        } else {
                          return Center(
                            child: Text(
                              '해당하는 졸업점수가 없습니다.',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.black,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          );
                        }
                      },
                    ),
                  ),
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  child: Text(
                    '닫기',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    primary: Color(0xFF1E90FF), // #1E90FF (Dodger Blue) 색상
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _showScoreDetails,
      child: Container(
        padding: const EdgeInsets.all(8),
        width: 100,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withOpacity(0.9),
              Colors.white,
              Colors.grey.withOpacity(0.9),
            ],
            stops: const [0.1, 0.5, 0.9],
          ),
          border: Border.all(
            color: Colors.grey.withOpacity(0.5),
            width: 1.5,
          ),
        ),
        alignment: Alignment.center,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              child: Text(
                widget.name,
                style: const TextStyle(
                  fontSize: 15,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              color: Colors.transparent,
              child: Text(
                '$myscore / $maxscore',
                style: const TextStyle(
                  fontSize: 15,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}