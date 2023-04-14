import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(MaterialApp(
    title: '졸업점수 셀프 계산기',
    home: SelfCalcScreen(),
  ));
}

class SelfCalcScreen extends StatefulWidget {
  const SelfCalcScreen({Key? key}) : super(key: key);

  @override
  SelfCalcScreenState createState() => SelfCalcScreenState();
}

class SelfCalcScreenState extends State<SelfCalcScreen> {
  @override
  void initState(){
    super.initState();
    _fetchPosts();
  }
  String? _activityType;

  String? _activityName;

  int? _score;

  final List<Map<String, dynamic>> _save = [];

  int _total = 0;

  int _remainingScore = 800;

  List<String> activityTypes = [];

  Map<String, Map<String,int>> activityNames = {
    '상담 실적': {'1':10,'2':20,'3':30,'4':40,'5':50,'6':60,'7':70,'8':80,'9':90,'10':100,'11':110,'12':120,'13':130,'14':140,'15':150},
    '해외 연수': {'30~39일':50, '40~49일':80, '50일 이상':0
    },
    '인턴쉽': {'30~39일':50, '40~49일':80, '50일 이상':0
    },
  };



  Future<void> _fetchPosts() async {
    final response = await http
        .get(Uri.parse('http://3.39.88.187:3000/gScore/info'));

    if (response.statusCode == 200) {
      final funcResult =  jsonDecode(response.body);
      for (var item in funcResult) {
        String gsinfoType = item['gsinfo_type'];
        if (!activityTypes.contains(gsinfoType)) {
          activityTypes.add(gsinfoType);
          if(!['상담 실적', '해외 연수', '인턴쉽'].contains(gsinfoType)){
            activityNames[gsinfoType] = {};
          }

          setState(() {
            activityTypes;
            activityNames;
          });
        }

        String gsinfoName = item['gsinfo_name'];
        int gsinfoScore = item['gsinfo_score'];

        if (!['상담 실적', '해외 연수', '인턴쉽'].contains(gsinfoType) &&activityNames.containsKey(gsinfoType)) {
          activityNames[gsinfoType]![gsinfoName] = gsinfoScore;
        }

      }
    } else {
      throw Exception('Failed to load posts');
    }
  }



  void _onActivityTypeChanged(String? newValue) {
    setState(() {
      _activityType = newValue;
      _activityName = null;
    });
  }

  void _onActivityNameChanged(String? newValue) {
    setState(() {
      _activityName = newValue;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '졸업점수 셀프 계산기',
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
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: '활동 종류',
                border: OutlineInputBorder(),
              ),
              value: _activityType,
              onChanged: _onActivityTypeChanged,
              items: activityTypes
                  .map<DropdownMenuItem<String>>(
                      (String value) => DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          ))
                  .toList(),
            ),
            const SizedBox(height: 16),
            // 활동명에 대한 드롭다운형식의 콤보박스
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: '활동명',
                border: OutlineInputBorder(),
              ),
              value: _activityName,
              onChanged: _onActivityNameChanged,
              items: activityNames[_activityType]
                      ?.entries
                      .map<DropdownMenuItem<String>>(
                          (MapEntry<String, int> entry) =>
                              DropdownMenuItem<String>(
                                value: entry.key,
                                child: Text(entry.key),
                              ))
                      .toList() ??
                  [],
            ),
            const SizedBox(height: 16),

            TextFormField(
              readOnly: _activityName == 'TOPCIT' ||
                  _activityName == '50일 이상'
                  ? false : true,
              decoration: const InputDecoration(
                labelText: '점수',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                if (value.isNotEmpty) {
                  _score = int.parse(value) * 2;
                  if(_activityName == 'TOPCIT' && (_score ?? 0) > 1000){
                    _score = 1000;
                  }
                  if(_activityType == '인턴쉽' && (_score ?? 0) > 300){
                    _score = 300;
                  }
                  if(_activityType == '해외 연수' && (_score ?? 0) > 200){
                    _score = 200;
                  }
                }

                else {
                  _score = 0;
                }
              },
              controller: TextEditingController(
                  text: activityNames[_activityType]?[_activityName]?.toString() ?? ''
              ),
            ),
            SizedBox(height: 16.0),

            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    readOnly: true,
                    decoration: const InputDecoration(
                      labelText: '취득 점수',
                      border: OutlineInputBorder(),
                    ),
                    controller: TextEditingController(text: _total.toString()),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    readOnly: true,
                    decoration: const InputDecoration(
                      labelText: '남은 점수',
                      border: OutlineInputBorder(),
                    ),
                    controller:
                        TextEditingController(text: _remainingScore.toString()),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Material(
                elevation: 5.0, //그림자효과
                borderRadius: BorderRadius.circular(30.0), //둥근효과
                color: const Color(0xffC1D3FF),
                child: MaterialButton(
                  onPressed: () {
                    if (_activityName == '50일 이상' || _activityName == 'TOPCIT' && _activityType != null) {
                      setState(() {
                        _save.add({
                          'Type': _activityType!,
                          'Name': _activityName!,
                          'score': _score
                        });
                        _total +=
                            _score ?? 0;
                        if (_remainingScore > 0) {
                          _remainingScore = 800 - _total;
                          if (_remainingScore < 0) {
                            _remainingScore = 0;
                          }
                        }
                        _activityType = null;
                        _activityName = null;
                        print(_save);
                      });
                    }
                    else if (_activityName != null && _activityType != null) {
                      setState(() {
                        _save.add({
                          'Type': _activityType!,
                          'Name': _activityName!,
                          'score': activityNames[_activityType]?[_activityName]
                        });
                        _total +=
                            activityNames[_activityType]?[_activityName] ?? 0;
                        if (_remainingScore > 0) {
                          _remainingScore = 800 - _total;
                          if (_remainingScore < 0) {
                            _remainingScore = 0;
                          }
                        }
                        _activityType = null;
                        _activityName = null;
                        print(_save);
                      });
                    }
                  },
                  child: const Text(
                    "추가하기",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.grey,
                    width: 1.0,
                  ),
                  borderRadius: const BorderRadius.all(Radius.circular(4.0)),
                ),
                child: ListView.builder(
                  itemCount: _save.length,
                  itemBuilder: (BuildContext context, int index) {
                    final activity = _save[index];
                    return Dismissible(
                      key: UniqueKey(),
                      onDismissed: (direction) {
                        setState(() {
                          _save.removeAt(index);
                          _total -= activity['score'] as int;
                          if (_remainingScore >= 0) {
                            _remainingScore = 800 - _total;
                            if (_remainingScore <= 0) {
                              _remainingScore = 0;
                            }
                          }
                        });
                      },
                      background: Container(color: Colors.red),
                      child: ListTile(
                        title:
                            Text('${activity['Type']} - ${activity['Name']}'),
                        trailing: Text('${activity['score']}점'),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
