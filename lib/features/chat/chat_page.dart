import 'package:flutter/material.dart';
import 'package:habit_builder/core/theme/app_colors.dart';

// ─────────────────────────────────────────────
// DATA MODELS
// ─────────────────────────────────────────────

enum MessageSender { ai, user }

class ChatMessage {
  final String text;
  final MessageSender sender;
  final String? time;
  final ExerciseCard? exerciseCard;

  const ChatMessage({
    required this.text,
    required this.sender,
    this.time,
    this.exerciseCard,
  });
}

class ExerciseCard {
  final String title;
  final String subtitle;

  const ExerciseCard({required this.title, required this.subtitle});
}

// ─────────────────────────────────────────────
// REUSABLE COMPONENT: CoachAppBar
// ─────────────────────────────────────────────

class CoachAppBar extends StatelessWidget {
  final String title;
  final VoidCallback? onSettingsTap;

  const CoachAppBar({
    super.key,
    required this.title,
    this.onSettingsTap,
  });

  @override
  Widget build(BuildContext context) {
    final AppColors color = AppColors();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color.cardColor,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.person_outline,
                color: color.primaryTextColor, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                color: color.primaryTextColor,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          GestureDetector(
            onTap: onSettingsTap,
            child: Icon(Icons.settings_outlined,
                color: color.subtitleColor, size: 20),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// REUSABLE COMPONENT: DateDivider
// ─────────────────────────────────────────────

class DateDivider extends StatelessWidget {
  final String label;

  const DateDivider({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    final AppColors color = AppColors();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          Expanded(child: Divider(color: color.borderColor, thickness: 1)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              label,
              style: TextStyle(
                color: color.subtitleColor,
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.2,
              ),
            ),
          ),
          Expanded(child: Divider(color: color.borderColor, thickness: 1)),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// REUSABLE COMPONENT: AiMessageBubble
// ─────────────────────────────────────────────

class AiMessageBubble extends StatelessWidget {
  final String text;
  final ExerciseCard? exerciseCard;

  const AiMessageBubble({
    super.key,
    required this.text,
    this.exerciseCard,
  });

  @override
  Widget build(BuildContext context) {
    final AppColors color = AppColors();
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // AI avatar dot
          Padding(
            padding: const EdgeInsets.only(top: 2, right: 10),
            child: _AiAvatar(),
          ),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Label
                Text(
                  'ARCHITECT AI',
                  style: TextStyle(
                    color: color.subtitleColor,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.3,
                  ),
                ),
                const SizedBox(height: 6),
                // Message text
                _buildRichText(text, color),
                // Exercise card if present
                if (exerciseCard != null) ...[
                  const SizedBox(height: 10),
                  _ExerciseTile(card: exerciseCard!),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRichText(String text, AppColors color) {
    final spans = <TextSpan>[];
    final regex = RegExp(r'\*(.*?)\*');
    int last = 0;
    for (final match in regex.allMatches(text)) {
      if (match.start > last) {
        spans.add(TextSpan(text: text.substring(last, match.start)));
      }
      spans.add(TextSpan(
        text: match.group(1),
        style: const TextStyle(fontWeight: FontWeight.w700),
      ));
      last = match.end;
    }
    if (last < text.length) spans.add(TextSpan(text: text.substring(last)));

    return RichText(
      text: TextSpan(
        style: TextStyle(
          color: color.primaryTextColor,
          fontSize: 14,
          height: 1.6,
        ),
        children: spans,
      ),
    );
  }
}

// ─────────────────────────────────────────────
// REUSABLE COMPONENT: UserMessageBubble
// ─────────────────────────────────────────────

class UserMessageBubble extends StatelessWidget {
  final String text;
  final String? time;

  const UserMessageBubble({
    super.key,
    required this.text,
    this.time,
  });

  @override
  Widget build(BuildContext context) {
    final AppColors color = AppColors();
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.68,
            ),
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: color.cardColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(4),
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
            ),
            child: Text(
              text,
              style: TextStyle(
                color: color.primaryTextColor,
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ),
          if (time != null) ...[
            const SizedBox(height: 4),
            Text(
              'READ $time',
              style: TextStyle(
                color: color.subtitleColor,
                fontSize: 10,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// PRIVATE COMPONENT: _AiAvatar
// ─────────────────────────────────────────────

class _AiAvatar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final AppColors color = AppColors();
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: color.cardColor,
        shape: BoxShape.circle,
        border: Border.all(color: color.borderColor, width: 1),
      ),
      child: Icon(Icons.auto_awesome,
          color: color.subtitleColor, size: 14),
    );
  }
}

// ─────────────────────────────────────────────
// PRIVATE COMPONENT: _ExerciseTile
// ─────────────────────────────────────────────

class _ExerciseTile extends StatelessWidget {
  final ExerciseCard card;

  const _ExerciseTile({required this.card});

  @override
  Widget build(BuildContext context) {
    final AppColors color = AppColors();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: color.tipIconBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.borderColor, width: 1),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  card.title,
                  style: TextStyle(
                    color: color.primaryTextColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  card.subtitle,
                  style: TextStyle(
                    color: color.subtitleColor,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: color.borderColor,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.play_arrow_rounded,
                color: color.primaryTextColor, size: 20),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// REUSABLE COMPONENT: TypingIndicator
// ─────────────────────────────────────────────

class TypingIndicator extends StatelessWidget {
  const TypingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    final AppColors color = AppColors();
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          ...List.generate(3, (_) => Container(
            width: 5,
            height: 5,
            margin: const EdgeInsets.only(right: 4),
            decoration: BoxDecoration(
              color: color.subtitleColor,
              shape: BoxShape.circle,
            ),
          )),
          const SizedBox(width: 6),
          Text(
            'ARCHITECT IS CONTEMPLATING',
            style: TextStyle(
              color: color.subtitleColor,
              fontSize: 10,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// REUSABLE COMPONENT: ChatInputBar
// ─────────────────────────────────────────────

class ChatInputBar extends StatelessWidget {
  final TextEditingController? controller;
  final VoidCallback? onSend;

  const ChatInputBar({
    super.key,
    this.controller,
    this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    final AppColors color = AppColors();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color.cardColor,
        border: Border(top: BorderSide(color: color.borderColor, width: 1)),
      ),
      child: Row(
        children: [
          // + button
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.tipIconBg,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.add, color: color.subtitleColor, size: 20),
          ),
          const SizedBox(width: 10),
          // Text field
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: color.tipIconBg,
                borderRadius: BorderRadius.circular(24),
              ),
              child: TextField(
                controller: controller,
                style: TextStyle(
                    color: color.primaryTextColor, fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Speak with the architect...',
                  hintStyle:
                      TextStyle(color: color.subtitleColor, fontSize: 14),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          // Send button
          GestureDetector(
            onTap: onSend,
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: color.primaryTextColor,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.arrow_upward_rounded,
                  color: color.backgroundColor, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// REUSABLE COMPONENT: BottomNavBar (shared)
// ─────────────────────────────────────────────

// ─────────────────────────────────────────────
// MAIN PAGE: AiCoachPage
// ─────────────────────────────────────────────

class AiCoachPage extends StatefulWidget {
  const AiCoachPage({super.key});

  @override
  State<AiCoachPage> createState() => _AiCoachPageState();
}

class _AiCoachPageState extends State<AiCoachPage> {
  int _navIndex = 3;
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final List<ChatMessage> _messages = const [
    ChatMessage(
      sender: MessageSender.ai,
      text:
          'Good morning. Your focus today is *Deep Work*. I see you have 3 sessions scheduled. How can I help you optimize your mental clarity before the first one starts?',
    ),
    ChatMessage(
      sender: MessageSender.user,
      text:
          "I'm feeling a bit scattered today. Maybe a quick breathing exercise or a prioritization check?",
      time: '08:42 AM',
    ),
    ChatMessage(
      sender: MessageSender.ai,
      text:
          "Understood. Let's start with a 2-minute box breathing session to lower your cortisol. Then, we will identify the single most impactful task for your 9:00 AM block.",
      exerciseCard: ExerciseCard(
        title: 'Box Breathing',
        subtitle: '2 Minutes • Calmness',
      ),
    ),
  ];

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppColors color = AppColors();

    return Scaffold(
      backgroundColor: color.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // ── App Bar ──
            CoachAppBar(title: 'The Silent Architect'),

            // ── Chat Area ──
            Expanded(
              child: ListView(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  // Date divider
                  const DateDivider(label: 'TODAY'),

                  // Messages
                  ..._messages.map((msg) {
                    if (msg.sender == MessageSender.ai) {
                      return AiMessageBubble(
                        text: msg.text,
                        exerciseCard: msg.exerciseCard,
                      );
                    } else {
                      return UserMessageBubble(
                        text: msg.text,
                        time: msg.time,
                      );
                    }
                  }),

                  // Typing indicator
                  const TypingIndicator(),

                  const SizedBox(height: 8),
                ],
              ),
            ),

            // ── Input Bar ──
            ChatInputBar(
              controller: _inputController,
              onSend: () {
                // TODO: Send message logic
                _inputController.clear();
              },
            ),

            // ── Bottom Nav ──
          
          ],
        ),
      ),
    );
  }
}