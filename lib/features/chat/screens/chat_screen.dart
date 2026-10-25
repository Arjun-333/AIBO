import 'package:flutter/material.dart';
import '../../../core/database/database_helper.dart';
import '../../../core/llm/llm_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/voice/voice_service.dart';
import '../models/chat_message.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  bool _isGenerating = false;
  String _providerStatus = 'Gemini 1.5 Flash';

  final List<String> _quickPrompts = [
    'How do I separate burnable vs non-burnable garbage?',
    'How to register my address at the Ward Office?',
    'Help me draft a polite email to my landlord.',
    'Explain how to pay electricity bills at 7-Eleven.',
  ];

  @override
  void initState() {
    super.initState();
    _loadChatHistory();
  }

  Future<void> _loadChatHistory() async {
    final history = await DatabaseHelper.instance.getChatMessages('default');
    setState(() {
      _messages.clear();
      _messages.addAll(history);
    });
    _scrollToBottom();
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

  Future<void> _sendMessage([String? presetText]) async {
    final text = presetText ?? _inputController.text.trim();
    if (text.isEmpty || _isGenerating) return;

    final userMsg = ChatMessage(
      sessionId: 'default',
      role: 'user',
      content: text,
    );

    setState(() {
      _messages.add(userMsg);
      _isGenerating = true;
    });

    if (presetText == null) {
      _inputController.clear();
    }
    _scrollToBottom();

    // Persist user message to SQLite
    await DatabaseHelper.instance.insertChatMessage(userMsg);

    try {
      final reply = await LlmService.instance.sendMessage(
        prompt: text,
        conversationHistory: _messages,
      );

      final assistantMsg = ChatMessage(
        sessionId: 'default',
        role: 'assistant',
        content: reply,
      );

      setState(() {
        _messages.add(assistantMsg);
        _isGenerating = false;
      });

      // Persist assistant reply to SQLite
      await DatabaseHelper.instance.insertChatMessage(assistantMsg);
      _scrollToBottom();
    } catch (e) {
      final errorMsg = ChatMessage(
        sessionId: 'default',
        role: 'assistant',
        content: '⚠️ AI Notice: ${e.toString().replaceAll("Exception: ", "")}',
      );

      setState(() {
        _messages.add(errorMsg);
        _isGenerating = false;
      });
      _scrollToBottom();
    }
  }

  Future<void> _confirmClearHistory() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surfaceDark,
        title: const Text('Clear Chat History?'),
        content: const Text(
          'This will permanently delete your stored conversation history from the on-device database.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accentRose),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await DatabaseHelper.instance.clearChatHistory('default');
      setState(() {
        _messages.clear();
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Chat history cleared.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Column(
          children: [
            Text('AIBO Japan Companion', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Text('Culture • Admin • Language • Rules', style: TextStyle(fontSize: 11, color: Colors.white54)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep_outlined),
            tooltip: 'Clear Conversation',
            onPressed: _messages.isEmpty ? null : _confirmClearHistory,
          ),
        ],
      ),
      body: Column(
        children: [
          // Messages List or Welcome Empty State
          Expanded(
            child: _messages.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final msg = _messages[index];
                      final isUser = msg.role == 'user';
                      return _buildMessageBubble(msg, isUser);
                    },
                  ),
          ),

          if (_isGenerating)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.accentTeal),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'AIBO is thinking...',
                    style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.6)),
                  ),
                ],
              ),
            ),

          // Quick Prompt Suggestion Chips (when idle)
          if (_messages.isEmpty)
            Container(
              height: 48,
              margin: const EdgeInsets.only(bottom: 8),
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _quickPrompts.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, idx) {
                  return ActionChip(
                    backgroundColor: AppTheme.surfaceDark,
                    side: const BorderSide(color: AppTheme.surfaceLightDark),
                    label: Text(
                      _quickPrompts[idx],
                      style: const TextStyle(fontSize: 12, color: Colors.white70),
                    ),
                    onPressed: () => _sendMessage(_quickPrompts[idx]),
                  );
                },
              ),
            ),

          // Input Bar
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: AppTheme.surfaceDark,
              border: Border(top: BorderSide(color: AppTheme.surfaceLightDark)),
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _inputController,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: const InputDecoration(
                        hintText: 'Ask about Japan life, garbage, Japanese...',
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      VoiceService.instance.isListening ? Icons.mic : Icons.mic_none_outlined,
                      color: VoiceService.instance.isListening ? AppTheme.accentRose : AppTheme.charcoal,
                    ),
                    tooltip: 'Voice Input (音声入力)',
                    onPressed: () {
                      if (VoiceService.instance.isListening) {
                        VoiceService.instance.stopListening(onStatusChanged: () => setState(() {}));
                      } else {
                        VoiceService.instance.startListening(
                          onResult: (spoken) {
                            setState(() {
                              _inputController.text = spoken;
                            });
                          },
                          onStatusChanged: () => setState(() {}),
                        );
                      }
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.send_rounded, color: AppTheme.primary),
                    onPressed: _isGenerating ? null : () => _sendMessage(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppTheme.primary.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.forum_outlined, color: AppTheme.primary, size: 32),
            ),
            const SizedBox(height: 16),
            const Text(
              'How can I help you in Japan today?',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Ask me about recycling rules, paying utility bills, ward office registration, or translating Japanese phrases.',
              style: TextStyle(fontSize: 13, color: Colors.white.withOpacity(0.6)),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage msg, bool isUser) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.82),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isUser ? AppTheme.primary : AppTheme.surfaceDark,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isUser ? 16 : 4),
            bottomRight: Radius.circular(isUser ? 4 : 16),
          ),
          border: isUser ? null : Border.all(color: AppTheme.surfaceLightDark),
        ),
        child: Text(
          msg.content,
          style: TextStyle(
            color: Colors.white,
            fontSize: 14.5,
            height: 1.4,
            fontFamily: isUser ? null : 'sans-serif',
          ),
        ),
      ),
    );
  }
}
