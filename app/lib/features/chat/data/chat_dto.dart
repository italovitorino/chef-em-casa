class ChatMessageDTO {
  final String id;
  final String negotiationId;
  final String senderId;
  final String senderName;
  final String content;
  final DateTime sentAt;

  const ChatMessageDTO({
    required this.id,
    required this.negotiationId,
    required this.senderId,
    required this.senderName,
    required this.content,
    required this.sentAt,
  });

  factory ChatMessageDTO.fromJson(Map<String, dynamic> json) => ChatMessageDTO(
        id: json['id']?.toString() ?? '',
        negotiationId: json['negotiationId']?.toString() ?? '',
        senderId: json['senderId']?.toString() ?? '',
        senderName: json['senderName'] as String? ?? '',
        content: json['content'] as String? ?? '',
        sentAt: json['sentAt'] != null
            ? DateTime.parse(json['sentAt'].toString())
            : DateTime.now(),
      );
}
