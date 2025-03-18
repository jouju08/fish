import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(
    MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: Colors.blue, // FAB 색상
        ),
      ),
      debugShowCheckedModeBanner: false,
      home: TheWater(),
    ),
  );
}

class TheWater extends StatefulWidget {
  const TheWater({super.key});

  @override
  State<TheWater> createState() => _TheWaterState();
}

class _TheWaterState extends State<TheWater> {
  int currentIndex = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: currentIndex,
        children: [FirstPage(), SecondPage()],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          print("클릭되었습니다");
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CameraPage()),
          );
        },
        child: const Icon(Icons.camera, color: Colors.white),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (newIndex) {
          print("selected new Index : $newIndex");
          setState(() {
            currentIndex = newIndex;
          });
        },

        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey, // 선택되지 않은 아이콘 색상
        showSelectedLabels: false, // 선택된 항목 label 숨기기
        showUnselectedLabels: false, // 선택되지 않은 항목 label 숨기기
        type: BottomNavigationBarType.fixed, // 선택시 아이콘 움직이지 않기
        backgroundColor: Colors.grey[100],
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: ""),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_pin_circle_outlined),
            label: "",
          ),
        ],
      ),
    );
  }
}

class FirstPage extends StatelessWidget {
  const FirstPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/background.png'),
                fit: BoxFit.cover,
              ),
            ),
            child: Center(
              child: Text("aquarium page", style: TextStyle(fontSize: 30)),
            ),
          ), //여기 Text 대신에 원하는 대로 페이지 구성하면 됨.
        ),
      ),
    );
  }
}

class SecondPage extends StatelessWidget {
  const SecondPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SizedBox(
          width: double.infinity,
          child: Center(
            child: Text("fishing point page", style: TextStyle(fontSize: 30)),
          ), //여기 Text 대신에 원하는 대로 페이지 구성하면 됨.
        ),
      ),
    );
  }
}

class CameraPage extends StatelessWidget {
  const CameraPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Camera page")),
      body: Center(
        child: Text("camera page", style: TextStyle(fontSize: 30)),
      ), //여기도 Text 대신에 원하는 대로 카메라 페이지 구성하면 됨.
    );
  }
}
