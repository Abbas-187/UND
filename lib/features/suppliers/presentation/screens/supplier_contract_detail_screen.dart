import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/supplier_contract.dart';
import '../providers/supplier_contract_provider.dart';

class SupplierContractDetailScreen extends ConsumerStatefulWidget {
  final String? contractId;

  const SupplierContractDetailScreen({Key? key, this.contractId})
      : super(key: key);

  @override
  ConsumerState<SupplierContractDetailScreen> createState() =>
      _SupplierContractDetailScreenState();
}

class _SupplierContractDetailScreenState
    extends ConsumerState<SupplierContractDetailScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Form controllers
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _contractNumberController;
  late TextEditingController _supplierNameController;
  late TextEditingController _supplierIdController;
  late TextEditingController _valueController;
  String _contractType = 'Purchase';
  String _currency = 'USD';
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(days: 365));
  bool _isActive = true;
  bool _autoRenew = false;
  int _renewalNoticeDays = 30;
  List<String> _tags = [];
  List<Map<String, dynamic>> _attachments = [];
  List<Map<String, dynamic>> _pricingSchedule = [];
  Map<String, dynamic>? _terms;

  bool _isEditMode = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _isEditMode = widget.contractId != null;

    if (_isEditMode) {
      _loadContractData();
    }
  }

  void _initializeControllers() {
    _titleController = TextEditingController();
    _descriptionController = TextEditingController();
    _contractNumberController = TextEditingController();
    _supplierNameController = TextEditingController();
    _supplierIdController = TextEditingController();
    _valueController = TextEditingController(text: '0.00');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _contractNumberController.dispose();
    _supplierNameController.dispose();
    _supplierIdController.dispose();
    _valueController.dispose();
    super.dispose();
  }

  Future<void> _loadContractData() async {
    if (widget.contractId == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final contractAsyncValue = ref.read(contractProvider(widget.contractId!));

      contractAsyncValue.whenData((contract) {
        _titleController.text = contract.title;
        _descriptionController.text = contract.description;
        _contractNumberController.text = contract.contractNumber;
        _supplierNameController.text = contract.supplierName;
        _supplierIdController.text = contract.supplierId;
        _valueController.text = contract.value.toString();
        _contractType = contract.contractType;
        _currency = contract.currency;
        _startDate = contract.startDate;
        _endDate = contract.endDate;
        _isActive = contract.isActive;
        _autoRenew = contract.autoRenew;
        _renewalNoticeDays = contract.renewalNoticeDays;
        _tags = contract.tags;
        _attachments = contract.attachments;
        _pricingSchedule = contract.pricingSchedule;
        _terms = contract.terms;
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveContract() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final contractManager = ref.read(contractManagerProvider.notifier);

      final contract = SupplierContract(
        id: widget.contractId ?? '',
        title: _titleController.text,
        description: _descriptionController.text,
        contractNumber: _contractNumberController.text,
        supplierId: _supplierIdController.text,
        supplierName: _supplierNameController.text,
        contractType: _contractType,
        value: double.tryParse(_valueController.text) ?? 0,
        currency: _currency,
        startDate: _startDate,
        endDate: _endDate,
        isActive: _isActive,
        autoRenew: _autoRenew,
        renewalNoticeDays: _renewalNoticeDays,
        tags: _tags,
        attachments: _attachments,
        pricingSchedule: _pricingSchedule,
        terms: _terms,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      if (_isEditMode) {
        await contractManager.updateContract(contract);
      } else {
        await contractManager.addContract(contract);
      }

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final contract = widget.contractId != null
        ? ref.watch(contractProvider(widget.contractId!))
        : null;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? 'Edit Contract' : 'New Contract'),
        actions: [
          if (_isEditMode)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _confirmDelete,
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : contract != null
              ? contract.when(
                  data: (data) => _buildForm(),
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (error, stackTrace) => Center(
                    child: Text('Error: ${error.toString()}'),
                  ),
                )
              : _buildForm(),
      bottomNavigationBar: BottomAppBar(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: ElevatedButton(
            onPressed: _isLoading ? null : _saveContract,
            child: Text(_isEditMode ? 'Update Contract' : 'Create Contract'),
          ),
        ),
      ),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildContractInfoSection(),
          const SizedBox(height: 24.0),
          _buildDateAndValueSection(),
          const SizedBox(height: 24.0),
          _buildContractOptionsSection(),
          const SizedBox(height: 24.0),
          _buildAttachmentsSection(),
          const SizedBox(height: 24.0),
          _buildPricingScheduleSection(),
          const SizedBox(height: 24.0),
          _buildTagsSection(),
        ],
      ),
    );
  }

  Widget _buildContractInfoSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Contract Information',
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16.0),
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Contract Title',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a contract title';
                }
                return null;
              },
            ),
            const SizedBox(height: 16.0),
            TextFormField(
              controller: _contractNumberController,
              decoration: const InputDecoration(
                labelText: 'Contract Number',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a contract number';
                }
                return null;
              },
            ),
            const SizedBox(height: 16.0),
            DropdownButtonFormField<String>(
              value: _contractType,
              decoration: const InputDecoration(
                labelText: 'Contract Type',
                border: OutlineInputBorder(),
              ),
              items: [
                'Purchase',
                'Service',
                'Distribution',
                'Manufacturing',
                'License',
                'Consulting',
                'Maintenance',
              ].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (newValue) {
                setState(() {
                  _contractType = newValue!;
                });
              },
            ),
            const SizedBox(height: 16.0),
            TextFormField(
              controller: _supplierNameController,
              decoration: const InputDecoration(
                labelText: 'Supplier Name',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a supplier name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16.0),
            TextFormField(
              controller: _supplierIdController,
              decoration: const InputDecoration(
                labelText: 'Supplier ID',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a supplier ID';
                }
                return null;
              },
            ),
            const SizedBox(height: 16.0),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
              maxLines: 3,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateAndValueSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Contract Terms',
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16.0),
            Row(
              children: [
                Expanded(
                  child: ListTile(
                    title: const Text('Start Date'),
                    subtitle: Text(DateFormat('dd/MM/yyyy').format(_startDate)),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _startDate,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) {
                        setState(() {
                          _startDate = picked;
                          // Ensure end date is after start date
                          if (_endDate.isBefore(_startDate)) {
                            _endDate = _startDate.add(const Duration(days: 1));
                          }
                        });
                      }
                    },
                  ),
                ),
                Expanded(
                  child: ListTile(
                    title: const Text('End Date'),
                    subtitle: Text(DateFormat('dd/MM/yyyy').format(_endDate)),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _endDate,
                        firstDate: _startDate,
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) {
                        setState(() {
                          _endDate = picked;
                        });
                      }
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _valueController,
                    decoration: const InputDecoration(
                      labelText: 'Contract Value',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a value';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Please enter a valid number';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16.0),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _currency,
                    decoration: const InputDecoration(
                      labelText: 'Currency',
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      'USD',
                      'EUR',
                      'GBP',
                      'JPY',
                      'CAD',
                      'AUD',
                      'CHF',
                      'CNY',
                      'INR'
                    ].map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      setState(() {
                        _currency = newValue!;
                      });
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContractOptionsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Contract Options',
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16.0),
            SwitchListTile(
              title: const Text('Active Contract'),
              value: _isActive,
              onChanged: (value) {
                setState(() {
                  _isActive = value;
                });
              },
            ),
            SwitchListTile(
              title: const Text('Auto Renew'),
              value: _autoRenew,
              onChanged: (value) {
                setState(() {
                  _autoRenew = value;
                });
              },
            ),
            if (_autoRenew)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: [
                    const Text('Renewal Notice Days:'),
                    Expanded(
                      child: Slider(
                        value: _renewalNoticeDays.toDouble(),
                        min: 1,
                        max: 90,
                        divisions: 89,
                        label: _renewalNoticeDays.toString(),
                        onChanged: (value) {
                          setState(() {
                            _renewalNoticeDays = value.toInt();
                          });
                        },
                      ),
                    ),
                    Text(_renewalNoticeDays.toString()),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttachmentsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  'Attachments',
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                TextButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text('Add'),
                  onPressed: _addAttachment,
                ),
              ],
            ),
            const SizedBox(height: 8.0),
            if (_attachments.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text('No attachments added'),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _attachments.length,
                itemBuilder: (context, index) {
                  final attachment = _attachments[index];
                  return ListTile(
                    leading: const Icon(Icons.attach_file),
                    title: Text(attachment['name'] as String),
                    subtitle: Text('Uploaded: ${attachment['uploadedAt']}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () {
                        setState(() {
                          _attachments.removeAt(index);
                        });
                      },
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPricingScheduleSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  'Pricing Schedule',
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                TextButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text('Add'),
                  onPressed: _addPricingItem,
                ),
              ],
            ),
            const SizedBox(height: 8.0),
            if (_pricingSchedule.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text('No pricing items added'),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _pricingSchedule.length,
                itemBuilder: (context, index) {
                  final item = _pricingSchedule[index];
                  final formatter = NumberFormat.currency(symbol: _currency);
                  return ListTile(
                    title: Text(item['description'] as String),
                    subtitle: Text('Quantity: ${item['quantity']}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(formatter.format(
                            item['unitPrice'] * (item['quantity'] ?? 1))),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () {
                            setState(() {
                              _pricingSchedule.removeAt(index);
                            });
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTagsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  'Tags',
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                TextButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text('Add'),
                  onPressed: _addTag,
                ),
              ],
            ),
            const SizedBox(height: 8.0),
            Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              children: _tags.map((tag) {
                return Chip(
                  label: Text(tag),
                  deleteIcon: const Icon(Icons.close, size: 18),
                  onDeleted: () {
                    setState(() {
                      _tags.remove(tag);
                    });
                  },
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  void _addAttachment() {
    // In a real app, this would show a file picker and upload the file
    // For this example, we'll just add a dummy attachment
    setState(() {
      _attachments.add({
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'name': 'Document_${_attachments.length + 1}.pdf',
        'url': 'https://example.com/document.pdf',
        'uploadedAt': DateTime.now().toIso8601String(),
      });
    });
  }

  void _addPricingItem() {
    // Show a dialog to add a pricing item
    showDialog(
      context: context,
      builder: (context) {
        final descriptionController = TextEditingController();
        final quantityController = TextEditingController(text: '1');
        final unitPriceController = TextEditingController(text: '0.00');

        return AlertDialog(
          title: const Text('Add Pricing Item'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                ),
              ),
              const SizedBox(height: 8.0),
              TextField(
                controller: quantityController,
                decoration: const InputDecoration(
                  labelText: 'Quantity',
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 8.0),
              TextField(
                controller: unitPriceController,
                decoration: InputDecoration(
                  labelText: 'Unit Price ($_currency)',
                ),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final quantity = int.tryParse(quantityController.text) ?? 1;
                final unitPrice =
                    double.tryParse(unitPriceController.text) ?? 0.0;

                setState(() {
                  _pricingSchedule.add({
                    'id': DateTime.now().millisecondsSinceEpoch.toString(),
                    'description': descriptionController.text,
                    'quantity': quantity,
                    'unitPrice': unitPrice,
                  });
                });

                Navigator.pop(context);
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _addTag() {
    // Show a dialog to add a tag
    showDialog(
      context: context,
      builder: (context) {
        final tagController = TextEditingController();

        return AlertDialog(
          title: const Text('Add Tag'),
          content: TextField(
            controller: tagController,
            decoration: const InputDecoration(
              labelText: 'Tag',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (tagController.text.isNotEmpty) {
                  setState(() {
                    _tags.add(tagController.text);
                  });
                  Navigator.pop(context);
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Contract'),
          content: const Text(
              'Are you sure you want to delete this contract? This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () async {
                Navigator.pop(context);

                setState(() {
                  _isLoading = true;
                });

                try {
                  await ref
                      .read(contractManagerProvider.notifier)
                      .deleteContract(widget.contractId!);
                  if (mounted) {
                    Navigator.pop(context);
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: ${e.toString()}')),
                    );
                  }
                } finally {
                  if (mounted) {
                    setState(() {
                      _isLoading = false;
                    });
                  }
                }
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}
