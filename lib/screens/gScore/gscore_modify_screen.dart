import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';







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

//메인
class _GScoreApcCtState extends State<GScoreApcCt> {

  String? _selectedActivityType;

  int userId = 0;
  int userPermission = 0;

  // 활동 종류에 대한 드롭다운형식의 콤보박스에서 선택된 값
  String? _activityType;

  // 활동명에 대한 드롭다운형식의 콤보박스에서 선택된 값
  String? _activityName;

  // 시작 날짜 선택박스에서 선택된 값
  DateTime? _startDate;

  // 종료 날짜 선택박스에서 선택된 값
  DateTime? _endDate;

  //점수값
  String _activityScore = '';

  // 점수를 입력할 수 있는 박스에서 입력된 값
  int? _mainscore;
  int? _subscore;

  // 신청 상태에 대한 드롭다운형식의 콤보박스에서 선택된 값
  String? _applicationStatus;

  String? _content;

  // 반려 사유를 입력할 수 있는 텍스트 입력박스에서 입력된 값
  String? _rejectionReason;




  //파일관련
  dynamic? uploadedFileData; //db에서 가져온 파일정보 json
  String? uploadedFilePath;
  String? uploadedFileName;


  int wasUploadedFile = 0; //업로드된 파일이 있었는가? 할당완료
  int fileCheck = 0; // 첨부파일이 있는가? 위 2개 변수 null인지 or연산자로 비교해서 대체 가능, 1이랑 같이 할당

  PlatformFile? selectedFile; //저장소에서 선택한 파일



  List<String> activityTypes = []; //활동 종류(카테고리)

  Map<String, Map<String, int>> activityNames = {}; //카테고리:{활동명:점수,}


  final _formKey = GlobalKey<FormState>();

  final TextEditingController _scoreController = TextEditingController();


  @override
  void initState() {
    super.initState();
    _fetchGsInfo();
    _fetchContent();
    _getUserInfo();

  }

  Future<void> _fetchGsInfo() async {
    final response =
    await http.get(Uri.parse('http://3.39.88.187:3000/gScore/info'));

    if (response.statusCode == 200) {
      final funcResult = jsonDecode(response.body);
      for (var item in funcResult) {
        String gsinfoType = item['gsinfo_type'];
        if (!activityTypes.contains(gsinfoType)) {
          activityTypes.add(gsinfoType);
          activityNames[gsinfoType] = {};

          setState(() {
            activityTypes;
            activityNames;
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

  void _fetchContent() {
    setState(() {
      _activityType = widget.post['gspost_category'];

      _activityName = widget.post['gspost_item'];

      if (widget.post['gspost_start_date'] != null) {
        _startDate = DateTime.parse(widget.post['gspost_start_date']);
      }

      if (widget.post['gspost_end_date'] != null) {
        _endDate = DateTime.parse(widget.post['gspost_end_date']);
      }

      _activityScore = widget.post['gspost_score'].toString();

      _applicationStatus = widget.post['gspost_pass'].toString();

      if (widget.post['gspost_content'] != null) {
        _content = widget.post['gspost_content'].toString();
      }



      if (widget.post['gspost_reason'] != null) {
        _rejectionReason = widget.post['gspost_reason'].toString();
      }

      wasUploadedFile = widget.post['gspost_file'];

      if(wasUploadedFile == 1){
        _getFileInfo();

      }
    });
  }

  Future<void> _getUserInfo() async {
    final storage = FlutterSecureStorage();
    final token = await storage.read(key: 'token');

    if (token == null) {
      return;
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
      userId = user['student_id'];
      userPermission = user['permission'];

      setState(() {
        userId;
        userPermission;
      });
    } else {
      throw Exception('예외 발생');
    }
  }

  Future<void> _getFileInfo() async {
    final response = await http.get(
      Uri.parse('http://3.39.88.187:3000/gScore/fileInfo?postId=${widget.post['gspost_id']}'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    if (response.statusCode == 200) {
      uploadedFileData = jsonDecode(response.body);
      uploadedFileName = uploadedFileData['file_original_name'];
      print(uploadedFileName);
      uploadedFilePath = uploadedFileData['file_path'];
      print(uploadedFilePath);

      setState(() {

      });
    } else {
      throw Exception('예외 발생');
    }
  }

  void _selectFile() async {
    final FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null && result.files.isNotEmpty) {
      setState(() {
        selectedFile = result.files.first;

      });
    }
  }

  Future<String?> downloadFile() async {

    final response = await http.get(
      Uri.parse('http://218.158.67.138:3000/gScore/download?reqPath=${Uri.encodeComponent(uploadedFilePath ?? '')}'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );


    if (response.statusCode == 200) {
      final bytes = response.bodyBytes;
      Directory? directory;

      // Android-specific code
      if (Platform.isAndroid) {
        directory = await getExternalStorageDirectory();
      } else {
        // iOS-specific code
        directory = await getApplicationDocumentsDirectory();
      }

      print(directory);

      if (directory != null) {
        final file = File('${directory.path}/$uploadedFileName');
        await file.writeAsBytes(bytes);
        return '파일이 다운로드 되었습니다';

      } else {
        return '저장 폴더 설정 오류';
      }
    } else if(response.statusCode == 404){
      return '파일이 존재하지 않습니다.';
    }
    else{
      return '파일 다운로드중 오류가 발생하였습니다.';
    }
  }

  void updateFile() async{
    if(selectedFile!=null){
      if(wasUploadedFile==1){
        deleteFile();
        uploadFile();
      }
      else{
        uploadFile();
      }

    }else{
      if(wasUploadedFile==1 && uploadedFileName==null){
        deleteFile();
      }

    }


  }

  void uploadFile() async{
    int postId = widget.post['gspost_id'];

    if(selectedFile == null){Navigator.pop(context);}

    else if(selectedFile!=null){
      final String fileName = selectedFile!.name;
      final bytes = File(selectedFile!.path!).readAsBytesSync();

      final request = http.MultipartRequest(
        'POST',
        Uri.parse('http://218.158.67.138:3000/gScore/upload'),
      );


      request.files.add(
        http.MultipartFile.fromBytes('file', bytes, filename: fileName),
      );

      request.fields['gspostid'] = postId.toString();

      final response = await request.send();

      if (response.statusCode == 201) {
        print("파일 등록 성공");
        Navigator.pop(context);

      } else {
        print(response.statusCode);
        print("파일 등록 실패");
      }

    }


  }

  void deleteFile() async {

    final response = await http.delete(
      Uri.parse('http://218.158.67.138:3000/gScore/deleteFile?reqPath=${Uri.encodeComponent(uploadedFilePath ?? '')}'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    if (response.statusCode == 200) {
      print('파일 삭제 성공');
    }else{
      print(response.statusCode);
      print('파일 삭제 실패');
    }

  }


  /*void _updatePost() async {
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

    final Map<String, dynamic> postData = {
      'gspost_category': _activityType,
      'gspost_item': _activityName,
      'gspost_score': int.tryParse(_activityScore),
      'gspost_content': _content,
      'gspost_pass': _applicationStatus,
      'gspost_reason': _rejectionReason,
      'gspost_start_date': _startDate?.toIso8601String(),
      'gspost_end_date': _endDate?.toIso8601String(),

      'gspost_file': null, //
    };

    final response = await http.put(
      Uri.parse('http://3.39.88.187:3000/gScore/update/${widget.post.id}'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': token,
      },
      body: jsonEncode(postData),
    );

    print(response.statusCode);

    if (response.statusCode == 201) {
      setState(() => _isLoading = false);
      Navigator.pop(context);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (BuildContext context) => GScoreForm()),
      );
    } else {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('실패: ${response.reasonPhrase}')),
      );
    }
  }

  void _deletePost() async {
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

    final response = await http.delete(
      Uri.parse('http://3.39.88.187:3000/gScore/delete/${widget.post.id}'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': token,
      },
    );

    if (response.statusCode == 201) {
      Navigator.pop(context);
      Navigator.pushReplacement(context,
        MaterialPageRoute(builder: (BuildContext context) => GScoreForm()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('실패: ${response.reasonPhrase}')),
      );
    }
  }*/


  //활동종류 드롭박스 눌렀을시 활동명을 초기화 해줘야 충돌이 안남
  void _onActivityTypeChanged(String? newValue) {
    setState(() {
      _activityType = newValue;
      _activityName = null;
      _scoreController.text = '';
      _activityScore = '';
    });
  }


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
      if(_mainscore != null) {
        _activityScore = _subscore.toString();
      }
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
                    value:
                    _applicationStatus == '승인' || _applicationStatus == '반려'
                        ? _activityType
                        : _selectedActivityType ?? _activityType,
                    onChanged:
                    _applicationStatus == '승인' || _applicationStatus == '반려'
                        ? null
                        : _onActivityTypeChanged,
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
                  // 활동명에 대한 드롭다운형식의 콤보박스
                  child: DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: '활동명',
                      border: OutlineInputBorder(),
                    ),
                    value: _activityName,
                    onChanged:
                    _applicationStatus == '승인' || _applicationStatus == '반려'
                        ? null
                        : _onActivityNameChanged,
                    items:
                    _applicationStatus == '승인' || _applicationStatus == '반려'
                        ? null
                        : activityNames[_activityType]
                        ?.entries
                        .map<DropdownMenuItem<String>>(
                            (MapEntry<String, int> entry) =>
                            DropdownMenuItem<String>(
                              value: entry.key,
                              child: Text(entry.key),
                            ))
                        .toList(),
                    // null일 경우에 대한 처리
                    disabledHint:
                    Text(_activityName ?? ''), // 비활성화 된 상태에서 선택된 값을 보여줌
                  ),
                ), //padding2

                Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextFormField(
                          readOnly: _applicationStatus == '승인' ||
                              _applicationStatus == '반려',
                          decoration: const InputDecoration(
                            labelText: '시작 날짜',
                            border: OutlineInputBorder(),
                            suffixIcon: Icon(Icons.date_range),
                          ),
                          onTap: _applicationStatus == '승인' ||
                              _applicationStatus == '반려'
                              ? null
                              : () async {
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
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextFormField(
                          readOnly: _applicationStatus == '승인' ||
                              _applicationStatus == '반려',
                          decoration: const InputDecoration(
                            labelText: '종료 날짜',
                            border: OutlineInputBorder(),
                            suffixIcon: Icon(Icons.date_range),
                          ),
                          onTap: _applicationStatus == '승인' ||
                              _applicationStatus == '반려'
                              ? null
                              : () async {
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
                ), //padding3
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
                          readOnly: userPermission != 2,
                          decoration: const InputDecoration(
                            labelText: '승인 점수',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                          onChanged: (value) {
                            setState(() {
                              _mainscore = int.tryParse(value);
                              _activityScore = _mainscore.toString();
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
                      onChanged: (userPermission == 2)
                          ? (value) {
                        setState(() {
                          _applicationStatus = value ?? '';
                          if (_applicationStatus == '대기' || _applicationStatus == '반려') {
                            _mainscore = 0;
                          }
                        });
                      }
                          : null,

                      items: [
                        DropdownMenuItem(value: '대기', child: Text('대기')),
                        DropdownMenuItem(value: '승인', child: Text('승인')),
                        DropdownMenuItem(value: '반려', child: Text('반려')),
                      ],
                    )),

                //비고란
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    readOnly: _applicationStatus == '승인' ||
                        _applicationStatus == '반려',
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

                // 반려 사유 입력박스
                Padding(
                    padding: const EdgeInsets.all(8.0),
                    // 활동 종류에 대한 드롭다운형식의 콤보박스
                    child: TextFormField(
                      decoration: const InputDecoration(
                        labelText: '반려 사유',
                        border: OutlineInputBorder(),
                      ),
                      enabled: userPermission == 2,
                      onChanged: (value) {
                        setState(() {
                          _rejectionReason = value;
                        });
                      },
                    )),
                SizedBox(height: 8.0),
                // 첨부파일 업로드박스
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Material(
                    elevation: 5.0, //그림자효과
                    borderRadius: BorderRadius.circular(30.0), //둥근효과
                    color: const Color(0xffC1D3FF),
                    child: MaterialButton(
                      onPressed: () {
                        if(uploadedFileName!=null){
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('게시글당 하나의 파일만 업로드 가능합니다.')));
                        }else{
                          _selectFile(); // 파일 선택 수행}
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
                      suffix: selectedFile != null
                          ? IconButton(
                        onPressed: () {
                          setState(() {
                            selectedFile = null;
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
                    controller: TextEditingController(text: '${selectedFile?.name ?? ''}',),
                  ),
                ),


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
                      labelText: '업로드된 파일',
                      labelStyle: TextStyle(
                        fontSize: 16.0,
                      ),
                      suffixIcon: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (uploadedFileName != null)
                            IconButton(
                              onPressed: ()async {
                                final String? downResult = await downloadFile();
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(downResult ?? '')));
                              },
                              icon: Icon(
                                Icons.file_download,
                                color: Colors.grey,
                              ),
                            ),
                          if (uploadedFileName!=null)
                            IconButton(
                              onPressed: () {
                                setState(() {
                                  uploadedFileName = null;
                                  fileCheck = 0;

                                });
                              },
                              icon: Icon(
                                Icons.delete,
                                color: Colors.grey,
                              ),
                            ),
                        ],
                      ),
                    ),
                    readOnly: true,
                    controller: TextEditingController(text: uploadedFileName ?? ''),

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
                          color: (userPermission == 2 || _applicationStatus == '대기')
                              ? const Color(0xffC1D3FF)
                              : const Color(0xff808080),
                          child: MaterialButton(
                            onPressed: /*_deletePost*/
                            (userPermission == 2 || _applicationStatus == '대기') ? () {
                              // 버튼 클릭 시 동작
                              //삭제 api
                              if(wasUploadedFile == 1){
                                deleteFile();
                              }


                            }
                                : null,
                            child: const Text(
                              "삭제하기",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          )),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Material(
                        elevation: 5.0, //그림자효과
                        borderRadius: BorderRadius.circular(30.0), //둥근효과
                        color: (userPermission == 2 || _applicationStatus == '대기')
                            ? const Color(0xffC1D3FF)
                            : const Color(0xff808080),
                        child: MaterialButton(
                          onPressed: (userPermission == 2 || _applicationStatus == '대기')
                              ? () {
                            updateFile();
                            Navigator.pop(context);

                            //수정 api

                          }
                              : null,
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
                      child: Material(
                        elevation: 5.0, //그림자효과
                        borderRadius: BorderRadius.circular(30.0), //둥근효과
                        color: const Color(0xffC1D3FF),
                        child: MaterialButton(
                          onPressed: () {

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
