# Understanding Wallet Balances

## The Issue You Encountered

**Scenario**: User has ₹10 in "Total Balance" but ₹0 "Available to Withdraw"

**Why?** The ₹10 is in **PENDING** status, which means it cannot be withdrawn yet.

## Balance Types Explained

### 1. Total Balance (₹10 in your case)
- **What it is**: ALL earnings ever credited to your account
- **Includes**: 
  - ✅ Completed earnings
  - ✅ Pending earnings (not yet verified)
  - ✅ Bonus earnings
- **Displayed**: On wallet card as "Total Balance"
- **Source**: `user.totalEarnings` from User model

### 2. Available Balance (₹0 in your case)
- **What it is**: Only money that can be withdrawn RIGHT NOW
- **Includes**:
  - ✅ Completed earnings only
  - ❌ Excludes pending earnings
  - ❌ Excludes failed transactions
- **Formula**: `Completed Earnings - Completed Withdrawals`
- **Displayed**: In withdrawal prompt as "Available to Withdraw"
- **Source**: `walletProvider.availableBalance`

### 3. Pending Balance
- **What it is**: Earnings waiting to be verified/completed
- **Includes**:
  - ✅ Referral earnings pending verification
  - ✅ Bonus earnings pending approval
- **Cannot be withdrawn**: Must wait for completion
- **Displayed**: On wallet card as "Pending"
- **Source**: `user.pendingEarnings`

## Transaction Status Flow

```
New Referral
    ↓
[PENDING] ← You are here (₹10)
    ↓ (After verification)
[COMPLETED] ← Can withdraw now
    ↓
[WITHDRAWN] ← Money sent to UPI
```

## Your Current Situation

| Balance Type | Amount | Status | Can Withdraw? |
|-------------|--------|--------|---------------|
| Total Balance | ₹10 | Includes all | ❌ No |
| Available Balance | ₹0 | Only completed | ❌ No |
| Pending Balance | ₹10 | Waiting verification | ❌ No |

**Result**: You need ₹1,000 in **AVAILABLE** balance (completed earnings) to withdraw.

## How to Get Available Balance

### Option 1: Wait for Pending to Complete
1. Your ₹10 pending earnings get verified
2. Status changes from PENDING → COMPLETED
3. ₹10 moves to Available Balance
4. You now have ₹10 available (still need ₹990 more)

### Option 2: Earn More Completed Earnings
1. Refer more people
2. Complete more tasks
3. Earn bonuses
4. Wait for them to be verified/completed
5. Accumulate ₹1,000 in completed earnings

## Code Implementation

### WalletProvider Calculation
```dart
// lib/providers/wallet_provider.dart (Line 47)
double get availableBalance => totalEarnings - totalWithdrawals;

// Where:
double get totalEarnings => _transactions
    .where((t) => t.isCredit && t.isCompleted)  // ← Only COMPLETED
    .fold(0.0, (sum, t) => sum + t.amount);

double get totalWithdrawals => _transactions
    .where((t) => t.isDebit && t.isCompleted)   // ← Only COMPLETED
    .fold(0.0, (sum, t) => sum + t.amount);
```

### User Model (Total Balance)
```dart
// lib/models/user.dart
final double totalEarnings;  // ← Includes ALL (pending + completed)
final double pendingEarnings; // ← Only pending
```

## Updated Withdrawal Messages

### When Available Balance = ₹0
```
🛈 Minimum withdrawal is ₹1,000. You need ₹1,000 in available balance.
   (Pending earnings cannot be withdrawn)
```

### When Available Balance = ₹500
```
🛈 Minimum withdrawal is ₹1,000. You need ₹500 more in available balance.
```

### When Available Balance = ₹1,500
```
✓ Minimum withdrawal is ₹1,000. You can withdraw now!
```

## Visual Breakdown

```
┌─────────────────────────────────────┐
│ TOTAL BALANCE: ₹10                  │
│                                     │
│ ┌─────────────────────────────────┐ │
│ │ Pending: ₹10 (Cannot withdraw)  │ │
│ └─────────────────────────────────┘ │
│                                     │
│ ┌─────────────────────────────────┐ │
│ │ Available: ₹0 (Can withdraw)    │ │ ← This is what matters!
│ └─────────────────────────────────┘ │
└─────────────────────────────────────┘
```

## Why This Design?

### Prevents Fraud
- Users can't withdraw money before referrals are verified
- Protects against fake referrals
- Ensures quality control

### Business Logic
- Referrals need time to verify (e.g., 7 days)
- Tasks need to be reviewed
- Bonuses need approval

### User Protection
- Prevents accidental withdrawals of unverified earnings
- Clear separation between "earned" and "available"

## How to Check Transaction Status

### In Database (Supabase)
```sql
SELECT 
  type,
  amount,
  status,
  created_at
FROM transactions
WHERE user_id = 'your-user-id'
ORDER BY created_at DESC;
```

### In App (Debug)
1. Check `WalletProvider.transactions`
2. Look for `status` field
3. Values: `pending`, `completed`, `processing`, `failed`

## Summary

**The calculation is working correctly!**

- Your ₹10 is **PENDING** (not yet completed)
- Only **COMPLETED** earnings can be withdrawn
- You need ₹1,000 in **AVAILABLE** (completed) balance
- The message now clarifies: "Pending earnings cannot be withdrawn"

**Next Steps**:
1. Wait for your ₹10 to be verified (pending → completed)
2. Earn more and wait for verification
3. Once you have ₹1,000 in completed earnings, you can withdraw!

