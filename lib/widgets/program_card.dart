import 'package:flutter/material.dart';
import 'package:uptop_careers/config/constants.dart';
import 'package:uptop_careers/config/theme.dart';

class ProgramCard extends StatelessWidget {
  final String universityName;
  final String programName;
  final String duration;
  final String mode;
  final double earning;
  final String? logoPath;
  final VoidCallback? onTap;
  final VoidCallback? onShare;

  const ProgramCard({
    super.key,
    required this.universityName,
    required this.programName,
    required this.duration,
    required this.mode,
    required this.earning,
    this.logoPath,
    this.onTap,
    this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusLG),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [_buildImageWithBadge(), _buildCardContent(context)],
        ),
      ),
    );
  }

  Widget _buildImageWithBadge() {
    return Stack(
      children: [
        AspectRatio(aspectRatio: 16 / 9, child: _buildImage()),
        Positioned(top: 8, right: 8, child: _buildEarningBadge()),
      ],
    );
  }

  Widget _buildImage() {
    final imagePath = logoPath ?? AppConstants.logoPath;
    final isNetworkImage =
        imagePath.startsWith('http://') || imagePath.startsWith('https://');

    if (isNetworkImage) {
      return Image.network(
        imagePath,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Container(
          color: Colors.grey[200],
          child: const Icon(Icons.school, size: 40, color: Colors.grey),
        ),
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            color: Colors.grey[200],
            child: Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                    : null,
              ),
            ),
          );
        },
      );
    } else {
      return Image.asset(
        imagePath,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Container(
          color: Colors.grey[200],
          child: const Icon(Icons.school, size: 40, color: Colors.grey),
        ),
      );
    }
  }

  Widget _buildEarningBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.successGreen,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        '${AppConstants.currency}${earning.toStringAsFixed(0)}',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildCardContent(BuildContext context) {
    return Flexible(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacingSM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  universityName,
                  style: Theme.of(context).textTheme.bodySmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  programName,
                  style: Theme.of(
                    context,
                  ).textTheme.titleMedium?.copyWith(fontSize: 14),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppConstants.spacingSM),
                Row(
                  children: [
                    _buildInfoChip(duration),
                    const SizedBox(width: AppConstants.spacingSM),
                    _buildInfoChip(mode),
                  ],
                ),
              ],
            ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onShare,
                icon: const Icon(Icons.share, size: 16),
                label: const Text('Share & Earn'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  textStyle: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.backgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.borderColor.withOpacity(0.5)),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 10, color: AppTheme.textSecondary),
      ),
    );
  }
}
