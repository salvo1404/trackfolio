import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/portfolio_service.dart';
import '../services/auth_service.dart';
import '../models/portfolio_item.dart';
import '../utils/constants.dart';

class AddAssetTab extends StatefulWidget {
  const AddAssetTab({super.key});

  @override
  State<AddAssetTab> createState() => _AddAssetTabState();
}

class _AddAssetTabState extends State<AddAssetTab> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _quantityController = TextEditingController();
  final _purchasePriceController = TextEditingController();
  final _currentValueController = TextEditingController();

  String _selectedType = AppConstants.typeShares;
  DateTime _purchaseDate = DateTime.now();
  String _selectedCurrency = 'USD';

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    _purchasePriceController.dispose();
    _currentValueController.dispose();
    super.dispose();
  }

  Future<void> _handleAddAsset() async {
    if (!_formKey.currentState!.validate()) return;

    final portfolioService = context.read<PortfolioService>();
    final authService = context.read<AuthService>();

    final newItem = PortfolioItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: _selectedType,
      name: _nameController.text.trim(),
      quantity: double.parse(_quantityController.text),
      purchasePrice: double.parse(_purchasePriceController.text),
      currentValue: double.parse(_currentValueController.text),
      purchaseDate: _purchaseDate,
      lastUpdated: DateTime.now(),
      currency: authService.currentUser?.currency ?? _selectedCurrency,
    );

    await portfolioService.addPortfolioItem(newItem);

    if (!mounted) return;

    // Clear form
    _formKey.currentState!.reset();
    _nameController.clear();
    _quantityController.clear();
    _purchasePriceController.clear();
    _currentValueController.clear();
    setState(() {
      _selectedType = AppConstants.typeShares;
      _purchaseDate = DateTime.now();
    });

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: const [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 12),
            Expanded(child: Text('Asset added successfully!')),
          ],
        ),
        backgroundColor: Colors.green[600],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.primary.withOpacity(0.02),
            Theme.of(context).colorScheme.secondary.withOpacity(0.02),
          ],
        ),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Add New Asset',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add a new investment to your portfolio',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Asset Type
                      DropdownButtonFormField<String>(
                        value: _selectedType,
                        decoration: InputDecoration(
                          labelText: 'Asset Type',
                          prefixIcon: Icon(
                            Icons.category,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        items: AppConstants.portfolioTypes.map((type) {
                          return DropdownMenuItem(
                            value: type,
                            child: Text(type),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedType = value!;
                          });
                        },
                      ),
                      const SizedBox(height: 16),

                      // Asset Name
                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: 'Asset Name',
                          hintText: 'e.g., Apple Inc., Bitcoin',
                          prefixIcon: Icon(
                            Icons.label,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter asset name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Quantity
                      TextFormField(
                        controller: _quantityController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Quantity',
                          hintText: 'e.g., 10, 0.5',
                          prefixIcon: Icon(
                            Icons.numbers,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter quantity';
                          }
                          if (double.tryParse(value) == null) {
                            return 'Please enter a valid number';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Purchase Price
                      TextFormField(
                        controller: _purchasePriceController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Purchase Price (per unit)',
                          hintText: 'e.g., 150.00',
                          prefixIcon: Icon(
                            Icons.attach_money,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter purchase price';
                          }
                          if (double.tryParse(value) == null) {
                            return 'Please enter a valid number';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Current Value
                      TextFormField(
                        controller: _currentValueController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Current Value (per unit)',
                          hintText: 'e.g., 175.00',
                          prefixIcon: Icon(
                            Icons.trending_up,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter current value';
                          }
                          if (double.tryParse(value) == null) {
                            return 'Please enter a valid number';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Purchase Date
                      InkWell(
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: _purchaseDate,
                            firstDate: DateTime(2000),
                            lastDate: DateTime.now(),
                          );
                          if (date != null) {
                            setState(() {
                              _purchaseDate = date;
                            });
                          }
                        },
                        child: InputDecorator(
                          decoration: InputDecoration(
                            labelText: 'Purchase Date',
                            prefixIcon: Icon(
                              Icons.calendar_today,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            '${_purchaseDate.day}/${_purchaseDate.month}/${_purchaseDate.year}',
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Add Button
                      ElevatedButton(
                        onPressed: _handleAddAsset,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.add_circle),
                            SizedBox(width: 8),
                            Text(
                              'Add Asset',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
