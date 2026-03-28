import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../nav.dart';
import '../theme.dart';

class ChurchDashboardScreen extends StatefulWidget {
  const ChurchDashboardScreen({Key? key}) : super(key: key);

  @override
  State<ChurchDashboardScreen> createState() => _ChurchDashboardScreenState();
}

class _ChurchDashboardScreenState extends State<ChurchDashboardScreen> {
  int _selectedTabIndex = 0;

  final List<Map<String, dynamic>> _teamMembers = [
    {
      'name': 'Sarah Johnson',
      'email': 'sarah@email.com',
      'onboarding': true,
      'skills': ['General Labor', 'Meals & Support'],
      'arrival': '2026-03-28',
      'departure': '2026-04-04',
      'checkedIn': true,
    },
    {
      'name': 'Michael Chen',
      'email': 'michael@email.com',
      'onboarding': true,
      'skills': ['Carpentry', 'Roofing'],
      'arrival': '2026-03-29',
      'departure': '2026-04-05',
      'checkedIn': true,
    },
    {
      'name': 'Emma Rodriguez',
      'email': 'emma@email.com',
      'onboarding': false,
      'skills': ['General Labor', 'Logistics'],
      'arrival': '2026-03-30',
      'departure': '2026-04-06',
      'checkedIn': false,
    },
    {
      'name': 'David Thompson',
      'email': 'david@email.com',
      'onboarding': true,
      'skills': ['Electrical', 'Plumbing'],
      'arrival': '2026-03-28',
      'departure': '2026-04-03',
      'checkedIn': true,
    },
    {
      'name': 'Lisa Martinez',
      'email': 'lisa@email.com',
      'onboarding': false,
      'skills': ['Medical', 'Meals & Support'],
      'arrival': '2026-03-31',
      'departure': '2026-04-07',
      'checkedIn': false,
    },
  ];

  final List<Map<String, dynamic>> _donations = [
    {
      'date': '2026-03-20',
      'type': 'Cash',
      'amount': 500,
      'designation': 'Dallas Tornado Relief',
    },
    {
      'date': '2026-03-15',
      'type': 'Materials',
      'amount': 0,
      'description': '50 boxes of cleaning supplies',
      'designation': 'General Fund',
    },
    {
      'date': '2026-03-10',
      'type': 'Cash',
      'amount': 1200,
      'designation': 'Dallas Tornado Relief',
    },
  ];

  final List<Map<String, dynamic>> _activeEvents = [
    {
      'name': 'Dallas Tornado Relief',
      'volunteers': 5,
      'startDate': '2026-03-28',
      'endDate': '2026-04-15',
    },
    {
      'name': 'Gulf Coast Hurricane Response',
      'volunteers': 3,
      'startDate': '2026-04-01',
      'endDate': '2026-04-20',
    },
  ];

  void _showTeamMemberDetails(Map<String, dynamic> member) {
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
                member['name'],
                style: context.textStyles.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: AppSpacing.sm),
              Text(
                member['email'],
                style: context.textStyles.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(height: AppSpacing.md),
              Text(
                'Skills',
                style: context.textStyles.labelSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: AppSpacing.xs),
              Wrap(
                spacing: AppSpacing.xs,
                children: (member['skills'] as List<String>)
                    .map(
                      (skill) => Chip(
                        label: Text(
                          skill,
                          style: context.textStyles.labelSmall?.copyWith(
                            fontSize: 11,
                          ),
                        ),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    )
                    .toList(),
              ),
              SizedBox(height: AppSpacing.md),
              Text(
                'Availability: ${member['arrival']} to ${member['departure']}',
                style: context.textStyles.bodySmall,
              ),
              SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        context.pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Onboarding marked complete'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4A6741),
                      ),
                      child: Text(
                        'Mark Onboarding Complete',
                        style: context.textStyles.labelSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        context.pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Member removed from team'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFBA1A1A),
                      ),
                      child: Text(
                        'Remove',
                        style: context.textStyles.labelSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _showInviteDialog() {
    late TextEditingController emailController;
    emailController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'Invite Member',
            style: context.textStyles.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          content: TextField(
            controller: emailController,
            decoration: InputDecoration(
              hintText: 'email@example.com',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
            ),
            keyboardType: TextInputType.emailAddress,
          ),
          actions: [
            TextButton(
              onPressed: () => context.pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                context.pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Invitation sent!'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              child: const Text('Send Invite'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Card
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'First Baptist Church of Dallas',
                  style: context.textStyles.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: AppSpacing.xs),
                Text(
                  'Active in 2 relief events',
                  style: context.textStyles.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: AppSpacing.md),

          // Stats Row
          Row(
            children: [
              Expanded(
                child: _buildStatCard('5', 'Team Members'),
              ),
              SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _buildStatCard('80%', 'Onboarding'),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(
                child: _buildStatCard('320', 'Hours'),
              ),
              SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _buildStatCard('\$2,200', 'Donations'),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.lg),

          // Active Events
          Text(
            'Active Events',
            style: context.textStyles.labelSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: AppSpacing.sm),
          Column(
            children: _activeEvents.map((event) {
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event['name'],
                      style: context.textStyles.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: AppSpacing.xs),
                    Text(
                      '${event['volunteers']} volunteers • ${event['startDate']} to ${event['endDate']}',
                      style: context.textStyles.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
          SizedBox(height: AppSpacing.lg),

          // Quick Actions
          Text(
            'Quick Actions',
            style: context.textStyles.labelSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: AppSpacing.sm),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => context.go(AppRoutes.teamRoster),
              icon: const Icon(Icons.people),
              label: const Text('Manage Team'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1B3A5C),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
              ),
            ),
          ),
          SizedBox(height: AppSpacing.sm),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => context.push(AppRoutes.eventOverview),
              icon: const Icon(Icons.info),
              label: const Text('View Project'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E7D8C),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
              ),
            ),
          ),
          SizedBox(height: AppSpacing.sm),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => context.go(AppRoutes.donationHistory),
              icon: const Icon(Icons.history),
              label: const Text('View Donations'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4A6741),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String value, String label) {
    return Container(
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
          Text(
            value,
            style: context.textStyles.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1B3A5C),
            ),
          ),
          SizedBox(height: AppSpacing.xs),
          Text(
            label,
            style: context.textStyles.labelSmall?.copyWith(
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMyTeamTab() {
    return Stack(
      children: [
        ListView.builder(
          padding: const EdgeInsets.all(AppSpacing.md),
          itemCount: _teamMembers.length,
          itemBuilder: (context, index) {
            final member = _teamMembers[index];
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
                onTap: () => _showTeamMemberDetails(member),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    member['name'],
                                    style: context.textStyles.titleSmall?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(width: AppSpacing.xs),
                                  Icon(
                                    member['onboarding'] ? Icons.check_circle : Icons.pending,
                                    size: 16,
                                    color: member['onboarding']
                                        ? const Color(0xFF4A6741)
                                        : Colors.orange,
                                  ),
                                ],
                              ),
                              SizedBox(height: AppSpacing.xs),
                              Text(
                                member['email'],
                                style: context.textStyles.bodySmall?.copyWith(
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (member['checkedIn'])
                          Chip(
                            label: const Text('Checked In'),
                            labelStyle: context.textStyles.labelSmall?.copyWith(
                              fontSize: 11,
                              color: Colors.white,
                            ),
                            backgroundColor: const Color(0xFF4A6741),
                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                      ],
                    ),
                    SizedBox(height: AppSpacing.sm),
                    Wrap(
                      spacing: AppSpacing.xs,
                      children: (member['skills'] as List<String>)
                          .map(
                            (skill) => Chip(
                              label: Text(
                                skill,
                                style: context.textStyles.labelSmall?.copyWith(
                                  fontSize: 11,
                                ),
                              ),
                              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                          )
                          .toList(),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        Positioned(
          bottom: AppSpacing.md,
          right: AppSpacing.md,
          child: FloatingActionButton(
            onPressed: _showInviteDialog,
            backgroundColor: const Color(0xFF1B3A5C),
            child: const Icon(Icons.add),
          ),
        ),
      ],
    );
  }

  Widget _buildDonationsTab() {
    return Stack(
      children: [
        ListView.builder(
          padding: const EdgeInsets.all(AppSpacing.md),
          itemCount: _donations.length,
          itemBuilder: (context, index) {
            final donation = _donations[index];
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
                      donation['type'] == 'Cash' ? Icons.attach_money : Icons.inventory,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          donation['type'],
                          style: context.textStyles.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: AppSpacing.xs),
                        Text(
                          donation['designation'],
                          style: context.textStyles.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                        SizedBox(height: AppSpacing.xs),
                        Text(
                          donation['date'],
                          style: context.textStyles.labelSmall?.copyWith(
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    donation['type'] == 'Cash'
                        ? '\$${donation['amount']}'
                        : donation['description'] ?? '',
                    style: context.textStyles.labelSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.right,
                  ),
                ],
              ),
            );
          },
        ),
        Positioned(
          bottom: AppSpacing.md,
          right: AppSpacing.md,
          child: FloatingActionButton(
            onPressed: () => context.push(AppRoutes.donationFlow),
            backgroundColor: const Color(0xFF1B3A5C),
            child: const Icon(Icons.add),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'My Church Dashboard',
          style: context.textStyles.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () => context.push(AppRoutes.userProfile),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => context.go(AppRoutes.login),
            tooltip: "Logout",
          ),
        ],
      ),
      body: IndexedStack(
        index: _selectedTabIndex,
        children: [
          _buildOverviewTab(),
          _buildMyTeamTab(),
          _buildDonationsTab(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedTabIndex,
        onTap: (index) => setState(() => _selectedTabIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Overview',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'My Team',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Donations',
          ),
        ],
      ),
    );
  }
}
