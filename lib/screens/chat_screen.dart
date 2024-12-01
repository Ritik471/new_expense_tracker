
import 'package:flutter/material.dart';
import '../services/message_service.dart';
import '../models/message_model.dart';

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  List<Message> messages = [];
  TextEditingController messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  // Load messages from the database
  void _loadMessages() async {
    final dbMessages = await MessageService.getMessages();
    setState(() {
      messages = dbMessages;
    });
  }

  // Send a user message
  void _sendMessage(String messageText) async {
    final message = Message(
      senderId: 'user',
      receiverId: 'system',
      message: messageText,
      timestamp: DateTime.now().toString(),
    );
    await MessageService.storeMessage(message);
    setState(() {
      messages.add(message);
    });
    _triggerAutoReply(messageText);
  }

  // Trigger auto-reply with delay
  void _triggerAutoReply(String userMessage) {
    Future.delayed(const Duration(seconds: 1), () {
      _sendAutoReply(userMessage);
    });
  }

  // Send auto-reply
  void _sendAutoReply(String userMessage) async {
    final replyMessage = await MessageService().handleQuery(userMessage); // Updated to use handleQuery
    final autoReply = Message(
      senderId: 'system',
      receiverId: 'user',
      message: replyMessage,
      timestamp: DateTime.now().toString(),
    );
    await MessageService.storeMessage(autoReply);
    setState(() {
      messages.add(autoReply);
    });
  }

  // Delete all chat history
  void _deleteHistory() async {
    await MessageService.clearMessages();
    setState(() {
      messages.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _deleteHistory, // Deletes chat history
            tooltip: 'Delete Chat History',
          ),
        ],
      ),
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  final message = messages[index];
                  final isUserMessage = message.senderId == 'user';

                  return _buildMessageBubble(message.message, isUserMessage);
                },
              ),
            ),
            _buildMessageInput(),
          ],
        ),
      ),
    );
  }

  // Message input field and send button
  Widget _buildMessageInput() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: messageController,
              decoration: InputDecoration(
                hintText: 'Type a message...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: () {
              if (messageController.text.isNotEmpty) {
                _sendMessage(messageController.text);
                messageController.clear();
              }
            },
          ),
        ],
      ),
    );
  }

  // Message bubble widget
  Widget _buildMessageBubble(String messageText, bool isUserMessage) {
    return Align(
      alignment: isUserMessage ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
          decoration: BoxDecoration(
            color: isUserMessage ? Colors.blueAccent : Colors.grey[300],
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(15),
              topRight: const Radius.circular(15),
              bottomLeft: isUserMessage ? const Radius.circular(15) : Radius.zero,
              bottomRight: isUserMessage ? Radius.zero : const Radius.circular(15),
            ),
          ),
          child: Text(
            messageText,
            style: TextStyle(
              color: isUserMessage ? Colors.white : Colors.black,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }
}