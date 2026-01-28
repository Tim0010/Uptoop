import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uptop_careers/config/constants.dart';
import 'package:uptop_careers/config/theme.dart';
import 'package:uptop_careers/models/program.dart';
import 'package:uptop_careers/models/application.dart';
import 'package:uptop_careers/screens/application_journey_screen.dart';
import 'package:uptop_careers/providers/application_provider.dart';
import 'package:url_launcher/url_launcher.dart';

class ProgramDetailsPopup extends StatelessWidget {
  final Program program;
  final String? referralId;

  const ProgramDetailsPopup({
    super.key,
    required this.program,
    this.referralId,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spacingLG),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context),
          const SizedBox(height: AppConstants.spacingMD),
          _buildProgramInfo(context),
          const SizedBox(height: AppConstants.spacingLG),
          _buildActionButtons(context),
          const SizedBox(height: AppConstants.spacingLG),
          _buildShareSection(),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          program.universityName,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }

  Widget _buildProgramInfo(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          program.programName,
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: AppConstants.spacingMD),
        ClipRRect(
          borderRadius: BorderRadius.circular(AppConstants.radiusLG),
          child: _buildProgramImage(),
        ),
        const SizedBox(height: AppConstants.spacingMD),
        _buildInfoRow(),
      ],
    );
  }

  Widget _buildProgramImage() {
    final imagePath = program.logoPath ?? AppConstants.logoPath;
    final isNetworkImage =
        imagePath.startsWith('http://') || imagePath.startsWith('https://');

    if (isNetworkImage) {
      return Image.network(
        imagePath,
        height: 150,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Container(
          height: 150,
          color: Colors.grey[200],
          child: const Icon(Icons.school, size: 40, color: Colors.grey),
        ),
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            height: 150,
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
        height: 150,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Container(
          height: 150,
          color: Colors.grey[200],
          child: const Icon(Icons.school, size: 40, color: Colors.grey),
        ),
      );
    }
  }

  Widget _buildInfoRow() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spacingMD),
      decoration: BoxDecoration(
        color: AppTheme.backgroundColor,
        borderRadius: BorderRadius.circular(AppConstants.radiusLG),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildInfoItem('Duration', program.duration),
          _buildInfoItem('Mode', program.mode),
          _buildInfoItem(
            'You Earn',
            '${AppConstants.currency}${program.earning.toStringAsFixed(0)}',
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String title, String value) {
    return Column(
      children: [
        Text(
          title,
          style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Consumer<ApplicationProvider>(
      builder: (context, appProvider, _) {
        final existingApp = appProvider.getApplicationByProgramId(program.id);
        final hasExistingApp = existingApp != null;
        final isCompleted =
            hasExistingApp && existingApp.status == ApplicationStatus.submitted;

        return Row(
          children: [
            Expanded(
              flex: 2,
              child: OutlinedButton.icon(
                onPressed: program.brochureUrl != null
                    ? () => _openBrochure(context, program.brochureUrl!)
                    : null,
                icon: const Icon(Icons.download_outlined),
                label: const Text('Brochure', style: TextStyle(fontSize: 12)),
              ),
            ),
            const SizedBox(width: AppConstants.spacingMD),
            Expanded(
              flex: 2,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => ApplicationJourneyScreen(
                        program: program,
                        referralId: referralId,
                      ),
                    ),
                  );
                },
                icon: Icon(
                  isCompleted ? Icons.check_circle : Icons.edit_outlined,
                ),
                label: Text(
                  isCompleted
                      ? 'View Application'
                      : hasExistingApp
                      ? 'Continue Application'
                      : 'Start Application',
                  style: const TextStyle(fontSize: 12),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildShareSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Share & Earn ${AppConstants.currency}${program.earning.toStringAsFixed(0)}',
        ),
        const SizedBox(height: AppConstants.spacingSM),
        // Share buttons removed as per user request
      ],
    );
  }

  Future<void> _openBrochure(BuildContext context, String brochureUrl) async {
    try {
      final Uri url = Uri.parse(brochureUrl);

      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Unable to open brochure'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error opening brochure: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
