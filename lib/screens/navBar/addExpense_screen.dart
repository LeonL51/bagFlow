import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
        : (row.selectedVendor != null && row.selectedVendor!.trim().isNotEmpty);

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
        row.selectedVendor = null;
        row.vendorController.clear();
      } else {
        row.isOtherVendor = false;
        row.selectedVendor = result;
        row.vendorController.text = result;
      }
    });

    row.priceFocusNode.requestFocus();
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

  void _submitExpenses() {
    if (selectedCategory == null) {
      _showMessage('Please select a category.');
      return;
    }

    final validRows = _expenseRows.where(_isRowValid).toList();

    if (validRows.isEmpty) {
      _showMessage('Please add at least one valid expense item.');
      return;
    }

    final expenses = validRows.map((row) {
      final vendorName = row.isOtherVendor
          ? row.vendorController.text.trim()
          : (row.selectedVendor ?? row.vendorController.text.trim());

      return {
        'category': selectedCategory,
        'company': vendorName,
        'price': _rowPrice(row),
        'date': DateTime.now(),
      };
    }).toList();

    Navigator.pop(context, expenses);
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
        borderSide: const BorderSide(color: Color(0xFF8B5CF6), width: 1.3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final total = _totalAmount();

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
                            hint: selectedCategory ?? 'Food',
                            suffixIcon: const Icon(
                              Icons.keyboard_arrow_down,
                              color: Color(0xFFB9BCC6),
                            ),
                            readOnly: true,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),

                    ...List.generate(_expenseRows.length, (index) {
                      final row = _expenseRows[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: _ExpenseInputRow(
                          index: index,
                          row: row,
                          onVendorTap: () => _openVendorSearch(index),
                          onDelete: () => _removeRow(index),
                          onChanged: () => setState(() {}),
                          inputDecorationBuilder: _inputDecoration,
                        ),
                      );
                    }),

                    const SizedBox(height: 8),
                    Center(
                      child: GestureDetector(
                        onTap: _addNewRow,
                        child: Container(
                          width: 58,
                          height: 58,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.blue,
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF8B5CF6).withOpacity(0.35),
                                blurRadius: 18,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.add,
                            color: Colors.white,
                            size: 30,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 34),

                    Container(
                      width: double.infinity,
                      height: 1.2,
                      color: Colors.white,
                    ),

                    const SizedBox(height: 18),

                    Row(
                      children: [
                        const Text(
                          'Total:',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        const Spacer(),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 180),
                          transitionBuilder: (child, animation) {
                            return FadeTransition(
                              opacity: animation,
                              child: child,
                            );
                          },
                          child: Text(
                            _formatCurrency(total),
                            key: ValueKey(total.toStringAsFixed(2)),
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _canSubmit() ? _submitExpenses : null,
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      backgroundColor: const Color(0xFF54B435),
                      disabledBackgroundColor: Colors.grey.shade700,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      'Confirm',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
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

class _ExpenseInputRow extends StatelessWidget {
  const _ExpenseInputRow({
    required this.index,
    required this.row,
    required this.onVendorTap,
    required this.onDelete,
    required this.onChanged,
    required this.inputDecorationBuilder,
  });

  final int index;
  final _ExpenseRowData row;
  final VoidCallback onVendorTap;
  final VoidCallback onDelete;
  final VoidCallback onChanged;
  final InputDecoration Function({
    required String hint,
    Widget? suffixIcon,
    bool readOnly,
  }) inputDecorationBuilder;

  @override
  Widget build(BuildContext context) {
    final vendorHint = row.isOtherVendor
        ? 'Enter vendor'
        : (row.selectedVendor ?? 'Search vendor');

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F3F7),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            flex: 5,
            child: row.isOtherVendor
                ? TextFormField(
                    controller: row.vendorController,
                    textInputAction: TextInputAction.next,
                    decoration: inputDecorationBuilder(
                      hint: vendorHint,
                      suffixIcon: IconButton(
                        icon: const Icon(
                          Icons.search,
                          color: Color(0xFFB9BCC6),
                        ),
                        onPressed: onVendorTap,
                      ),
                    ),
                    onChanged: (_) => onChanged(),
                  )
                : GestureDetector(
                    onTap: onVendorTap,
                    child: AbsorbPointer(
                      child: TextFormField(
                        controller: row.vendorController,
                        readOnly: true,
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                        decoration: inputDecorationBuilder(
                          hint: vendorHint,
                          suffixIcon: const Icon(
                            Icons.search,
                            color: Color(0xFFB9BCC6),
                          ),
                          readOnly: true,
                        ),
                      ),
                    ),
                  ),
          ),
          const SizedBox(width: 10),
          Expanded(
            flex: 3,
            child: TextFormField(
              controller: row.priceController,
              focusNode: row.priceFocusNode,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
              ],
              style: const TextStyle(
                color: Colors.black,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
              decoration: inputDecorationBuilder(
                hint: '\$0.00',
              ),
              onChanged: (_) => onChanged(),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: onDelete,
            icon: const Icon(
              Icons.close_rounded,
              color: Colors.black54,
              size: 28,
            ),
            tooltip: index == 0 ? 'Clear row' : 'Remove row',
          ),
        ],
      ),
    );
  }
}

class _ExpenseRowData {
  _ExpenseRowData()
      : vendorController = TextEditingController(),
        priceController = TextEditingController(),
        priceFocusNode = FocusNode();

  final TextEditingController vendorController;
  final TextEditingController priceController;
  final FocusNode priceFocusNode;

  String? selectedVendor;
  bool isOtherVendor = false;

  void clear() {
    selectedVendor = null;
    isOtherVendor = false;
    vendorController.clear();
    priceController.clear();
  }

  void dispose() {
    vendorController.dispose();
    priceController.dispose();
    priceFocusNode.dispose();
  }
}

class VendorSearchDelegate extends SearchDelegate<String?> {
  VendorSearchDelegate({
    required this.vendors,
  });

  final List<String> vendors;

  @override
  String get searchFieldLabel => 'Search vendors';

  @override
  ThemeData appBarTheme(BuildContext context) {
    return ThemeData(
      scaffoldBackgroundColor: Colors.black,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      inputDecorationTheme: const InputDecorationTheme(
        hintStyle: TextStyle(color: Colors.white54),
        border: InputBorder.none,
      ),
      textTheme: const TextTheme(
        titleLarge: TextStyle(color: Colors.white),
      ),
    );
  }

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          onPressed: () => query = '',
          icon: const Icon(Icons.clear, color: Colors.white),
        ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      onPressed: () => close(context, null),
      icon: const Icon(Icons.arrow_back, color: Colors.white),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final results = _filteredVendors();

    return Container(
      color: Colors.black,
      child: ListView.builder(
        itemCount: results.length,
        itemBuilder: (context, index) {
          final vendor = results[index];
          return ListTile(
            title: Text(
              vendor,
              style: const TextStyle(color: Colors.white),
            ),
            onTap: () => close(context, vendor),
          );
        },
      ),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final results = _filteredVendors();

    return Container(
      color: Colors.black,
      child: ListView.builder(
        itemCount: results.length,
        itemBuilder: (context, index) {
          final vendor = results[index];
          return ListTile(
            leading: const Icon(
              Icons.storefront_outlined,
              color: Colors.white70,
            ),
            title: Text(
              vendor,
              style: const TextStyle(color: Colors.white),
            ),
            onTap: () => close(context, vendor),
          );
        },
      ),
    );
  }

  List<String> _filteredVendors() {
    if (query.trim().isEmpty) return vendors;

    return vendors
        .where(
          (vendor) =>
              vendor.toLowerCase().contains(query.trim().toLowerCase()),
        )
        .toList();
  }
}

class _CategoryPickerSheet extends StatelessWidget {
  const _CategoryPickerSheet({
    required this.categories,
    required this.selectedCategory,
  });

  final List<String> categories;
  final String? selectedCategory;

  IconData _iconForCategory(String category) {
    switch (category) {
      case 'Food':
        return Icons.restaurant_rounded;
      case 'Transportation':
        return Icons.directions_car_filled_rounded;
      case 'Rent':
        return Icons.home_rounded;
      case 'Shopping':
        return Icons.shopping_bag_rounded;
      case 'Subscription':
        return Icons.subscriptions_rounded;
      case 'Education':
        return Icons.menu_book_rounded;
      default:
        return Icons.category_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.72,
      minChildSize: 0.5,
      maxChildSize: 0.92,
      builder: (context, controller) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFFF3F1F8),
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 10),
              Container(
                width: 42,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.black26,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Select Category',
                style: TextStyle(
                  color: Colors.black, 
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 18),
              Expanded(
                child: GridView.builder(
                  controller: controller,
                  padding: const EdgeInsets.fromLTRB(18, 8, 18, 24),
                  itemCount: categories.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 0.95,
                  ),
                  itemBuilder: (context, index) {
                    final category = categories[index];
                    final isSelected = category == selectedCategory;

                    return GestureDetector(
                      onTap: () => Navigator.pop(context, category),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFFE9E2FF)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected
                                ? const Color(0xFF8B5CF6)
                                : Colors.black12,
                            width: 1.2,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _iconForCategory(category),
                              size: 28,
                              color: const Color(0xFF8B5CF6),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              category,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}