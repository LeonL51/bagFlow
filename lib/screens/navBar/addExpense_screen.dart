import 'package:flutter/material.dart';
import 'package:bag_flow/widgets/layouts/fixed_bottomNavBar.dart';
import 'package:bag_flow/widgets/layouts/fixed_appBar.dart';
import 'package:bag_flow/utils/bottom_nav_handler.dart';

class AddExpenseScreen extends StatefulWidget {
  const AddExpenseScreen({super.key});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  int _currentIndex = 2;

  // Default selections 
  String selectedCategory = 'Food';
  String selectedCompany = 'Chipotle';
  String selectedStreaming = 'Netflix';

  final TextEditingController priceController = TextEditingController();

  // TODO: Replace hard coding for categories 
  final Map<String, List<String>> categories = {
    'Food': ['Chipotle', 'McDonalds', 'Starbucks'],
    'Rent': ['Landlord', 'Apartment Office'],
    'Transportation': ['Uber', 'Lyft', 'Metro'],
  };

  @override
  void dispose() {
    priceController.dispose();
    super.dispose();
  }

  void _addExpense() {
    final priceText = priceController.text.trim();

    // Asks user to enter a price 
    if (priceText.isEmpty) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Missing Price'),
          content: const Text('Please enter a price'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return; 
    }

    // Removes comma 
    final normalizedText = priceText.replaceAll(',', '');
    final price = double.tryParse(normalizedText);

    // Asks user to enter a valid price 
    if (price == null || price <= 0) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Re-enter price'),
          content: const Text('Please enter a valid price'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK')
            )
          ]
        )
      );
      return; 
    }

    // Holds expense data 
    final expense = {
      'category': selectedCategory,
      'company': selectedCompany,
      'price': price,
      'date': DateTime.now(),
    };

    // Closes the current screen and sends expense back to the prev screen
    Navigator.pop(context, expense); 
  }

  // Replace this with a widget that I made 
  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 16,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.black12),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.black12),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.blue),
      )
    );
  }

  // Format total pricing 
  String _formattedEnteredTotal() {
    final value = double.tryParse(
      priceController.text.trim().replaceAll(',', ''),
    );

    if (value == null || value <= 0) {
      return '\$0.00';
    }

    return '\$${value.toStringAsFixed(2)}';
  }

  @override
  Widget build(BuildContext context) {
    // Get list of companies from selected category
    final companies = categories[selectedCategory] ?? []; 
    // If the selected category contains the selected company, use that or default to null 
    final dropdownValue = companies.contains(selectedCompany) ? selectedCompany : null; 

    return Scaffold(
      appBar: GradientAppBar(
        title: 'Add Expense',
        onMenuTap: () {},
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Category',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 8),
            // Select a category 
            DropdownButtonFormField<String>(
              value: selectedCategory,
              decoration: _inputDecoration('Select category'),
              items: categories.keys.map((category) {
                return DropdownMenuItem<String>(
                  value: category,
                  child: Text(category),
                );
              }).toList(),
              // Update state after user input 
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    selectedCategory = value;
                    // Gets list of companies from the selected category 
                    final updatedCompanies = categories[value] ?? []; 
                    // 
                    if (updatedCompanies.isNotEmpty) {
                      selectedCompany = updatedCompanies.first;
                    } else {
                      selectedCompany = '';
                    }
                  }); 
                }
              }, 
            ),

            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Company',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: dropdownValue,
                        decoration: _inputDecoration('Select'), 
                        items: companies.map((company) {
                          return DropdownMenuItem<String>(
                            value: company,
                            child: Text(company),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              selectedCompany = value;
                            });
                          }
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Price (USD)',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: priceController,
                        autofocus: true,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: _inputDecoration('\$0.00'),
                        onChanged: (_) {
                          setState(() {});
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.black12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Total Spent',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _formattedEnteredTotal(),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _addExpense,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: const Color(0xFF2563EB),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Add'),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) async {
          await handleBottomNavTap(
            context: context,
            index: index,
            currentIndex: _currentIndex,
            setIndex: (i) => setState(() => _currentIndex = i),
          ); 
        },
      ),
    );
  }
}