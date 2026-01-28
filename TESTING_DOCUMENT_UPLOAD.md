# Testing Document Upload & Database Collection

## 🚀 Quick Start

### 1. Run the Application
```bash
flutter run -d chrome
```

### 2. Navigate to Document Collection
1. Open the app
2. Go to Refer screen
3. Click on a program card
4. Click "Start Application"
5. Click "Collect Documents" button

## 🧪 Test Scenarios

### Scenario 1: Upload Documents
**Steps:**
1. Click "Upload" button for "10th Marksheet"
2. Select a PDF/JPG/PNG file from your device
3. Verify status changes to "Uploaded ✓"
4. Repeat for other documents

**Expected Result:**
- File picker opens
- File selected successfully
- Status updates to "Uploaded ✓"
- Success message shows file name

### Scenario 2: Form Validation
**Steps:**
1. Leave "Father's Name" empty
2. Click "Submit and Pay"

**Expected Result:**
- Red error snackbar appears
- Message: "Father's name is required"
- Form not submitted

### Scenario 3: Complete Submission
**Steps:**
1. Fill all form fields:
   - Father's Name: "John Doe"
   - Mother's Name: "Jane Doe"
   - Gender: "Male"
   - Aadhar: "123456789012"
   - Address: "123 Main St"
   - City: "New York"
   - State: "NY"
   - Country: "USA"
   - Pin Code: "10001"
   - Category: "General"
2. Upload all 5 documents
3. Check "I accept terms and conditions"
4. Click "Submit and Pay"

**Expected Result:**
- Form validates successfully
- Data saves to database
- Success message appears
- Navigation back to Journey Screen

### Scenario 4: Data Persistence
**Steps:**
1. Complete submission
2. Close app
3. Reopen app
4. Navigate back to same application

**Expected Result:**
- All submitted data is still there
- Documents marked as uploaded
- Data persisted in SharedPreferences

## 📋 Validation Test Cases

| Field | Valid Input | Invalid Input | Expected |
|-------|------------|---------------|----------|
| Father's Name | "John Doe" | "" | Error |
| Mother's Name | "Jane Doe" | "" | Error |
| Gender | "Male" | null | Error |
| Aadhar | "123456789012" | "" | Error |
| Address | "123 Main St" | "" | Error |
| City | "New York" | "" | Error |
| State | "NY" | "" | Error |
| Country | "USA" | "" | Error |
| Pin Code | "10001" | "" | Error |
| Category | "General" | null | Error |
| Terms | Checked | Unchecked | Error |

## 🔍 Debug Checklist

### File Upload Issues
- [ ] File picker opens when clicking upload
- [ ] Can select files from device
- [ ] Status updates after selection
- [ ] File name shown in message

### Form Validation Issues
- [ ] All fields validate correctly
- [ ] Error messages are clear
- [ ] Submit button disabled until terms checked
- [ ] Validation prevents submission

### Database Save Issues
- [ ] Data saves to ApplicationProvider
- [ ] SharedPreferences updated
- [ ] No errors in console
- [ ] Navigation works after save

### Async Issues
- [ ] No "BuildContext across async gaps" errors
- [ ] Mounted checks prevent crashes
- [ ] Snackbars show correctly
- [ ] Navigation works properly

## 📊 Data Verification

### Check Saved Data
```dart
// In ApplicationProvider
final app = appProvider.getApplicationById(applicationId);
print('Father Name: ${app.fatherName}');
print('Address: ${app.address}');
print('Documents: ${app.uploadedDocuments}');
```

### Check SharedPreferences
```dart
final prefs = await SharedPreferences.getInstance();
final applicationsJson = prefs.getString('applications');
print('Saved Data: $applicationsJson');
```

## 🐛 Common Issues & Solutions

### Issue: File Picker Not Opening
**Solution:**
- Check file_picker package is installed
- Verify permissions are granted
- Check console for errors

### Issue: Data Not Saving
**Solution:**
- Verify ApplicationProvider is initialized
- Check application ID is correct
- Verify updateApplication() is called
- Check SharedPreferences permissions

### Issue: Validation Not Working
**Solution:**
- Check all validation methods are called
- Verify error messages are shown
- Check form fields have values
- Verify terms checkbox is checked

### Issue: Navigation Not Working
**Solution:**
- Check mounted flag before navigation
- Verify context is available
- Check no exceptions are thrown
- Verify pop() is called correctly

## ✅ Success Criteria

- [ ] All form fields accept input
- [ ] File picker works for all documents
- [ ] Validation prevents invalid submission
- [ ] Data saves to database
- [ ] Data persists after app restart
- [ ] Navigation works correctly
- [ ] No compilation errors
- [ ] No runtime errors
- [ ] User-friendly error messages
- [ ] Smooth user experience

## 📞 Support

### Documentation
- See `DOCUMENT_UPLOAD_AND_DATABASE_IMPLEMENTATION.md` for implementation details
- See `DEVELOPER_QUICK_START.md` for code examples

### Code Location
- Document Collection Screen: `lib/screens/document_collection_screen.dart`
- Application Provider: `lib/providers/application_provider.dart`
- Application Model: `lib/models/application.dart`

---

**Last Updated:** December 2024
**Version:** 1.0
**Status:** Ready for Testing

