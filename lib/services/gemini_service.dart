import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../config/api_keys.dart';

class TextPart {
  final String text;
  TextPart(this.text);
}

class Content {
  final String? role;
  final List<dynamic> parts;

  Content(this.role, this.parts);

  Content.text(String text)
      : role = 'user',
        parts = [TextPart(text)];

  Content.model(List<dynamic> partsList)
      : role = 'model',
        parts = partsList;
}

class GeminiService {
  static const String _systemContext =
      'You are a helpful assistant for FixFlow complaint management system. '
      'Help users with safety tips, troubleshooting advice, and answering '
      'questions about electrical, plumbing, internet, maintenance issues until '
      'their complaint is resolved. Keep responses concise and practical.';

  List<Content> _history = [];

  GeminiService() {
    debugPrint('Groq API Key length: ${ApiKeys.groqApiKey.length}');
  }

  /// Start or reset a chat session with provided history
  void initChatSession(List<Content> history) {
    _history = List.from(history);
  }

  /// Send a message and get a response
  Future<String> sendMessage(String message) async {
    // Add user message to history
    _history.add(Content.text(message));

    // Construct history for Groq API
    final List<Map<String, String>> groqMessages = [
      {
        "role": "system",
        "content": _systemContext,
      }
    ];

    for (final content in _history) {
      final role = content.role == 'model' ? 'assistant' : 'user';
      final text = content.parts.map((p) {
        if (p is TextPart) return p.text;
        return p.toString();
      }).join('');
      groqMessages.add({
        "role": role,
        "content": text,
      });
    }

    try {
      final url = Uri.parse('https://api.groq.com/openai/v1/chat/completions');
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer ${ApiKeys.groqApiKey}',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': 'llama-3.3-70b-versatile',
          'messages': groqMessages,
          'temperature': 0.7,
        }),
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body) as Map<String, dynamic>;
        final reply = decoded['choices'][0]['message']['content'] as String? ?? '';
        
        // Add assistant response to history
        _history.add(Content.model([TextPart(reply)]));
        return reply;
      } else {
        throw Exception(
            'Groq API error (status: ${response.statusCode}): ${response.body}');
      }
    } catch (e, stackTrace) {
      debugPrint('Groq API call failed: $e\n$stackTrace');
      throw Exception('Failed to get response: $e');
    }
  }

  /// Build Content history from stored messages for session restoration
  static List<Content> buildHistory(
      List<Map<String, dynamic>> messages) {
    final List<Content> history = [];
    for (final msg in messages) {
      final isUser = msg['isUser'] as bool? ?? true;
      final text = msg['text'] as String? ?? '';
      if (text.isEmpty) continue;
      history.add(isUser ? Content.text(text) : Content.model([TextPart(text)]));
    }
    return history;
  }
}
