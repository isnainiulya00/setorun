import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/chat_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_client.dart';
import '../../services/chat_service.dart';
import '../../services/storage_service.dart';
import '../../widgets/chat_bubble.dart';
import 'chat_detail_screen.dart';

class ChatPage extends StatefulWidget {
  final String role;

  const ChatPage({super.key, required this.role});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  late final ChatService _chatService;
  final TextEditingController _messageController = TextEditingController();
  Timer? _pollTimer;

  List<ChatConversationModel> _conversations = [];
  ChatRoomData? _room;
  bool _loading = true;
  String? _error;

  bool get _isGuru => widget.role == 'Guru';

  @override
  void initState() {
    super.initState();
    _chatService = ChatService(ApiClient(StorageService()));
    _load();
    _pollTimer = Timer.periodic(const Duration(seconds: 4), (_) => _load(silent: true));
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _load({bool silent = false}) async {
    if (!silent) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }
    try {
      if (_isGuru) {
        final conv = await _chatService.fetchConversations();
        if (!mounted) return;
        setState(() {
          _conversations = conv;
          _loading = false;
        });
      } else {
        final room = await _chatService.fetchMessages();
        if (!mounted) return;
        setState(() {
          _room = room;
          _loading = false;
        });
      }
    } catch (e) {
      if (!mounted || silent) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _send() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;
    _messageController.clear();
    try {
      await _chatService.sendMessage(text: text);
      await _load(silent: true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal kirim pesan: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final guruNama = _room?.guruNama.isNotEmpty == true
        ? _room!.guruNama
        : (user?.halaqoh?.guruName ?? 'Guru');

    return Scaffold(
      backgroundColor: const Color(0xFFF5FAF9),
      appBar: AppBar(
        title: Text(
          _isGuru ? 'Chat Murid' : 'Chat dengan $guruNama',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: Colors.teal))
          : _error != null
              ? Center(child: Text('Error: $_error'))
              : _isGuru
                  ? _buildTeacherChatList()
                  : _buildStudentChatDetail(),
    );
  }

  Widget _buildTeacherChatList() {
    if (_conversations.isEmpty) {
      return const Center(child: Text('Belum ada murid di halaqoh'));
    }
    return ListView.separated(
      itemCount: _conversations.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final chat = _conversations[index];
        return ListTile(
          leading: const CircleAvatar(
            backgroundColor: Colors.teal,
            child: Icon(Icons.person, color: Colors.white),
          ),
          title: Text(chat.muridNama, style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text(chat.lastMessage, maxLines: 1, overflow: TextOverflow.ellipsis),
          trailing: Text(chat.lastTime, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChatDetailScreen(
                  muridId: chat.muridId,
                  muridNama: chat.muridNama,
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildStudentChatDetail() {
    final messages = _room?.messages ?? [];
    return Column(
      children: [
        Expanded(
          child: messages.isEmpty
              ? const Center(child: Text('Mulai percakapan dengan guru...'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: messages.length,
                  itemBuilder: (context, index) => chatMessageBubble(messages[index]),
                ),
        ),
        _buildInputBar(),
      ],
    );
  }

  Widget _buildInputBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: 'Ketik pesan...',
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey.shade100,
              ),
              onSubmitted: (_) => _send(),
            ),
          ),
          const SizedBox(width: 8),
          CircleAvatar(
            backgroundColor: Colors.teal,
            child: IconButton(
              icon: const Icon(Icons.send, color: Colors.white, size: 20),
              onPressed: _send,
            ),
          ),
        ],
      ),
    );
  }
}
