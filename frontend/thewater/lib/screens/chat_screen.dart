//auther: Jeong JuHa
//Date: 2025.04.09
//Description: 챗봇 화면

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:thewater/providers/user_provider.dart';
import 'package:provider/provider.dart';
//widgets
import 'widgets/message_bubble.dart';
import 'widgets/loading_bubble.dart';

class FourthPage extends StatefulWidget {
  const FourthPage({super.key});

  @override
  State<FourthPage> createState() => _FourthPageState();
}

class _FourthPageState extends State<FourthPage> {
  @override
  Widget build(BuildContext context) {
    return const ChatScreen();
  }
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  List<Map<String, dynamic>> messages = [];
  bool isLoading = false;

  void sendMessage() async {
    final input = _controller.text.trim();
    if (input.isEmpty) return;
    final user=Provider.of<UserModel>(context, listen: false);
    

    setState(() {
      messages.add({"text": input, "isUser": true});
      isLoading = true;
      _controller.clear();
    });

    final url = Uri.parse('http://j12c201.p.ssafy.io:8000/chat'); 
    try {
      final res = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "question": input,
          "session_id":user.loginId
        }),
      );

      final decodedBody = utf8.decode(res.bodyBytes);
      final data = jsonDecode(decodedBody);
      setState(() {
        messages.add({"text": data["response"], "isUser": false});
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        messages.add({"text": "서버 오류: ${e.toString()}", "isUser": false});
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('조태공의 낚시 이야기', style:TextStyle(fontWeight: FontWeight.bold))),
      body:Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/image/chat_back.png'), // 도감 배경
            fit: BoxFit.cover,
          ),
        ),
        child:Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: messages.length + (isLoading ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == messages.length) {
                  return const LoadingBubble();
                }
                final msg = messages[index];
                return MessageBubble(text: msg["text"], isUser: msg["isUser"]);
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 6, 8, 20),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    onSubmitted: (_) => sendMessage(),
                    decoration: const InputDecoration(
                      hintText: '낚시에 대해 뭐든지 물어보시오.',
                      filled: true,
                      fillColor: Color(0xAAFFFFFF),
                      contentPadding: EdgeInsets.symmetric(vertical: 4, horizontal: 12),
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: sendMessage,
                  color: Color(0XFF176B87)
                )
              ],
            ),
          ),
        ],
      ),
      )
    );
  }
}
