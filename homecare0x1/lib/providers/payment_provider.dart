import 'package:flutter/material.dart';
import 'package:homecare0x1/models/payment.dart';

class PaymentProvider with ChangeNotifier {
  final List<Payment> _payments = [
    Payment(
      id: 'p1',
      invoiceNumber: 'HC-2025-001',
      amount: 850.00,
      dueDate: DateTime(2025, 2, 15),
      status: 'Pending',
      description: 'January 2025 caregiving services',
      servicePeriod: 'Jan 1-31, 2025',
      hoursBilled: 120.0,
      rate: 25.0,
    ),
    Payment(
      id: 'p2',
      invoiceNumber: 'HC-2024-012',
      amount: 400.00,
      dueDate: DateTime(2025, 1, 10),
      status: 'Overdue',
      description: 'December 2024 caregiving services',
      servicePeriod: 'Dec 1-31, 2024',
      hoursBilled: 80.0,
      rate: 20.0,
    ),
    Payment(
      id: 'p3',
      invoiceNumber: 'HC-2024-011',
      amount: 720.00,
      dueDate: DateTime(2024, 12, 15),
      status: 'Paid',
      description: 'November 2024 caregiving services',
      servicePeriod: 'Nov 1-30, 2024',
      hoursBilled: 100.0,
      rate: 22.0,
    ),
    Payment(
      id: 'p4',
      invoiceNumber: 'HC-2024-010',
      amount: 680.00,
      dueDate: DateTime(2024, 11, 15),
      status: 'Paid',
      description: 'October 2024 caregiving services',
      servicePeriod: 'Oct 1-31, 2024',
      hoursBilled: 90.0,
      rate: 21.0,
    ),
  ];

  final List<Map<String, dynamic>> _paymentMethods = [
    {
      'id': 'pm1',
      'title': 'Credit Card ending in 4532',
      'subtitle': 'Primary payment method',
      'icon': Icons.credit_card,
      'color': const Color(0xFF3498DB),
      'isDefault': true,
    },
    {
      'id': 'pm2',
      'title': 'Bank Account ending in 8901',
      'subtitle': 'Backup payment method',
      'icon': Icons.account_balance,
      'color': const Color(0xFF16A085),
      'isDefault': false,
    },
  ];

  List<Payment> get payments => _payments;

  List<Map<String, dynamic>> get paymentMethods => _paymentMethods;

  double get totalBilledThisMonth =>
      _payments.where((p) => p.dueDate.month == DateTime.now().month).fold(0.0,
          (sum, payment) => sum + payment.amount);

  double get totalPaidYTD => _payments
      .where((p) =>
          p.status.toLowerCase() == 'paid' &&
          p.dueDate.year == DateTime.now().year)
      .fold(0.0, (sum, payment) => sum + payment.amount);

  int get pendingInvoices =>
      _payments.where((p) => p.status.toLowerCase() == 'pending').length;

  double get outstandingBalance =>
      _payments.where((p) => p.status.toLowerCase() != 'paid').fold(
          0.0, (sum, payment) => sum + payment.amount);

  int get overduePayments =>
      _payments.where((p) => p.status.toLowerCase() == 'overdue').length;

  void addPayment(Payment payment) {
    _payments.add(payment);
    notifyListeners();
  }

  void addPaymentMethod(Map<String, dynamic> method) {
    _paymentMethods.add(method);
    notifyListeners();
  }
}
