import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:io';

//신청창
void main() {
  runApp(MaterialApp(
    title: '관리자 신청 페이지',
    home: GScoreAdminRegist(),
  ));
}

class GScoreAdminRegist extends StatefulWidget {
  const GScoreAdminRegist({Key? key}) : super(key: key);

  @override
  _GScoreAdminRegistState createState() => _GScoreAdminRegistState();
}

class _GScoreAdminRegistState extends State<GScoreAdminRegist> {
  void initState() {
    super.initState();
  }


  Future<void> _writePostAndFile() async {
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

    final storage = FlutterSecureStorage();
    final token = await storage.read(key: 'token');
    if (token == null) {
      setState(() {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('실패: 로그인 정보 없음')));
      });
      return;
    }

    final Map<String, dynamic> postData = {
      'gspost_category': _activityType,
      'gspost_item': _activityName,
      'gspost_score': int.tryParse(_activityScore),
      'gspost_content': _contentController.text,
      'gspost_pass': _applicationStatus,
      'gspost_reason': _rejectionReason,
      'gspost_start_date': _startDate?.toIso8601String(),
      'gspost_end_date': _endDate?.toIso8601String(),
      'gspost_file': fileCheck,
    };

    final response = await http.post(
      Uri.parse('http://3.39.88.187:3000/gScore/write'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': token,
      },
      body: jsonEncode(postData),
    );

    print(response.statusCode);

    if (response.statusCode == 201) {
      postUploadCheck = 1;
      if (fileCheck == 1) {
        var jsonResponse = jsonDecode(response.body);
        postId = jsonResponse['postId'];
        //uploadFile();
      }
    } else {
      print(response.statusCode);
      print('에러');
    }
  }

  Future<void> uploadFile() async {
    print(postId.toString());

    if (selectedFile != null) {
      final String fileName = selectedFile!.name;
      final bytes = File(selectedFile!.path!).readAsBytesSync();

      final maxRetries = 3; // 최대 재시도 횟수
      var retryCount = 0; // 현재 재시도 횟수

      while (retryCount < maxRetries) {
        try {
          final request = http.MultipartRequest(
            'POST',
            Uri.parse('http://3.39.88.187:3000/gScore/upload'),
          );

          request.files.add(
            http.MultipartFile.fromBytes('file', bytes, filename: fileName),
          );

          request.fields['gspostid'] = postId.toString();

          final response = await request.send();
          print(response.statusCode);

          if (response.statusCode == 201) {
            print("파일 등록 성공");

            var responseData = await response.stream.bytesToString();
            var decodedData = json.decode(responseData);
            var file = decodedData['file'];

            fileInfo = {
              'post_id': postId,
              'file_name': file['filename'],
              'file_original_name': file['originalname'],
              'file_size': file['size'],
              'file_path': file['path'],
            };
            fileUploadCheck = 1;

            print(fileInfo);
            return; // 성공적으로 요청을 보냈으면 메서드를 종료
          } else {
            print(response.statusCode);
            print("파일 등록 실패");
          }
        } catch (error) {
          print('등록 네트워크 연결 오류: $error');
        }

        retryCount++;
        await Future.delayed(Duration(seconds: 1)); // 1초 후에 재시도
      }

      print('재시도 횟수 초과');
    }
  }

  Future<void> _uploadfileToDB() async {
    final maxRetries = 3; // 최대 재시도 횟수
    var retryCount = 0; // 현재 재시도 횟수

    while (retryCount < maxRetries) {
      try {
        final response = await http.post(
          Uri.parse('http://3.39.88.187:3000/gScore/fileToDB'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(fileInfo),
        );

        if (response.statusCode == 201) {
          print('DB저장 완료');
          return; // 성공적으로 요청을 보냈으면 메서드를 종료
        } else {
          print(response.statusCode);
          print('에러');
        }
      } catch (error) {
        print('DB 네트워크 연결 오류: $error');
      }

      retryCount++;
      await Future.delayed(Duration(seconds: 1)); // 1초 후에 재시도
    }

    print('재시도 횟수 초과'); // 최대 재시도 횟수를 초과하면 에러 메시지 출력
  }

  Future<void> _getuserInfo() async {
    final response = await http.get(
      Uri.parse('http://3.39.88.187:3000/gScore/allUser'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );
    if (response.statusCode == 200) {
      final maxScoreTemp = jsonDecode(response.body);
      for (var item in maxScoreTemp) {
        String username = item['name'];
        int userid = item['student_id'];
        userInfo[userid] = username;
      }
    } else {
      throw Exception('예외 발생');
    }
  }

  //학생정보 리스트
  Map<int, String> userInfo = {
    20180621: "김민구",
    20160620: "곽예빈",
    20170619: "이나훈",
    20180618: "박태수"
  };
  Map<int, String> userInfosave = {};
  TextEditingController _userid = TextEditingController();
  int? _searchId;

  bool isEditable = false;

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
  TextEditingController _contentController = TextEditingController();

  // 반려 사유를 입력할 수 있는 텍스트 입력박스에서 입력된 값
  String? _rejectionReason;

  //파일이 저장값
  PlatformFile? selectedFile;

  int fileCheck = 0;

  //작성된 게시글 번호
  int postId = 0;

  //게시글이 정상적으로 업로드 되었는지 체크
  int postUploadCheck = 0;

  //파일이 정상적으로 서버에 업로드 되었는지 체크
  int fileUploadCheck = 0;

  //업로드한 파일의 정보
  Map<String, dynamic> fileInfo = {};

  //활동종류
  String _activityType = "관리자 승인";
  // 활동명에 대한 드롭다운형식의 콤보박스에서 선택된 값


  //활동명 리스트
  TextEditingController _activityNames = TextEditingController();
  String? _activityName;

  TextEditingController _scoreController = TextEditingController();

  final _formKey = GlobalKey<FormState>();


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '관리자 신청 페이지',
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
                  child: Expanded(
                    child: TextFormField(
                      readOnly: true,
                      initialValue: _activityType, // 값을 넣어줍니다.
                      decoration: InputDecoration(
                        labelText: '활동종류',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Expanded(
                    child: TextFormField(
                      controller: _activityNames, // 값을 넣어줍니다.
                      decoration: InputDecoration(
                        labelText: '활동명',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextFormField(
                          controller: _scoreController,
                          decoration: const InputDecoration(
                            labelText: '점수',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                          ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Stack(
                          children: [
                            TextFormField(
                              controller: _userid,
                              decoration: const InputDecoration(
                                labelText: '학생 추가',
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                              onChanged: (value) {
                                setState(() {
                                  _searchId = int.tryParse(value);
                                });
                              },
                            ),
                            Positioned(
                              right: 0,
                              top: 0,
                              bottom: 0,
                              child: Material(
                                borderRadius: BorderRadius.circular(24.0),
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () {
                                    // 버튼을 눌렀을 때 동작할 코드를 추가하세요.
                                    // 예를 들면, 학생을 추가하는 로직을 구현할 수 있습니다.
                                    if (_searchId != null) {
                                      print('검색 키워드: $_searchId');
                                    }
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Icon(Icons.add),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: userInfo.length,
                    itemBuilder: (context, index) {
                      int key = userInfo.keys.elementAt(index);
                      String? name = userInfo[key];

                      if (_searchId != null && key.toString().startsWith(_searchId.toString())) {
                        return ListTile(
                          title: Text('$name($key)'),
                          onTap: () {
                            setState(() {
                              _userid.text = key.toString();
                            });
                          },
                        );
                      } else {
                        return SizedBox.shrink();
                      }
                    },
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    decoration: const InputDecoration(
                      labelText: '비고',
                      border: OutlineInputBorder(),
                    ),
                    controller: _contentController,
                  ),
                ),
                // 신청 상태에 대한 드롭다운형식의 콤보박스
                const SizedBox(height: 8),
                // 저장 버튼
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Material(
                    elevation: 5.0, //그림자효과
                    borderRadius: BorderRadius.circular(30.0), //둥근효과
                    color: const Color(0xffC1D3FF),
                    child: MaterialButton(
                      onPressed: () async {
                        await _writePostAndFile();
                        if (fileUploadCheck == 1) {
                          await _uploadfileToDB();
                        }
                        if (postUploadCheck == 1) {
                          Navigator.of(context).pop();
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('게시글 작성 실패: 서버 오류')));
                        }
                      },
                      child: const Text(
                        "저장",
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
