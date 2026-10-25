import 'package:flutter_test/flutter_test.dart';
import 'package:aibo/features/chat/models/chat_message.dart';

void main() {
  group('ChatMessage Unit Tests', () {
    test('Serializes to Map and restores correctly', () {
      final msg = ChatMessage(
        id: 101,
        sessionId: 'tokyo_session_1',
        role: 'user',
        content: 'Where do I dispose of used batteries in Shibuya?',
      );

      final map = msg.toMap();
      expect(map['id'], 101);
      expect(map['session_id'], 'tokyo_session_1');
      expect(map['role'], 'user');
      expect(map['content'], 'Where do I dispose of used batteries in Shibuya?');

      final restored = ChatMessage.fromMap(map);
      expect(restored.id, 101);
      expect(restored.sessionId, 'tokyo_session_1');
      expect(restored.role, 'user');
      expect(restored.content, msg.content);
    });

    test('Assistant role mapping is preserved', () {
      final map = {
        'id': 202,
        'session_id': 'default',
        'role': 'assistant',
        'content': 'Batteries (乾電池) are hazardous waste and must be placed in designated collection boxes.',
        'timestamp': DateTime.now().toIso8601String(),
      };

      final msg = ChatMessage.fromMap(map);
      expect(msg.role, 'assistant');
      expect(msg.content.contains('乾電池'), isTrue);
    });
  });
}
