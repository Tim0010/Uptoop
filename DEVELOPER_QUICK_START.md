# Document Collection - Developer Quick Start

## 🚀 Quick Navigation

### Files to Know
```
lib/screens/
├── document_collection_screen.dart    ← Main form screen
├── application_journey_screen.dart    ← Updated with button
└── ...

lib/models/
└── application.dart                   ← Updated model
```

## 📝 How to Use

### 1. Navigate to Document Collection
```dart
// From any screen
Navigator.of(context).push(
  MaterialPageRoute(
    builder: (_) => DocumentCollectionScreen(
      applicationId: 'app_id_here',
    ),
  ),
);
```

### 2. Access Collected Data
```dart
// From ApplicationProvider
final appProvider = context.read<ApplicationProvider>();
final app = appProvider.getApplicationById('app_id');

// Access fields
print(app.fatherName);
print(app.address);
print(app.uploadedDocuments);
```

### 3. Save Data
```dart
// Update application with collected data
await appProvider.updateApplication(
  applicationId: 'app_id',
  fatherName: 'John Doe',
  address: '123 Main St',
  // ... other fields
);
```

## 🔧 Implementation Checklist

### Phase 1: File Picker (TODO)
```dart
// In _uploadDocument() method
// Add this code:
final result = await FilePicker.platform.pickFiles(
  type: FileType.custom,
  allowedExtensions: ['pdf', 'jpg', 'png'],
);

if (result != null) {
  setState(() {
    _uploadedDocuments[docName] = true;
  });
}
```

### Phase 2: Cloud Upload (TODO)
```dart
// Upload to Supabase
final response = await supabase
  .storage
  .from('documents')
  .upload('path/to/file', file);

// Store URL
_uploadedDocuments[docName] = response.path;
```

### Phase 3: Form Validation (TODO)
```dart
// Add validation method
bool _validateForm() {
  if (_fatherNameController.text.isEmpty) {
    _showError('Father\'s name is required');
    return false;
  }
  // ... validate other fields
  return true;
}
```

### Phase 4: Payment Integration (TODO)
```dart
// After submission
void _submitDocuments() {
  if (!_validateForm()) return;
  
  // Process payment
  _initiatePayment(amount: 500);
}
```

## 📊 Data Model Reference

```dart
class Application {
  // Personal Information
  String? fatherName;
  String? motherName;
  String? gender;
  String? aadharNumber;
  
  // Address
  String? address;
  String? city;
  String? state;
  String? country;
  String? pinCode;
  
  // Education
  String? category;
  
  // Documents
  Map<String, String> uploadedDocuments;
}
```

## 🎯 Common Tasks

### Get All Collected Data
```dart
final app = appProvider.getApplicationById(appId);
final data = {
  'personal': {
    'father': app.fatherName,
    'mother': app.motherName,
    'gender': app.gender,
    'aadhar': app.aadharNumber,
  },
  'address': {
    'address': app.address,
    'city': app.city,
    'state': app.state,
    'country': app.country,
    'pinCode': app.pinCode,
  },
  'education': app.category,
  'documents': app.uploadedDocuments,
};
```

### Check if All Documents Uploaded
```dart
bool allDocumentsUploaded() {
  final requiredDocs = [
    '10th Marksheet',
    '12th Marksheet',
    'Graduation Certificate',
    'Degree Certificate',
    'Photo ID',
  ];
  
  return requiredDocs.every(
    (doc) => app.uploadedDocuments.containsKey(doc),
  );
}
```

### Display Collected Data
```dart
// Show summary
Text('Father: ${app.fatherName}'),
Text('Address: ${app.address}'),
Text('Documents: ${app.uploadedDocuments.length}/5'),
```

## 🧪 Testing

### Test Navigation
```dart
// From journey screen, click "Collect Documents"
// Should navigate to DocumentCollectionScreen
```

### Test Form Input
```dart
// Fill all fields
// Verify data is captured
// Check form state updates
```

### Test Document Upload
```dart
// Click upload button
// Select file (mock)
// Verify status changes to "Uploaded ✓"
```

### Test Terms Acceptance
```dart
// Uncheck terms → Submit button disabled
// Check terms → Submit button enabled
```

## 📚 Documentation Files

- `DOCUMENT_COLLECTION_GUIDE.md` - Feature overview
- `DOCUMENT_COLLECTION_IMPLEMENTATION.md` - Technical details
- `DOCUMENT_COLLECTION_SUMMARY.md` - Complete summary
- `FORM_LAYOUT_REFERENCE.md` - UI layout reference
- `DOCUMENT_COLLECTION_COMPLETE.md` - Full documentation

## 🔗 Related Files

- `lib/providers/application_provider.dart` - State management
- `lib/models/application.dart` - Data model
- `lib/screens/application_journey_screen.dart` - Journey screen

## 💡 Tips

1. **Always use ApplicationProvider** for data management
2. **Validate before saving** to prevent invalid data
3. **Show loading states** during file upload
4. **Handle errors gracefully** with user-friendly messages
5. **Test on multiple devices** for responsive design

## 🚨 Common Issues

### Issue: Data not persisting
**Solution:** Make sure to call `appProvider.updateApplication()`

### Issue: File picker not working
**Solution:** Add file_picker package and request permissions

### Issue: Navigation not working
**Solution:** Ensure DocumentCollectionScreen is imported

### Issue: Form validation failing
**Solution:** Check field values before submission

---

**Last Updated:** December 2024
**Version:** 1.0

