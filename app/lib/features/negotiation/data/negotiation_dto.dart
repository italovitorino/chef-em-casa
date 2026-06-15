class ProposalResponse {
  final String id;
  final double totalAmount;
  final String serviceDescription;
  final String? validUntil;
  final String? notes;
  final DateTime? sentAt;

  const ProposalResponse({
    required this.id,
    required this.totalAmount,
    required this.serviceDescription,
    this.validUntil,
    this.notes,
    this.sentAt,
  });

  factory ProposalResponse.fromJson(Map<String, dynamic> json) =>
      ProposalResponse(
        id: json['id']?.toString() ?? '',
        totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0.0,
        serviceDescription: json['serviceDescription'] as String? ?? '',
        validUntil: json['validUntil'] as String?,
        notes: json['notes'] as String?,
        sentAt: json['sentAt'] != null
            ? DateTime.tryParse(json['sentAt'].toString())
            : null,
      );

  String get formattedAmount =>
      'R\$ ${totalAmount.toStringAsFixed(2).replaceAll('.', ',')}';
}

class NegotiationResponse {
  final String id;
  final String briefingId;
  final String clientId;
  final String chefId;
  final String status;
  final ProposalResponse? currentProposal;
  final List<ProposalResponse> proposalHistory;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const NegotiationResponse({
    required this.id,
    required this.briefingId,
    required this.clientId,
    required this.chefId,
    required this.status,
    this.currentProposal,
    required this.proposalHistory,
    this.createdAt,
    this.updatedAt,
  });

  bool get isAwaitingProposal => status == 'AWAITING_PROPOSAL';
  bool get hasProposal => status == 'PROPOSAL_SENT';
  bool get isConfirmed => status == 'RESERVATION_CONFIRMED';
  bool get isCompleted => status == 'SERVICE_COMPLETED';
  bool get isCancelled => status == 'CANCELLED';
  bool get isActive => !isCompleted && !isCancelled;

  factory NegotiationResponse.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(dynamic raw) =>
        raw != null ? DateTime.tryParse(raw.toString()) : null;

    ProposalResponse? parseProposal(dynamic raw) {
      if (raw == null) return null;
      if (raw is Map<String, dynamic>) return ProposalResponse.fromJson(raw);
      return null;
    }

    final history = json['proposalHistory'];
    final proposals = history is List
        ? history
            .whereType<Map<String, dynamic>>()
            .map(ProposalResponse.fromJson)
            .toList()
        : <ProposalResponse>[];

    return NegotiationResponse(
      id: json['id']?.toString() ?? '',
      briefingId: json['briefingId']?.toString() ?? '',
      clientId: json['clientId']?.toString() ?? '',
      chefId: json['chefId']?.toString() ?? '',
      status: json['status'] as String? ?? 'AWAITING_PROPOSAL',
      currentProposal: parseProposal(json['currentProposal']),
      proposalHistory: proposals,
      createdAt: parseDate(json['createdAt']),
      updatedAt: parseDate(json['updatedAt']),
    );
  }
}

class StartNegotiationRequest {
  final String chefId;

  const StartNegotiationRequest({required this.chefId});

  Map<String, dynamic> toJson() => {'chefId': chefId};
}

class NegotiationListItem {
  final String id;
  final String status;
  final String chefId;
  final double? latestProposalAmount;
  final DateTime? createdAt;

  const NegotiationListItem({
    required this.id,
    required this.status,
    required this.chefId,
    this.latestProposalAmount,
    this.createdAt,
  });

  factory NegotiationListItem.fromJson(Map<String, dynamic> json) {
    final currentProposal = json['currentProposal'] as Map<String, dynamic>?;
    return NegotiationListItem(
      id: json['id']?.toString() ?? '',
      status: json['status'] as String? ?? 'AWAITING_PROPOSAL',
      chefId: json['chefId']?.toString() ?? '',
      latestProposalAmount:
          (currentProposal?['totalAmount'] as num?)?.toDouble(),
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
    );
  }
}
