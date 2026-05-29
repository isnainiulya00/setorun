class ChatMessageModel {
  final int id;
  final String text;
  final String senderName;
  final String timeDisplay;
  final bool isMe;

  const ChatMessageModel({
    required this.id,
    required this.text,
    required this.senderName,
    required this.timeDisplay,
    required this.isMe,
  });

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    return ChatMessageModel(
      id: json['id'] as int,
      text: json['text'] as String? ?? '',
      senderName: json['sender_name'] as String? ?? '',
      timeDisplay: json['time_display'] as String? ?? '',
      isMe: json['is_me'] as bool? ?? false,
    );
  }
}

class ChatConversationModel {
  final int roomId;
  final int muridId;
  final String muridNama;
  final String lastMessage;
  final String lastTime;
  final int unreadCount;

  const ChatConversationModel({
    required this.roomId,
    required this.muridId,
    required this.muridNama,
    required this.lastMessage,
    required this.lastTime,
    required this.unreadCount,
  });

  factory ChatConversationModel.fromJson(Map<String, dynamic> json) {
    return ChatConversationModel(
      roomId: json['room_id'] as int,
      muridId: json['murid_id'] as int,
      muridNama: json['murid_nama'] as String? ?? '',
      lastMessage: json['last_message'] as String? ?? '',
      lastTime: json['last_time'] as String? ?? '',
      unreadCount: json['unread_count'] as int? ?? 0,
    );
  }
}

class ChatRoomData {
  final int roomId;
  final int muridId;
  final String muridNama;
  final String guruNama;
  final List<ChatMessageModel> messages;

  const ChatRoomData({
    required this.roomId,
    required this.muridId,
    required this.muridNama,
    required this.guruNama,
    required this.messages,
  });

  factory ChatRoomData.fromJson(Map<String, dynamic> json) {
    final raw = json['messages'];
    final list = raw is List
        ? raw
            .map((e) => ChatMessageModel.fromJson(e as Map<String, dynamic>))
            .toList()
        : <ChatMessageModel>[];

    return ChatRoomData(
      roomId: json['room_id'] as int? ?? 0,
      muridId: json['murid_id'] as int? ?? 0,
      muridNama: json['murid_nama'] as String? ?? '',
      guruNama: json['guru_nama'] as String? ?? '',
      messages: list,
    );
  }
}
