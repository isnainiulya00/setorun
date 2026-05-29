import 'dart:async';

import 'package:flutter/material.dart';

import '../../models/chat_model.dart';
import '../../services/api_client.dart';
import '../../services/chat_service.dart';
import '../../services/storage_service.dart';
import '../../widgets/chat_bubble.dart';

class ChatDetailScreen extends StatefulWidget {
  final int muridId;
  final String muridNama;

  const ChatDetailScreen({
    super.key,
    required this.muridId,
    required this.muridNama,
  });

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  late final ChatService _chatService;
  final TextEditingController _controller = TextEditingController();
  Timer? _pollTimer;
  ChatRoomData? _room;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _chatService = ChatService(ApiClient(StorageService()));
    _load();
    _pollTimer = Timer.periodic(const Duration(seconds: 3), (_) => _load(silent: true));
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _load({bool silent = false}) async {
    if (!silent) setState(() => _loading = true);
    try {
      final room = await _chatService.fetchMessages(muridId: widget.muridId);
      if (!mounted) return;
      setState(() {
        _room = room;
        _loading = false;
      });
    } catch (_) {
      if (!mounted || silent) return;
      setState(() => _loading = false);
    }
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    _controller.clear();
    await _chatService.sendMessage(text: text, muridId: widget.muridId);
    await _load(silent: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5FAF9),
      appBar: AppBar(
        title: Text(widget.muridNama, style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: Colors.teal))
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _room?.messages.length ?? 0,
                    itemBuilder: (context, index) {
                      return chatMessageBubble(_room!.messages[index]);
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  color: Colors.white,
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _controller,
                          decoration: InputDecoration(
                            hintText: 'Ketik pesan...',
                            filled: true,
                            fillColor: Colors.grey.shade100,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          onSubmitted: (_) => _send(),
                        ),
                      ),
                      IconButton(
                        onPressed: _send,
                        icon: const Icon(Icons.send, color: Colors.teal),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
