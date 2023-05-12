import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:capstone/screens/gScore/gscore_list_screen.dart';

import 'dart:io';
import 'package:http_parser/http_parser.dart';

import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';

//신청창
void main() {
  runApp(MaterialApp(
    title: '졸업점수 신청',
    home: GScoreApc(),
  ));
}

class GScoreApc extends StatefulWidget {
  const GScoreApc({Key? key}) : super(key: key);

  @override
  _GScoreApcState createState() => _GScoreApcState();
}

class _GScoreApcState extends State<GScoreApc> {
  void initState() {
    super.initState();
    _fetchLists();
  }

  Future<void> _fetchLists() async {
    //목록 불러오기
    final response =
    await http.get(Uri.parse('http://3.39.88.187:3000/gScore/info'));

    if (response.statusCode == 200) {
      final funcResult = jsonDecode(response.body);
      for (var item in funcResult) {
        String gsinfoType = item['gsinfo_type'];
        if (!activityTypes.contains(gsinfoType)) {
          activityTypes.add(gsinfoType);
          activityNames[gsinfoType] = {};
        }

        String gsinfoName = item['gsinfo_name'];
        int gsinfoScore = item['gsinfo_score'];

        if (activityNames.containsKey(gsinfoType)) {
          activityNames[gsinfoType]![gsinfoName] = gsinfoScore;
        }
      }
      setState(() {
        activityTypes;
        activityNames;
      });
    } else {
      throw Exception('Failed to load posts');
    }
  }

  void _writePost() async {
    if (_activityType == null || _activityName == null) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('알림'),
            content: Text('활동 종류와 활동명은 필수 선택 항목입니다.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // 경고창 닫기
                },
                child: Text('확인'),
              ),
            ],
          );
        },
      );
      return; // 함수 종료
    }

    setState(() => _isLoading = true);

    final storage = FlutterSecureStorage();
    final token = await storage.read(key: 'token');
    if (token == null) {
      setState(() {
        _isLoading = false;
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('실패: 로그인 정보 없음')));
      });
      return;
    }

    // MultipartRequest 객체 생성
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('http://3.39.88.187:3000/gScore/write'),
    );

    // 헤더 설정
    request.headers.addAll({
      'Content-Type': 'multipart/form-data',
      'Authorization': token,
    });

    // 폼 데이터 추가
    request.fields['gspost_category'] = _activityType ?? '';
    request.fields['gspost_item'] = _activityName ?? '';
    request.fields['gspost_score'] = _activityScore;
    request.fields['gspost_content'] = _content ?? '';
    request.fields['gspost_pass'] = _applicationStatus;
    request.fields['gspost_reason'] = _rejectionReason ?? '';
    request.fields['gspost_start_date'] = _startDate?.toIso8601String() ?? '';
    request.fields['gspost_end_date'] = _endDate?.toIso8601String() ?? '';

    // 첨부 파일이 있는 경우, 파일 추가

    if (_files != null) {
      for (final file in _files!.files) {
        if (file.path != null) { // 추가된 null 검사
          // 파일을 MultipartFile로 변환
          final multipartFile = await http.MultipartFile.fromPath(
            'gs_file', // 서버에서 요청을 처리하는 데 사용되는 필드 이름
            file.path!, // Use the null assertion operator (!)
            filename: file.name,
          );

          // MultipartRequest 객체에 파일 추가
          request.files.add(multipartFile);
        }
      }
    }

    // 요청 전송
    var response = await request.send();

    if (response.statusCode == 201) {
      // Success
      Navigator.pop(context);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (BuildContext context) => GScoreForm(),
        ),
      );
    }
  }

  bool isEditable = false;
  bool _isLoading = false;

  // 활동 종류에 대한 드롭다운형식의 콤보박스에서 선택된 값
  String? _activityType;

  // 활동명에 대한 드롭다운형식의 콤보박스에서 선택된 값
  String? _activityName;

  //점수값
  String _activityScore = '';

  // 시작 날짜 선택박스에서 선택된 값
  DateTime? _startDate;

  // 종료 날짜 선택박스에서 선택된 값
  DateTime? _endDate;

  // 점수를 입력할 수 있는 박스에서 입력된 값
  int? _subscore;

  // 신청 상태에 대한 드롭다운형식의 콤보박스에서 선택된 값
  String _applicationStatus = '대기';

  //비고란
  String? _content;

  // 반려 사유를 입력할 수 있는 텍스트 입력박스에서 입력된 값
  String? _rejectionReason;

  //파일이 저장값
  List<PlatformFile?> _attachmentFile = [];

  FilePickerResult? _files;

  //파일명
  final Map<String?, String?> _Filenames = {};

  //활동종류 리스트
  List<String> activityTypes = [];

  //활동명 리스트
  Map<String, Map<String, int>> activityNames = {};

  final TextEditingController _scoreController = TextEditingController();

  //활동종류 드롭박스 눌렀을시 활동명을 초기화 해줘야 충돌이 안남
  void _onActivityTypeChanged(String? newValue) {
    setState(() {
      _activityType = newValue;
      _activityName = null;
      _scoreController.text = '';
      _activityScore = '';
    });
  }

  final _formKey = GlobalKey<FormState>();

  void _onActivityNameChanged(String? newValue) {
    setState(() {
      _activityName = newValue;
      _scoreController.text =
          activityNames[_activityType]?[_activityName]?.toString() ?? '';
      if(_activityName != '50일 이상' || _activityName !='TOPCIT') {
        _activityScore =
            activityNames[_activityType]?[_activityName]?.toString() ?? '';
      }
      else{
        _activityScore = _subscore.toString();
      }
    });
  }
  void _subscore_function(String value){
    if (value.isNotEmpty &&
        _activityName == 'TOPCIT' ||
        _activityName == '50일 이상') {
      _subscore = int.parse(value) * 2;
      if (_activityName == 'TOPCIT' &&
          (_subscore ?? 0) > 1000) {
        _subscore = 1000;
      }
      else if (_activityType == '인턴쉽' &&
          (_subscore ?? 0) > 300) {
        _subscore = 300;
      }
      else if (_activityType == '해외 연수' &&
          (_subscore ?? 0) > 200) {
        _subscore = 200;
      }
      _activityScore = _subscore.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '졸업점수 신청',
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
                    SizedBox(width: 8),
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
                // 점수 출력박스와 입력박스
                Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextFormField(
                          readOnly: _activityName == 'TOPCIT' ||
                              _activityName == '50일 이상'
                              ? false
                              : true,
                          decoration: const InputDecoration(
                            labelText: '점수',
                            border: OutlineInputBorder(),
                          ),
                          onChanged: _subscore_function,
                          controller: TextEditingController(
                              text: _activityName == 'TOPCIT' && _subscore != null ? _subscore.toString()
                                  : _activityName == '50일 이상' && _subscore != null ? _subscore.toString()
                                  : activityNames[_activityType]?[_activityName]?.toString() ?? ''
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
                            labelText: '승인 점수',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                          onChanged: (value) {
                            setState(() {
                            });
                          },
                        ),
                      ),
                    ),
                  ],
                ),

                //비고란
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    decoration: const InputDecoration(
                      labelText: '비고',
                      border: OutlineInputBorder(),
                    ),
                    controller: TextEditingController(text: _content),
                    onChanged: (value) {
                      setState(() {
                        _content = value;
                      });
                    },
                  ),
                ),

                // 신청 상태에 대한 드롭다운형식의 콤보박스
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: '신청 상태',
                      border: OutlineInputBorder(),
                    ),
                    value: _applicationStatus,
                    items: const [
                      DropdownMenuItem(value: '대기', child: Text('대기')),
                      DropdownMenuItem(value: '승인', child: Text('승인')),
                      DropdownMenuItem(value: '반려', child: Text('반려')),
                    ],
                    onChanged: isEditable
                        ? (value) {
                      setState(() {
                        _applicationStatus = value ?? '';
                      });
                    }
                        : null,
                  ),
                ),

                // 반려 사유 입력박스
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  // 활동 종류에 대한 드롭다운형식의 콤보박스
                  child: TextFormField(
                    readOnly: true,
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
                            _files = result;
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

/*
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
                                _files = null;
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

 */

                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.grey,
                          width: 1.0,
                        ),
                        borderRadius: BorderRadius.circular(4.0),
                      ),
                      labelText: '첨부 파일',
                      labelStyle: TextStyle(
                        fontSize: 16.0,
                      ),
                      suffix: _files != null && _files?.names != null
                          ? IconButton(
                        onPressed: () {
                          setState(() {
                            _files = null;
                          });
                          // 버튼이 눌렸을 때 수행할 동작
                        },
                        icon: Icon(
                          Icons.delete,
                          color: Colors.grey,
                        ),
                      )
                          : null,
                    ),
                    readOnly: true,
                    controller: TextEditingController(text: '${_files?.names ?? ''}'),
                  ),
                ),
                const SizedBox(height: 8),

                // 저장 버튼
                Padding(
                  //세번째 padding
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Material(
                    elevation: 5.0, //그림자효과
                    borderRadius: BorderRadius.circular(30.0), //둥근효과
                    color: const Color(0xffC1D3FF),
                    child: MaterialButton(
                      onPressed: _writePost,
                      child: const Text(
                        "신청하기",
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
          ),
        ),
      ),
    );
  }
}
