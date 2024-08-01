import 'package:chatapp/components/my_drawer.dart';
import 'package:chatapp/components/user_tile.dart';
import 'package:chatapp/pages/chat_page.dart';
import 'package:chatapp/services/auth/auth_service.dart';
import 'package:chatapp/services/chat/chat_services.dart';
import 'package:flutter/material.dart';
import 'package:chatapp/components/my_textfield.dart';

class HomePage extends StatefulWidget {
  HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ChatServices _chatServices = ChatServices();
  final AuthService _authService = AuthService();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text("Home"),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.grey,
        elevation: 0,
      ),
      drawer: const MyDrawer(),
      body: Column(
        children: [
          MyTextField(
            controller: _searchController,
            hintText: "Search by email",
            obsecureText: false,
          ),
          const SizedBox(height: 30),
          Expanded(child: _buildUserList()),
        ],
      ),
    );
  }

  // build a list of users except for the current logged-in user
  Widget _buildUserList() {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _chatServices.getUserStreamExcludeBlocked(),
      builder: (context, snapshot) {
        // error check
        if (snapshot.hasError) {
          return const Text("Error!");
        }
        // loading
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Text("Loading...");
        }
        var users = snapshot.data!;
        if (_searchQuery.isNotEmpty) {
          users = users
              .where((user) => user["email"]
                  .toString()
                  .toLowerCase()
                  .contains(_searchQuery.toLowerCase()))
              .toList();
        }
        return ListView(
          children: users
              .map<Widget>((userData) => FutureBuilder<int>(
                    future: _chatServices.getUnreadMessagesCount(
                        _authService.getCurrentUser()!.uid, userData["uid"]),
                    builder: (context, snapshot) {
                      int unreadCount = 0;
                      if (snapshot.connectionState == ConnectionState.done) {
                        unreadCount = snapshot.data ?? 0;
                      }
                      return _buildUserListItem(userData, unreadCount, context);
                    },
                  ))
              .toList(),
        );
      },
    );
  }

  // build individual list tile for users
  Widget _buildUserListItem(
      Map<String, dynamic> userData, int unreadCount, BuildContext context) {
    if (userData["email"] != _authService.getCurrentUser()!.email) {
      return UserTile(
        text: userData["email"],
        unreadCount: unreadCount,
        onTap: () async {
          // Mark messages as read and update state
          await _chatServices.markMessagesAsRead(
            _authService.getCurrentUser()!.uid,
            userData["uid"],
          );

          // Refresh the state to update the UI
          setState(() {
            // This forces a rebuild to reflect changes
          });

          // Navigate to chat page
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatPage(
                receiverEmail: userData["email"],
                receiverID: userData["uid"],
              ),
            ),
          );
        },
      );
    } else {
      return Container();
    }
  }
}

