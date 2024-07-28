import 'package:chatapp/components/chat_bubble.dart';
import 'package:chatapp/components/my_textfield.dart';
import 'package:chatapp/services/auth/auth_service.dart';
import 'package:chatapp/services/chat/chat_services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ChatPage extends StatelessWidget {
  final String receiverEmail;
  final String receiverID;
  ChatPage({super.key, required this.receiverEmail, required this.receiverID});

  final TextEditingController _messageController = TextEditingController();

  // chat & auth services

  final ChatServices _chatServices = ChatServices();
  final AuthService _authService = AuthService();

  // send message
  void sendMessage() async {
    if (_messageController.text.isNotEmpty) {
      await _chatServices.sendMessage(receiverID, _messageController.text);
      _messageController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text(receiverEmail),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.grey,
      ),
      body: Column(
        children: [
          Expanded(
            child: _buildMessageList(),
          ),
          // user input
          _buildUserInput(),
        ],
      ),
    );
  }

  Widget _buildMessageList() {
    String senderID = _authService.getCurrentUser()!.uid;
    return StreamBuilder(
      stream: _chatServices.getMessages(receiverID, senderID),
      builder: (context, snapshot) {
        // errors
        if (snapshot.hasError) {
          return const Text("Errors!");
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Text("Loading...");
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Text("No messages found.");
        }

        var messages = snapshot.data!.docs;

        return ListView(
          children:
              messages.map<Widget>((doc) => _buildMessageItem(doc)).toList(),
        );
      },
    );
  }

  Widget _buildMessageItem(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    // check current user
    bool isCurrentUser = data['senderID'] == _authService.getCurrentUser()!.uid;

    var alignment =
        isCurrentUser ? Alignment.centerRight : Alignment.centerLeft;

    return Container(
      alignment: alignment,
      child: Column(
        crossAxisAlignment:
            isCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          ChatBubble(message: data["message"], isCurrentUser: isCurrentUser)
        ],
      ),
    );
  }

  Widget _buildUserInput() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 50.0),
      child: Row(
        children: [
          Expanded(
              child: MyTextField(
                  controller: _messageController,
                  hintText: "Type a message..",
                  obsecureText: false)),
          Container(
              margin: const EdgeInsets.only(right: 25),
              decoration: const BoxDecoration(
                  color: Colors.green, shape: BoxShape.circle),
              child: IconButton(
                  onPressed: sendMessage, icon: const Icon(Icons.arrow_upward)))
        ],
      ),
    );
  }
}

