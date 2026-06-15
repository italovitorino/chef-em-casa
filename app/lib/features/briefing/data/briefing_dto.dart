class CreateBriefingRequest {
  final String eventType;
  final String eventDate; // ISO 8601 ex: "2026-06-20"
  final int numberOfGuests;
  final String street;
  final String number;
  final String city;
  final String state;
  final String zipCode;
  final int estimatedDurationMinutes;
  final String? notes;

  const CreateBriefingRequest({
    required this.eventType,
    required this.eventDate,
    required this.numberOfGuests,
    required this.street,
    required this.number,
    required this.city,
    required this.state,
    required this.zipCode,
    required this.estimatedDurationMinutes,
    this.notes,
  });

  Map<String, dynamic> toJson() => {
        'eventType': eventType,
        'eventDate': eventDate,
        'numberOfGuests': numberOfGuests,
        'street': street,
        'number': number,
        'city': city,
        'state': state,
        'zipCode': zipCode,
        'estimatedDurationMinutes': estimatedDurationMinutes,
        if (notes != null && notes!.isNotEmpty) 'notes': notes,
      };
}

class BriefingResponse {
  final String id;
  final String status;
  final String eventType;
  final String eventDate;

  const BriefingResponse({
    required this.id,
    required this.status,
    required this.eventType,
    required this.eventDate,
  });

  factory BriefingResponse.fromJson(Map<String, dynamic> json) =>
      BriefingResponse(
        id: json['id']?.toString() ?? '',
        status: json['status'] as String? ?? '',
        eventType: (json['eventType'] ?? json['event_type']) as String? ?? '',
        eventDate: (json['eventDate'] ?? json['event_date']) as String? ?? '',
      );
}

class ChefInterestItem {
  final String chefId;
  final DateTime expressedAt;
  final String? message;

  const ChefInterestItem({
    required this.chefId,
    required this.expressedAt,
    this.message,
  });

  factory ChefInterestItem.fromJson(Map<String, dynamic> json) =>
      ChefInterestItem(
        chefId: json['chefId']?.toString() ?? '',
        expressedAt: DateTime.tryParse(json['expressedAt']?.toString() ?? '') ??
            DateTime.now(),
        message: json['message'] as String?,
      );
}

class BriefingDetailResponse {
  final String id;
  final String clientId;
  final String status;
  final String eventType;
  final String eventDate;
  final int numberOfGuests;
  final int estimatedDurationMinutes;
  final String? notes;
  final String street;
  final String number;
  final String city;
  final String state;
  final String zipCode;
  final List<ChefInterestItem> interests;
  final DateTime? expiresAt;
  final DateTime? closedAt;
  final DateTime? createdAt;

  const BriefingDetailResponse({
    required this.id,
    required this.clientId,
    required this.status,
    required this.eventType,
    required this.eventDate,
    required this.numberOfGuests,
    required this.estimatedDurationMinutes,
    this.notes,
    required this.street,
    required this.number,
    required this.city,
    required this.state,
    required this.zipCode,
    required this.interests,
    this.expiresAt,
    this.closedAt,
    this.createdAt,
  });

  bool get isActive => status == 'OPEN';
  int get hours => (estimatedDurationMinutes / 60).round();

  factory BriefingDetailResponse.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(dynamic raw) =>
        raw != null ? DateTime.tryParse(raw.toString()) : null;

    final details = json['details'] as Map<String, dynamic>? ?? {};
    final location = details['location'] as Map<String, dynamic>? ?? {};
    final rawInterests = json['interests'];
    final interests = rawInterests is List
        ? rawInterests
            .whereType<Map<String, dynamic>>()
            .map(ChefInterestItem.fromJson)
            .toList()
        : <ChefInterestItem>[];

    return BriefingDetailResponse(
      id: json['id']?.toString() ?? '',
      clientId: json['clientId']?.toString() ?? '',
      status: json['status'] as String? ?? 'OPEN',
      eventType: details['eventType'] as String? ?? '',
      eventDate: details['eventDate'] as String? ?? '',
      numberOfGuests: details['numberOfGuests'] as int? ?? 0,
      estimatedDurationMinutes:
          details['estimatedDurationMinutes'] as int? ?? 0,
      notes: details['notes'] as String?,
      street: location['street'] as String? ?? '',
      number: location['number'] as String? ?? '',
      city: location['city'] as String? ?? '',
      state: location['state'] as String? ?? '',
      zipCode: location['zipCode'] as String? ?? '',
      interests: interests,
      expiresAt: parseDate(json['expiresAt']),
      closedAt: parseDate(json['closedAt']),
      createdAt: parseDate(json['createdAt']),
    );
  }
}

class BriefingListItem {
  final String id;
  final String status;
  final String eventType;
  final String eventDate;
  final int numberOfGuests;
  final int estimatedDurationMinutes;
  final String? city;
  final DateTime? expiresAt;
  final DateTime? closedAt;
  final int interestCount;
  final DateTime? createdAt;

  const BriefingListItem({
    required this.id,
    required this.status,
    required this.eventType,
    required this.eventDate,
    required this.numberOfGuests,
    required this.estimatedDurationMinutes,
    this.city,
    this.expiresAt,
    this.closedAt,
    required this.interestCount,
    this.createdAt,
  });

  // OPEN = Ativo.
  // CLOSED + closedAt null  = auto-expirado = Encerrado.
  // CLOSED + closedAt set   = encerrado manualmente = Concluído.
  bool get isActive => status == 'OPEN';
  bool get isConcluded => status == 'CLOSED' && closedAt != null;
  bool get isExpiredAuto => status == 'CLOSED' && closedAt == null;

  int get hours => (estimatedDurationMinutes / 60).round();

  factory BriefingListItem.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(dynamic raw) =>
        raw != null ? DateTime.tryParse(raw.toString()) : null;

    final details = json['details'] as Map<String, dynamic>? ?? {};
    final location = details['location'] as Map<String, dynamic>? ?? {};
    final interests = json['interests'];
    final interestCount = interests is List ? interests.length : 0;

    return BriefingListItem(
      id: json['id']?.toString() ?? '',
      status: json['status'] as String? ?? 'OPEN',
      eventType: details['eventType'] as String? ?? '',
      eventDate: details['eventDate'] as String? ?? '',
      numberOfGuests: details['numberOfGuests'] as int? ?? 0,
      estimatedDurationMinutes:
          details['estimatedDurationMinutes'] as int? ?? 0,
      city: location['city'] as String?,
      expiresAt: parseDate(json['expiresAt']),
      closedAt: parseDate(json['closedAt']),
      interestCount: interestCount,
      createdAt: parseDate(json['createdAt']),
    );
  }
}
