# Withdrawal Minimum Balance - User Scenarios

## Configuration
- **Minimum Withdrawal Amount**: ₹1,000
- **Location**: `lib/config/constants.dart`

## Scenario Examples

### Scenario 1: User has ₹0 (Empty Wallet)
**Available Balance Display**: ₹0 (Orange)

**Notice Message**:
```
🛈 Minimum withdrawal is ₹1,000. You need ₹1,000 more.
```
- Color: Red
- Icon: Info (🛈)

**Form State**:
- UPI Field: ❌ Disabled - "Minimum balance required"
- Amount Field: ❌ Disabled - "Minimum balance required"
- Button: ❌ Disabled - "Insufficient Balance (Min ₹1,000)"

---

### Scenario 2: User has ₹250
**Available Balance Display**: ₹250 (Orange)

**Notice Message**:
```
🛈 Minimum withdrawal is ₹1,000. You need ₹750 more.
```
- Color: Red
- Icon: Info (🛈)
- Calculation: 1,000 - 250 = 750

**Form State**:
- UPI Field: ❌ Disabled - "Minimum balance required"
- Amount Field: ❌ Disabled - "Minimum balance required"
- Button: ❌ Disabled - "Insufficient Balance (Min ₹1,000)"

---

### Scenario 3: User has ₹500
**Available Balance Display**: ₹500 (Orange)

**Notice Message**:
```
🛈 Minimum withdrawal is ₹1,000. You need ₹500 more.
```
- Color: Red
- Icon: Info (🛈)
- Calculation: 1,000 - 500 = 500

**Form State**:
- UPI Field: ❌ Disabled - "Minimum balance required"
- Amount Field: ❌ Disabled - "Minimum balance required"
- Button: ❌ Disabled - "Insufficient Balance (Min ₹1,000)"

---

### Scenario 4: User has ₹999 (Just Below Minimum)
**Available Balance Display**: ₹999 (Orange)

**Notice Message**:
```
🛈 Minimum withdrawal is ₹1,000. You need ₹1 more.
```
- Color: Red
- Icon: Info (🛈)
- Calculation: 1,000 - 999 = 1

**Form State**:
- UPI Field: ❌ Disabled - "Minimum balance required"
- Amount Field: ❌ Disabled - "Minimum balance required"
- Button: ❌ Disabled - "Insufficient Balance (Min ₹1,000)"

---

### Scenario 5: User has ₹1,000 (Exactly Minimum) ✅
**Available Balance Display**: ₹1,000 (Green)

**Notice Message**:
```
✓ Minimum withdrawal is ₹1,000. You can withdraw now!
```
- Color: Blue
- Icon: Check Circle (✓)

**Form State**:
- UPI Field: ✅ Enabled - "yourname@upi"
- Amount Field: ✅ Enabled - "Enter amount (Min ₹1,000)"
- Button: ✅ Enabled - "Confirm Withdrawal"

**User Can Withdraw**: ₹1,000 (full balance)

---

### Scenario 6: User has ₹1,500 ✅
**Available Balance Display**: ₹1,500 (Green)

**Notice Message**:
```
✓ Minimum withdrawal is ₹1,000. You can withdraw now!
```
- Color: Blue
- Icon: Check Circle (✓)

**Form State**:
- UPI Field: ✅ Enabled - "yourname@upi"
- Amount Field: ✅ Enabled - "Enter amount (Min ₹1,000)"
- Button: ✅ Enabled - "Confirm Withdrawal"

**User Can Withdraw**: ₹1,000 to ₹1,500

---

### Scenario 7: User has ₹5,000 ✅
**Available Balance Display**: ₹5,000 (Green)

**Notice Message**:
```
✓ Minimum withdrawal is ₹1,000. You can withdraw now!
```
- Color: Blue
- Icon: Check Circle (✓)

**Form State**:
- UPI Field: ✅ Enabled - "yourname@upi"
- Amount Field: ✅ Enabled - "Enter amount (Min ₹1,000)"
- Button: ✅ Enabled - "Confirm Withdrawal"

**User Can Withdraw**: ₹1,000 to ₹5,000

---

## Calculation Logic

### When Balance < ₹1,000 (Insufficient)
```dart
final amountNeeded = AppConstants.minWithdrawalAmount - widget.withdrawableBalance;
// Example: 1,000 - 500 = 500
// Message: "You need ₹500 more."
```

### When Balance ≥ ₹1,000 (Sufficient)
```dart
final hasMinimumBalance = widget.withdrawableBalance >= AppConstants.minWithdrawalAmount;
// Example: 1,500 >= 1,000 = true
// Message: "You can withdraw now!"
```

## Color Coding

| Balance Status | Available Balance | Notice Box | Icon |
|---------------|------------------|------------|------|
| Below Minimum | 🟠 Orange | 🔴 Red | 🛈 Info |
| At or Above Minimum | 🟢 Green | 🔵 Blue | ✓ Check |

## Validation Rules

### Amount Field Validation (When Enabled)
1. ✅ Must not be empty
2. ✅ Must be a valid number
3. ✅ Must be ≥ ₹1,000 (minimum)
4. ✅ Must be ≤ available balance (maximum)

### UPI Field Validation (When Enabled)
1. ✅ Must not be empty
2. ✅ Must contain "@" symbol
3. ✅ Format: `username@provider`

## Testing Checklist

- [ ] Test with ₹0 balance → Shows "You need ₹1,000 more"
- [ ] Test with ₹500 balance → Shows "You need ₹500 more"
- [ ] Test with ₹999 balance → Shows "You need ₹1 more"
- [ ] Test with ₹1,000 balance → Shows "You can withdraw now!"
- [ ] Test with ₹2,500 balance → Shows "You can withdraw now!"
- [ ] Verify all fields disabled when below minimum
- [ ] Verify all fields enabled when at or above minimum
- [ ] Verify button text changes based on balance
- [ ] Verify color changes (orange → green, red → blue)
- [ ] Try to withdraw ₹500 when balance is ₹2,000 → Should show error
- [ ] Try to withdraw ₹1,500 when balance is ₹1,000 → Should show error

## Code Location

**File**: `lib/widgets/withdrawal_prompt.dart`

**Key Lines**:
- Line 69-70: Check if balance meets minimum
- Line 139: Calculate remaining amount needed
- Line 138: Success message when minimum is met
- Line 167: Disable UPI field when below minimum
- Line 199: Disable amount field when below minimum
- Line 226: Disable confirm button when below minimum

