
import 'package:cloud_firestore/cloud_firestore.dart';

class MessageChat {
  String idFrom;
  String idTo;
  String timestamp;
  String content;
  int type;

  MessageChat({
    this.idFrom,
    this.idTo,
    this.timestamp,
    this.content,
    this.type,
  });

  Map<String, dynamic> toJson() {
    return {
      'idFrom': this.idFrom,
      'idTo': this.idTo,
      'timestamp': this.timestamp,
      'content': this.content,
      'type': this.type,
    };
  }

  factory MessageChat.fromDocument(DocumentSnapshot doc) {
    String idFrom = doc.get("idFrom");
    String idTo = doc.get("idTo");
    String timestamp = doc.get("timestamp");
    String content = doc.get("content");
    int type = doc.get("type");
    return MessageChat(idFrom: idFrom, idTo: idTo, timestamp: timestamp, content: content, type: type);
  }
}
