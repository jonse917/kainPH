import 'package:flutter/material.dart';
import 'mock_data.dart';

class StockAdjustmentForm extends StatefulWidget {
  final InventoryItem item;

  const StockAdjustmentForm({super.key, required this.item});

  @override
  State<StockAdjustmentForm> createState() => _StockAdjustmentFormState();
}

class _StockAdjustmentFormState extends State<StockAdjustmentForm> {
  String _type = 'Add';
  late final TextEditingController _qtyController;
  late final TextEditingController _noteController;

  @override
  void initState() {
    super.initState();
    _qtyController = TextEditingController();
    _noteController = TextEditingController();
  }

  @override
  void dispose() {
    _qtyController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.only(bottom: bottom),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Adjust ${widget.item.name}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  IconButton(onPressed: () => Navigator.of(context).pop(), icon: const Icon(Icons.close)),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  ChoiceChip(label: const Text('Add'), selected: _type == 'Add', onSelected: (_) => setState(() => _type = 'Add')),
                  const SizedBox(width: 8),
                  ChoiceChip(label: const Text('Remove'), selected: _type == 'Remove', onSelected: (_) => setState(() => _type = 'Remove')),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _qtyController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Quantity (${widget.item.unit})'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _noteController,
                decoration: const InputDecoration(labelText: 'Reason / Note (optional)'),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      final quantity = int.tryParse(_qtyController.text);
                      if (quantity == null || quantity <= 0) return;
                      Navigator.of(context).pop(_type == 'Add' ? quantity : -quantity);
                    },
                    child: const Text('Apply'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
