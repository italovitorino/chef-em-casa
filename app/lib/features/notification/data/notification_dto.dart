class NotificationDTO {
  final String id;
  final String type;
  final String title;
  final String body;
  final String? relatedId;
  final bool read;
  final DateTime createdAt;

  const NotificationDTO({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    this.relatedId,
    required this.read,
    required this.createdAt,
  });

  factory NotificationDTO.fromJson(Map<String, dynamic> json) => NotificationDTO(
        id: json['id'].toString(),
        type: json['type'] as String? ?? '',
        title: json['title'] as String? ?? '',
        body: json['body'] as String? ?? '',
        relatedId: json['relatedId']?.toString(),
        read: json['read'] as bool? ?? false,
        createdAt: json['createdAt'] != null
            ? DateTime.parse(json['createdAt'].toString())
            : DateTime.now(),
      );
}
