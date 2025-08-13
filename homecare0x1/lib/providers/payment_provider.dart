import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:homecare0x1/models/payment.dart';

class PaymentProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final List<Payment> _payments = [];
  final List<Map<String, dynamic>> _paymentMethods = [];

  List<Payment> get payments => _payments;

  List<Map<String, dynamic>> get paymentMethods => _paymentMethods;

  Future<void> fetchPayments() async {
    try {
      final snapshot = await _firestore.collection('payments').get();
      _payments.clear();
      _payments.addAll(snapshot.docs.map((doc) => Payment(
        id: doc.id,
        invoiceNumber: doc['invoiceNumber'],
        amount: doc['amount'].toDouble(),
        dueDate: (doc['dueDate'] as Timestamp).toDate(),
        status: doc['status'],
        description: doc['description'],
        servicePeriod: doc['servicePeriod'],
        hoursBilled: doc['hoursBilled'].toDouble(),
        rate: doc['rate'].toDouble(),
      )).toList());
      notifyListeners();
    } catch (e) {
      print('Error fetching payments: $e');
    }
  }

  Future<void> fetchPaymentMethods() async {
    try {
      final snapshot = await _firestore.collection('payment_methods').get();
      _paymentMethods.clear();
      _paymentMethods.addAll(snapshot.docs.map((doc) => {
        'id': doc.id,
        'title': doc['title'],
        'subtitle': doc['subtitle'],
        'icon': Icons.credit_card, // Note: Icons can't be stored in Firestore, handle accordingly
        'color': Color(doc['color']),
        'isDefault': doc['isDefault'],
      }).toList());
      notifyListeners();
    } catch (e) {
      print('Error fetching payment methods: $e');
    }
  }

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

  Future<void> addPayment(Payment payment) async {
    try {
      await _firestore.collection('payments').doc(payment.id).set({
        'invoiceNumber': payment.invoiceNumber,
        'amount': payment.amount,
        'dueDate': Timestamp.fromDate(payment.dueDate),
        'status': payment.status,
        'description': payment.description,
        'servicePeriod': payment.servicePeriod,
        'hoursBilled': payment.hoursBilled,
        'rate': payment.rate,
      });
      _payments.add(payment);
      notifyListeners();
    } catch (e) {
      print('Error adding payment: $e');
    }
  }

  Future<void> addPaymentMethod(Map<String, dynamic> method) async {
    try {
      await _firestore.collection('payment_methods').doc(method['id']).set({
        'title': method['title'],
        'subtitle': method['subtitle'],
        'color': method['color'].value,
        'isDefault': method['isDefault'],
      });
      _paymentMethods.add(method);
      notifyListeners();
    } catch (e) {
      print('Error adding payment method: $e');
    }
  }
}
