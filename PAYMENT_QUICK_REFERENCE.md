# 💳 Payment System - Quick Reference Card

## 🎯 Payment Modes & Verification

| Payment Mode | Auto-Verified? | Required Fields | Admin Action |
|--------------|----------------|-----------------|--------------|
| **Cash** | ❌ No | Amount | ✅ Must Verify |
| **Cheque** | ❌ No | Cheque No., Bank, Amount, Date | ✅ Must Verify |
| **DD** | ❌ No | DD No., Bank, Amount, Date | ✅ Must Verify |
| **Online** | ✅ Yes | Razorpay Payment ID | ⚡ Auto-Verified |

## 📊 Payment Status Flow

```
PENDING → (Admin Verifies) → VERIFIED → (User can accept offer)
   ↓
(Admin Rejects) → FAILED → (User must resubmit)
```

## 🔑 Key Methods

### Check if Payment Verified
```dart
bool hasVerified = paymentProvider.hasVerifiedPayment(
  applicationId,
  PaymentType.applicationFee,
);
```

### Create Payment
```dart
Payment payment = await paymentProvider.createPayment(
  applicationId: app.id,
  userId: user.id,
  type: PaymentType.applicationFee,
  mode: PaymentMode.cash,
  amount: 500.0,
);
```

### Verify Payment (Admin)
```dart
await paymentProvider.verifyPayment(
  paymentId: payment.id,
  adminId: admin.id,
  notes: 'Cash received',
);
```

### Reject Payment (Admin)
```dart
await paymentProvider.rejectPayment(
  paymentId: payment.id,
  adminId: admin.id,
  reason: 'Invalid cheque',
);
```

### Get Payment History
```dart
List<Payment> payments = paymentProvider.getPaymentsByApplication(app.id);
```

### Get Pending Payments (Admin)
```dart
List<Payment> pending = paymentProvider.getPendingPayments();
```

## 🎨 Status Colors

| Status | Color | Icon | Meaning |
|--------|-------|------|---------|
| **Pending** | 🟡 Orange | `pending` | Awaiting verification |
| **Verified** | 🟢 Green | `check_circle` | Approved by admin |
| **Failed** | 🔴 Red | `error` | Rejected or failed |
| **Refunded** | 🔵 Blue | `refresh` | Money returned |

## 🚫 Offer Acceptance Rules

### ✅ Can Accept Offer When:
- Application fee payment status = **VERIFIED**
- Offer has been received
- All documents submitted

### ❌ Cannot Accept Offer When:
- Payment status = **PENDING** (waiting for admin)
- Payment status = **FAILED** (need to resubmit)
- No payment submitted

## 📱 User Messages

### Cash/Cheque/DD Submitted
```
"Payment submitted! Awaiting admin verification."
```

### Online Payment Success
```
"Payment verified successfully!"
```

### Payment Verified (Admin Action)
```
"Your payment has been verified. You can now accept the offer!"
```

### Payment Rejected
```
"Payment verification failed: [reason]. Please submit payment again."
```

### Trying to Accept Offer Without Verified Payment
```
"Payment verification required. Your payment is pending admin verification."
```

## 🔐 Security Checklist

- [x] Cash payments require admin verification
- [x] Cheque payments require cheque number
- [x] DD payments require DD number
- [x] Online payments verified via Razorpay
- [x] Offer acceptance gated by payment verification
- [x] Complete audit trail (who verified, when)
- [x] Rejection reasons documented
- [x] Payment history preserved

## 📋 Admin Workflow

1. **View Pending Payments**
   - Navigate to Admin Dashboard
   - Click "Pending Payments"
   - See list of unverified payments

2. **Review Payment Details**
   - Click on payment
   - View user info, amount, mode, date
   - Check payment proof/receipt

3. **Verify Payment**
   - Click "Verify"
   - Add notes (optional)
   - Confirm verification

4. **Reject Payment**
   - Click "Reject"
   - Enter rejection reason (required)
   - Confirm rejection

## 💡 Common Scenarios

### Scenario 1: Student Pays Cash
1. Student selects "Cash" mode
2. Enters amount (₹500)
3. Submits payment
4. Status = **PENDING**
5. Admin verifies cash received
6. Status = **VERIFIED**
7. Student can accept offer

### Scenario 2: Student Pays via Cheque
1. Student selects "Cheque" mode
2. Enters cheque number, bank, amount, date
3. Submits payment
4. Status = **PENDING**
5. Admin deposits cheque
6. Cheque clears
7. Admin verifies payment
8. Status = **VERIFIED**
9. Student can accept offer

### Scenario 3: Cheque Bounces
1. Student submits cheque payment
2. Status = **PENDING**
3. Admin deposits cheque
4. Cheque bounces
5. Admin rejects payment with reason
6. Status = **FAILED**
7. Student notified to resubmit
8. Student submits new payment

### Scenario 4: Online Payment
1. Student selects "Online" mode
2. Redirected to Razorpay
3. Completes payment
4. Razorpay confirms payment
5. Status = **VERIFIED** (auto)
6. Student can immediately accept offer

## 🎯 Integration Checklist

- [ ] Add PaymentProvider to main.dart
- [ ] Initialize PaymentProvider on app start
- [ ] Update payment submission in journey screen
- [ ] Add payment status display
- [ ] Gate offer acceptance with payment check
- [ ] Create admin verification screen
- [ ] Add payment history view
- [ ] Test all payment modes
- [ ] Test admin verification flow
- [ ] Test offer acceptance gate

## 📞 Support

For questions or issues:
1. Check `PAYMENT_VERIFICATION_SYSTEM.md` for detailed docs
2. Check `PAYMENT_IMPLEMENTATION_STEPS.md` for integration steps
3. Review the flow diagrams
4. Check the code in `lib/models/payment.dart` and `lib/providers/payment_provider.dart`

---

**Quick Tip:** Always check `hasVerifiedPayment()` before allowing offer acceptance!

