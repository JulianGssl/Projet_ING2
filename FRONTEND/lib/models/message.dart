class Message {
  int idConv;
  int idSender;
  String content;
  DateTime date;
  bool isRead;

  Message({
    required this.idConv,
    required this.idSender,
    required this.content,
    required this.date,
    required this.isRead,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      idConv: json['id_conv'] as int,
      idSender: json['id_sender'] as int,
      content: json['content'] as String,
      date: DateTime.parse(json['date'] as String),
      isRead: json['is_read'] == 1, // Convertir le TINYINT en booléen
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_conv': idConv,
      'id_sender': idSender,
      'content': content,
      'date': date.toIso8601String(),
      'is_read': isRead ? 1 : 0, // Convertir le booléen en TINYINT
    };
  }
}
