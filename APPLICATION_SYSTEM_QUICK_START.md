# Application System - Quick Start Guide

## 🚀 Getting Started

The application system is already integrated into your app. Here's how to use it:

## 📱 For Users

### Starting an Application
1. User taps a program card on the Refer screen
2. Program Details Popup appears
3. User taps "Start Application" button
4. Application Journey Screen opens
5. User fills in 5 steps
6. Application is saved automatically
7. User can resume later if needed

### Resuming an Application
1. User taps the same program card again
2. Popup shows "Continue Application" button
3. User taps button
4. Previous data is loaded
5. User continues from where they left off

### Viewing Submitted Application
1. User taps program card
2. Popup shows "View Application" button
3. User can view submitted application
4. Status shows as "Submitted"

## 💻 For Developers

### Access Application Provider

```dart
final appProvider = context.read<ApplicationProvider>();
```

### Create New Application

```dart
final app = await appProvider.createApplication(
  programId: 'prog_123',
  userId: 'user_456',
);
```

### Update Personal Information

```dart
await appProvider.updateApplicationField(
  applicationId: app.id,
  fullName: 'John Doe',
  email: 'john@example.com',
  phoneNumber: '9876543210',
);
```

### Update Documents

```dart
await appProvider.updateDocumentStatus(
  applicationId: app.id,
  idDocUploaded: true,
  marksheetDocUploaded: true,
);
```

### Update Enrollment

```dart
await appProvider.updateEnrollmentConfirmation(
  applicationId: app.id,
  confirmed: true,
);
```

### Update Payment Status

```dart
await appProvider.updatePaymentStatus(
  applicationId: app.id,
  applicationFeePaid: true,
  enrollmentFeePaid: false,
);
```

### Submit Application

```dart
await appProvider.submitApplication(app.id);
```

### Get Application by Program

```dart
final app = appProvider.getApplicationByProgramId('prog_123');
if (app != null) {
  print('Status: ${app.statusText}');
  print('Progress: ${app.progressPercentage}%');
}
```

### Get All Applications by Status

```dart
final submitted = appProvider.getApplicationsByStatus(
  ApplicationStatus.submitted,
);
```

### Delete Application

```dart
await appProvider.deleteApplication(app.id);
```

## 🎨 Display Application Status

### In Referrals Tab

```dart
Consumer<ApplicationProvider>(
  builder: (context, appProvider, _) {
    final applications = appProvider.applications.values.toList();
    
    return ListView.builder(
      itemCount: applications.length,
      itemBuilder: (context, index) {
        final app = applications[index];
        return ApplicationStatusCard(
          application: app,
          programName: 'Program Name',
          universityName: 'University Name',
          onTap: () {
            // Navigate to application
          },
        );
      },
    );
  },
)
```

### Show Progress

```dart
Text('${application.progressPercentage}% Complete')
```

### Show Status

```dart
Text(application.statusText)
```

## 🔍 Application Status Values

```dart
enum ApplicationStatus {
  draft,           // Not started
  inProgress,      // In progress
  submitted,       // Submitted
  accepted,        // Accepted
  rejected,        // Rejected
  withdrawn,       // Withdrawn
}
```

## 📊 Application Properties

```dart
application.id              // Unique ID
application.programId       // Program ID
application.userId          // User ID
application.fullName        // User's full name
application.email           // User's email
application.phoneNumber     // User's phone
application.idDocUploaded   // ID document uploaded?
application.marksheetDocUploaded  // Marksheet uploaded?
application.enrollmentConfirmed   // Enrollment confirmed?
application.applicationFeePaid    // App fee paid?
application.enrollmentFeePaid     // Enrollment fee paid?
application.status          // Current status
application.createdAt       // Creation date
application.submittedAt     // Submission date
application.completedAt     // Completion date
application.progressPercentage    // 0-100%
application.isComplete      // All fields filled?
application.statusText      // Display text
```

## 🛠️ Common Tasks

### Check if User Has Applied

```dart
final app = appProvider.getApplicationByProgramId(programId);
if (app != null) {
  print('User has applied');
} else {
  print('User has not applied');
}
```

### Check Application Progress

```dart
final app = appProvider.getApplicationByProgramId(programId);
if (app != null) {
  if (app.progressPercentage == 100) {
    print('Application complete');
  } else {
    print('${app.progressPercentage}% complete');
  }
}
```

### Get All Submitted Applications

```dart
final submitted = appProvider.getApplicationsByStatus(
  ApplicationStatus.submitted,
);
print('${submitted.length} applications submitted');
```

### Check if Application is Complete

```dart
final app = appProvider.getApplicationByProgramId(programId);
if (app?.isComplete ?? false) {
  print('All required fields filled');
}
```

## 📝 Data Persistence

Data is automatically saved to SharedPreferences:
- After creating application
- After updating any field
- After submitting application
- After deleting application

No manual save needed!

## ⚠️ Error Handling

```dart
try {
  await appProvider.createApplication(
    programId: programId,
    userId: userId,
  );
} catch (e) {
  print('Error: $e');
  // Show error to user
}
```

## 🎯 Integration Checklist

- [x] Application model created
- [x] Application provider created
- [x] Data persistence implemented
- [x] Application journey screen enhanced
- [x] Program details popup enhanced
- [x] Application status card created
- [ ] Referrals tab updated (TODO)
- [ ] Backend integration (TODO)
- [ ] Document upload (TODO)
- [ ] Payment integration (TODO)

## 📞 Need Help?

1. Check `APPLICATION_SYSTEM_IMPLEMENTATION.md` for detailed docs
2. Check `lib/models/application.dart` for data structure
3. Check `lib/providers/application_provider.dart` for methods
4. Check `lib/screens/application_journey_screen.dart` for UI

---

**Last Updated:** December 2024
**Version:** 1.0

