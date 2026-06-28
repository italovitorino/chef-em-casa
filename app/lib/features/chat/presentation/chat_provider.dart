import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stomp_dart_client/stomp_dart_client.dart';

import '../../../core/network/api_config.dart';
import '../../../core/storage/token_storage.dart';
import '../data/chat_dto.dart';
import '../data/chat_repository.dart';

class ChatNotifier
    extends AutoDisposeFamilyAsyncNotifier<List<ChatMessageDTO>, String> {
  StompClient? _stompClient;

  @override
  Future<List<ChatMessageDTO>> build(String negotiationId) async {
    final history =
        await ref.read(chatRepositoryProvider).getHistory(negotiationId);

    final token = await ref.read(tokenStorageProvider).accessToken;
    if (token != null) {
      _connectStomp(negotiationId: negotiationId, token: token);
    }

    ref.onDispose(() {
      _stompClient?.deactivate();
    });

    return history;
  }

  void _connectStomp({
    required String negotiationId,
    required String token,
  }) {
    _stompClient = StompClient(
      config: StompConfig(
        url: ApiConfig.wsUrl,
        connectHeaders: {'Authorization': 'Bearer $token'},
        heartbeatOutgoing: const Duration(seconds: 20),
        heartbeatIncoming: const Duration(seconds: 20),
        reconnectDelay: const Duration(seconds: 5),
        onConnect: (frame) => _onConnect(frame, negotiationId),
        onDisconnect: (_) {},
        onWebSocketError: (error) => _onError(error.toString()),
        onStompError: (frame) => _onError(frame.body ?? 'Erro STOMP'),
      ),
    );
    _stompClient!.activate();
  }

  void _onConnect(StompFrame frame, String negotiationId) {
    _stompClient?.subscribe(
      destination: '/topic/negotiations/$negotiationId/chat',
      callback: (frame) {
        if (frame.body == null) return;
        final json = jsonDecode(frame.body!) as Map<String, dynamic>;
        final incoming = ChatMessageDTO.fromJson(json);

        final current = state.valueOrNull ?? [];
        if (current.any((m) => m.id == incoming.id)) return;
        state = AsyncData([...current, incoming]);
      },
    );
  }

  void _onError(String message) {
    state = AsyncError(Exception('WebSocket: $message'), StackTrace.current);
  }

  Future<void> sendMessage(String negotiationId, String content) async {
    if (_stompClient == null || !_stompClient!.connected) return;
    _stompClient!.send(
      destination: '/app/negotiations/$negotiationId/chat',
      body: jsonEncode({'content': content}),
    );
  }
}

final chatProvider = AsyncNotifierProvider.autoDispose
    .family<ChatNotifier, List<ChatMessageDTO>, String>(ChatNotifier.new);
