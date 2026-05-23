import 'package:flutter/material.dart';
import 'placeholder_screen.dart';

class ChatPage extends StatefulWidget {
  final String role; // Menerima peran (Guru / Murid)

  const ChatPage({super.key, required this.role});

  @override  
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  // --- DATA DUMMY ---
  final List<Map<String, String>> _guruChatList = [
    {'nama': 'Nadia Qurrotu', 'pesan': 'Ustazah, besok jadi halaqah?', 'waktu': '10:30', 'unread': '2'},
    {'nama': 'Zunaizah', 'pesan': 'Syukron ustazah.', 'waktu': 'Kemarin', 'unread': '0'},
    {'nama': 'Ahmad', 'pesan': 'Assalamu\'alaikum, mau tanya...', 'waktu': 'Kemarin', 'unread': '0'},
  ];

  final List<Map<String, dynamic>> _muridChatHistory = [
    {'sender': 'Ustazah Isna', 'text': 'Wa\'alaikumussalam, siap setor hari ini?', 'isMe': false, 'time': '09:00'},
    {'sender': 'Saya', 'text': 'InsyaAllah siap ustazah, juz 30.', 'isMe': true, 'time': '09:05'},
  ];

  final TextEditingController _messageController = TextEditingController();

  // --- TAMPILAN UNTUK GURU (DAFTAR CHAT) ---
  Widget _buildTeacherChatList() {
    return ListView.separated(
      itemCount: _guruChatList.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final chat = _guruChatList[index];
        return ListTile(
          leading: const CircleAvatar(
            backgroundColor: Colors.teal,
            child: Icon(Icons.person, color: Colors.white),
          ),
          title: Text(chat['nama']!, style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text(chat['pesan']!, maxLines: 1, overflow: TextOverflow.ellipsis),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(chat['waktu']!, style: const TextStyle(fontSize: 12, color: Colors.grey)),
              if (chat['unread'] != '0')
                Container(
                  margin: const EdgeInsets.only(top: 4),
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(color: Colors.teal, shape: BoxShape.circle),
                  child: Text(chat['unread']!, style: const TextStyle(color: Colors.white, fontSize: 10)),
                ),
            ],
          ),
         onTap: () {
            // GURU KLIK CHAT MURID -> BUKA DETAIL CHAT
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PlaceholderScreen(title: 'Chat: ${chat['nama']}'),
              ),
            );
          },
        );
      },
    );
  }

  // --- TAMPILAN UNTUK MURID (RUANG CHAT) ---
  Widget _buildStudentChatDetail() {
    return Column(
      children: [
        // Riwayat Pesan (Bubble Chat)
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _muridChatHistory.length,
            itemBuilder: (context, index) {
              final msg = _muridChatHistory[index];
              final isMe = msg['isMe'];
              return Align(
                alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: isMe ? Colors.teal : Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft: Radius.circular(isMe ? 16 : 0),
                      bottomRight: Radius.circular(isMe ? 0 : 16),
                    ),
                    border: isMe ? null : Border.all(color: Colors.grey.shade300),
                  ),
                  child: Column(
                    crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                    children: [
                      Text(
                        msg['text'],
                        style: TextStyle(color: isMe ? Colors.white : Colors.black87),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        msg['time'],
                        style: TextStyle(fontSize: 10, color: isMe ? Colors.teal.shade100 : Colors.grey),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        
        // Input Teks untuk mengetik pesan
        Container(
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
                ),
              ),
              const SizedBox(width: 8),
              CircleAvatar(
                backgroundColor: Colors.teal,
                child: IconButton(
                  icon: const Icon(Icons.send, color: Colors.white, size: 20),
                  onPressed: () {
                    if (_messageController.text.isNotEmpty) {
                      setState(() {
                        _muridChatHistory.add({
                          'sender': 'Saya',
                          'text': _messageController.text,
                          'isMe': true,
                          'time': 'Sekarang', // Simulasi waktu
                        });
                        _messageController.clear();
                      });
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5FAF9),
      appBar: AppBar(
        // Judul AppBar menyesuaikan peran
        title: Text(
          widget.role == 'Guru' ? 'Chat Guru' : 'Chat dengan Ustazah',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      // Body akan merender tampilan yang berbeda sesuai peran
      body: widget.role == 'Guru' ? _buildTeacherChatList() : _buildStudentChatDetail(),
    );
  }
}