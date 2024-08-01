import 'package:flutter/material.dart';
import 'package:chatapp/services/chat/chat_services.dart';

class ChatProvider with ChangeNotifier {
  final ChatServices _chatServices = ChatServices();
  int _unreadCount = 0; // Change to int

  int get unreadCount => _unreadCount;

  Future<void> fetchUnreadCounts(String userID, String otherUserID) async {
    // Fetch unread count from your data source
    final count =
        await _chatServices.getUnreadMessagesCount(userID, otherUserID);
    _unreadCount = count; // Update the unread count
    notifyListeners();
  }

  Future<void> markMessagesAsRead(String userID, String otherUserID) async {
    await _chatServices.markMessagesAsRead(userID, otherUserID);
    // Update the unread count after marking messages as read
    await fetchUnreadCounts(userID, otherUserID);
  }
}
