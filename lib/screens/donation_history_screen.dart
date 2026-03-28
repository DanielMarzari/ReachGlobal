import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../nav.dart';
import '../theme.dart';

class DonationHistoryScreen extends StatefulWidget {
  const DonationHistoryScreen({Key? key}) : super(key: key);

  @override
  State<DonationHistoryScreen> createState() => _DonationHistoryScreenState();
}

class _DonationHistoryScreenState extends State<DonationHistoryScreen> {
  String _filterType = 'All';

  final List<Map<String, dynamic>> _donations = [
    {
      'id': '001',
      'date': '2026-03-25',
      'type': 'Cash',
      'amount': 500,
      'designation': 'Dallas Tornado Relief',
      'paymentMethod': 'Credit Card',
      'receiptNumber': 'RCP-2026-001',
    },
    {
      'id': '002',
      'date': '2026-03-20',
      'type': 'Materials',
      'amount': 0,
      'description': '50 boxes of cleaning supplies',
      'designation': 'General Fund',
    },
    {
      'id': '003',
      'date': '2026-03-18',
      'type': 'Cash',
      'amount': 1200,
      'designation': 'Dallas Tornado Relief',
      'paymentMethod': 'Bank Transfer',
      'receiptNumber': 'RCP-2026-003',
    },
    {
      'id': '004',
      'date': '2026-03-15',
      'type': 'Materials',
      'amount': 0,
      'description': '20 cases of bottled water',
      'designation': 'Emergency Supplies',
    },
    {
      'id': '005',
      'date': '2026-03-10',
      'type': 'Cash',
      'amount': 250,
      'designation': 'General Fund',
      'paymentMethod': 'Credit Card',
      'receiptNumber': 'RCP-2026-005',
    },
    {
      'id': '006',
      'date': '2026-03-05',
      'type': 'Cash',
      'amount': 1000,
      'designation': 'Gulf Coast Hurricane Response',
      'paymentMethod': 'Check',
      'receiptNumber': 'RCP-2026-006',
    },
    {
      'id': '007',
      'date': '2026-02-28',
      'type': 'Materials',
      'amount': 0,
      'description': 'First aid kits and medical supplies',
      'designation': 'Medical Relief',
    },
    {
      'id': '008',
      'date': '2026-02-20',
      'type': 'Cash',
      'amount': 750,
      'designation': 'General Fund',
      'paymentMethod': 'Credit Card',
      'receiptNumber': 'RCP-2026-008',
    },
  ];

  List<Map<String, dynamic>> get _filteredDonations {
    if (_filterType == 'All') {
      return _donations;
    }
    return _donations.where((d) => d['type'] == _filterType).toList();
  }

  int get _totalCash {
    return _donations
        .where((d) => d['type'] == 'Cash')
        .fold<int>(0, (sum, d) => sum + (d['amount'] as int));
  }

  int get _materialsCount {
    return _donations.where((d) => d['type'] == 'Materials').length;
  }

  void _showDonationReceipt(Map<String, dynamic> donation) {
    if (donation['type'] == 'Materials') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No receipt available for material donations'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Donation Receipt',
                style: context.textStyles.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: AppSpacing.md),
              _buildReceiptRow('Receipt Number', donation['receiptNumber']),
              _buildReceiptRow('Date', donation['date']),
              _buildReceiptRow('Amount', '\$${donation['amount']}'),
              _buildReceiptRow('Payment Method', donation['paymentMethod']),
              _buildReceiptRow('Designation', donation['designation']),
              SizedBox(height: AppSpacing.md),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    context.pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Receipt downloading...'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                  icon: const Icon(Icons.download),
                  label: const Text('Download Receipt'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1B3A5C),
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildReceiptRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: context.textStyles.labelSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: AppSpacing.xs),
        Text(
          value,
          style: context.textStyles.bodySmall,
        ),
        SizedBox(height: AppSpacing.md),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(AppRoutes.churchDashboard),
        ),
        title: Text(
          'Giving History',
          style: context.textStyles.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Summary Card
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
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
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildSummaryItem(
                          'Total Given',
                          '\$${_totalCash}',
                          'Cash',
                        ),
                      ),
                      SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: _buildSummaryItem(
                          'Materials',
                          '$_materialsCount',
                          'Items',
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: AppSpacing.md),
                  Divider(color: Colors.grey[300]),
                  SizedBox(height: AppSpacing.md),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Combined Total',
                        style: context.textStyles.labelSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '\$${_totalCash}',
                        style: context.textStyles.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1B3A5C),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: AppSpacing.sm),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Year-to-Date',
                        style: context.textStyles.labelSmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                      Text(
                        '\$${_totalCash}',
                        style: context.textStyles.labelSmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: AppSpacing.lg),

            // Filter Chips
            Wrap(
              spacing: AppSpacing.sm,
              children: ['All', 'Cash', 'Materials'].map((type) {
                return FilterChip(
                  label: Text(type),
                  selected: _filterType == type,
                  onSelected: (selected) {
                    setState(() => _filterType = selected ? type : 'All');
                  },
                );
              }).toList(),
            ),
            SizedBox(height: AppSpacing.lg),

            // Donations List
            Text(
              'Donations',
              style: context.textStyles.labelSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: AppSpacing.sm),
            Column(
              children: _filteredDonations.map((donation) {
                return Container(
                  margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                  padding: const EdgeInsets.all(AppSpacing.md),
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
                  child: InkWell(
                    onTap: () => _showDonationReceipt(donation),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(AppSpacing.sm),
                          decoration: BoxDecoration(
                            color: donation['type'] == 'Cash'
                                ? const Color(0xFF4A6741)
                                : const Color(0xFF2E7D8C),
                            borderRadius: BorderRadius.circular(AppRadius.sm),
                          ),
                          child: Icon(
                            donation['type'] == 'Cash'
                                ? Icons.attach_money
                                : Icons.inventory,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    donation['type'],
                                    style: context.textStyles.titleSmall
                                        ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  if (donation['type'] == 'Cash')
                                    Text(
                                      '\$${donation['amount']}',
                                      style: context.textStyles.titleSmall
                                          ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: const Color(0xFF1B3A5C),
                                      ),
                                    ),
                                ],
                              ),
                              SizedBox(height: AppSpacing.xs),
                              Text(
                                donation['designation'] ?? '',
                                style: context.textStyles.bodySmall?.copyWith(
                                  color: Colors.grey[600],
                                ),
                              ),
                              SizedBox(height: AppSpacing.xs),
                              if (donation['type'] == 'Materials')
                                Text(
                                  donation['description'],
                                  style: context.textStyles.bodySmall?.copyWith(
                                    color: Colors.grey[700],
                                  ),
                                ),
                              SizedBox(height: AppSpacing.xs),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    donation['date'],
                                    style: context.textStyles.labelSmall
                                        ?.copyWith(
                                      color: Colors.grey[500],
                                    ),
                                  ),
                                  if (donation['type'] == 'Cash')
                                    Icon(
                                      Icons.receipt,
                                      size: 16,
                                      color: Colors.grey[400],
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            SizedBox(height: AppSpacing.lg),

            // Year-End Tax Summary
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(AppRadius.lg),
                border: Border.all(color: Theme.of(context).dividerColor),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Year-End Tax Summary',
                    style: context.textStyles.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: AppSpacing.md),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '2026 Total',
                        style: context.textStyles.bodySmall,
                      ),
                      Text(
                        '\$${_totalCash}',
                        style: context.textStyles.labelSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: AppSpacing.md),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Generating tax summary letter...'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1B3A5C),
                        foregroundColor: Colors.white,
                      ),
                      child: Text(
                        'Request Summary Letter',
                        style: context.textStyles.labelSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push(AppRoutes.donationFlow),
        backgroundColor: const Color(0xFF1B3A5C),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, String unit) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: context.textStyles.labelSmall?.copyWith(
            color: Colors.grey[600],
          ),
        ),
        SizedBox(height: AppSpacing.xs),
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              value,
              style: context.textStyles.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1B3A5C),
              ),
            ),
            SizedBox(width: AppSpacing.xs),
            Text(
              unit,
              style: context.textStyles.labelSmall?.copyWith(
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
