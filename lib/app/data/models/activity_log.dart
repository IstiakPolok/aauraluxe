class ActivityLog {
  final String id;
  final String? performerId;
  final String performerEmail;
  final String performerRole;
  final String action;
  final String entityType; // 'product', 'order', 'category', 'user'
  final String entityId;
  final DateTime timestamp;

  ActivityLog({
    required this.id,
    this.performerId,
    required this.performerEmail,
    required this.performerRole,
    required this.action,
    required this.entityType,
    required this.entityId,
    required this.timestamp,
  });

  factory ActivityLog.fromJson(Map<String, dynamic> json) {
    return ActivityLog(
      id: json['id'] as String? ?? '',
      performerId: json['performer_id'] as String?,
      performerEmail: json['performer_email'] as String? ?? '',
      performerRole: json['performer_role'] as String? ?? '',
      action: json['action'] as String? ?? '',
      entityType: json['entity_type'] as String? ?? '',
      entityId: json['entity_id']?.toString() ?? '',
      timestamp: json['timestamp'] != null 
          ? DateTime.parse(json['timestamp'] as String) 
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id.isNotEmpty) 'id': id,
      'performer_id': performerId,
      'performer_email': performerEmail,
      'performer_role': performerRole,
      'action': action,
      'entity_type': entityType,
      'entity_id': entityId,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}
