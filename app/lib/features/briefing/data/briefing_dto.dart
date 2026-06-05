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
        id: json['id'].toString(),
        status: json['status'] as String,
        eventType: json['eventType'] as String,
        eventDate: json['eventDate'] as String,
      );
}
