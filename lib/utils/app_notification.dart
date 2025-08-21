class AppNotification {
  final String id;
  final String title;
  final String body;
  final Map<String, dynamic> data;
  bool read;
  final DateTime receivedAt;

  AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.data,
    this.read = false,
    DateTime? receivedAt,
  }) : receivedAt = receivedAt ?? DateTime.now();

  // For SharedPreferences (as JSON)
  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'body': body,
    'data': data,
    'read': read,
    'receivedAt': receivedAt.toIso8601String(),
  };

  static AppNotification fromJson(Map<String, dynamic> json) => AppNotification(
    id: json['id'],
    title: json['title'] ?? '',
    body: json['body'] ?? '',
    data: Map<String, dynamic>.from(json['data'] ?? {}),
    read: json['read'] ?? false,
    receivedAt: DateTime.tryParse(json['receivedAt'] ?? '') ?? DateTime.now(),
  );
}
