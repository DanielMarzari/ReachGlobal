import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme.dart';
import '../nav.dart';

class MaterialsInventoryScreen extends StatefulWidget {
  const MaterialsInventoryScreen({Key? key}) : super(key: key);

  @override
  State<MaterialsInventoryScreen> createState() =>
      _MaterialsInventoryScreenState();
}

class _MaterialsInventoryScreenState extends State<MaterialsInventoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<Map<String, dynamic>> _mockNeeds = [
    {
      'id': '1',
      'name': 'Lumber (2x4x8)',
      'needed': 50,
      'fulfilled': 30,
      'unit': 'pieces',
      'project': '1247 Maple Street',
      'status': 'partially_met',
    },
    {
      'id': '2',
      'name': 'Tarps (10x12)',
      'needed': 12,
      'fulfilled': 8,
      'unit': 'pieces',
      'project': '523 Oak Avenue',
      'status': 'partially_met',
    },
    {
      'id': '3',
      'name': 'Drywall (4x8)',
      'needed': 20,
      'fulfilled': 0,
      'unit': 'sheets',
      'project': '891 Elm Drive',
      'status': 'needed',
    },
    {
      'id': '4',
      'name': 'Roofing Shingles',
      'needed': 8,
      'fulfilled': 8,
      'unit': 'squares',
      'project': '2156 Pine Road',
      'status': 'fulfilled',
    },
    {
      'id': '5',
      'name': 'Nails & Fasteners Assort.',
      'needed': 15,
      'fulfilled': 10,
      'unit': 'boxes',
      'project': '1247 Maple Street',
      'status': 'partially_met',
    },
  ];

  final List<Map<String, dynamic>> _mockInventory = [
    {
      'id': '1',
      'name': 'Generators (5kW)',
      'quantity': 3,
      'unit': 'units',
      'location': 'Tool Shed A',
      'received': '2025-03-15',
    },
    {
      'id': '2',
      'name': 'Work Gloves',
      'quantity': 120,
      'unit': 'pairs',
      'location': 'Supply Room',
      'received': '2025-03-18',
    },
    {
      'id': '3',
      'name': 'Safety Helmets',
      'quantity': 45,
      'unit': 'units',
      'location': 'Supply Room',
      'received': '2025-03-10',
    },
    {
      'id': '4',
      'name': 'Power Drills',
      'quantity': 8,
      'unit': 'units',
      'location': 'Tool Shed A',
      'received': '2025-03-20',
    },
    {
      'id': '5',
      'name': 'Circular Saws',
      'quantity': 5,
      'unit': 'units',
      'location': 'Tool Shed B',
      'received': '2025-03-19',
    },
    {
      'id': '6',
      'name': 'Rope & Cordage',
      'quantity': 25,
      'unit': 'spools',
      'location': 'Tool Shed A',
      'received': '2025-03-17',
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'needed':
        return const Color(0xFFBA1A1A);
      case 'partially_met':
        return const Color(0xFFC0582A);
      case 'fulfilled':
        return const Color(0xFF4A6741);
      default:
        return const Color(0xFF999999);
    }
  }

  String _getStatusLabel(String status) {
    switch (status) {
      case 'needed':
        return 'Needed';
      case 'partially_met':
        return 'Partially Met';
      case 'fulfilled':
        return 'Fulfilled';
      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Materials & Inventory',
          style: context.textStyles.titleMedium?.bold,
        ),
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Needs'),
            Tab(text: 'Inventory'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Needs Tab
          ListView.builder(
            padding: EdgeInsets.all(AppSpacing.md),
            itemCount: _mockNeeds.length,
            itemBuilder: (context, index) {
              final need = _mockNeeds[index];
              final progress =
                  (need['fulfilled'] as int) / (need['needed'] as int);

              return Container(
                margin: EdgeInsets.only(bottom: AppSpacing.md),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  border:
                      Border.all(color: Theme.of(context).dividerColor),
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
                    crossAxisAlignment: CrossAxisAlignment.start,
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
                                  need['name'],
                                  style:
                                      context.textStyles.labelSmall
                                          ?.bold,
                                ),
                                SizedBox(height: AppSpacing.xs),
                                Text(
                                  need['project'],
                                  style:
                                      context.textStyles.bodySmall,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: AppSpacing.sm,
                              vertical: AppSpacing.xs,
                            ),
                            decoration: BoxDecoration(
                              color: _getStatusColor(need['status'])
                                  .withOpacity(0.15),
                              borderRadius: BorderRadius.circular(
                                  AppRadius.sm),
                            ),
                            child: Text(
                              _getStatusLabel(need['status']),
                              style: context.textStyles.labelSmall
                                  ?.copyWith(
                                color: _getStatusColor(
                                    need['status']),
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: AppSpacing.md),
                      // Progress bar
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${need['fulfilled']} / ${need['needed']} ${need['unit']}',
                                style: context.textStyles.labelSmall,
                              ),
                              Text(
                                '${(progress * 100).toStringAsFixed(0)}%',
                                style: context.textStyles.labelSmall
                                    ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: AppSpacing.sm),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(
                                AppRadius.sm),
                            child: LinearProgressIndicator(
                              value: progress,
                              minHeight: 8,
                              backgroundColor: Theme.of(context)
                                  .colorScheme
                                  .primary
                                  .withOpacity(0.2),
                              valueColor: AlwaysStoppedAnimation(
                                _getStatusColor(need['status']),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: AppSpacing.md),
                      // Action button
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () {
                            ScaffoldMessenger.of(context)
                                .showSnackBar(
                              SnackBar(
                                content: Text(
                                    'Marked "${need['name']}" as fulfilled'),
                              ),
                            );
                          },
                          icon: const Icon(Icons.check),
                          label: const Text('Mark Fulfilled'),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          // Inventory Tab
          ListView.builder(
            padding: EdgeInsets.all(AppSpacing.md),
            itemCount: _mockInventory.length,
            itemBuilder: (context, index) {
              final item = _mockInventory[index];

              return Container(
                margin: EdgeInsets.only(bottom: AppSpacing.md),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  border:
                      Border.all(color: Theme.of(context).dividerColor),
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
                    crossAxisAlignment: CrossAxisAlignment.start,
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
                                  item['name'],
                                  style:
                                      context.textStyles.labelSmall
                                          ?.bold,
                                ),
                                SizedBox(height: AppSpacing.xs),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.location_on,
                                      size: 14,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .primary
                                          .withOpacity(0.7),
                                    ),
                                    SizedBox(width: AppSpacing.xs),
                                    Text(
                                      item['location'],
                                      style: context.textStyles
                                          .bodySmall,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '${item['quantity']}',
                                style: context.textStyles
                                    .titleMedium
                                    ?.bold,
                              ),
                              Text(
                                item['unit'],
                                style: context.textStyles.labelSmall,
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: AppSpacing.md),
                      // Received date
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            size: 14,
                            color: Theme.of(context)
                                .colorScheme
                                .primary
                                .withOpacity(0.7),
                          ),
                          SizedBox(width: AppSpacing.xs),
                          Text(
                            'Received: ${item['received']}',
                            style: context.textStyles.labelSmall,
                          ),
                        ],
                      ),
                      SizedBox(height: AppSpacing.md),
                      // Action buttons
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(
                                  SnackBar(
                                    content: Text(
                                        'Allocate "${item['name']}" to project'),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.assignment),
                              label:
                                  const Text('Allocate to Project'),
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
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Log new donation')),
          );
        },
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 3,
        onTap: (index) {
          switch (index) {
            case 0: context.go(AppRoutes.staffDashboard); break;
            case 1: context.go(AppRoutes.staffProjects); break;
            case 2: context.go(AppRoutes.staffVolunteers); break;
            case 3: context.go(AppRoutes.staffMaterials); break;
            case 4: context.go(AppRoutes.staffFinancial); break;
            case 5: context.go(AppRoutes.staffReports); break;
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Dashboard"),
          BottomNavigationBarItem(icon: Icon(Icons.assignment), label: "Projects"),
          BottomNavigationBarItem(icon: Icon(Icons.groups), label: "Volunteers"),
          BottomNavigationBarItem(icon: Icon(Icons.inventory), label: "Materials"),
          BottomNavigationBarItem(icon: Icon(Icons.account_balance), label: "Financial"),
          BottomNavigationBarItem(icon: Icon(Icons.assessment), label: "Reports"),
        ],
      ),
    );
  }
}
