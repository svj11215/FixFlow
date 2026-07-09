import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../services/gemini_service.dart';

class ChatMessage {
  final String id;
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.id,
    required this.text,
    required this.isUser,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() => {
        'text': text,
        'isUser': isUser,
        'timestamp': Timestamp.fromDate(timestamp),
      };

  factory ChatMessage.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ChatMessage(
      id: doc.id,
      text: data['text'] as String? ?? '',
      isUser: data['isUser'] as bool? ?? true,
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}

class ChatProvider extends ChangeNotifier {
  final GeminiService _geminiService = GeminiService();
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  List<ChatMessage> _messages = [];
  bool _isTyping = false;
  bool _isLoading = false;
  String? _error;
  String? _currentUserId;

  List<ChatMessage> get messages => List.unmodifiable(_messages);
  bool get isTyping => _isTyping;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasMessages => _messages.isNotEmpty;

  CollectionReference? get _messagesRef => _currentUserId != null
      ? _db
          .collection('chatSessions')
          .doc(_currentUserId)
          .collection('messages')
      : null;

  /// Load history from Firestore and initialise a Gemini chat session
  Future<void> loadHistory(String userId) async {
    if (_currentUserId == userId && _messages.isNotEmpty) return;

    _currentUserId = userId;
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final snapshot = await _messagesRef!
          .orderBy('timestamp', descending: false)
          .limit(100)
          .get();

      _messages = snapshot.docs
          .map((doc) => ChatMessage.fromFirestore(doc))
          .toList();

      // Rebuild Gemini session from history
      final history = GeminiService.buildHistory(
        _messages.map((m) => m.toMap()..remove('timestamp')).toList(),
      );
      // Remove the last message if it's from the user (Gemini will re-use the session)
      final historyForSession = <Content>[];
      for (int i = 0; i < history.length - 1; i++) {
        historyForSession.add(history[i]);
      }
      // Only pass alternating pairs (user→model) to avoid API errors
      _geminiService.initChatSession(_buildValidHistory(historyForSession));
    } catch (e) {
      _error = 'Failed to load chat history.';
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Ensures history alternates user/model and ends with a model turn
  List<Content> _buildValidHistory(List<Content> raw) {
    final valid = <Content>[];
    for (final content in raw) {
      if (valid.isEmpty) {
        if (content.role == 'user') valid.add(content);
      } else {
        final lastRole = valid.last.role;
        if (lastRole != content.role) valid.add(content);
      }
    }
    // Must end with a model turn for a valid multi-turn history
    if (valid.isNotEmpty && valid.last.role == 'user') {
      valid.removeLast();
    }
    return valid;
  }

  /// Send a user message, persist it, call Gemini, persist the response
  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty || _currentUserId == null) return;

    _error = null;

    // Optimistically add user message to UI
    final userMsg = ChatMessage(
      id: '',
      text: text.trim(),
      isUser: true,
      timestamp: DateTime.now(),
    );
    _messages.add(userMsg);
    _isTyping = true;
    notifyListeners();

    // Persist user message
    try {
      await _messagesRef!.add(userMsg.toMap());
    } catch (_) {
      // Non-fatal — continue even if persistence fails
    }

    // Call Gemini
    try {
      final response = await _geminiService.sendMessage(text.trim());

      final botMsg = ChatMessage(
        id: '',
        text: response,
        isUser: false,
        timestamp: DateTime.now(),
      );
      _messages.add(botMsg);

      // Persist bot message
      try {
        await _messagesRef!.add(botMsg.toMap());
      } catch (_) {}
    } catch (e) {
      debugPrint('ChatProvider caught exception: $e');
      _error = e.toString();
      // Remove the optimistic user message on hard failure
      _messages.removeLast();
    }

    _isTyping = false;
    notifyListeners();
  }

  /// Delete all messages from Firestore and reset local state
  Future<void> clearChat() async {
    if (_currentUserId == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      final snapshot = await _messagesRef!.get();
      final batch = _db.batch();
      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();

      _messages.clear();
      _geminiService.initChatSession([]);
    } catch (e) {
      _error = 'Failed to clear chat.';
    }

    _isLoading = false;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Call when the user logs out to reset state
  void reset() {
    _messages = [];
    _isTyping = false;
    _isLoading = false;
    _error = null;
    _currentUserId = null;
    notifyListeners();
  }
}
