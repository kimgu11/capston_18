import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

//셀프계산기 창
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
  void initState() {
    super.initState();
    _fetchPosts();
  }
  int? _TopcitScore;
  String? _activityType;

  String? _activityName;

  // 시작 날짜 선택박스에서 선택된 값
  DateTime? _startDate;

  // 종료 날짜 선택박스에서 선택된 값
  DateTime? _endDate;

  // 활동 기간 저장 값
  int? _period;

  final List<Map<String, dynamic>> _save = [];

  int _total = 0;

  int _remainingScore = 800;

  final List<String> activityTypes = [
    '취업/대학원 진학',
    '자격증',
    '외국어 능력',
    '상담 실적',
    '학과 행사',
    '취업 훈련',
    '해외 연수',
    '인턴쉽',
    's/w 공모전',
    '졸업작품 입상',
    '캡스톤 디자인'
  ];

  Map<String, Map<String, int>> activityNames = {
    '취업/대학원 진학': {},
    '자격증': {},
    '외국어 능력': {},
    '상담 실적': {
      '1': 10,
      '2': 20,
      '3': 30,
      '4': 40,
      '5': 50,
      '6': 60,
      '7': 70,
      '8': 80,
      '9': 90,
      '10': 100,
      '11': 110,
      '12': 120,
      '13': 130,
      '14': 140,
      '15': 150
    },
    '학과 행사': {},
    '취업 훈련': {},
    '해외 연수': {'30~39일':50, '40~49일':80, '50일 이상':100},
    '인턴쉽': {'30~39일':50, '40~49일':80, '50일 이상':100},
    's/w 공모전': {},
    '졸업작품 입상': {},
    '캡스톤 디자인': {}
  };

  Future<void> _fetchPosts() async {
    final response =
        await http.get(Uri.parse('http://192.168.219.170:3000/gScore/info'));

    if (response.statusCode == 200) {
      final funcResult = jsonDecode(response.body);
      for (var item in funcResult) {
        String gsinfoType = item['gsinfo_type'];
        if (!['상담 실적', '해외 연수', '인턴쉽'].contains(gsinfoType)) {
          String gsinfoName = item['gsinfo_name'];
          int gsinfoScore = item['gsinfo_score'];

          if (activityNames.containsKey(gsinfoType)) {
            activityNames[gsinfoType]![gsinfoName] = gsinfoScore;
          }
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

  void _calculateResult() {
    if (_startDate != null && _endDate != null) {
      final duration = _endDate!.difference(_startDate!).inDays + 1;
      _period = duration * 2;
      if(_activityType == '인턴쉽'){
        if ((_period ?? 0) > 300){
          _period = 300;
        }
        if ((_period ?? 0) < 0){
          _period = 0;
        }
      }
      if(_activityType == '해외 연수'){
        if ((_period ?? 0) > 200){
          _period = 200;
        }
        if ((_period ?? 0) < 0){
          _period = 0;
        }
      }
    } else {
      _period = null;
    }
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
            Padding(
              padding: const EdgeInsets.all(8.0),
              // 활동 종류에 대한 드롭다운형식의 콤보박스
              child: DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: '활동 종류',
                  border: OutlineInputBorder(),
                ),
                value: _activityType,
                validator: (value) => (value!.isEmpty) ? "asd" : null,
                onChanged: _onActivityTypeChanged,
                items: activityTypes
                    .map<DropdownMenuItem<String>>(
                        (String value) => DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            ))
                    .toList(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              // 활동 종류에 대한 드롭다운형식의 콤보박스
              child: DropdownButtonFormField<String>(
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
                    .toList(), // null일 경우에 대한 처리
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextFormField(
                      readOnly: true,
                      decoration: const InputDecoration(
                        labelText: '시작 날짜',
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(Icons.date_range),
                      ),
                      onTap: () async {
                        final selectedDate = await showDatePicker(
                          context: context,
                          initialDate: _startDate ?? DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        setState(() {
                          _startDate = selectedDate;
                          _calculateResult();
                        });
                      },
                      controller: TextEditingController(
                        text: _startDate != null
                            ? '${_startDate!.year}-${_startDate!.month}-${_startDate!.day}'
                            : null,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextFormField(
                      readOnly: true,
                      decoration: const InputDecoration(
                        labelText: '종료 날짜',
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(Icons.date_range),
                      ),
                      onTap: () async {
                        final selectedDate = await showDatePicker(
                          context: context,
                          initialDate: _endDate ?? DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        setState(() {
                          _endDate = selectedDate;
                          _calculateResult();
                        });
                      },
                      controller: TextEditingController(
                        text: _endDate != null
                            ? '${_endDate!.year}-${_endDate!.month}-${_endDate!.day}'
                            : null,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child:TextFormField(
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: '점수',
                  border: OutlineInputBorder(),
                ),
                controller: TextEditingController(
                    text: _activityName == '50일 이상' ? _period.toString()
                        : activityNames[_activityType]?[_activityName]?.toString() ?? ''
                ),
                onChanged: _activityName == 'TOPCIT' ? (value){
                  try {
                    _TopcitScore = int.parse(value) * 2;
                  } catch (e) {
                    _TopcitScore = 0;
                  }
                }:null,
              ),
            ),

            Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextFormField(
                      readOnly: false,
                      decoration: const InputDecoration(
                        labelText: '취득 점수',
                        border: OutlineInputBorder(),
                      ),
                      controller:
                          TextEditingController(text: _total.toString()),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextFormField(
                      readOnly: true,
                      decoration: const InputDecoration(
                        labelText: '남은 점수',
                        border: OutlineInputBorder(),
                      ),
                      controller: TextEditingController(
                          text: _remainingScore.toString()),
                    ),
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
                    if (_activityName != null && _activityType != null) {
                      setState(() {
                        if(_activityName != '50일 이상') {
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
                        }
                        else if (_activityName == '50일 이상'){
                          _save.add({
                            'Type': _activityType!,
                            'Name': _activityName!,
                            'score': _period
                          });
                          _total += _period ?? 0;
                          if (_remainingScore > 0) {
                            _remainingScore = 800 - _total;
                            if (_remainingScore < 0) {
                              _remainingScore = 0;
                            }
                          }
                          _activityType = null;
                          _activityName = null;
                          print(_save);
                        }
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
