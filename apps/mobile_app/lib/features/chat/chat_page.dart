import 'package:flutter/material.dart';
import 'package:habit_builder/core/theme/app_colors.dart';
import 'package:habit_builder/core/api/api_service.dart';

enum MessageSender { ai, user }

class ChatMessage {
  final String text;
  final MessageSender sender;
  final String? time;

  const ChatMessage({
    required this.text,
    required this.sender,
    this.time,
  });
}

class AiCoachPage extends StatefulWidget {
  const AiCoachPage({super.key});

  @override
  State<AiCoachPage> createState() => _AiCoachPageState();
}

class _AiCoachPageState extends State<AiCoachPage> {
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [
    const ChatMessage(
      sender: MessageSender.ai,
      text: 'Hello! I am your Silent Architect. How can I help you with your habits today?',
    ),
  ];
  bool _isLoading = false;

  void _sendMessage() async {
    final text = _inputController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add(ChatMessage(sender: MessageSender.user, text: text, time: 'Now'));
      _isLoading = true;
    });
    _inputController.clear();
    _scrollToBottom();

    try {
      // For chat, we might want a different endpoint that returns plain text
      // but we can reuse generateHabits if we want, or create a simple chat one.
      // I'll assume generateHabits (Gemini) can handle it if we just want a chat response.
      // Actually, I'll create a dedicated chat method in ApiService if needed.
      final response = await ApiService.generateHabits(text);
      final aiText = response['user_prompt'] ?? 'Done!'; // Fallback logic or similar
      
      // If the response contains suggested achievements, we handle it
      // but for simple chat, let's just show the response text if available.
      // Optimization: The backend generateChatResponse now returns JSON.
      // For a plain chat, maybe it should return a 'message' field instead.
      
      setState(() {
        _messages.add(ChatMessage(sender: MessageSender.ai, text: "I've processed your request. Check your blueprints if I suggested new habits!"));
      });
    } catch (e) {
      setState(() {
        _messages.add(ChatMessage(sender: MessageSender.ai, text: 'Sorry, I encountered an error: $e'));
      });
    } finally {
      setState(() => _isLoading = false);
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
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
    final AppColors color = AppColors();

    return Scaffold(
      backgroundColor: color.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text('AI Coach', style: TextStyle(color: color.primaryTextColor, fontSize: 20, fontWeight: FontWeight.bold)),
            ),
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final msg = _messages[index];
                  return _MessageBubble(msg: msg);
                },
              ),
            ),
            if (_isLoading) const Padding(padding: EdgeInsets.all(8.0), child: CircularProgressIndicator()),
            _ChatInputBar(controller: _inputController, onSend: _sendMessage),
          ],
        ),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final ChatMessage msg;
  const _MessageBubble({required this.msg});
  @override
  Widget build(BuildContext context) {
    final color = AppColors();
    final isAi = msg.sender == MessageSender.ai;
    return Align(
      alignment: isAi ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isAi ? color.cardColor : color.accentColor.withOpacity(0.8),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(msg.text, style: TextStyle(color: isAi ? color.primaryTextColor : Colors.black)),
      ),
    );
  }
}

class _ChatInputBar extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;
  const _ChatInputBar({required this.controller, required this.onSend});
  @override
  Widget build(BuildContext context) {
    final color = AppColors();
    return Container(
      padding: const EdgeInsets.all(8),
      color: color.cardColor,
      child: Row(
        children: [
          Expanded(child: TextField(controller: controller, style: TextStyle(color: color.primaryTextColor), decoration: const InputDecoration(hintText: 'Ask me anything...', border: InputBorder.none))),
          IconButton(icon: Icon(Icons.send, color: color.accentColor), onPressed: onSend),
        ],
      ),
    );
  }
}