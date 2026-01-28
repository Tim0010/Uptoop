import 'package:flutter/material.dart';
import 'package:uptop_careers/models/leaderboard_entry.dart'; // Assuming model exists

class LeaderboardItem extends StatelessWidget {
  final LeaderboardEntry entry;

  const LeaderboardItem({super.key, required this.entry});

  @override
  Widget build(BuildContext context) {
    final bool isCurrentUser = entry.isCurrentUser;
    final int rank = entry.rank;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6.0),
      elevation: isCurrentUser ? 4 : 1,
      shadowColor: isCurrentUser
          ? Colors.blue.withOpacity(0.3)
          : Colors.grey.withOpacity(0.2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
        side: isCurrentUser
            ? const BorderSide(color: Colors.blue, width: 2)
            : BorderSide(color: Colors.grey.shade300, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
        child: Row(
          children: [
            _buildRankIndicator(rank),
            const SizedBox(width: 12),
            _buildAvatar(entry),
            const SizedBox(width: 12),
            _buildUserInfo(entry),
            _buildEarnings(entry),
          ],
        ),
      ),
    );
  }

  Widget _buildRankIndicator(int rank) {
    if (rank <= 3) {
      Color color;
      switch (rank) {
        case 1:
          // Placeholder
          color = Colors.amber;
          break;
        case 2:
          // Placeholder
          color = Colors.grey.shade400;
          break;
        default:
          // Placeholder
          color = Colors.brown.shade400;
      }
      // Using an icon as a placeholder for the image asset
      return Icon(Icons.emoji_events, color: color, size: 28);
    } else {
      return SizedBox(
        width: 28,
        child: Center(
          child: Text(
            '$rank',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
          ),
        ),
      );
    }
  }

  Widget _buildAvatar(LeaderboardEntry entry) {
    return CircleAvatar(
      radius: 22,
      backgroundColor: Colors.grey.shade200,
      // backgroundImage: entry.avatarUrl != null ? NetworkImage(entry.avatarUrl!) : null,
      child: Text(
        entry.name.isNotEmpty ? entry.name[0].toUpperCase() : '?',
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
      ),
    );
  }

  Widget _buildUserInfo(LeaderboardEntry entry) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                entry.name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              if (entry.isCurrentUser)
                const Text(
                  ' (You)',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.blue,
                    fontWeight: FontWeight.w500,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            '${entry.totalReferrals} referrals',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildEarnings(LeaderboardEntry entry) {
    return Text(
      '₹${entry.totalEarnings.toStringAsFixed(0)}',
      style: TextStyle(
        color: Colors.green.shade600,
        fontWeight: FontWeight.bold,
        fontSize: 16,
      ),
    );
  }
}
