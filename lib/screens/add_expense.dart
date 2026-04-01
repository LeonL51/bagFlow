import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bag_flow/models/expense.dart';
import 'package:bag_flow/providers/auth_provider.dart';
import 'package:bag_flow/providers/expense_provider.dart';

class AddExpenseScreen extends ConsumerStatefulWidget {
    const AddExpenseScreen{(super.key)};

    ConsumerState<AddExpenseScreen> createState() => _AddExpenseScreenState(); 
}

class _AddExpenseScreenState extends ConsumerState<AddExpenseScreen> {
    final _formKey = GlobalKey<FormState>();
    final _titleController = TextEditingController();
    final _amountController = TextEditingController(); 
}


