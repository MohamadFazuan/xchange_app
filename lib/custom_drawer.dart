import 'package:flutter/material.dart';
import 'package:xchange_app/login_state.dart';
import 'package:badges/badges.dart' as badges;
import 'package:xchange_app/notification_state.dart';

class CustomScaffold extends StatelessWidget {
  final Widget body;
  final String? appBarTitle;
  final String? profileImageUrl;
  final AppBar? appBar;
  bool hasUnreadNotifications = false;

  CustomScaffold({
    super.key,
    required this.body,
    this.appBarTitle,
    this.profileImageUrl,
    this.appBar,
  });

  Future<Map<String, dynamic>> fetchUserData() async {
    _checkNotifications();
    return await LoginState.getUserData() ?? {};
  }

  Future<void> _checkNotifications() async {
    final notifications = await NotificationState.getNotifications();
    if (notifications != null) {
      hasUnreadNotifications = notifications.isNotEmpty;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: fetchUserData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Text('Error: ${snapshot.error}'),
            ),
          );
        }

        final userData = snapshot.data ?? {};
        final userName = userData['name'] ?? 'Guest';
        final userId = userData['walletId'] ?? 'Unknown';

        return Scaffold(
          appBar: appBarTitle != null
              ? AppBar(
                  title: Text(appBarTitle!),
                  actions: [
                    IconButton(
                      icon: badges.Badge(
                        showBadge: hasUnreadNotifications,
                        badgeContent: Text(
                          "!",
                          style: TextStyle(color: Colors.white),
                        ),
                        badgeStyle: badges.BadgeStyle(
                          badgeColor: Colors.red,
                        ),
                        child: Icon(Icons.notifications),
                      ),
                      onPressed: () {
                        Navigator.pushNamed(context, '/notification');
                      },
                    ),
                  ],
                )
              : null,
          drawer: _buildDrawer(context, userName, userId),
          body: body,
        );
      },
    );
  }

  Widget _buildDrawer(BuildContext context, String userName, String userId) {
    return Drawer(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(16, 32, 16, 16),
            height: 170, // Fixed height for header
            decoration: const BoxDecoration(
              color: Colors.blue,
              image: DecorationImage(
                image: AssetImage('assets/header_bg.jpeg'),
                fit: BoxFit.cover,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 35,
                      backgroundImage:
                          profileImageUrl != null && profileImageUrl!.isNotEmpty
                              ? NetworkImage(profileImageUrl!)
                              : const AssetImage('assets/profile_sample.png')
                                  as ImageProvider,
                      backgroundColor: Colors.white,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            userName,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'ID: $userId',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildDrawerItem(
                  icon: Icons.home,
                  text: 'Home',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/wallet');
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.list,
                  text: 'Transaction',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/transaction');
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.account_circle,
                  text: 'Account',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/account');
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.people,
                  text: 'Friends',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/friends');
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.settings,
                  text: 'Settings',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/setting');
                  },
                ),
                const Divider(),
                _buildDrawerItem(
                  icon: Icons.logout,
                  text: 'Logout',
                  onTap: () {
                    Navigator.of(context).pushNamedAndRemoveUntil(
                      '/login',
                      (Route<dynamic> route) => false,
                    );
                  },
                  color: Colors.red,
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              'Version 1.0.0',
              style: TextStyle(color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String text,
    required GestureTapCallback onTap,
    Color? color,
  }) {
    return ListTile(
      leading: Icon(icon, color: color ?? Colors.black87),
      title: Text(
        text,
        style: TextStyle(
          fontSize: 16,
          color: color ?? Colors.black87,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: onTap,
    );
  }
}
