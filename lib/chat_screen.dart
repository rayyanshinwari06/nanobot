import 'package:nanobot/chat_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:characters/characters.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, dynamic>> _messages = [];
  final GeminiApiSevice _geminiApiService = GeminiApiSevice();
  final ScrollController _scrollController = ScrollController();
  bool _isTyping = false;

  // Send Message
  void _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add({'text': text, 'isUser': true});
      _messages.add({'text': '', 'isUser': false});
      _isTyping = true;
    });

    _controller.clear();
    _scrollToBottom();

    try {
      final response = await _geminiApiService.getChatResponse(text);
      await _showTypingEffect(response);
    } catch (e) {
      debugPrint(e.toString());
      setState(() {
        _messages.last['text'] = 'Failed to load response.';
      });
    } finally {
      _scrollToBottom();
    }
  }

  Future<void> _showTypingEffect(String fullText) async {
    setState(() {
      _isTyping = false;
    });
    String displayedText = '';
    final Characters characters = fullText.characters;

    for (final char in characters) {
      await Future.delayed(const Duration(milliseconds: 30));
      displayedText += char;
      setState(() {
        _messages.last['text'] = displayedText;
      });
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          const SafeArea(
            child: Padding(
              padding: EdgeInsets.only(top: 12.0),
              child: Text(
                'NanoBot',
                style: TextStyle(
                  fontSize: 30,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(8),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                return Align(
                  alignment: msg['isUser']
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: msg['isUser']
                          ? Colors.grey.shade900
                          : Colors.black,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      msg['text'],
                      style: const TextStyle(fontSize: 20, color: Colors.white),
                    ),
                  ),
                );
              },
            ),
          ),
          if (_isTyping)
            const Padding(
              padding: EdgeInsets.all(8),
              child: CircularProgressIndicator(),
            ),
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    textCapitalization: TextCapitalization.sentences,
                    onSubmitted: (_) => _sendMessage(),
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      hintStyle: const TextStyle(color: Colors.white),
                      filled: true,
                      fillColor: Colors.grey.shade900,
                      suffixIcon: IconButton(
                        icon: const Icon(
                          Icons.send_outlined,
                          color: Colors.white,
                        ),
                        onPressed: _sendMessage,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
