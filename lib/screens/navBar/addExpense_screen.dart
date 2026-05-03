import 'package:bag_flow/models/expense.dart';
import 'package:bag_flow/providers/auth_provider.dart';
import 'package:bag_flow/providers/expense_provider.dart';
import 'package:bag_flow/utils/bottom_nav_handler.dart';
import 'package:bag_flow/widgets/layouts/fixed_appBar.dart';
import 'package:bag_flow/widgets/layouts/fixed_bottomNavBar.dart';
import 'package:bag_flow/screens/navBar/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AddExpenseScreen extends ConsumerStatefulWidget {
  const AddExpenseScreen({super.key});

  @override
  ConsumerState<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends ConsumerState<AddExpenseScreen> {
  int _currentIndex = 2;

  String? selectedCategory;

  final Map<String, List<String>> categories = {
    'Food': [
      'Chipotle',
      'McDonalds',
      'Starbucks',
      'Chick-fil-A',
      'Subway',
      'Panera',
      'Other',
    ],
    'Transportation': [
      'Uber',
      'Lyft',
      'Metro',
      'Bus',
      'Gas Station',
      'Other',
    ],
    'Rent': [
      'Landlord',
      'Apartment Office',
      'Dorm Housing',
      'Other',
    ],
    'Shopping': [
      'Amazon',
      'Target',
      'Walmart',
      'Bookstore',
      'Other',
    ],
    'Subscription': [
      'Netflix',
      'Spotify',
      'Apple Music',
      'Hulu',
      'Gym Membership',
      'Other',
    ],
    'Education': [
      'Campus Bookstore',
      'Pearson',
      'Chegg',
      'Udemy',
      'Other',
    ],
    'Bills': [
      'Verizon',
      'Internet',
      'Electric',
      'Water',
      'Insurance',
      'Other',
    ],
  };

  final List<_ExpenseRowData> _expenseRows = [];

  @override
  void initState() {
    super.initState();
    _addNewRow();
  }

  @override
  void dispose() {
    for (final row in _expenseRows) {
      row.dispose();
    }
    super.dispose();
  }

  void _addNewRow() {
    setState(() {
      _expenseRows.add(_ExpenseRowData());
    });
  }

  void _removeRow(int index) {
    if (_expenseRows.length == 1) {
      _expenseRows[index].clear();
      setState(() {});
      return;
    }

    _expenseRows[index].dispose();

    setState(() {
      _expenseRows.removeAt(index);
    });
  }

  List<String> _vendorsForSelectedCategory() {
    if (selectedCategory == null) return [];
    return categories[selectedCategory] ?? [];
  }

  bool get _hasStartedEnteringItems {
    return _expenseRows.any((row) {
      return row.selectedVendor != null ||
          row.vendorController.text.trim().isNotEmpty ||
          row.priceController.text.trim().isNotEmpty;
    });
  }

  double _rowPrice(_ExpenseRowData row) {
    final raw = row.priceController.text.trim().replaceAll(',', '');
    return double.tryParse(raw) ?? 0.0;
  }

  double _totalAmount() {
    double total = 0.0;

    for (final row in _expenseRows) {
      total += _rowPrice(row);
    }

    return total;
  }

  String _formatCurrency(double amount) {
    return '\$${amount.toStringAsFixed(2)}';
  }

  bool _isRowValid(_ExpenseRowData row) {
    final hasVendor = row.isOtherVendor
        ? row.vendorController.text.trim().isNotEmpty
        : (row.selectedVendor != null &&
            row.selectedVendor!.trim().isNotEmpty);

    final price = _rowPrice(row);

    return hasVendor && price > 0;
  }

  bool _canSubmit() {
    if (selectedCategory == null) return false;
    if (_expenseRows.isEmpty) return false;

    return _expenseRows.any(_isRowValid);
  }

  Future<void> _openVendorSearch(int rowIndex) async {
    if (selectedCategory == null) {
      _showMessage('Please select a category first.');
      return;
    }

    final row = _expenseRows[rowIndex];

    final result = await showSearch<String?>(
      context: context,
      delegate: VendorSearchDelegate(
        vendors: _vendorsForSelectedCategory(),
      ),
    );

    if (result == null) return;

    setState(() {
      if (result == 'Other') {
        row.isOtherVendor = true;
        row.selectedVendor = 'Other';

        // Show "Other" immediately so user sees feedback
        row.vendorController.text = 'Other';
      } else {
        row.isOtherVendor = false;
        row.selectedVendor = result;
        row.vendorController.text = result;
      }
    });

    if (row.isOtherVendor) {
      row.vendorFocusNode.requestFocus();
    } else {
      row.priceFocusNode.requestFocus();
    }
  }

  void _onCategoryTapped() async {
    if (_hasStartedEnteringItems && selectedCategory != null) {
      final shouldChange = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Change category?'),
          content: const Text(
            'Changing the category will reset your current items. '
            'Add all items for this category before switching.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Change'),
            ),
          ],
        ),
      );

      if (shouldChange != true) return;
    }

    final category = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _CategoryPickerSheet(
        categories: categories.keys.toList(),
        selectedCategory: selectedCategory,
      ),
    );

    if (category == null) return;

    for (final row in _expenseRows) {
      row.dispose();
    }

    setState(() {
      selectedCategory = category;
      _expenseRows
        ..clear()
        ..add(_ExpenseRowData());
    });
  }

  Future<void> _submitExpenses() async {
    if (selectedCategory == null) {
      _showMessage('Please select a category.');
      return;
    }

    final validRows = _expenseRows.where(_isRowValid).toList();

    if (validRows.isEmpty) {
      _showMessage('Please add at least one valid expense item.');
      return;
    }

    final user = ref.read(authServiceProvider).currentUser;

    if (user == null) {
      _showMessage('Please log in before adding expenses.');
      return;
    }

    final now = DateTime.now();

    final expenses = validRows.map((row) {
      final vendorName = row.isOtherVendor
          ? row.vendorController.text.trim()
          : (row.selectedVendor ?? row.vendorController.text.trim());

      return Expense(
        id: '',
        userId: user.uid,
        title: vendorName,
        amount: _rowPrice(row),
        category: selectedCategory!,
        date: now,
      );
    }).toList();

    try {
      ref.read(expenseLoadingProvider.notifier).state = true;

      await ref.read(expenseServiceProvider).addExpenses(expenses);

      if (!mounted) return;

      _showMessage('Expense saved.');

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const HomeScreen(),
        ),
      );
    } catch (e) {
      _showMessage('Could not save expense: $e');
    } finally {
      ref.read(expenseLoadingProvider.notifier).state = false;
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  InputDecoration _inputDecoration({
    required String hint,
    Widget? suffixIcon,
    bool readOnly = false,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(
        color: Color(0xFF9CA3AF),
        fontSize: 15,
        fontWeight: FontWeight.w500,
      ),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: Color(0xFF8B5CF6),
          width: 1.3,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final total = _totalAmount();
    final isLoading = ref.watch(expenseLoadingProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: GradientAppBar(
        title: 'New Entries',
        onMenuTap: () {},
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Category',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 10),
                    GestureDetector(
                      onTap: _onCategoryTapped,
                      child: AbsorbPointer(
                        child: TextFormField(
                          readOnly: true,
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                          decoration: _inputDecoration(
                            hint: selectedCategory ?? 'Select a category',
                            suffixIcon:
                                const Icon(Icons.keyboard_arrow_down_rounded),
                            readOnly: true,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 22),
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Items',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        TextButton.icon(
                          onPressed: _addNewRow,
                          icon: const Icon(Icons.add_rounded),
                          label: const Text('Add Row'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ...List.generate(_expenseRows.length, (index) {
                      return _expenseRow(index);
                    }),
                  ],
                ),
              ),
            ),
            _bottomSubmitBar(total, isLoading),
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

  Widget _expenseRow(int index) {
    final row = _expenseRows[index];

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        children: [
          TextFormField(
            controller: row.vendorController,
            focusNode: row.vendorFocusNode,

            // Editable ONLY when "Other" is selected
            readOnly: !row.isOtherVendor,

            // Open search ONLY when not "Other"
            onTap: row.isOtherVendor ? null : () => _openVendorSearch(index),

            style: const TextStyle(color: Colors.black),
            decoration: _inputDecoration(
              hint: selectedCategory == null
                  ? 'Select category first'
                  : 'Search vendor',
              suffixIcon: row.isOtherVendor
                  ? const Icon(Icons.edit_rounded)
                  : const Icon(Icons.search_rounded),
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: row.priceController,
            focusNode: row.priceFocusNode,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
            ],
            style: const TextStyle(color: Colors.black),
            decoration: _inputDecoration(
              hint: 'Amount',
              suffixIcon: IconButton(
                onPressed: () => _removeRow(index),
                icon: const Icon(Icons.close_rounded),
              ),
            ),
            onChanged: (_) => setState(() {}),
          ),
        ],
      ),
    );
  }

  Widget _bottomSubmitBar(double total, bool isLoading) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      decoration: BoxDecoration(
        color: Colors.black,
        border: Border(
          top: BorderSide(color: Colors.white.withOpacity(0.08)),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Total: ${_formatCurrency(total)}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 12),

          // SizedBox gives the button a fixed width so it does not try to be infinite
          SizedBox(
            width: 110,
            height: 55,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(110, 55),
              ),
              onPressed: !_canSubmit() || isLoading ? null : _submitExpenses,
              child: isLoading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Save'),
            ),
          ),
        ],
      ),
    );
  }
}

class _ExpenseRowData {
  String? selectedVendor;
  bool isOtherVendor = false;

  final TextEditingController vendorController = TextEditingController();
  final TextEditingController priceController = TextEditingController();

  final FocusNode vendorFocusNode = FocusNode();
  final FocusNode priceFocusNode = FocusNode();

  void clear() {
    selectedVendor = null;
    isOtherVendor = false;
    vendorController.clear();
    priceController.clear();
  }

  void dispose() {
    vendorController.dispose();
    priceController.dispose();
    vendorFocusNode.dispose();
    priceFocusNode.dispose();
  }
}

class _CategoryPickerSheet extends StatelessWidget {
  final List<String> categories;
  final String? selectedCategory;

  const _CategoryPickerSheet({
    required this.categories,
    required this.selectedCategory,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 30),
      decoration: const BoxDecoration(
        color: Color(0xFF111827),
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
      ),
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: categories.map((category) {
          final selected = category == selectedCategory;

          return ChoiceChip(
            label: Text(category),
            selected: selected,
            selectedColor: const Color(0xFF8B5CF6),
            backgroundColor: Colors.white.withOpacity(0.06),
            labelStyle: TextStyle(
              color: selected ? Colors.white : Colors.white70,
              fontWeight: FontWeight.w700,
            ),
            side: BorderSide(color: Colors.white.withOpacity(0.08)),
            onSelected: (_) => Navigator.pop(context, category),
          );
        }).toList(),
      ),
    );
  }
}

class VendorSearchDelegate extends SearchDelegate<String?> {
  final List<String> vendors;

  VendorSearchDelegate({required this.vendors});

  @override
  ThemeData appBarTheme(BuildContext context) {
    return ThemeData.dark().copyWith(
      scaffoldBackgroundColor: Colors.black,
      inputDecorationTheme: const InputDecorationTheme(
        border: InputBorder.none,
      ),
    );
  }

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        onPressed: () => query = '',
        icon: const Icon(Icons.clear_rounded),
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      onPressed: () => close(context, null),
      icon: const Icon(Icons.arrow_back_rounded),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _vendorList(context);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _vendorList(context);
  }

  Widget _vendorList(BuildContext context) {
    final filtered = vendors.where((vendor) {
      return vendor.toLowerCase().contains(query.trim().toLowerCase());
    }).toList();

    return ListView(
      children: filtered.map((vendor) {
        return ListTile(
          title: Text(vendor),
          onTap: () => close(context, vendor),
        );
      }).toList(),
    );
  }
}