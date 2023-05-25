import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';


void main() {
  runApp(MaterialApp(
    title: '관리자 목록 편집',
    home: GScoreEditor(),
  ));
}

class GScoreEditor extends StatefulWidget {
  const GScoreEditor({Key? key}) : super(key: key);

  @override
  _GScoreEditorState createState() => _GScoreEditorState();
}

class _GScoreEditorState extends State<GScoreEditor> {
void initState(){
  super.initState();
  _fetchGsInfo();
  _getMaxScore();
}

  @override

  Future<void> _fetchGsInfo() async {
    if (activityTypes.isEmpty) {
      final typeResponse = await http.get(Uri.parse('http://3.39.88.187:3000/gScore/getType'));
      if (typeResponse.statusCode == 200) {
        final typeResult = jsonDecode(typeResponse.body);
        for (var typeItem in typeResult) {
          String gsinfoType = typeItem['gsinfo_type'];
          if (!activityTypes.contains(gsinfoType)) {
            activityTypes.add(gsinfoType);
          }
        }
        setState(() {
          activityTypes;
        });
      } else {
        throw Exception('Failed to load types');
      }
    }
  }

Future<void> _fetchNamesAndScores(String selectedType) async {
  if (!activityNames.containsKey(selectedType)) {
    final encodedType = Uri.encodeComponent(selectedType);
    final infoResponse = await http.get(Uri.parse('http://3.39.88.187:3000/gScore/getInfoByType/$encodedType'));
    if (infoResponse.statusCode == 200) {
      final infoResult = jsonDecode(infoResponse.body);
      activityNames[selectedType] = {};
      for (var infoItem in infoResult) {
        String gsinfoName = infoItem['gsinfo_name'];
        int gsinfoScore = infoItem['gsinfo_score'];
        activityNames[selectedType]![gsinfoName] = gsinfoScore;
      }
      setState(() {
        activityNames;
      });
    } else {
      throw Exception('Failed to load names and scores');
    }
  }
}

  List<String> activityTypes = [];
  Map<String, Map<String, int>> activityNames = {};

  TextEditingController _activityTypeController = TextEditingController();
  TextEditingController _activityNameController = TextEditingController();
  TextEditingController _activityScoreController = TextEditingController();
  TextEditingController _maxScoreController = TextEditingController();

Map<String, dynamic> MaxScore = {};

Future<void> _getMaxScore() async {
  final response = await http.get(
    Uri.parse('http://3.39.88.187:3000/gScore/maxScore'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
  );

  if (response.statusCode == 200) {
    final maxScoreTemp = jsonDecode(response.body);
    for (var item in maxScoreTemp) {
      String categoryName = item['max_category'];
      int categoryScore = item['max_score'];
      MaxScore[categoryName] = categoryScore;
    }
  } else {
    throw Exception('예외 발생');
  }
}

  void addActivityType() {
    String newActivityType = _activityTypeController.text;
    if (newActivityType.isNotEmpty &&
        !activityTypes.contains(newActivityType)) {
      setState(() {
        activityTypes.add(newActivityType);
        activityNames[newActivityType] = {};
        _activityTypeController.clear();
      });
    }
  }

  void addActivityName() {
    String selectedActivityType = activityTypes.first;
    String newActivityName = _activityNameController.text;
    int newActivityScore = int.tryParse(_activityScoreController.text) ?? 0;
    if (newActivityName.isNotEmpty &&
        !activityNames[selectedActivityType]!.containsKey(newActivityName)) {
      setState(() {
        activityNames[selectedActivityType]![newActivityName] =
            newActivityScore;
        _activityNameController.clear();
        _activityScoreController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '관리자 목록 편집',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Color(0xffC1D3FF),
        centerTitle: true,
        elevation: 0.0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Form(
          child: Center(
            child: ListView(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  // 활동 종류에 대한 드롭다운형식의 콤보박스
                  child: Text(
                    '활동종류 선택',
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Wrap(
                    spacing: 8.0,
                    children: activityTypes.map((type) {
                      return ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _activityTypeController.text = type;
                            _fetchNamesAndScores(_activityTypeController.text);
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _activityTypeController.text == type ? Color(0xffbabfcc) : Color(0xffC1D3FF),
                          elevation: _activityTypeController.text == type ? 2.0 : 0.0,
                        ),
                        child: Text(type),
                      );
                    }).toList(),
                  ),
                ),


                Padding(
                  padding: const EdgeInsets.all(8.0),
                  // 활동 종류에 대한 드롭다운형식의 콤보박스
                  child: Text(
                    '활동명 삭제및 추가',
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  // 활동 종류에 대한 드롭다운형식의 콤보박스
                  child: Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _activityNameController,
                          decoration: InputDecoration(
                            labelText: '활동명',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      SizedBox(width: 8.0),
                      Expanded(
                        child: TextFormField(
                          controller: _activityScoreController,
                          decoration: InputDecoration(
                            labelText: '점수',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      SizedBox(width: 8.0),
                      ElevatedButton(
                        onPressed: addActivityName,
                        child: Text('추가'),
                      ),
                    ],
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    height: 200,  // 세로 크기 제한
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,  // 세로 스크롤 가능
                      child: Wrap(
                        spacing: 8.0,
                        children: activityNames[_activityTypeController.text]?.entries.map((entry) {
                          String name = entry.key;
                          int score = entry.value;
                          return Chip(
                            label: Text('$name ($score)'),
                            onDeleted: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Text('삭제'),
                                    content: Text('정말로 활동명과 점수를 삭제하시겠습니까? 정말로?'),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: Text('취소'),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          setState(() {
                                            activityNames[_activityTypeController.text]?.remove(name);
                                          });
                                          Navigator.of(context).pop();
                                        },
                                        child: Text('삭제'),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                          );
                        }).toList() ?? <Widget>[],
                      ),
                    ),
                  ),
                ),


                Padding(
                  padding: const EdgeInsets.all(8.0),
                  // 활동 종류에 대한 드롭다운형식의 콤보박스
                  child: Text(
                    '최고점수 설정',
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(8.0),
                  // 활동 종류에 대한 드롭다운형식의 콤보박스
                  child: Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _maxScoreController,
                          decoration: InputDecoration(
                            labelText: '점수',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      SizedBox(width: 8.0),
                      ElevatedButton(
                        onPressed: () {
                          String selectedType = _activityTypeController.text;
                          int newScore = int.tryParse(_maxScoreController.text) ?? 0;
                          setState(() {
                            MaxScore[selectedType] = newScore;
                          });
                          print(MaxScore);
                        },
                        child: Text('수정'),
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
