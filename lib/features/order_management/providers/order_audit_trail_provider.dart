import 'package:flutter/material.dart';
import '../models/order_audit_trail.dart';

class OrderAuditTrailProvider extends ChangeNotifier {
  List<OrderAuditTrail> _auditTrails = [];

  List<OrderAuditTrail> get auditTrails => _auditTrails;

  void setAuditTrails(List<OrderAuditTrail> auditTrails) {
    _auditTrails = auditTrails;
    notifyListeners();
  }

  void addAuditTrail(OrderAuditTrail auditTrail) {
    _auditTrails.add(auditTrail);
    notifyListeners();
  }
}