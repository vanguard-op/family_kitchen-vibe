class KingdomModel {
  final String kingdomId;
  final String name;
  final String mode; // "solo" or "family"
  final String createdBy;
  final String timezone;
  final int memberCount;
  final DateTime createdAt;

  KingdomModel({
    required this.kingdomId,
    required this.name,
    required this.mode,
    required this.createdBy,
    required this.timezone,
    required this.memberCount,
    required this.createdAt,
  });

  factory KingdomModel.fromJson(Map<String, dynamic> json) {
    return KingdomModel(
      kingdomId: json['kingdom_id'],
      name: json['name'],
      mode: json['mode'],
      createdBy: json['created_by'],
      timezone: json['timezone'],
      memberCount: json['member_count'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}
