# Withdrawal Minimum Balance Implementation

## Overview
Users can now only withdraw funds when they have a **minimum of ₹1,000** in their wallet. This minimum amount is configurable and clearly displayed in the withdrawal UI.

## Features Implemented

### 1. Configurable Minimum Amount
- **Location**: `lib/config/constants.dart`
- **Current Value**: ₹1,000
- **Easy to Change**: Simply update `minWithdrawalAmount` constant

```dart
static const double minWithdrawalAmount = 1000.0; // Minimum amount to withdraw
```

### 2. Visual Indicators

#### Available Balance Display
- **Green** when balance meets minimum (≥ ₹1,000)
- **Orange** when balance is below minimum (< ₹1,000)
- Shows exact available amount

#### Minimum Requirement Notice
- **Blue with checkmark** when requirement is met
- **Red with info icon** when below minimum
- Shows how much more is needed
- Example: "You need ₹500 more" when balance is ₹500

### 3. Form Field Behavior

#### When Balance < ₹1,000 (Insufficient)
- ✅ UPI ID field is **disabled**
- ✅ Amount field is **disabled**
- ✅ Placeholder text: "Minimum balance required"
- ✅ Confirm button is **disabled**
- ✅ Button text: "Insufficient Balance (Min ₹1,000)"

#### When Balance ≥ ₹1,000 (Sufficient)
- ✅ UPI ID field is **enabled**
- ✅ Amount field is **enabled**
- ✅ Helpful hint: "Enter amount (Min ₹1,000)"
- ✅ Confirm button is **enabled**
- ✅ Button text: "Confirm Withdrawal"

### 4. Validation
- Amount must be ≥ ₹1,000
- Amount cannot exceed available balance
- UPI ID must be valid format (contains @)
- All validations are skipped when form is disabled

## Files Modified

### 1. `lib/config/constants.dart`
**Changed**: Updated minimum withdrawal amount from ₹500 to ₹1,000

```dart
// Before
static const double minWithdrawalAmount = 500.0;

// After
static const double minWithdrawalAmount = 1000.0; // Minimum amount to withdraw
```

### 2. `lib/widgets/withdrawal_prompt.dart`
**Major Updates**:

#### Available Balance Section
- Added color-coded display (green/orange)
- Added minimum requirement notice box
- Shows remaining amount needed

#### Form Fields
- Added `enabled` property based on minimum balance
- Updated placeholder text dynamically
- Skip validation when disabled

#### Confirm Button
- Disabled when balance < minimum
- Updated button text to show requirement
- Visual feedback with grey color when disabled

## User Experience

### Scenario 1: User has ₹500 (Below Minimum)

**What User Sees**:
1. **Available Balance**: ₹500 (in orange)
2. **Notice**: "Minimum withdrawal: ₹1,000. You need ₹500 more." (in red)
3. **UPI Field**: Disabled with "Minimum balance required"
4. **Amount Field**: Disabled with "Minimum balance required"
5. **Button**: Disabled - "Insufficient Balance (Min ₹1,000)"

**User Action**: Cannot proceed with withdrawal

### Scenario 2: User has ₹1,500 (Above Minimum)

**What User Sees**:
1. **Available Balance**: ₹1,500 (in green)
2. **Notice**: "Minimum requirement met (₹1,000)" (in blue with checkmark)
3. **UPI Field**: Enabled - "yourname@upi"
4. **Amount Field**: Enabled - "Enter amount (Min ₹1,000)"
5. **Button**: Enabled - "Confirm Withdrawal"

**User Action**: Can enter UPI and amount to withdraw

## How to Change Minimum Amount

### Option 1: Update Constant (Recommended)
Edit `lib/config/constants.dart`:

```dart
static const double minWithdrawalAmount = 2000.0; // Change to ₹2,000
```

### Option 2: Make it Dynamic (Future Enhancement)
Store in database and fetch at runtime:

```dart
// In Supabase
CREATE TABLE app_settings (
  key TEXT PRIMARY KEY,
  value NUMERIC
);

INSERT INTO app_settings (key, value) VALUES ('min_withdrawal', 1000.00);

// In Flutter
final settings = await SupabaseService.getAppSettings();
final minWithdrawal = settings['min_withdrawal'] ?? 1000.0;
```

## Testing

### Test Case 1: Below Minimum
1. Ensure wallet balance is < ₹1,000
2. Click "Withdraw" button (Home or Wallet screen)
3. **Expected**: All fields disabled, button shows "Insufficient Balance"

### Test Case 2: Exactly Minimum
1. Ensure wallet balance is exactly ₹1,000
2. Click "Withdraw" button
3. **Expected**: All fields enabled, can withdraw ₹1,000

### Test Case 3: Above Minimum
1. Ensure wallet balance is > ₹1,000 (e.g., ₹2,500)
2. Click "Withdraw" button
3. **Expected**: All fields enabled, can withdraw up to ₹2,500

### Test Case 4: Try to Withdraw Below Minimum
1. Have balance of ₹2,000
2. Try to enter ₹500 in amount field
3. **Expected**: Validation error "Minimum withdrawal is ₹1,000"

## Benefits

1. **Clear Communication**: Users know exactly how much they need
2. **Prevents Errors**: Can't submit invalid withdrawal requests
3. **Professional UX**: Disabled state makes it obvious what's needed
4. **Configurable**: Easy to change minimum amount
5. **Consistent**: Same behavior on Home and Wallet screens

## Screenshots Description

### Below Minimum (₹500 balance)
- Orange balance display
- Red warning notice
- Disabled grey fields
- Disabled grey button

### Above Minimum (₹1,500 balance)
- Green balance display
- Blue success notice
- Enabled white fields
- Enabled blue button

## Future Enhancements

1. **Progressive Disclosure**: Show earning tips when below minimum
2. **Goal Tracker**: "You're 50% to withdrawal minimum!"
3. **Notifications**: Alert when balance reaches minimum
4. **Tiered Minimums**: Different minimums for different payment methods
5. **Admin Panel**: Change minimum without code deployment

