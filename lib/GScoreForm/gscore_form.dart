import 'package:flutter/material.dart';
import 'package:adder_main/GScoreForm/gscore_Application.dart';
import 'package:adder_main/GScoreForm/gscore_apcCt.dart';

void main() {
  runApp(MaterialApp(
    title: '졸업점수 신청 목록',
    home: GScoreApcForm(),
  ));
}

class GScoreApcForm extends StatefulWidget {
  const GScoreApcForm({Key? key}) : super(key: key);

  @override
  _GScoreApcFormState createState() => _GScoreApcFormState();
}

class _GScoreApcFormState extends State<GScoreApcForm> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '졸업점수',
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
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => GScoreApc()),
                );
              },
              child: Text(
                '졸업점수 신청',
                style: TextStyle(fontSize: 20),
              ),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 20.0),
                backgroundColor: Color(0xffC1D3FF),
              ),
            ),
            SizedBox(height: (16.0)),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => GScoreApcCt()),
                );
              },
              child: Text(
                '졸업점수 수정 삭제',
                style: TextStyle(fontSize: 20),
              ),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 20.0),
                backgroundColor: Color(0xffC1D3FF),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
