import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:provider/provider.dart';
import 'package:uptop_careers/providers/payment_provider.dart';
import 'package:uptop_careers/providers/auth_provider.dart';
import 'package:uptop_careers/models/payment.dart';
import 'package:uptop_careers/screens/demo_payment_screens.dart';

class PaymentScreen extends StatefulWidget {
  final String applicationId;
  final Function onPaymentSuccess;

  const PaymentScreen({
    super.key,
    required this.applicationId,
    required this.onPaymentSuccess,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  late Razorpay _razorpay;
  bool _isLoading = false;
  final TextEditingController _amountController = TextEditingController(
    text: '500',
  );
  String _selectedPaymentMethod = 'All Methods';

  final List<Map<String, dynamic>> _paymentMethods = [
    {'name': 'All Methods', 'icon': Icons.payment, 'color': Colors.blue},
    {'name': 'UPI', 'icon': Icons.qr_code_scanner, 'color': Colors.green},
    {'name': 'Card', 'icon': Icons.credit_card, 'color': Colors.orange},
    {
      'name': 'Net Banking',
      'icon': Icons.account_balance,
      'color': Colors.purple,
    },
    {
      'name': 'Wallets',
      'icon': Icons.account_balance_wallet,
      'color': Colors.teal,
    },
  ];

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  @override
  void dispose() {
    _razorpay.clear();
    _amountController.dispose();
    super.dispose();
  }

  double get _amount {
    return double.tryParse(_amountController.text) ?? 0.0;
  }

  void _openCheckout() async {
    // Validate amount
    if (_amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid amount'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Navigate to demo payment screen based on selected method
    Widget? demoScreen;

    switch (_selectedPaymentMethod) {
      case 'UPI':
        demoScreen = UpiPaymentDemoScreen(
          amount: _amount,
          onSuccess: _showPaymentSuccess,
        );
        break;
      case 'Card':
        demoScreen = CardPaymentDemoScreen(
          amount: _amount,
          onSuccess: _showPaymentSuccess,
        );
        break;
      case 'Net Banking':
        demoScreen = NetBankingDemoScreen(
          amount: _amount,
          onSuccess: _showPaymentSuccess,
        );
        break;
      case 'Wallets':
        demoScreen = WalletsDemoScreen(
          amount: _amount,
          onSuccess: _showPaymentSuccess,
        );
        break;
      case 'All Methods':
        // Show a dialog to select specific method
        _showAllMethodsDialog();
        return;
    }

    if (demoScreen != null) {
      Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (_) => demoScreen!));
    }
  }

  void _showAllMethodsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Payment Method'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.qr_code_scanner, color: Colors.green),
              title: const Text('UPI'),
              onTap: () {
                Navigator.pop(context);
                setState(() {
                  _selectedPaymentMethod = 'UPI';
                });
                _openCheckout();
              },
            ),
            ListTile(
              leading: const Icon(Icons.credit_card, color: Colors.orange),
              title: const Text('Card'),
              onTap: () {
                Navigator.pop(context);
                setState(() {
                  _selectedPaymentMethod = 'Card';
                });
                _openCheckout();
              },
            ),
            ListTile(
              leading: const Icon(Icons.account_balance, color: Colors.purple),
              title: const Text('Net Banking'),
              onTap: () {
                Navigator.pop(context);
                setState(() {
                  _selectedPaymentMethod = 'Net Banking';
                });
                _openCheckout();
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.account_balance_wallet,
                color: Colors.teal,
              ),
              title: const Text('Wallets'),
              onTap: () {
                Navigator.pop(context);
                setState(() {
                  _selectedPaymentMethod = 'Wallets';
                });
                _openCheckout();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showPaymentSuccess() async {
    // Navigate back to payment screen first
    Navigator.of(context).pop();

    // Show success dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: 60,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Payment Successful!',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Text(
                '₹${_amount.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Payment Method: $_selectedPaymentMethod',
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 24),
              const Text(
                'Your application fee has been paid successfully.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close dialog
                    _handleDemoPaymentSuccess();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Done',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleDemoPaymentSuccess() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Create payment record in the system
      final paymentProvider = context.read<PaymentProvider>();
      final authProvider = context.read<AuthProvider>();

      // Generate a demo payment ID
      final demoPaymentId = 'pay_demo_${DateTime.now().millisecondsSinceEpoch}';

      await paymentProvider.createPayment(
        applicationId: widget.applicationId,
        userId: authProvider.userId ?? '',
        type: PaymentType.applicationFee,
        mode: PaymentMode.online,
        amount: _amount,
        transactionId: demoPaymentId,
        razorpayPaymentId: demoPaymentId,
      );

      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        // Call the success callback
        widget.onPaymentSuccess();

        // Navigate back to previous screen
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error saving payment: $e');
      }
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving payment: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    if (kDebugMode) {
      print('✅ Payment Success!');
      print('Payment ID: ${response.paymentId}');
      print('Order ID: ${response.orderId}');
      print('Signature: ${response.signature}');
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Create payment record in the system
      final paymentProvider = context.read<PaymentProvider>();
      final authProvider = context.read<AuthProvider>();

      await paymentProvider.createPayment(
        applicationId: widget.applicationId,
        userId: authProvider.userId ?? 'demo_user',
        type: PaymentType.applicationFee,
        mode: PaymentMode.online,
        amount: _amount,
        razorpayPaymentId: response.paymentId,
        razorpayOrderId: response.orderId,
        razorpaySignature: response.signature,
      );

      if (kDebugMode) {
        print('✅ Payment record created successfully');
      }

      // Call the success callback
      widget.onPaymentSuccess();

      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        // Show success dialog
        await _showSuccessDialog(response.paymentId ?? 'N/A');

        // Navigate back
        if (mounted) {
          Navigator.of(context).pop();
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error creating payment record: $e');
      }
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Payment successful but error saving: $e'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  Future<void> _showSuccessDialog(String paymentId) async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, color: Colors.white, size: 48),
              ),
              const SizedBox(height: 24),
              const Text(
                'Payment Successful!',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Text(
                '₹${_amount.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    const Text(
                      'Payment ID',
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      paymentId,
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Done',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    if (kDebugMode) {
      print('❌ Payment Error!');
      print('Code: ${response.code}');
      print('Message: ${response.message}');
    }

    setState(() {
      _isLoading = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Payment Failed: ${response.message ?? "Unknown error"}'),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    if (kDebugMode) {
      print('💳 External Wallet Selected: ${response.walletName}');
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('External Wallet: ${response.walletName}'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        // Allow normal back navigation - just pop this screen
        // Don't sign out the user
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Pay Application Fee'),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
        ),
        backgroundColor: Colors.grey[50],
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Invoice Card
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      const Text(
                        'INVOICE',
                        style: TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Invoice #${widget.applicationId}',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Amount Input Field
                      TextField(
                        controller: _amountController,
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                        ),
                        decoration: const InputDecoration(
                          prefixText: '₹',
                          prefixStyle: TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                          ),
                          border: InputBorder.none,
                          hintText: '0.00',
                        ),
                        onChanged: (value) {
                          setState(() {}); // Update UI when amount changes
                        },
                      ),

                      const SizedBox(height: 8),
                      const Text(
                        'Enter amount to pay',
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                      const SizedBox(height: 24),
                      const Divider(),
                      const SizedBox(height: 16),
                      _buildInvoiceRow(
                        'Application Fee',
                        '₹${_amount.toStringAsFixed(2)}',
                      ),
                      const SizedBox(height: 8),
                      _buildInvoiceRow('Convenience Fee', '₹0.00'),
                      const SizedBox(height: 16),
                      const Divider(),
                      const SizedBox(height: 16),
                      _buildInvoiceRow(
                        'Total Charge',
                        '₹${_amount.toStringAsFixed(2)}',
                        isTotal: true,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Payment Methods Section
              const Text(
                'Select Payment Method',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              // Payment Method Options
              ...(_paymentMethods.map(
                (method) => _buildPaymentMethodTile(method),
              )),

              const SizedBox(height: 24),

              // Pay Now Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _openCheckout,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    backgroundColor: Colors.blue,
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          'Pay ₹${_amount.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentMethodTile(Map<String, dynamic> method) {
    final isSelected = _selectedPaymentMethod == method['name'];

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPaymentMethod = method['name'];
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? method['color'] : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? method['color'].withOpacity(0.2)
                  : Colors.grey.withOpacity(0.1),
              blurRadius: isSelected ? 8 : 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Payment method icon/image placeholder
            Container(
              width: 56,
              height: 56,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    method['color'].withOpacity(0.2),
                    method['color'].withOpacity(0.1),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: method['color'].withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Icon(method['icon'], color: method['color'], size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    method['name'],
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.w600,
                      color: isSelected ? method['color'] : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _getPaymentMethodDescription(method['name']),
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: method['color'],
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, color: Colors.white, size: 20),
              ),
          ],
        ),
      ),
    );
  }

  String _getPaymentMethodDescription(String methodName) {
    switch (methodName) {
      case 'All Methods':
        return 'UPI, Cards, Wallets & More';
      case 'UPI':
        return 'Google Pay, PhonePe, Paytm';
      case 'Card':
        return 'Credit & Debit Cards';
      case 'Net Banking':
        return 'All Major Banks';
      case 'Wallets':
        return 'Paytm, PhonePe & More';
      default:
        return '';
    }
  }

  Widget _buildInvoiceRow(String title, String amount, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            color: isTotal ? Colors.black : Colors.grey[700],
          ),
        ),
        Text(
          amount,
          style: TextStyle(
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            color: isTotal ? Colors.black : Colors.grey[700],
          ),
        ),
      ],
    );
  }
}
