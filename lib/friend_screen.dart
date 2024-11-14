import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:xchange_app/friend.dart';
import 'package:http/http.dart' as http;


class FriendScreen extends StatefulWidget {
  const FriendScreen({super.key});

  @override
  _FriendScreenState createState() => _FriendScreenState();
}

class _FriendScreenState extends State<FriendScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> friends = [];
  List<Map<String, dynamic>> filteredFriends = [];

  List<Friends> friend = [];

  Future<void> _loadMatchExchanges() async {
    var url = Uri.http("192.168.8.106:3000", '/friend/queryAll');
    var response = await http.get(url);
    final jsonData = jsonDecode(response.body);
    setState(() {
      friend = jsonData.map<Friends>((data) => Friends.fromJson(data)).toList();
    });
    }

  @override
  void initState() {
    super.initState();
    filteredFriends = friends;
  }

  void _searchFriends(String query) {
    setState(() {
      filteredFriends = friends.where((friend) => friend['name'].toLowerCase().contains(query.toLowerCase())).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Friends'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Search friends',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: _searchFriends,
            ),
            const SizedBox(height: 20),
            const Text("Long press to delete friends"),
            const SizedBox(height: 20),
            Expanded( // Wrap ListView.builder with Expanded
              child: ListView.builder(
                itemCount: filteredFriends.length,
                itemBuilder: (context, index) {
                  final friend = filteredFriends[index];
                  return Card(
                    child: ListTile(
                      leading: const Icon(Icons.person), // Icon at the left side
                      title: Text(friend['name']),
                      subtitle: Text('Status: ${friend['status']}'),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('${friend['distance']}'),
                          const SizedBox(height: 5),
                          const Icon(Icons.call, size: 18, color: Colors.blue),
                        ],
                      ),
                      onTap: () {
                        Navigator.pushNamed(context, '/checkout', arguments: friend);
                      },
                      onLongPress: () {
                        // Show delete confirmation dialog
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Delete Friend'),
                            content: Text('Are you sure you want to delete ${friend['name']}?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () {
                                  setState(() {
                                    friends.remove(friend);
                                    filteredFriends = friends; // Update filtered list
                                    Navigator.pop(context); // Close dialog
                                  });
                                },
                                child: const Text('Delete'),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/add_friend');
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}