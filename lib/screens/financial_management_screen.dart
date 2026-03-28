import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme.dart';
import '../nav.dart';

class FinancialManagementScreen extends StatefulWidget {
  const FinancialManagementScreen({Key? key}) : super(key: key);

  @override
  State<FinancialManagementScreen> createState() =>
      _FinancialManagementScreenState();
}

class _FinancialManagementScreenState extends State<FinancialManagementScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<Map<String, dynamic>> _mockCashDonations = [
    {
      'id': '1',
      'donor': 'Springfield Rotary Club',
      'amount': 5000.00,
      'date': '2025-03-20',
      'designation': 'general',
      'receipt': 'sent',
    },
    {
      'id': '2',
      'donor': 'John Smith',
      'amount': 500.00,
      'date': '2025-03-19',
      'designation': 'specific',
      'receipt': 'pending',
    },
    {
      'id': '3',
      'donor': 'First National Bank',
      'amount': 10000.00,
      'date': '2025-03-18',
      'designation': 'general',
      'receipt': 'sent',
    },
    {
      'id': '4',
      'donor': 'Sarah Martinez',
      'amount': 250.00,
      'date': '2025-03-17',
      'designation': 'specific',
      'receipt': 'sent',
    },
  ];

  final List<Map<String, dynamic>> _mockMaterialDonations = [
    {
      'id': '1',
      'donor': 'Home Depot - Springfield',
      'item': 'Lumber & Materials',
      'quantity': 150,
      'unit': 'pieces',
      'value': 3500.00,
      'condition': 'new',
      'date': '2025-03-20',
    },
    {
      'id': '2',
      'donor': 'Local Roofing Supply',
      'item': 'Roofing Shingles',
      'quantity': 12,
      'unit': 'squares',
      'value': 1200.00,
      'condition': 'new',
      'date': '2025-03-19',
    },
    {
      'id': '3',
      'donor': 'Construction Equipment Co.',
      'item': 'Power Tools (Various)',
      'quantity': 8,
      'unit': 'units',
      'value': 2000.00,
      'condition': 'used - excellent',
      'date': '2025-03-18',
    },
    {
      'id': '4',
      'donor': 'Local Church',
      'item': 'Work Gloves & PPE',
      'quantity': 200,
      'unit': 'units',
      'value': 400.00,
      'condition': 'new',
      'date': '2025-03-17',
    },
  ];

  final List<Map<String, dynamic>> _mockExpenses = [
    {
      'id': '1',
      'category': 'materials',
      'amount': 1250.00,
      'description': 'Plywood, nails, and hardware for project 1247',
      'date': '2025-03-20',
      'logged_by': 'John Martinez',
    },
    {
      'id': '2',
      'category': 'equipment',
      'amount': 450.00,
      'description': 'Rental of dumpster for debris removal',
      'date': '2025-03-19',
      'logged_by': 'Sarah Chen',
    },
    {
      'id': '3',
      'category': 'lodging',
      'amount': 800.00,
      'description': 'Hotel accommodations for volunteer team',
      'date': '2025-03-18',
      'logged_by': 'Emily Rodriguez',
    },
    {
      'id': '4',
      'category': 'food',
      'amount': 350.00,
      'description': 'Meals for 25 volunteers on site',
      'date': '2025-03-18',
      'logged_by': 'Emily Rodriguez',
    },
    {
      'id': '5',
      'category': 'transport',
      'amount': 200.00,
      'description': 'Fuel for supply transport',
      'date': '2025-03-17',
      'logged_by': 'Michael O\'Brien',
    },
    {
      'id': '6',
      'category': 'admin',
      'amount': 150.00,
      'description': 'Printing and office supplies',
      'date': '2025-03-16',
      'logged_by': 'John Martinez',
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  double get _totalRaised {
    double cash = _mockCashDonations
        .fold(0, (sum, item) => sum + (item['amount'] as double));
    double materials = _mockMaterialDonations
        .fold(0, (sum, item) => sum + (item['value'] as double));
    return cash + materials;
  }

  double get _totalSpent {
    return _mockExpenses
        .fold(0, (sum, item) => sum + (item['amount'] as double));
  }

  double get _netSurplus {
    return _totalRaised - _totalSpent;
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'materials':
        return const Color(0xFF795548);
      case 'equipment':
        return const Color(0xFFF57C00);
      case 'lodging':
        return const Color(0xFF1976D2);
      case 'food':
        return const Color(0xFF7B1FA2);
      case 'transport':
        return const Color(0xFF00796B);
      case 'admin':
        return const Color(0xFF616161);
      default:
        return const Color(0xFF999999);
    }
  }

  String _getCategoryLabel(String category) {
    switch (category) {
      case 'materials':
        return 'Materials';
      case 'equipment':
        return 'Equipment';
      case 'lodging':
        return 'Lodging';
      case 'food':
        return 'Food';
      case 'transport':
        return 'Transport';
      case 'admin':
        return 'Admin';
      default:
        return category;
    }
  }

  Color _getReceiptColor(String receipt) {
    return receipt == 'sent'
        ? const Color(0xFF4A6741)
        : const Color(0xFFC0582A);
  }

  String _getReceiptLabel(String receipt) {
    return receipt == 'sent' ? 'Sent' : 'Pending';
  }

  Color _getConditionColor(String condition) {
    return condition.contains('excellent')
        ? const Color(0xFF4A6741)
        : const Color(0xFF4A90E2);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Financial',
          style: context.textStyles.titleMedium?.bold,
        ),
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Cash Donations'),
            Tab(text: 'Material Donations'),
            Tab(text: 'Expenses'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Summary cards
          Padding(
            padding: EdgeInsets.all(AppSpacing.md),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildSummaryCard(
                        context,
                        'Total Raised',
                        '\$${_totalRaised.toStringAsFixed(2)}',
                        const Color(0xFF4A6741),
                      ),
                    ),
                    SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: _buildSummaryCard(
                        context,
                        'Total Spent',
                        '\$${_totalSpent.toStringAsFixed(2)}',
                        const Color(0xFFC0582A),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: AppSpacing.md),
                _buildSummaryCard(
                  context,
                  'Net Surplus',
                  '\$${_netSurplus.toStringAsFixed(2)}',
                  _netSurplus >= 0
                      ? const Color(0xFF4A6741)
                      : const Color(0xFFBA1A1A),
                ),
              ],
            ),
          ),
          // Tab content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Cash Donations Tab
                ListView.builder(
                  padding: EdgeInsets.all(AppSpacing.md),
                  itemCount: _mockCashDonations.length,
                  itemBuilder: (context, index) {
                    final donation = _mockCashDonations[index];

                    return Container(
                      margin: EdgeInsets.only(bottom: AppSpacing.md),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius:
                            BorderRadius.circular(AppRadius.lg),
                        border: Border.all(
                            color: Theme.of(context).dividerColor),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x0D000000),
                            blurRadius: 2,
                            offset: Offset(0, 1),
                          )
                        ],
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(AppSpacing.md),
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        donation['donor'],
                                        style: context.textStyles
                                            .labelSmall
                                            ?.bold,
                                      ),
                                      SizedBox(
                                          height: AppSpacing.xs),
                                      Text(
                                        donation['date'],
                                        style: context.textStyles
                                            .bodySmall,
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  '\$${donation['amount'].toStringAsFixed(2)}',
                                  style: context.textStyles
                                      .titleMedium
                                      ?.bold,
                                ),
                              ],
                            ),
                            SizedBox(height: AppSpacing.md),
                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: AppSpacing.sm,
                                    vertical: AppSpacing.xs,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .primary
                                        .withOpacity(0.15),
                                    borderRadius:
                                        BorderRadius.circular(
                                      AppRadius.sm,
                                    ),
                                  ),
                                  child: Text(
                                    donation['designation']
                                            .toString()
                                            .toUpperCase() ==
                                        'GENERAL'
                                        ? 'General Fund'
                                        : 'Specific Project',
                                    style: context.textStyles
                                        .labelSmall
                                        ?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .primary,
                                      fontWeight:
                                          FontWeight.bold,
                                      fontSize: 11,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: AppSpacing.sm,
                                    vertical: AppSpacing.xs,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _getReceiptColor(
                                            donation['receipt'])
                                        .withOpacity(0.15),
                                    borderRadius:
                                        BorderRadius.circular(
                                      AppRadius.sm,
                                    ),
                                  ),
                                  child: Text(
                                    _getReceiptLabel(
                                        donation['receipt']),
                                    style: context.textStyles
                                        .labelSmall
                                        ?.copyWith(
                                      color: _getReceiptColor(
                                          donation['receipt']),
                                      fontWeight:
                                          FontWeight.bold,
                                      fontSize: 11,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                // Material Donations Tab
                ListView.builder(
                  padding: EdgeInsets.all(AppSpacing.md),
                  itemCount: _mockMaterialDonations.length,
                  itemBuilder: (context, index) {
                    final donation = _mockMaterialDonations[index];

                    return Container(
                      margin: EdgeInsets.only(bottom: AppSpacing.md),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius:
                            BorderRadius.circular(AppRadius.lg),
                        border: Border.all(
                            color: Theme.of(context).dividerColor),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x0D000000),
                            blurRadius: 2,
                            offset: Offset(0, 1),
                          )
                        ],
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(AppSpacing.md),
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        donation['donor'],
                                        style: context.textStyles
                                            .labelSmall
                                            ?.bold,
                                      ),
                                      SizedBox(
                                          height: AppSpacing.xs),
                                      Text(
                                        donation['item'],
                                        style: context.textStyles
                                            .bodySmall,
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      '\$${donation['value'].toStringAsFixed(2)}',
                                      style: context.textStyles
                                          .titleMedium
                                          ?.bold,
                                    ),
                                    Text(
                                      '${donation['quantity']} ${donation['unit']}',
                                      style: context.textStyles
                                          .labelSmall,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            SizedBox(height: AppSpacing.md),
                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: AppSpacing.sm,
                                    vertical: AppSpacing.xs,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _getConditionColor(
                                            donation['condition'])
                                        .withOpacity(0.15),
                                    borderRadius:
                                        BorderRadius.circular(
                                      AppRadius.sm,
                                    ),
                                  ),
                                  child: Text(
                                    donation['condition'],
                                    style: context.textStyles
                                        .labelSmall
                                        ?.copyWith(
                                      color: _getConditionColor(
                                          donation['condition']),
                                      fontWeight:
                                          FontWeight.bold,
                                      fontSize: 11,
                                    ),
                                  ),
                                ),
                                Text(
                                  'Received: ${donation['date']}',
                                  style:
                                      context.textStyles.bodySmall,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                // Expenses Tab
                ListView.builder(
                  padding: EdgeInsets.all(AppSpacing.md),
                  itemCount: _mockExpenses.length,
                  itemBuilder: (context, index) {
                    final expense = _mockExpenses[index];

                    return Container(
                      margin: EdgeInsets.only(bottom: AppSpacing.md),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius:
                            BorderRadius.circular(AppRadius.lg),
                        border: Border.all(
                            color: Theme.of(context).dividerColor),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x0D000000),
                            blurRadius: 2,
                            offset: Offset(0, 1),
                          )
                        ],
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(AppSpacing.md),
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        expense['description'],
                                        style: context.textStyles
                                            .labelSmall
                                            ?.bold,
                                        maxLines: 2,
                                        overflow:
                                            TextOverflow.ellipsis,
                                      ),
                                      SizedBox(
                                          height: AppSpacing.xs),
                                      Text(
                                        expense['date'],
                                        style: context.textStyles
                                            .bodySmall,
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  '\$${expense['amount'].toStringAsFixed(2)}',
                                  style: context.textStyles
                                      .titleMedium
                                      ?.bold,
                                ),
                              ],
                            ),
                            SizedBox(height: AppSpacing.md),
                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: AppSpacing.sm,
                                    vertical: AppSpacing.xs,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _getCategoryColor(
                                            expense['category'])
                                        .withOpacity(0.15),
                                    borderRadius:
                                        BorderRadius.circular(
                                      AppRadius.sm,
                                    ),
                                  ),
                                  child: Text(
                                    _getCategoryLabel(
                                        expense['category']),
                                    style: context.textStyles
                                        .labelSmall
                                        ?.copyWith(
                                      color: _getCategoryColor(
                                          expense['category']),
                                      fontWeight:
                                          FontWeight.bold,
                                      fontSize: 11,
                                    ),
                                  ),
                                ),
                                Text(
                                  'By: ${expense['logged_by']}',
                                  style:
                                      context.textStyles.bodySmall,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Add new expense')),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSummaryCard(
    BuildContext context,
    String label,
    String value,
    Color color,
  ) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: Theme.of(context).dividerColor),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 2,
            offset: Offset(0, 1),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 20,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              SizedBox(width: AppSpacing.sm),
              Text(
                label,
                style: context.textStyles.labelSmall,
              ),
            ],
          ),
          SizedBox(height: AppSpacing.sm),
          Text(
            value,
            style: context.textStyles.titleMedium?.bold,
          ),
        ],
      ),
    );
  }
}
