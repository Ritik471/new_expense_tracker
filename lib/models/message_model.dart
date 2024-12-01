class Message {
  final int? id;
  final String senderId;
  final String receiverId;
  final String message;
  final String timestamp;
  final int isSent;
  final int isDelivered;

  Message({
    this.id,
    required this.senderId,
    required this.receiverId,
    required this.message,
    required this.timestamp,
    this.isSent = 1,
    this.isDelivered = 1,
  });

  Map<String, dynamic> toMap() {
    return {
      'sender_id': senderId,
      'receiver_id': receiverId,
      'message': message,
      'timestamp': timestamp,
      'is_sent': isSent,
      'is_delivered': isDelivered,
    };
  }

  factory Message.fromMap(Map<String, dynamic> map) {
    return Message(
      id: map['id'],
      senderId: map['sender_id'],
      receiverId: map['receiver_id'],
      message: map['message'],
      timestamp: map['timestamp'],
      isSent: map['is_sent'],
      isDelivered: map['is_delivered'],
    );
  }
}
