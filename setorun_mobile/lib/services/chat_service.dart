import '../models/chat_model.dart';
import 'api_client.dart';

class ChatService {
  ChatService(this._api);

  final ApiClient _api;

  Future<List<ChatConversationModel>> fetchConversations() async {
    final response = await _api.dio.get('/chat/conversations/');
    final data = response.data;
    if (data is! List) return [];
    return data
        .map((e) => ChatConversationModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<ChatRoomData> fetchMessages({int? muridId}) async {
    final response = await _api.dio.get(
      '/chat/messages/',
      queryParameters: muridId != null ? {'murid_id': muridId} : null,
    );
    return ChatRoomData.fromJson(response.data as Map<String, dynamic>);
  }

  Future<ChatMessageModel> sendMessage({
    required String text,
    int? muridId,
  }) async {
    final response = await _api.dio.post(
      '/chat/send/',
      data: {
        'text': text,
        if (muridId != null) 'murid_id': muridId,
      },
    );
    return ChatMessageModel.fromJson(response.data as Map<String, dynamic>);
  }
}
