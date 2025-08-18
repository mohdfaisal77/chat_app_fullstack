class MessageModel {
  final String id;
  final String from;
  final String to;
  final String text;
  final DateTime createdAt;

  MessageModel({
    required this.id,
    required this.from,
    required this.to,
    required this.text,
    required this.createdAt,
  });

  factory MessageModel.fromJson(Map<String, dynamic> j) => MessageModel(
        id: j['id']?.toString() ?? '',
        from: j['from']?.toString() ?? '',
        to: j['to']?.toString() ?? '',
        text: j['text'] ?? '',
        createdAt: DateTime.parse(j['createdAt']).toLocal(),
      );
}
