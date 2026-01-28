# Razorpay Demo/Test Setup Guide

## 🎯 Overview

This guide explains how to set up and test Razorpay payment integration in the Uptop Careers application.

## 📋 Prerequisites

1. **Razorpay Account**: Sign up at [https://razorpay.com](https://razorpay.com)
2. **Test API Keys**: Get your test keys from [Razorpay Dashboard](https://dashboard.razorpay.com/app/keys)

## 🔧 Setup Steps

### Step 1: Get Razorpay Test Keys

1. Go to [Razorpay Dashboard](https://dashboard.razorpay.com/app/keys)
2. Switch to **Test Mode** (toggle in the top-right corner)
3. Copy your **Test Key ID** (starts with `rzp_test_`)
4. Copy your **Test Key Secret**

### Step 2: Update Environment Variables

Open the `.env` file and update the Razorpay credentials:

```env
# Razorpay Configuration (TEST MODE)
RAZORPAY_KEY_ID=rzp_test_YOUR_KEY_ID_HERE
RAZORPAY_KEY_SECRET=your_test_key_secret_here
```

**Example:**
```env
RAZORPAY_KEY_ID=rzp_test_1DP5mmOlF5G5ag
RAZORPAY_KEY_SECRET=thisissecret
```

### Step 3: Restart the Application

After updating the `.env` file:

```bash
# Stop the running app (press 'q' in terminal)
# Then restart
flutter run
```

## 🧪 Testing Payment Flow

### Test the Application Journey Payment

1. **Navigate to a Program**:
   - Go to Home → Browse Programs
   - Select any program
   - Click "Apply Now"

2. **Fill Application Details**:
   - Complete Personal Information
   - Complete Academic Information
   - Upload Documents
   - Accept Terms & Conditions

3. **Make Payment**:
   - Expand the "Application Fee Payment" section
   - Select **"Online"** as payment mode
   - Click **"Pay ₹500 via Razorpay"** button

4. **Razorpay Checkout**:
   - Razorpay test checkout will open
   - Use test card details (see below)

### Test Card Details

Razorpay provides test cards for different scenarios:

#### ✅ Successful Payment
```
Card Number: 4111 1111 1111 1111
CVV: Any 3 digits
Expiry: Any future date
```

#### ❌ Failed Payment
```
Card Number: 4000 0000 0000 0002
CVV: Any 3 digits
Expiry: Any future date
```

#### 🔐 3D Secure Authentication
```
Card Number: 5104 0600 0000 0008
CVV: Any 3 digits
Expiry: Any future date
OTP: 1234
```

### Test UPI (India)
```
UPI ID: success@razorpay
```

### Test Wallets
- Select any wallet (Paytm, PhonePe, etc.)
- It will simulate a successful payment

## 📱 What Happens After Payment

### On Success:
1. ✅ Payment record is created in the system
2. ✅ Application status is updated to "Fee Paid"
3. ✅ Referrer receives ₹500 reward
4. ✅ Success message is displayed
5. ✅ User is redirected back to application journey

### On Failure:
1. ❌ Error message is displayed
2. ❌ No payment record is created
3. ❌ User can retry payment

## 🔍 Debugging

### Check Payment Logs

The app logs payment information in debug mode:

```
🔑 Using Razorpay Key: rzp_test_xxxxx
💰 Amount: ₹500 (50000 paise)
📱 Phone: +919999999999
✅ Payment Success!
Payment ID: pay_xxxxx
Order ID: order_xxxxx
Signature: xxxxx
✅ Payment record created successfully
```

### Common Issues

#### Issue: "Invalid Key ID"
**Solution**: Make sure you're using the correct test key from Razorpay dashboard

#### Issue: "Payment not opening"
**Solution**: 
- Check if `.env` file is loaded correctly
- Restart the app after changing `.env`
- Check console for error messages

#### Issue: "Payment successful but not saved"
**Solution**: Check the payment provider logs for errors

## 🎮 Games Screen Back Button Fix

### What Was Fixed:
The Games screen now properly handles the back button:

- **When accessed via bottom navigation**: No back button (normal behavior)
- **When pushed onto navigation stack**: Shows back button in AppBar
- **Back button behavior**: Properly pops the route instead of logging out

### How It Works:
```dart
final canPop = Navigator.of(context).canPop();
```

This checks if there's a route to pop. If yes, shows AppBar with back button. If no, shows the regular header.

## 📊 Payment Provider Integration

The payment is integrated with the `PaymentProvider`:

```dart
await paymentProvider.createPayment(
  applicationId: widget.applicationId,
  userId: authProvider.userId ?? 'demo_user',
  type: PaymentType.applicationFee,
  mode: PaymentMode.online,
  amount: 500.0,
  razorpayPaymentId: response.paymentId,
  razorpayOrderId: response.orderId,
  razorpaySignature: response.signature,
);
```

## 🚀 Going Live (Production)

When ready to go live:

1. Switch to **Live Mode** in Razorpay Dashboard
2. Get your **Live API Keys**
3. Update `.env` with live keys:
   ```env
   RAZORPAY_KEY_ID=rzp_live_YOUR_LIVE_KEY
   RAZORPAY_KEY_SECRET=your_live_secret
   ```
4. Test thoroughly before deploying
5. Enable webhooks for payment verification

## 📞 Support

- **Razorpay Docs**: [https://razorpay.com/docs](https://razorpay.com/docs)
- **Test Mode Guide**: [https://razorpay.com/docs/payments/payments/test-mode](https://razorpay.com/docs/payments/payments/test-mode)

