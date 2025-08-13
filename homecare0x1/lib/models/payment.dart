import 'package:flutter/material.dart';

class Payment {
  final String id;
  final String invoiceNumber;
  final double amount;
  final DateTime dueDate;
  final String status;
  final String description;
  final String servicePeriod;
  final double hoursBilled;
  final double rate;

  Payment({
    required this.id,
    required this.invoiceNumber,
    required this.amount,
    required this.dueDate,
    required this.status,
    required this.description,
    required this.servicePeriod,
    required this.hoursBilled,
    required this.rate,
  });

  Color getStatusColor() {
    switch (status.toLowerCase()) {
      case 'pending':
        return const Color(0xFFE67E22);
      case 'overdue':
        return const Color(0xFFE74C3C);
      case 'paid':
        return const Color(0xFF00A86B);
      default:
        return const Color(0xFF7F8C8D);
    }
  }

  IconData getStatusIcon() {
    switch (status.toLowerCase()) {
      case 'pending':
        return Icons.pending;
      case 'overdue':
        return Icons.warning;
      case 'paid':
        return Icons.check_circle;
      default:
        return Icons.info;
    }
  }
}
