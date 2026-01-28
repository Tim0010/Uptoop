import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:uptop_careers/config/theme.dart';
import 'package:uptop_careers/models/program.dart';
import 'package:uptop_careers/models/application.dart';
import 'package:uptop_careers/providers/application_provider.dart';
import 'package:uptop_careers/providers/user_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:uptop_careers/screens/payment_screen.dart';
import 'package:uptop_careers/utils/validators.dart';
import 'package:uptop_careers/utils/input_formatters.dart';

class JourneyStage {
  final String title;
  final bool isCompleted;
  final String? reward;
  final bool isExpanded;
  final bool isSaved;

  JourneyStage({
    required this.title,
    required this.isCompleted,
    this.reward,
    this.isExpanded = false,
    this.isSaved = false,
  });
}

class ApplicationJourneyScreen extends StatefulWidget {
  final Program program;
  final String? referralId;

  const ApplicationJourneyScreen({
    super.key,
    required this.program,
    this.referralId,
  });

  @override
  State<ApplicationJourneyScreen> createState() =>
      _ApplicationJourneyScreenState();
}

class _ApplicationJourneyScreenState extends State<ApplicationJourneyScreen> {
  Application? _application;
  bool _isDocumentCollectionExpanded = false;
  bool _isPersonalInfoExpanded = false;
  bool _isAcademicInfoExpanded = false;
  bool _isPaymentExpanded = false;
  bool _isTermsExpanded = false;

  // Section save states
  bool _isDocumentCollectionSaved = false;
  bool _isPersonalInfoSaved = false;
  bool _isAcademicInfoSaved = false;
  bool _isPaymentSaved = false;
  bool _isTermsSaved = false;

  final _formKey = GlobalKey<FormState>();
  final _fatherNameController = TextEditingController();
  final _motherNameController = TextEditingController();
  final _genderController = TextEditingController();
  final _aadharController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _countryController = TextEditingController();
  final _pinCodeController = TextEditingController();
  final _categoryController = TextEditingController();
  final _nationalityController = TextEditingController();
  DateTime? _dateOfBirth;
  bool _termsAccepted = false;

  // Academic info controllers
  final _courseNameController = TextEditingController();
  final _enrollmentNoController = TextEditingController();
  final _programmeController = TextEditingController();
  final _electiveController = TextEditingController();
  final _candidateNameController = TextEditingController();

  final Map<String, String> _documentPaths = {};

  @override
  void dispose() {
    _fatherNameController.dispose();
    _motherNameController.dispose();
    _genderController.dispose();
    _aadharController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _countryController.dispose();
    _pinCodeController.dispose();
    _categoryController.dispose();
    _nationalityController.dispose();
    _courseNameController.dispose();
    _enrollmentNoController.dispose();
    _programmeController.dispose();
    _electiveController.dispose();
    _candidateNameController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _initializeApplication();
  }

  Future<void> _initializeApplication() async {
    debugPrint('📋 Initializing application for program: ${widget.program.id}');
    final appProvider = context.read<ApplicationProvider>();
    final userProvider = context.read<UserProvider>();

    _application = appProvider.getApplicationByProgramId(widget.program.id);

    // If application already exists, rebuild UI immediately
    if (_application != null) {
      debugPrint('✅ Found existing application: ${_application!.id}');
      setState(() {});
    } else {
      debugPrint('🆕 No existing application found, creating new one...');
    }

    // Get the actual user ID from UserProvider
    final userId = userProvider.currentUser?.id;

    if (userId == null) {
      debugPrint('❌ User ID is null, cannot create application');
      return;
    }

    _application ??= await appProvider.createApplication(
      programId: widget.program.id,
      userId: userId,
      referralId: widget.referralId,
    );

    debugPrint('✅ Application initialized: ${_application?.id}');

    if (_application != null) {
      _fatherNameController.text = _application!.fatherName ?? '';
      _motherNameController.text = _application!.motherName ?? '';
      _genderController.text = _application!.gender ?? '';
      _aadharController.text = _application!.aadharNumber ?? '';
      _addressController.text = _application!.address ?? '';
      _cityController.text = _application!.city ?? '';
      _stateController.text = _application!.state ?? '';
      _countryController.text = _application!.country ?? '';
      _pinCodeController.text = _application!.pinCode ?? '';
      _categoryController.text = _application!.category ?? '';
      _nationalityController.text = _application!.nationality ?? '';
      _candidateNameController.text = _application!.fullName;
      _dateOfBirth = _application!.dateOfBirth;
      _termsAccepted = _application!.termsAndConditionsAccepted;

      if (_application!.profilePictureUrl != null) {
        _documentPaths['Profile Picture'] = _application!.profilePictureUrl!;
      }
      if (_application!.marksheet10thUrl != null) {
        _documentPaths['10th Marksheet'] = _application!.marksheet10thUrl!;
      }
      if (_application!.marksheet12thUrl != null) {
        _documentPaths['12th Marksheet'] = _application!.marksheet12thUrl!;
      }
      if (_application!.graduationMarksheetsUrl != null) {
        _documentPaths['Graduation Marksheets (1st, 2nd, 3rd year)'] =
            _application!.graduationMarksheetsUrl!;
      }
      if (_application!.degreeCertificateUrl != null) {
        _documentPaths['Degree Certificate'] =
            _application!.degreeCertificateUrl!;
      }
      if (_application!.photoIdUrl != null) {
        _documentPaths['Photo ID'] = _application!.photoIdUrl!;
      }

      // Set save states based on application data
      _isPersonalInfoSaved = _application!.fullName.isNotEmpty;
      _isAcademicInfoSaved =
          _application!.address != null && _application!.address!.isNotEmpty;
      _isDocumentCollectionSaved = _application!.documentsSubmitted;
      _isPaymentSaved = _application!.applicationFeePaid;
      _isTermsSaved = _application!.termsAndConditionsAccepted;
    }

    setState(() {});
  }

  List<JourneyStage> _getJourneyStages() {
    if (_application == null) return [];

    return [
      JourneyStage(
        title: 'Personal Information',
        isCompleted:
            _application!.fatherName != null &&
            _application!.motherName != null &&
            _application!.gender != null &&
            _application!.dateOfBirth != null,
        isExpanded: _isPersonalInfoExpanded,
        isSaved: _isPersonalInfoSaved,
      ),
      JourneyStage(
        title: 'Academic Information',
        isCompleted:
            _application!.city != null &&
            _application!.state != null &&
            _application!.country != null,
        isExpanded: _isAcademicInfoExpanded,
        isSaved: _isAcademicInfoSaved,
      ),
      JourneyStage(
        title: 'Document Collection',
        isCompleted:
            _application!.documentsSubmitted &&
            _application!.dateOfBirth != null &&
            _application!.nationality != null &&
            _application!.nationality!.isNotEmpty &&
            _application!.termsAndConditionsAccepted &&
            _application!.profilePictureUrl != null &&
            _application!.photoIdUrl != null &&
            _application!.marksheet10thUrl != null &&
            _application!.marksheet12thUrl != null &&
            _application!.graduationMarksheetsUrl != null &&
            _application!.degreeCertificateUrl != null,
        isExpanded: _isDocumentCollectionExpanded,
        isSaved: _isDocumentCollectionSaved,
      ),
      JourneyStage(
        title: 'Application Fee Payment',
        isCompleted: _application!.applicationFeePaid,
        reward: 'Your referrer received a reward of ₹500',
        isExpanded: _isPaymentExpanded,
        isSaved: _isPaymentSaved,
      ),
      JourneyStage(
        title: 'Terms & Conditions',
        isCompleted: _application!.termsAndConditionsAccepted,
        isExpanded: _isTermsExpanded,
        isSaved: _isTermsSaved,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    if (_application == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            'Journey • ${widget.program.programName}',
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: AppTheme.primaryBlue,
          foregroundColor: Colors.white,
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final stages = _getJourneyStages();

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        // Allow normal back navigation - just pop this screen
        // Don't sign out the user
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Journey • ${widget.program.programName}',
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: AppTheme.primaryBlue,
          foregroundColor: Colors.white,
          iconTheme: const IconThemeData(color: Colors.white),
          elevation: 0,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                _buildJourneyTimeline(stages),
                _buildWarningBox(),
                _buildBottomButtons(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildJourneyTimeline(List<JourneyStage> stages) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(bottom: 16),
            child: Text(
              'Application journey',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          ...List.generate(stages.length, (index) {
            final stage = stages[index];
            final isLast = index == stages.length - 1;

            switch (index) {
              case 0:
                return _buildPersonalInfoStage(stage, isLast);
              case 1:
                return _buildAcademicInfoStage(stage, isLast);
              case 2:
                return _buildDocumentCollectionStage(stage, isLast);
              case 3:
                return _buildPaymentStage(stage, isLast);
              case 4:
                return _buildTermsStage(stage, isLast);
              default:
                return _buildTimelineItem(stage, isLast);
            }
          }),
        ],
      ),
    );
  }

  Widget _buildPersonalInfoStage(JourneyStage stage, bool isLast) {
    return Column(
      children: [
        _buildTimelineItem(
          stage,
          isLast,
          isExpandable: true,
          onExpand: () {
            setState(() {
              _isPersonalInfoExpanded = !_isPersonalInfoExpanded;
            });
          },
        ),
        if (_isPersonalInfoExpanded) _buildPersonalInfoForm(),
      ],
    );
  }

  Widget _buildAcademicInfoStage(JourneyStage stage, bool isLast) {
    return Column(
      children: [
        _buildTimelineItem(
          stage,
          isLast,
          isExpandable: true,
          onExpand: () {
            setState(() {
              _isAcademicInfoExpanded = !_isAcademicInfoExpanded;
            });
          },
        ),
        if (_isAcademicInfoExpanded) _buildAcademicInfoForm(),
      ],
    );
  }

  Widget _buildTermsStage(JourneyStage stage, bool isLast) {
    return Column(
      children: [
        _buildTimelineItem(
          stage,
          isLast,
          isExpandable: true,
          onExpand: () {
            setState(() {
              _isTermsExpanded = !_isTermsExpanded;
            });
          },
        ),
        if (_isTermsExpanded) _buildTermsForm(),
      ],
    );
  }

  Widget _buildDocumentCollectionStage(JourneyStage stage, bool isLast) {
    return Column(
      children: [
        _buildTimelineItem(
          stage,
          isLast,
          isExpandable: true,
          onExpand: () {
            setState(() {
              _isDocumentCollectionExpanded = !_isDocumentCollectionExpanded;
            });
          },
        ),
        if (_isDocumentCollectionExpanded) _buildDocumentCollectionForm(),
      ],
    );
  }

  Widget _buildPaymentStage(JourneyStage stage, bool isLast) {
    return Column(
      children: [
        _buildTimelineItem(
          stage,
          isLast,
          isExpandable: true,
          onExpand: () {
            setState(() {
              _isPaymentExpanded = !_isPaymentExpanded;
            });
          },
        ),
        if (_isPaymentExpanded) _buildPaymentSection(),
      ],
    );
  }

  Widget _buildPaymentSection() {
    return Container(
      margin: const EdgeInsets.only(left: 40, top: 16, right: 16, bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Application Fee Payment',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          // Online payment - show Razorpay button
          const Text(
            'Pay securely online via UPI, Card, Net Banking, or Wallets',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _navigateToPaymentScreen,
              icon: const Icon(Icons.payment),
              label: const Text('Pay Application Fee Online'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2196F3),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  void _navigateToPaymentScreen() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PaymentScreen(
          applicationId: _application!.id,
          onPaymentSuccess: _onPaymentSuccess,
        ),
      ),
    );
  }

  void _onPaymentSuccess() {
    final appProvider = context.read<ApplicationProvider>();
    final updatedApplication = _application!.copyWith(applicationFeePaid: true);
    appProvider.updateApplication(updatedApplication);
    setState(() {
      _application = updatedApplication;
    });
  }

  Widget _buildPersonalInfoForm() {
    return Container(
      margin: const EdgeInsets.only(left: 40, top: 16, right: 16, bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Personal Information',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildTextField(_candidateNameController, 'Candidate Name'),
            _buildTextField(_fatherNameController, 'Father\'s Name'),
            _buildTextField(_motherNameController, 'Mother\'s Name'),
            _buildGenderDropdown(),
            const SizedBox(height: 16),
            _buildDatePicker(),
            const SizedBox(height: 16),
            _buildTextField(
              _aadharController,
              'Aadhar Number',
              keyboardType: TextInputType.number,
              inputFormatters: AppInputFormatters.aadhaarFormatter,
              maxLength: 12,
              validator: AppValidators.validateAadhaar,
            ),
            const SizedBox(height: 16),
            _buildSectionButtons(
              () => _savePersonalInfo(),
              () => _editLaterPersonalInfo(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAcademicInfoForm() {
    return Container(
      margin: const EdgeInsets.only(left: 40, top: 16, right: 16, bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Form(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Academic Information',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildTextField(_enrollmentNoController, 'Enrollment No.'),
            _buildTextField(_courseNameController, 'Course Name'),
            _buildTextField(_programmeController, 'Programme'),
            _buildTextField(_electiveController, 'Elective'),
            const SizedBox(height: 16),
            _buildTextField(_addressController, 'Address'),
            _buildTextField(_cityController, 'City'),
            _buildTextField(_stateController, 'State'),
            _buildTextField(_countryController, 'Country'),
            _buildTextField(_pinCodeController, 'Pin Code'),
            const SizedBox(height: 16),
            _buildSectionButtons(
              () => _saveAcademicInfo(),
              () => _editLaterAcademicInfo(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTermsForm() {
    return Container(
      margin: const EdgeInsets.only(left: 40, top: 16, right: 16, bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Terms & Conditions',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Text(
              'I hereby declare that the information furnished by me in the application form is correct to the best of my knowledge and belief. I understand that if any information is found to be incorrect or false, my admission may be cancelled. I agree to abide by the rules and regulations of the university.',
              style: TextStyle(fontSize: 12),
            ),
          ),
          const SizedBox(height: 16),
          _buildTermsAndConditionsCheckbox(),
          const SizedBox(height: 16),
          _buildSectionButtons(() => _saveTerms(), () => _editLaterTerms()),
        ],
      ),
    );
  }

  Widget _buildSectionButtons(VoidCallback onSave, VoidCallback onEditLater) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: onSave,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: const Text('Save'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton(
            onPressed: onEditLater,
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: AppTheme.primaryBlue),
            ),
            child: Text(
              'Edit Later',
              style: TextStyle(color: AppTheme.primaryBlue),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGenderDropdown() {
    return DropdownButtonFormField<String>(
      initialValue: _genderController.text.isEmpty
          ? null
          : _genderController.text,
      decoration: const InputDecoration(
        labelText: 'Gender',
        border: OutlineInputBorder(),
      ),
      items: const [
        DropdownMenuItem(value: 'Male', child: Text('Male')),
        DropdownMenuItem(value: 'Female', child: Text('Female')),
        DropdownMenuItem(value: 'Other', child: Text('Other')),
      ],
      onChanged: (value) {
        setState(() {
          _genderController.text = value ?? '';
        });
      },
    );
  }

  Widget _buildDocumentCollectionForm() {
    return Container(
      margin: const EdgeInsets.only(left: 40, top: 16, right: 16, bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTextField(_fatherNameController, 'Father\'s Name'),
            _buildTextField(_motherNameController, 'Mother\'s Name'),
            _buildTextField(_genderController, 'Gender'),
            _buildTextField(
              _aadharController,
              'Aadhar Number',
              keyboardType: TextInputType.number,
              inputFormatters: AppInputFormatters.aadhaarFormatter,
              maxLength: 12,
              validator: AppValidators.validateAadhaar,
            ),
            _buildTextField(_addressController, 'Address'),
            _buildTextField(_cityController, 'City'),
            _buildTextField(_stateController, 'State'),
            _buildTextField(_countryController, 'Country'),
            _buildTextField(_pinCodeController, 'Pin Code'),
            _buildTextField(_categoryController, 'Category'),
            _buildTextField(_nationalityController, 'Nationality'),
            const SizedBox(height: 16),
            _buildDatePicker(),
            const SizedBox(height: 16),
            _buildFileUploadButton('Profile Picture'),
            _buildFileUploadButton('10th Marksheet'),
            _buildFileUploadButton('12th Marksheet'),
            _buildFileUploadButton(
              'Graduation Marksheets (1st, 2nd, 3rd year)',
            ),
            _buildFileUploadButton('Degree Certificate'),
            _buildFileUploadButton('Photo ID'),
            const SizedBox(height: 16),
            _buildSectionButtons(
              () => _saveDocumentCollection(),
              () => _editLaterDocumentCollection(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label, {
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
    int? maxLength,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          counterText: maxLength != null
              ? ''
              : null, // Hide counter if maxLength is set
        ),
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        maxLength: maxLength,
        validator:
            validator ??
            (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter $label';
              }
              return null;
            },
      ),
    );
  }

  Widget _buildDatePicker() {
    return InkWell(
      onTap: () => _selectDate(context),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.grey[400]!)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _dateOfBirth == null
                  ? 'Date of Birth'
                  : 'DOB: ${_dateOfBirth!.toLocal().toString().split(' ')[0]}',
              style: const TextStyle(fontSize: 16),
            ),
            const Icon(Icons.calendar_today),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dateOfBirth ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _dateOfBirth) {
      setState(() {
        _dateOfBirth = picked;
      });
    }
  }

  Widget _buildTermsAndConditionsCheckbox() {
    return Row(
      children: [
        Checkbox(
          value: _termsAccepted,
          onChanged: (bool? value) {
            setState(() {
              _termsAccepted = value ?? false;
            });
          },
        ),
        const Expanded(child: Text('I accept the Terms and Conditions')),
      ],
    );
  }

  Future<void> _pickDocument(String docType) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
      );

      if (result != null && result.files.single.name.isNotEmpty) {
        setState(() {
          _documentPaths[docType] = result.files.single.name;
        });
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '$docType uploaded successfully: ${result.files.single.name}',
            ),
          ),
        );
      }
    } catch (e) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(
        // ignore: use_build_context_synchronously
        context,
      ).showSnackBar(SnackBar(content: Text('Error picking document: $e')));
    }
  }

  Widget _buildFileUploadButton(String title) {
    final fileName = _documentPaths[title];

    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          OutlinedButton.icon(
            onPressed: () => _pickDocument(title),
            icon: const Icon(Icons.upload_file),
            label: Text(fileName != null ? 'Change $title' : 'Upload $title'),
          ),
          if (fileName != null)
            Padding(
              padding: const EdgeInsets.only(top: 4.0, left: 4.0),
              child: Text(
                '✓ $fileName',
                style: const TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _savePersonalInfo() {
    if (_candidateNameController.text.isEmpty ||
        _fatherNameController.text.isEmpty ||
        _motherNameController.text.isEmpty ||
        _genderController.text.isEmpty ||
        _dateOfBirth == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all required fields'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final appProvider = context.read<ApplicationProvider>();
    final updatedApplication = _application!.copyWith(
      fullName: _candidateNameController.text,
      fatherName: _fatherNameController.text,
      motherName: _motherNameController.text,
      gender: _genderController.text,
      dateOfBirth: _dateOfBirth,
      aadharNumber: _aadharController.text,
    );

    appProvider.updateApplication(updatedApplication);
    setState(() {
      _application = updatedApplication;
      _isPersonalInfoSaved = true;
      _isPersonalInfoExpanded = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Personal information saved successfully!')),
    );
  }

  void _editLaterPersonalInfo() {
    setState(() {
      _isPersonalInfoExpanded = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('You can edit this section later')),
    );
  }

  void _saveAcademicInfo() {
    if (_enrollmentNoController.text.isEmpty ||
        _courseNameController.text.isEmpty ||
        _programmeController.text.isEmpty ||
        _addressController.text.isEmpty ||
        _cityController.text.isEmpty ||
        _stateController.text.isEmpty ||
        _countryController.text.isEmpty ||
        _pinCodeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all required fields'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final appProvider = context.read<ApplicationProvider>();
    final updatedApplication = _application!.copyWith(
      address: _addressController.text,
      city: _cityController.text,
      state: _stateController.text,
      country: _countryController.text,
      pinCode: _pinCodeController.text,
    );

    appProvider.updateApplication(updatedApplication);
    setState(() {
      _application = updatedApplication;
      _isAcademicInfoSaved = true;
      _isAcademicInfoExpanded = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Academic information saved successfully!')),
    );
  }

  void _editLaterAcademicInfo() {
    setState(() {
      _isAcademicInfoExpanded = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('You can edit this section later')),
    );
  }

  void _saveTerms() {
    if (!_termsAccepted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please accept the terms and conditions'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final appProvider = context.read<ApplicationProvider>();
    final updatedApplication = _application!.copyWith(
      termsAndConditionsAccepted: _termsAccepted,
    );

    appProvider.updateApplication(updatedApplication);
    setState(() {
      _application = updatedApplication;
      _isTermsSaved = true;
      _isTermsExpanded = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Terms and conditions accepted!')),
    );
  }

  void _editLaterTerms() {
    setState(() {
      _isTermsExpanded = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('You can edit this section later')),
    );
  }

  void _saveDocumentCollection() {
    const requiredDocs = [
      'Profile Picture',
      '10th Marksheet',
      '12th Marksheet',
      'Graduation Marksheets (1st, 2nd, 3rd year)',
      'Degree Certificate',
      'Photo ID',
    ];

    for (final doc in requiredDocs) {
      if (_documentPaths[doc] == null || _documentPaths[doc]!.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Please upload your $doc.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    }

    final appProvider = context.read<ApplicationProvider>();
    final updatedApplication = _application!.copyWith(
      documentsSubmitted: true,
      profilePictureUrl: _documentPaths['Profile Picture'],
      marksheet10thUrl: _documentPaths['10th Marksheet'],
      marksheet12thUrl: _documentPaths['12th Marksheet'],
      graduationMarksheetsUrl:
          _documentPaths['Graduation Marksheets (1st, 2nd, 3rd year)'],
      degreeCertificateUrl: _documentPaths['Degree Certificate'],
      photoIdUrl: _documentPaths['Photo ID'],
    );

    appProvider.updateApplication(updatedApplication);
    setState(() {
      _application = updatedApplication;
      _isDocumentCollectionSaved = true;
      _isDocumentCollectionExpanded = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Documents saved successfully!')),
    );
  }

  void _editLaterDocumentCollection() {
    setState(() {
      _isDocumentCollectionExpanded = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('You can edit this section later')),
    );
  }

  Widget _buildTimelineItem(
    JourneyStage stage,
    bool isLast, {
    bool isExpandable = false,
    VoidCallback? onExpand,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: stage.isCompleted
                    ? const Color(0xFF2E7D32)
                    : Colors.grey[400],
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: stage.isCompleted
                  ? const Icon(Icons.check, color: Colors.white, size: 16)
                  : null,
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 60,
                color: Colors.grey[400],
                margin: const EdgeInsets.symmetric(vertical: 2),
              ),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: InkWell(
            onTap: isExpandable ? onExpand : null,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        stage.title,
                        style: TextStyle(
                          fontSize: 15,
                          color: stage.isCompleted
                              ? Colors.black
                              : Colors.grey[700],
                          fontWeight: stage.isCompleted
                              ? FontWeight.w600
                              : FontWeight.w500,
                        ),
                      ),
                    ),
                    if (stage.isSaved)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2E7D32),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'Saved',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    if (isExpandable)
                      Icon(
                        stage.isExpanded
                            ? Icons.expand_less
                            : Icons.expand_more,
                        size: 20,
                        color: Colors.grey[600],
                      ),
                  ],
                ),
                if (stage.reward != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    stage.reward!,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF2E7D32),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWarningBox() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF9E6),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFFFE082)),
      ),
      child: const Text(
        '*If student doesn\'t meet academic requirements, then he/she can get rejected by the university.',
        style: TextStyle(fontSize: 13, color: Colors.black87),
      ),
    );
  }

  Widget _buildBottomButtons() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.share),
                  label: const Text('Other'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    side: BorderSide(color: AppTheme.primaryBlue, width: 2),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.chat),
                  label: const Text('Whatsapp'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryBlue,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
