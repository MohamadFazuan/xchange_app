import 'package:flutter/material.dart';

class AddFriendScreen extends StatefulWidget {
  const AddFriendScreen({super.key});

  @override
  _AddFriendScreenState createState() => _AddFriendScreenState();
}

class _AddFriendScreenState extends State<AddFriendScreen> {
  final _formKey = GlobalKey<FormState>();
  String _friendUsername = "";
  List<Map<String, dynamic>> filteredUsers = [];
  List<Map<String, dynamic>> users = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Friend'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Friend\'s Username',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter a username';
                  }
                  return null;
                },
                onSaved: (value) => _friendUsername = value!,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    // TODO: Implement add friend logic here
                    Navigator.pushNamed(context, '/friends');
                  }
                },
                child: const Text('Add Friend'),
              ),
              const SizedBox(height: 20),
              Expanded(
                // Wrap ListView.builder with Expanded
                child: ListView.builder(
                  itemCount: filteredUsers.length,
                  itemBuilder: (context, index) {
                    final friend = filteredUsers[index];
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
                          Navigator.pushNamed(context, '/checkout',
                              arguments: friend);
                        },
                        onLongPress: () {
                          // Show delete confirmation dialog
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Delete Friend'),
                              content: Text(
                                  'Are you sure you want to delete ${friend['name']}?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    setState(() {
                                      users.remove(friend);
                                      filteredUsers =
                                          users; // Update filtered list
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
      ),
    );
  }
}
