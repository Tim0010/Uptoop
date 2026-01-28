import 'package:flutter/material.dart';

class NotificationsScreen extends StatelessWidget {
  final VoidCallback onBack;

  const NotificationsScreen({super.key, required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: onBack,
        ),
        title: const Text('Notifications', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 1,
        shadowColor: Colors.grey.withOpacity(0.2),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        itemCount: _notifications.length,
        itemBuilder: (context, index) {
          return _NotificationItem(notification: _notifications[index]);
        },
        separatorBuilder: (context, index) => const Divider(
          height: 1,
          indent: 72,
          endIndent: 16,
        ),
      ),
    );
  }
}

class _NotificationItem extends StatelessWidget {
  final _Notification notification;

  const _NotificationItem({required this.notification});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: notification.iconBgColor,
            child: Icon(notification.icon, color: notification.iconColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  notification.title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 4),
                Text(
                  notification.message,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                ),
                const SizedBox(height: 8),
                Text(
                  notification.time,
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                ),
              ],
            ),
          ),
          if (notification.isUnread)
            Container(
              margin: const EdgeInsets.only(left: 16, top: 4),
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
              ),
            ),
        ],
      ),
    );
  }
}

class _Notification {
  final IconData icon;
  final Color iconBgColor;
  final Color iconColor;
  final String title;
  final String message;
  final String time;
  final bool isUnread;

  const _Notification({
    required this.icon,
    required this.iconBgColor,
    required this.iconColor,
    required this.title,
    required this.message,
    required this.time,
    this.isUnread = false,
  });
}

final _notifications = [
  const _Notification(
    icon: Icons.card_giftcard,
    iconBgColor: Color(0xFFFFF3E0),
    iconColor: Color(0xFFFFA726),
    title: 'Referral Bonus Unlocked!',
    message: 'Your referral, Piyush Kumar, has completed their application. You\'ve earned ₹100!',
    time: '2 hours ago',
    isUnread: true,
  ),
  const _Notification(
    icon: Icons.star_outline,
    iconBgColor: Color(0xFFFFF3E0),
    iconColor: Color(0xFFFFA726),
    title: 'Spin Wheel Winner!',
    message: 'Congratulations! You won ₹50 on the Daily Spin Wheel.',
    time: '1 day ago',
    isUnread: true,
  ),
  const _Notification(
    icon: Icons.military_tech_outlined,
    iconBgColor: Color(0xFFE3F2FD),
    iconColor: Color(0xFF42A5F5),
    title: '5-Day Streak!',
    message: 'You\'ve logged in for 5 days in a row. Here\'s a bonus of 20 coins!',
    time: '2 days ago',
  ),
  const _Notification(
    icon: Icons.notifications_none,
    iconBgColor: Color(0xFFE8F5E9),
    iconColor: Color(0xFF66BB6A),
    title: 'New Weekly Mission',
    message: 'A new weekly mission is available. Refer 5 friends to earn ₹100.',
    time: '3 days ago',
  ),
];
