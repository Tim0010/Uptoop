import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:uptop_careers/config/theme.dart';
import 'package:uptop_careers/providers/application_provider.dart';
import 'package:uptop_careers/utils/validators.dart';
import 'package:uptop_careers/utils/input_formatters.dart';

class DocumentCollectionScreen extends StatefulWidget {
  final String applicationId;

  const DocumentCollectionScreen({super.key, required this.applicationId});

  @override
  State<DocumentCollectionScreen> createState() =>
      _DocumentCollectionScreenState();
}

class _DocumentCollectionScreenState extends State<DocumentCollectionScreen> {
  late TextEditingController _fatherNameController;
  late TextEditingController _motherNameController;
  late TextEditingController _aadharController;
  late TextEditingController _addressController;
  late TextEditingController _cityController;
  late TextEditingController _stateController;
  late TextEditingController _countryController;
  late TextEditingController _pinCodeController;

  String? _selectedGender;
  String? _selectedNationality;
  bool _termsAccepted = false;

  final Map<String, bool> _uploadedDocuments = {
    '10th Marksheet': false,
    '12th Marksheet': false,
    'Graduation Certificate': false,
    'Degree Certificate': false,
    'Photo ID': false,
  };

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    _fatherNameController = TextEditingController();
    _motherNameController = TextEditingController();
    _aadharController = TextEditingController();
    _addressController = TextEditingController();
    _cityController = TextEditingController();
    _stateController = TextEditingController();
    _countryController = TextEditingController();
    _pinCodeController = TextEditingController();
  }

  @override
  void dispose() {
    _fatherNameController.dispose();
    _motherNameController.dispose();
    _aadharController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _countryController.dispose();
    _pinCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Complete Your Profile'),
        backgroundColor: AppTheme.primaryBlue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildPersonalInfoSection(),
              const SizedBox(height: 24),
              _buildAddressSection(),
              const SizedBox(height: 24),
              _buildEducationSection(),
              const SizedBox(height: 24),
              _buildDocumentsSection(),
              const SizedBox(height: 24),
              _buildTermsSection(),
              const SizedBox(height: 24),
              _buildSubmitButton(),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPersonalInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Personal Information',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        _buildTextField('Father\'s Name', _fatherNameController),
        const SizedBox(height: 12),
        _buildTextField('Mother\'s Name', _motherNameController),
        const SizedBox(height: 12),
        _buildGenderDropdown(),
        const SizedBox(height: 12),
        _buildTextField(
          'Aadhar Number',
          _aadharController,
          keyboardType: TextInputType.number,
          inputFormatters: AppInputFormatters.aadhaarFormatter,
          maxLength: 12,
          validator: AppValidators.validateAadhaar,
        ),
      ],
    );
  }

  Widget _buildAddressSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Address', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 16),
        _buildTextField('Address', _addressController, maxLines: 2),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildTextField('City', _cityController)),
            const SizedBox(width: 12),
            Expanded(child: _buildTextField('State', _stateController)),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildTextField('Country', _countryController)),
            const SizedBox(width: 12),
            Expanded(
              child: _buildTextField(
                'Pin Code',
                _pinCodeController,
                keyboardType: TextInputType.number,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEducationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Education', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 16),
        _buildNationalityDropdown(),
      ],
    );
  }

  Widget _buildDocumentsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Required Documents',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        ..._uploadedDocuments.entries.map((entry) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildDocumentUploadTile(entry.key, entry.value),
          );
        }),
      ],
    );
  }

  Widget _buildTermsSection() {
    return CheckboxListTile(
      value: _termsAccepted,
      onChanged: (value) {
        setState(() => _termsAccepted = value ?? false);
      },
      title: const Text('I accept the terms and conditions'),
      controlAffinity: ListTileControlAffinity.leading,
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _termsAccepted ? _submitDocuments : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryBlue,
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child: const Text('Submit and Pay'),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    List<TextInputFormatter>? inputFormatters,
    int? maxLength,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      inputFormatters: inputFormatters,
      maxLength: maxLength,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        counterText: maxLength != null ? '' : null, // Hide counter
      ),
    );
  }

  Widget _buildGenderDropdown() {
    return DropdownButtonFormField<String>(
      initialValue: _selectedGender,
      items: ['Male', 'Female', 'Other']
          .map((gender) => DropdownMenuItem(value: gender, child: Text(gender)))
          .toList(),
      onChanged: (value) => setState(() => _selectedGender = value),
      decoration: InputDecoration(
        labelText: 'Gender',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  Widget _buildNationalityDropdown() {
    return DropdownButtonFormField<String>(
      initialValue: _selectedNationality,
      items: [
        'General',
        'SC',
        'OBC',
      ].map((cat) => DropdownMenuItem(value: cat, child: Text(cat))).toList(),
      onChanged: (value) => setState(() => _selectedNationality = value),
      decoration: InputDecoration(
        labelText: 'Category',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  Widget _buildDocumentUploadTile(String docName, bool isUploaded) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  docName,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Text(
                  isUploaded ? 'Uploaded ✓' : 'Not uploaded',
                  style: TextStyle(
                    fontSize: 12,
                    color: isUploaded ? Colors.green : Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton.icon(
            onPressed: () => _uploadDocument(docName),
            icon: const Icon(Icons.upload_file),
            label: const Text('Upload'),
          ),
        ],
      ),
    );
  }

  void _uploadDocument(String docName) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
      );

      if (!mounted) return;

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        setState(() {
          _uploadedDocuments[docName] = true;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('$docName uploaded: ${file.name}')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error uploading $docName: $e')));
      }
    }
  }

  void _submitDocuments() async {
    // Validate all required fields
    if (!_validateForm()) {
      return;
    }

    try {
      final appProvider = context.read<ApplicationProvider>();
      final app = appProvider.getApplicationById(widget.applicationId);

      if (app == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Application not found')),
          );
        }
        return;
      }

      // Update application with collected data
      final updatedApp = app.copyWith(
        fatherName: _fatherNameController.text,
        motherName: _motherNameController.text,
        gender: _selectedGender,
        aadharNumber: _aadharController.text,
        address: _addressController.text,
        city: _cityController.text,
        state: _stateController.text,
        country: _countryController.text,
        pinCode: _pinCodeController.text,
        category: _selectedNationality,
        uploadedDocuments: _uploadedDocuments.map(
          (key, value) => MapEntry(key, value ? 'uploaded' : ''),
        ),
      );

      // Save to database
      await appProvider.updateApplication(updatedApp);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Documents submitted successfully')),
        );

        // Navigate back
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error submitting documents: $e')),
        );
      }
    }
  }

  bool _validateForm() {
    if (_fatherNameController.text.isEmpty) {
      _showError('Father\'s name is required');
      return false;
    }
    if (_motherNameController.text.isEmpty) {
      _showError('Mother\'s name is required');
      return false;
    }
    if (_selectedGender == null) {
      _showError('Gender is required');
      return false;
    }
    if (_aadharController.text.isEmpty) {
      _showError('Aadhar number is required');
      return false;
    }
    if (_addressController.text.isEmpty) {
      _showError('Address is required');
      return false;
    }
    if (_cityController.text.isEmpty) {
      _showError('City is required');
      return false;
    }
    if (_stateController.text.isEmpty) {
      _showError('State is required');
      return false;
    }
    if (_countryController.text.isEmpty) {
      _showError('Country is required');
      return false;
    }
    if (_pinCodeController.text.isEmpty) {
      _showError('Pin code is required');
      return false;
    }
    if (_selectedNationality == null) {
      _showError('Category is required');
      return false;
    }
    if (!_termsAccepted) {
      _showError('You must accept the terms and conditions');
      return false;
    }
    return true;
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }
}
