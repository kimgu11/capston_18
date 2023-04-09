import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:capstone/screens/gScore/gscore_form.dart';
//조회,수정창
void main() {
  runApp(MaterialApp(
    title: '신청글 조회/수정',
  ));
}

class GScoreApcCt extends StatefulWidget {
  final dynamic post;

  GScoreApcCt({required this.post});

  @override
  _GScoreApcCtState createState() => _GScoreApcCtState();
}

class _GScoreApcCtState extends State<GScoreApcCt> {

  dynamic _post;

  @override
  void initState() {
    super.initState();
    _fetchPosts();
    _fetchContent();
    // do something with _post
  }

  Future<void> _fetchPosts() async {
    final response = await http
        .get(Uri.parse('http://192.168.219.170:3000/gScore/info'));

    if (response.statusCode == 200) {
      final funcResult =  jsonDecode(response.body);
      for (var item in funcResult) {
        String gsinfoType = item['gsinfo_type'];
        if (!activityTypes.contains(gsinfoType)) {
          activityTypes.add(gsinfoType);
          activityNames[gsinfoType] = {};

          setState(() {
            activityTypes = activityTypes;
            activityNames = activityNames;
          });
        }

        String gsinfoName = item['gsinfo_name'];
        int gsinfoScore = item['gsinfo_score'];

        if (activityNames.containsKey(gsinfoType)) {
          activityNames[gsinfoType]![gsinfoName] = gsinfoScore;
        }

      }
    } else {
      throw Exception('Failed to load posts');
    }
  }


  void _fetchContent(){
    setState(() {
      //_typeController.text = widget.post['gspost_type'].toString();
      _activityType = widget.post['gspost_category'];

      //_nameController.text = widget.post['gspost_item'].toString();
      _activityName = widget.post['gspost_item'];

      //_startDateController.text = widget.post['gspost_start_date'].toString();
     if(widget.post['gspost_start_date']!=null) {
       _startDate = DateTime.parse(widget.post['gspost_start_date']);
     }
      //_endDateController.text = widget.post['gspost_end_date'].toString();
      if(widget.post['gspost_end_date']!=null) {
        _endDate = DateTime.parse(widget.post['gspost_end_date']);
      }
      //_scoreController.text = widget.post['gspost_score'].toString();
      _activityScore = widget.post['gspost_score'].toString();

      //_selfScoreController.text = widget.post[''].toString();
      //_statusController.text = widget.post['gspost_pass'].toString();
      _applicationStatus = widget.post['gspost_pass'].toString();

      if(widget.post['gspost_content']!=null) {
        _content = widget.post['gspost_content'].toString();
      }

      //_reasonController.text = widget.post['gspost_reason'].toString();
      if(widget.post['gspost_reason']!=null) {
        _rejectionReason = widget.post['gspost_reason'].toString();
      }

    });
  }

  // 활동 종류에 대한 드롭다운형식의 콤보박스에서 선택된 값
  String? _activityType;

  // 활동명에 대한 드롭다운형식의 콤보박스에서 선택된 값
  String? _activityName;

  // 시작 날짜 선택박스에서 선택된 값
  DateTime? _startDate;

  // 종료 날짜 선택박스에서 선택된 값
  DateTime? _endDate;

  // 활동 기간 저장 값
  int? _period;

  //점수값
  String _activityScore='';

  // 점수를 입력할 수 있는 박스에서 입력된 값
  int? _score;
  int? _TopcitScore;

  // 신청 상태에 대한 드롭다운형식의 콤보박스에서 선택된 값
  String? _applicationStatus;

  String? _content;

  // 반려 사유를 입력할 수 있는 텍스트 입력박스에서 입력된 값
  String? _rejectionReason;

  //파일이 저장값
  List<PlatformFile?> _attachmentFile = [];

  //파일명
  final Map<String?, String?> _Filenames = {};

  List<String> activityTypes = []; //활동 종류(카테고리)

  Map<String, Map<String, int>> activityNames = {}; //활동명, 점수

  void _onActivityTypeChanged(String? newValue) {
    setState(() {
      _activityType = newValue;
      _activityName = null;
    });
  }

  final _formKey = GlobalKey<FormState>();

  void _onActivityNameChanged(String? newValue) {
    setState(() {
      _activityName = newValue;
    });
  }

  void _calculateResult() {
    if (_startDate != null && _endDate != null) {
      final duration = _endDate!.difference(_startDate!).inDays + 1;
      _period = duration * 2;
    } else {
      _period = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '신청글 조회/수정',
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
          key: _formKey,
          child: Center(
            child: ListView(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  // 활동 종류에 대한 드롭다운형식의 콤보박스
                  child: DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: '활동 종류',
                      border: OutlineInputBorder(),
                    ),
                    value: _activityType,
                    validator: (value) =>
                    (value!.isEmpty) ? "asd" : null,
                    onChanged: _onActivityTypeChanged,
                    items: activityTypes
                        .map<DropdownMenuItem<String>>(
                            (String value) => DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        ))
                        .toList(),
                  ),
                ), //padding1
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
                ), //padding2
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
                ), //padding3
                // 점수 출력박스와 입력박스
                Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextFormField(
                          readOnly: true,
                          decoration: const InputDecoration(
                            labelText: '점수',
                            border: OutlineInputBorder(),
                          ),
                          controller: TextEditingController(
                              text: _activityName == 'TOPCIT'
                                  ? _TopcitScore.toString()
                                  : _activityName == '50일 이상'
                                  ? _period.toString()
                                  : activityNames[_activityType]?[_activityName]?.toString() ?? ''
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextFormField(
                          decoration: const InputDecoration(
                            labelText: '점수 입력',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                          onChanged: (value) {
                            setState(() {
                              _score = int.tryParse(value);
                              _TopcitScore = (_score ?? 0) * 2;
                            });
                          },
                        ),
                      ),
                    ),
                  ],
                ),

                Padding(
                  padding: const EdgeInsets.all(8.0),
                  // 활동 종류에 대한 드롭다운형식의 콤보박스
                  child: DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: '신청 상태',
                      border: OutlineInputBorder(),
                    ),
                    value: _applicationStatus,
                    items: const [
                      DropdownMenuItem(value: '승인 대기', child: Text('승인 대기')),
                      DropdownMenuItem(value: '승인 완료', child: Text('승인 완료')),
                      DropdownMenuItem(value: '반려', child: Text('반려')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _applicationStatus = value ?? '';
                      });
                    },
                  ),
                ),

                //비고란
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    decoration: const InputDecoration(
                      labelText: '비고',
                      border: OutlineInputBorder(),
                    ),
                    controller: TextEditingController(
                        text: _content),
                    onChanged: (value) {
                      setState(() {
                        _content = value;
                      });
                    },
                  ),
                ),
                // 신청 상태에 대한 드롭다운형식의 콤보박스

                // 반려 사유 입력박스
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  // 활동 종류에 대한 드롭다운형식의 콤보박스
                  child: TextFormField(
                    decoration: const InputDecoration(
                      labelText: '반려 사유',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _rejectionReason = value;
                      });
                    },
                  ),
                ),
                SizedBox(height: 8.0),
                // 첨부파일 업로드박스
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Material(
                    elevation: 5.0, //그림자효과
                    borderRadius: BorderRadius.circular(30.0), //둥근효과
                    color: const Color(0xffC1D3FF),
                    child: MaterialButton(
                      onPressed: () async {
                        final result = await FilePicker.platform.pickFiles();
                        if (result != null) {
                          setState(() {
                            _attachmentFile.add(result.files.single);
                            _Filenames.addAll(
                                {'파일명': result.files.single.name});
                          });
                        }
                      },
                      child: const Text(
                        "첨부파일 업로드",
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

                // 활동 종류에 대한 드롭다운형식의 콤보박스
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(
                          width: 2.0,
                          color: Colors.grey.withOpacity(0.5),
                        ),
                        borderRadius:
                        const BorderRadius.all(Radius.circular(4.0)),
                      ),
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: _attachmentFile.length,
                        itemBuilder: (BuildContext context, int index) {
                          return Dismissible(
                            key: UniqueKey(),
                            onDismissed: (direction) {
                              setState(() {
                                _attachmentFile.removeAt(index);
                                _Filenames.removeWhere((key, value) => false);
                              });
                            },
                            background: Container(color: Colors.red),
                            child: ListTile(
                              title: Text('$_Filenames'),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 8.0),

                Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Material(
                        elevation: 5.0, //그림자효과
                        borderRadius: BorderRadius.circular(30.0), //둥근효과
                        color: const Color(0xffC1D3FF),
                        child: MaterialButton(
                          onPressed: () {
                            // 여기에 저장 버튼 클릭 시 수행할 동작을 작성합니다.
                            print('저장 버튼이 클릭되었습니다.');
                            print('활동 종류: $_activityType');
                            print('활동명: $_activityName');
                            print('시작 날짜: $_startDate');
                            print('종료 날짜: $_endDate');
                            print('점수: $_score');
                            print('신청 상태: $_applicationStatus');
                            print('반려 사유: $_rejectionReason');
                            print('첨부 파일: ${_attachmentFile}');
                          },
                          child: const Text(
                            "삭제하기",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Material(
                        elevation: 5.0, //그림자효과
                        borderRadius: BorderRadius.circular(30.0), //둥근효과
                        color: const Color(0xffC1D3FF),
                        child: MaterialButton(
                          onPressed: () {
                            // 여기에 저장 버튼 클릭 시 수행할 동작을 작성합니다.
                            print('저장 버튼이 클릭되었습니다.');
                            print('활동 종류: $_activityType');
                            print('활동명: $_activityName');
                            print('시작 날짜: $_startDate');
                            print('종료 날짜: $_endDate');
                            print('점수: $_score');
                            print('신청 상태: $_applicationStatus');
                            print('반려 사유: $_rejectionReason');
                            print('첨부 파일: ${_attachmentFile}');
                          },
                          child: const Text(
                            "수정하기",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child:  Material(
                        elevation: 5.0, //그림자효과
                        borderRadius: BorderRadius.circular(30.0), //둥근효과
                        color: const Color(0xffC1D3FF),
                        child: MaterialButton(
                          onPressed: () {
                            // 여기에 저장 버튼 클릭 시 수행할 동작을 작성합니다.
                            Navigator.pop(context);
                          },
                          child: const Text(
                            "목록으로",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}