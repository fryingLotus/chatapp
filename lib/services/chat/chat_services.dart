import 'package:chatapp/models/message.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatServices extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<List<Map<String, dynamic>>> getUserStream() {
    return _firestore.collection("Users").snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final user = doc.data();
        return user;
      }).toList();
    });
  }

  Stream<List<Map<String, dynamic>>> getUserStreamExcludeBlocked() {
    final currentUser = _auth.currentUser;
    return _firestore
        .collection('Users')
        .doc(currentUser!.uid)
        .collection('BlockedUsers')
        .snapshots()
        .asyncMap((snapshot) async {
      final blockedUserIds = snapshot.docs.map((doc) => doc.id).toList();
      final usersSnapshot = await _firestore.collection('Users').get();

      return usersSnapshot.docs
          .where((doc) =>
              doc.data()['email'] != currentUser.email &&
              !blockedUserIds.contains(doc.id))
          .map((doc) => doc.data())
          .toList();
    });
  }

  Future<void> sendMessage(String receiverID, String message) async {
    final String currentUserID = _auth.currentUser!.uid;
    final String currentUserEmail = _auth.currentUser!.email!;
    final Timestamp timestamp = Timestamp.now();
    Message newMessage = Message(
        senderID: currentUserID,
        senderEmail: currentUserEmail,
        receiverID: receiverID,
        message: message,
        timestamp: timestamp,
        isRead: false);

    List<String> ids = [currentUserID, receiverID];
    ids.sort(); // ensure the chatroomID is the same for any 2 people
    String chatroomID = ids.join('_');
    await _firestore
        .collection("chat_rooms")
        .doc(chatroomID)
        .collection("messages")
        .add(newMessage.toMap());
  }

  Stream<QuerySnapshot> getMessages(String userID, String otherUserID) {
    List<String> ids = [userID, otherUserID];
    ids.sort(); // ensure the chatroomID is the same for any 2 people
    String chatroomID = ids.join('_');
    return _firestore
        .collection("chat_rooms")
        .doc(chatroomID)
        .collection("messages")
        .orderBy("timestamp", descending: false)
        .snapshots();
  }

  Future<int> getUnreadMessagesCount(String userID, String otherUserID) async {
    List<String> ids = [userID, otherUserID];
    ids.sort(); // ensure the chatroomID is the same for any 2 people
    String chatroomID = ids.join('_');
    QuerySnapshot querySnapshot = await _firestore
        .collection("chat_rooms")
        .doc(chatroomID)
        .collection("messages")
        .where('receiverID', isEqualTo: userID)
        .where('isRead', isEqualTo: false)
        .get();
    return querySnapshot.docs.length;
  }

  Future<void> markMessagesAsRead(String userID, String otherUserID) async {
    List<String> ids = [userID, otherUserID];
    ids.sort(); // ensure the chatroomID is the same for any 2 people
    String chatroomID = ids.join('_');
    QuerySnapshot querySnapshot = await _firestore
        .collection("chat_rooms")
        .doc(chatroomID)
        .collection("messages")
        .where('receiverID', isEqualTo: userID)
        .where('isRead', isEqualTo: false)
        .get();

    for (var doc in querySnapshot.docs) {
      await doc.reference.update({'isRead': true});
    }
  }

  Future<void> reportUser(String messageId, String userId) async {
    final currentUser = _auth.currentUser;
    final Map<String, Object> report = {
      'reportedBy': currentUser!.uid,
      'messageId': messageId,
      'messageOwnerId': userId,
      'timestamp': FieldValue.serverTimestamp()
    };
    await _firestore.collection('Reports').add(report);
  }

  Future<void> blockUser(String userId) async {
    final currentUser = _auth.currentUser;
    await _firestore
        .collection('Users')
        .doc(currentUser!.uid)
        .collection('BlockedUsers')
        .doc(userId)
        .set({});
    notifyListeners();
  }

  Future<void> unblockUser(String blockedUserId) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      print('Current user is null');
      return;
    }

    try {
      await _firestore
          .collection('Users')
          .doc(currentUser.uid)
          .collection('BlockedUsers')
          .doc(blockedUserId)
          .delete();
      print('User unblocked successfully');
    } catch (e) {
      print('Error unblocking user: $e');
    }

    notifyListeners();
  }

  Stream<List<Map<String, dynamic>>> getBlockedUserStream(String userId) {
    return _firestore
        .collection('Users')
        .doc(userId)
        .collection('BlockedUsers')
        .snapshots()
        .asyncMap((snapshot) async {
      final blockedUserIds = snapshot.docs.map((doc) => doc.id).toList();
      final userDoc = await Future.wait(blockedUserIds
          .map((id) => _firestore.collection('Users').doc(id).get()));
      return userDoc.map((doc) => doc.data() as Map<String, dynamic>).toList();
    });
  }
}
