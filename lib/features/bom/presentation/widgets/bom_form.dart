import 'package:flutter/material.dart';

import '../../domain/entities/bill_of_materials.dart';

// This file is a placeholder for BOM form widgets
// The actual form implementation is handled in the create/edit screens

class BomForm extends StatelessWidget {
  const BomForm({
    super.key,
    this.bom,
    required this.onSave,
  });

  final BillOfMaterials? bom;
  final Function(BillOfMaterials) onSave;

  @override
  Widget build(BuildContext context) {
    return const Placeholder(
      child: Text('BOM Form - Implementation in create/edit screens'),
    );
  }
}
