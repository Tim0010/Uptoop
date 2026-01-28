import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:uptop_careers/providers/user_provider.dart';
import 'package:uptop_careers/providers/auth_provider.dart';
import 'package:uptop_careers/services/user_data_service.dart';

class ProfileScreen extends StatefulWidget {
  final VoidCallback onBack;

  const ProfileScreen({super.key, required this.onBack});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isEditing = false;
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _schoolController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _schoolController.dispose();
    super.dispose();
  }

  void _showQrDialog(String referralCode) {
    final referralLink = 'https://uptop.careers/ref/$referralCode';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Your Referral QR Code', textAlign: TextAlign.center),
        content: SizedBox(
          width: 250,
          height: 250,
          child: Center(
            child: QrImageView(
              data: referralLink,
              version: QrVersions.auto,
              size: 200.0,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final user = userProvider.currentUser;

    // Initialize fields from user once
    if (user != null) {
      if (_nameController.text.isEmpty) _nameController.text = user.name;
      if (_ageController.text.isEmpty) _ageController.text = user.age ?? '';
      if (_schoolController.text.isEmpty)
        _schoolController.text = user.school ?? '';
    }

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: widget.onBack,
        ),
        title: const Text(
          'My Profile',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildUserSummaryCard(userProvider),
            const SizedBox(height: 24),
            if (user != null)
              _buildReferralCodeCard(user.referralCode, user.name),
            const SizedBox(height: 24),
            _buildProfileDetailsCard(userProvider),
            const SizedBox(height: 24),
            if (user != null)
              _buildAccountInfoCard(user.email, user.phone, user.createdAt),
            const SizedBox(height: 24),
            _buildSignOutButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildReferralCodeCard(String referralCode, String userName) {
    return Card(
      elevation: 1,
      shadowColor: Colors.grey.withOpacity(0.2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: const [
                    Icon(Icons.qr_code_2),
                    SizedBox(width: 8),
                    Text(
                      'Your Referral Code',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                TextButton(
                  onPressed: () => _showQrDialog(referralCode),
                  child: const Text('Show QR'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    referralCode,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.copy),
                    onPressed: () =>
                        Clipboard.setData(ClipboardData(text: referralCode)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      final referralLink =
                          'https://uptop.careers/ref/$referralCode';
                      final message =
                          '$userName invites you to join Uptop Careers and start earning! Use my referral code: $referralCode\n$referralLink';
                      Share.share(message);
                    },
                    icon: const Icon(Icons.share),
                    label: const FittedBox(child: Text('WhatsApp')),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      final referralLink =
                          'https://uptop.careers/ref/$referralCode';
                      Clipboard.setData(ClipboardData(text: referralLink));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Referral link copied!')),
                      );
                    },
                    icon: const Icon(Icons.copy),
                    label: const FittedBox(child: Text('Copy Link')),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserSummaryCard(UserProvider userProvider) {
    final user = userProvider.currentUser;
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.blue.shade700,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            _buildAvatar(),
            const SizedBox(width: 16),
            if (user != null)
              _buildUserInfo(
                user.name,
                user.level,
                user.totalReferrals,
                user.totalEarnings,
              )
            else
              const SizedBox.shrink(),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        const CircleAvatar(
          radius: 40,
          backgroundColor: Colors.white,
          child: Icon(Icons.person, color: Colors.blue, size: 36),
        ),
        Positioned(
          bottom: -4,
          right: -4,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.orange,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.blue.shade700, width: 2),
            ),
            child: const Icon(Icons.camera_alt, color: Colors.white, size: 18),
            padding: const EdgeInsets.all(4),
          ),
        ),
      ],
    );
  }

  Widget _buildUserInfo(
    String fullName,
    int level,
    int totalReferrals,
    double earned,
  ) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            fullName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Level $level',
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    _StatItem(count: '$totalReferrals', label: 'Referrals'),
                    const SizedBox(width: 24),
                    _StatItem(
                      count: '₹${earned.toStringAsFixed(0)}',
                      label: 'Earned',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProfileDetailsCard(UserProvider userProvider) {
    return Card(
      elevation: 1,
      shadowColor: Colors.grey.withOpacity(0.2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Profile Details',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                if (_isEditing)
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => setState(() => _isEditing = false),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          final updates = <String, dynamic>{};
                          if (_nameController.text.isNotEmpty)
                            updates['full_name'] = _nameController.text;
                          if (_ageController.text.isNotEmpty)
                            updates['age'] = _ageController.text;
                          if (_schoolController.text.isNotEmpty)
                            updates['college'] = _schoolController.text;
                          if (updates.isNotEmpty) {
                            await UserDataService.updateUserProfile(updates);
                            await userProvider.loadUserData();
                          }
                          if (mounted) setState(() => _isEditing = false);
                        },
                        child: const Text('Save'),
                      ),
                    ],
                  )
                else
                  TextButton.icon(
                    onPressed: () => setState(() => _isEditing = true),
                    icon: const Icon(Icons.edit, size: 16),
                    label: const Text('Edit'),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            _buildDetailItem(
              icon: Icons.person,
              label: 'Full Name',
              controller: _nameController,
              isEditing: _isEditing,
            ),
            _buildDetailItem(
              icon: Icons.calendar_today,
              label: 'Age',
              controller: _ageController,
              isEditing: _isEditing,
            ),
            _buildDetailItem(
              icon: Icons.school,
              label: 'School/College',
              controller: _schoolController,
              isEditing: _isEditing,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem({
    required IconData icon,
    required String label,
    required TextEditingController controller,
    required bool isEditing,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey.shade600, size: 20),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                ),
                const SizedBox(height: 2),
                if (isEditing)
                  TextField(
                    controller: controller,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                    decoration: const InputDecoration(
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                      border: InputBorder.none,
                    ),
                  )
                else
                  Text(
                    controller.text,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountInfoCard(
    String email,
    String phone,
    DateTime memberSince,
  ) {
    return Card(
      elevation: 1,
      shadowColor: Colors.grey.withOpacity(0.2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.school_outlined),
                SizedBox(width: 8),
                Text(
                  'Account Info',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _buildInfoRow(label: 'Email', value: email.isEmpty ? '-' : email),
            _buildInfoRow(label: 'Phone', value: phone.isEmpty ? '-' : phone),
            _buildInfoRow(
              label: 'Member Since',
              value: '${_monthName(memberSince.month)} ${memberSince.year}',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow({required String label, required String value}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildSignOutButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () async {
          await context.read<AuthProvider>().logout();
          if (mounted) Navigator.of(context).pop();
        },
        icon: const Icon(Icons.logout, color: Colors.red),
        label: const Text('Sign Out', style: TextStyle(color: Colors.red)),
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: Colors.red.withOpacity(0.3)),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String count;
  final String label;

  const _StatItem({required this.count, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          count,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 13),
        ),
      ],
    );
  }
}

String _monthName(int m) {
  const names = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];
  if (m < 1 || m > 12) return '';
  return names[m - 1];
}
