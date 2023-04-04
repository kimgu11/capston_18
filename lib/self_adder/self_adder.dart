import 'package:flutter/material.dart';

void main() {
  runApp(MaterialApp(
    title:'졸업점수 셀프 계산기',
    home:SelfAdder(),
  ));
}

class SelfAdder extends StatefulWidget {
  const SelfAdder ({Key? key}):super(key:key);
  @override
  _SelfAdderState createState() => _SelfAdderState();
}

class _SelfAdderState extends State<SelfAdder> {
  String? _activityType;

  String? _activityName;

  final List<Map<String, dynamic>> _save = [];

  int _total = 0;

  int _remainingScore = 800;

  final List<String> _activityTypes = [
    '취업',
    '자격증',
    '외국어 능력',
    '상담 실적',
    '학과 행사',
    '취업 훈련',
    '해외 연수',
    '인턴쉽',
    's/w 공모전',
    '졸업작품 입상',
    '캡스톤'
  ];

  final Map<String, Map<String,int>> _activityNames = {
    '취업': {'기업 취업':850, '대학원 진학':850, '군입대':850},
    '자격증': {'CISA':400,'CISSP':400,
  '중등학교정교사 2급':300,'정보처리기사':300,'전자계산기조직응용기사':300,'전자계산기기사':300,'정보보호전문가(SIS)1급':300,
  '웹프로그래머(WPC)1급':300,'네트워크관리사 1급':300,'인터넷보안전문가 자격증 1급':300,'정보보호기사':300,'MCSE':300,'MCSA':300,'MCITP':300,'MCTS':300,
  'MTA''MCDST':300,'MCDBA':300,'MCSD':300,'MCPD':300,'MTA':300,'MCAD':300,'OCP':300,'OCJAP':300,'OCPJP':300,'OCWCD':300,'OCBCD':300,
  'OCSA':300,'OCNA':300,'CCNA':300,'CCNP':300,'CCDA':300,'CCDP':300,'CCIE':300,'CCSP':300,'사무자동화산업기사':100,'정보처리산업기사':100,'전자계산기조직으용산업기사':100,
  '웹디자인산업기사':100,'정보보안산업기사(SIS) 2급':100,'리눅스 마스터 1급':100,'네트워크관리사 2급':100,'인터넷보안전문가 자격증 2급':100,'웹프로그래머(WPC) 2급':100,
 '정보처리기능사':50,'정보기기운용기능사':50,'전자계산기기능사':50,'멀티미디어콘텐츠제작전문가':50,'게임프로그램전문가':50,'게임그래픽전문가':50,'컴퓨터활용 1급':50,
  '리눅스마스터 2급':50,'전산회계기능사':50,'컴퓨터그래픽스운용기능사':50,'컴퓨터운용사':50,'점보시스템감리사':50,'웹디자인기능사':50,'웹프로그래머(WPC) 3급':50},
    '외국어 능력': {'TOEIC 400~499':100,'TOEIC 500~599':200,'TOEIC 600~699':300,'TOEIC 700~799':400,'TOEIC 800이상':500,'TEPS 167~194':100,'TEPS 195~226':200,
      'TEPS 227~263':300,'TEPS 264~308':400,'TEPS 309이상':500,'TOEFL 91이상':500,'TOEFL 80~90':400,'TOEFL 69~79':300,'TOEFL 56~68':200,'TOEFL 40~55':100,
      'JLPT 2급':350, 'TOPCIT':0},
    '상담 실적': {'1':10,'2':20,'3':30,'4':40,'5':50,'6':60,'7':70,'8':80,'9':90,'10':100,'11':110,'12':120,'13':130,'14':140,'15':150},
    '학과 행사': {'세미나':30,'현장견학':30,'임원':20,'MT':20,'체육대회':20,'학술제':20,'기타':20},
    '취업 훈련': {'1회':50, '2회':100, '3회':150},
    '해외 연수': {'30~39일':50, '40~49일':80, '50일':100,'51일':102, '52일':104,'53일':106,'54일':108,'55일':110,'56일':112,'57일':124,'58일':126,
      '59일':128,'60일':120,'61일':122,'62일':124,'63일':126,'64일':128,'65일':130,'66일':132,'67일':134,'68일':136,'69일':138, '70일':140,'71일':142,
      '72일':144,'73일':146,'74일':148,'75일':150,'76일':152,'77일':154,'78일':156,'79일':158,'80일':160,'81일':162,'82일':164,'83일':166,'84일':168,
      '85일':170,'86일':172, '87일':174,'88일':176,'89일':178,'90일':180,'91일':182,'92일':184,'93일':186,'94일':188,'95일':190,'96일':192,'97일':194,
      '98일':196,'99일':198,'100일 이상':200
    },
    '인턴쉽': {'30~39일':50, '40~49일':80, '50일':100,'51일':102, '52일':104,'53일':106,'54일':108,'55일':110,'56일':112,'57일':124,'58일':126,
  '59일':128,'60일':120,'61일':122,'62일':124,'63일':126,'64일':128,'65일':130,'66일':132,'67일':134,'68일':136,'69일':138, '70일':140,'71일':142,
  '72일':144,'73일':146,'74일':148,'75일':150,'76일':152,'77일':154,'78일':156,'79일':158,'80일':160,'81일':162,'82일':164,'83일':166,'84일':168,
  '85일':170,'86일':172, '87일':174,'88일':176,'89일':178,'90일':180,'91일':182,'92일':184,'93일':186,'94일':188,'95일':190,'96일':192,'97일':194,
  '98일':196,'99일':198,'100일':200,'101일':202,'102일':204, '103일':206,'104일':208,'105일':210,'106일':212,'107일':214,'108일':216,'109일':218,
  '110일':220,'111일':222,'112일':224,'113일':226, '114일':228,'115일':230,'116일':232,'117일':234,'118일':236,'119일':238,'120일':240,'121일':242,
  '122일':244,'123일':246,'124일':248,'125일':250,'126일':252,'127일':254,'128일':256,'129일':258,'130일':260,'131일':262,'132일':264,'133일':266,
  '134일':268,'135일':270,'136일':272,'137일':274,'138일':276,'139일':278, '140일':280,'141일':282,'142일':284,'143일':286,'144일':288,'145일':290,
  '146일':292,'147일':294,'148일':296,'149일':298,'150일 이상':300
  },
    's/w 공모전': {'전국 1등':600, '전국 2등':400, '전국 3등':300,'교내 1등':300,'교내 2등':200,'교내 3등':100},
    '졸업작품 입상': {'축하드려요~~':100},
    '캡스톤': {'캡스톤': 0}
  };

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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: const Text('졸업점수 셀프 계산기'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: '활동 종류',
                border: OutlineInputBorder(),
              ),
              value: _activityType,
              onChanged: _onActivityTypeChanged,
              items: _activityTypes
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
              items: _activityNames[_activityType]
                  ?.entries
                  .map<DropdownMenuItem<String>>(
                      (MapEntry<String, int> entry) => DropdownMenuItem<String>(
                    value: entry.key,
                    child: Text(entry.key),
                  ))
                  .toList() ??
                  [],

            ),
            const SizedBox(height: 16),
            Expanded(
              child: TextFormField(
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: '점수',
                  border: OutlineInputBorder(),
                ),
                controller:
                TextEditingController(text: _activityNames[_activityType]?[_activityName]?.toString() ?? ''),
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    readOnly: true,
                    decoration: const InputDecoration(
                      labelText: '취득 점수',
                      border: OutlineInputBorder(),
                    ),
                    controller:
                    TextEditingController(text: _total.toString()),
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
                    TextEditingController(text:_remainingScore.toString()),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton(
                onPressed: () {
                  if(_activityName != null && _activityType != null) {
                    setState(() {
                    _save.add({
                      'Type': _activityType!,
                      'Name': _activityName!,
                      'score': _activityNames[_activityType]?[_activityName]
                    });
                    _total += _activityNames[_activityType]?[_activityName]?? 0;
                    if(_remainingScore > 0){_remainingScore = 800 - _total;
                    if(_remainingScore < 0){_remainingScore = 0;}}
                    _activityType = null;
                    _activityName = null;
                    print(_save);
                    });
                  }
                },
                child: const Text('추가'),
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
                          if(_remainingScore >= 0){_remainingScore = 800 - _total;
                          if(_remainingScore <= 0) {_remainingScore = 0;}}
                        });
                      },
                      background: Container(color: Colors.red),
                      child: ListTile(
                        title: Text('${activity['Type']} - ${activity['Name']}'),
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