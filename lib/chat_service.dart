import 'dart:convert';

import 'package:http/http.dart' as http;

class GeminiApiSevice {
  List<Map<String, dynamic>> chatHistory = [];

  final String apiKey = 'AIzaSyAHGBioxTs0tZGVI5OqcW_32Ne2cGsbIc8';

  Future<String> getChatResponse(String userMessage) async {
    const url =
        "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent";

    chatHistory.add({
      'role': 'user',
      'parts': [
        {
          'text': '''
You are NanoBot 🤖 — a smart, friendly, and helpful assistant.

➡️ Respond casually and like a real human.
➡️ Always include fun, relevant emojis based on the message 🎉😊💡.
➡️ Do **not** start messages with "As an AI..." or introduce yourself repeatedly.
➡️ Keep replies short, friendly, and to the point — like chatting with a friend.

If the user asks for something complex, break it down simply. Be creative and fun!: $userMessage''',
        },
      ],
    });

    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json', 'X-goog-api-key': apiKey},
      body: jsonEncode({'contents': chatHistory}),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final reply = data['candidates'][0]['content']['parts'][0]['text'];
      chatHistory.add({
        'role': 'model',
        'parts': [
          {'text': reply},
        ],
      });

      return reply;
    } else {
      print('Api error ${response.body}');
      return 'Sorry something went wrong';
    }
  }
}
