import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../nav.dart';
import '../theme.dart';

extension TextStyleContext on BuildContext {
  TextTheme get textStyles => Theme.of(this).textTheme;
}

class VolunteerRegistrationScreen extends StatefulWidget {
  const VolunteerRegistrationScreen({Key? key}) : super(key: key);

  @override
  State<VolunteerRegistrationScreen> createState() => _VolunteerRegistrationScreenState();
}

class _VolunteerRegistrationScreenState extends State<VolunteerRegistrationScreen> {
  late TextEditingController _fullNameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;

  DateTime? _startDate;
  DateTime? _endDate;
  String? _selectedEvent;
  String? _selectedHowHeardAboutUs;
  bool _agreeToContact = false;
  Set<String> _selectedSkills = {};

  final List<String> _disasterEvents = [
    'Dallas Tornado Relief 2026',
    'Gulf Coast Hurricane Response',
    'Midwest Flooding Initiative',
  ];

  final List<String> _skills = [
    'General Labor',
    'Carpentry',
    'Electrical',
    'Plumbing',
    'Roofing',
    'Demo/Debris',
    'Meals & Support',
    'Logistics',
    'Medical',
  ];

  final List<String> _howHeardAboutUs = [
    'Social Media',
    'Church',
    'Friend or Family',
    'News/Media',
    'Website Search',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    _fullNameController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2027),
    );
    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  void _handleSubmit() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Thank You!',
            style: context.textStyles.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Your volunteer interest has been submitted.',
                style: context.textStyles.bodyMedium,
              ),
              SizedBox(height: AppSpacing.md),
              Text(
                "We'll send you an email with next steps and how you can help with the relief effort.",
                style: context.textStyles.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                context.pop();
                context.go(AppRoutes.home);
              },
              child: const Text('Done'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Volunteer Interest Form',
          style: context.textStyles.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Full Name
            Text(
              'Full Name',
              style: context.textStyles.labelSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: AppSpacing.xs),
            TextField(
              controller: _fullNameController,
              decoration: InputDecoration(
                hintText: 'John Doe',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
              ),
            ),
            SizedBox(height: AppSpacing.md),

            // Email
            Text(
              'Email',
              style: context.textStyles.labelSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: AppSpacing.xs),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                hintText: 'you@example.com',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: AppSpacing.md),

            // Phone
            Text(
              'Phone',
              style: context.textStyles.labelSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: AppSpacing.xs),
            TextField(
              controller: _phoneController,
              decoration: InputDecoration(
                hintText: '(555) 123-4567',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
              ),
              keyboardType: TextInputType.phone,
            ),
            SizedBox(height: AppSpacing.md),

            // Disaster Event Dropdown
            Text(
              'Which disaster event?',
              style: context.textStyles.labelSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: AppSpacing.xs),
            DropdownButtonFormField<String>(
              value: _selectedEvent,
              items: _disasterEvents.map((event) {
                return DropdownMenuItem(
                  value: event,
                  child: Text(event),
                );
              }).toList(),
              onChanged: (value) {
                setState(() => _selectedEvent = value);
              },
              decoration: InputDecoration(
                hintText: 'Select an event',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
              ),
            ),
            SizedBox(height: AppSpacing.md),

            // Availability Start Date
            Text(
              'Available from',
              style: context.textStyles.labelSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: AppSpacing.xs),
            InkWell(
              onTap: () => _selectDate(context, true),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _startDate == null
                          ? 'Select start date'
                          : '${_startDate!.month}/${_startDate!.day}/${_startDate!.year}',
                      style: context.textStyles.bodyMedium?.copyWith(
                        color: _startDate == null ? Colors.grey[600] : Colors.black,
                      ),
                    ),
                    Icon(Icons.calendar_today, color: Colors.grey[600]),
                  ],
                ),
              ),
            ),
            SizedBox(height: AppSpacing.md),

            // Availability End Date
            Text(
              'Available until',
              style: context.textStyles.labelSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: AppSpacing.xs),
            InkWell(
              onTap: () => _selectDate(context, false),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _endDate == null
                          ? 'Select end date'
                          : '${_endDate!.month}/${_endDate!.day}/${_endDate!.year}',
                      style: context.textStyles.bodyMedium?.copyWith(
                        color: _endDate == null ? Colors.grey[600] : Colors.black,
                      ),
                    ),
                    Icon(Icons.calendar_today, color: Colors.grey[600]),
                  ],
                ),
              ),
            ),
            SizedBox(height: AppSpacing.lg),

            // Skills
            Text(
              'Skills & Experience',
              style: context.textStyles.labelSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: _skills.map((skill) {
                return FilterChip(
                  label: Text(skill),
                  selected: _selectedSkills.contains(skill),
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedSkills.add(skill);
                      } else {
                        _selectedSkills.remove(skill);
                      }
                    });
                  },
                );
              }).toList(),
            ),
            SizedBox(height: AppSpacing.lg),

            // How did you hear about us?
            Text(
              'How did you hear about us?',
              style: context.textStyles.labelSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: AppSpacing.xs),
            DropdownButtonFormField<String>(
              value: _selectedHowHeardAboutUs,
              items: _howHeardAboutUs.map((option) {
                return DropdownMenuItem(
                  value: option,
                  child: Text(option),
                );
              }).toList(),
              onChanged: (value) {
                setState(() => _selectedHowHeardAboutUs = value);
              },
              decoration: InputDecoration(
                hintText: 'Select an option',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
              ),
            ),
            SizedBox(height: AppSpacing.md),

            // Agree to Contact Checkbox
            CheckboxListTile(
              title: Text(
                'I agree to be contacted by Reach Global',
                style: context.textStyles.bodyMedium,
              ),
              value: _agreeToContact,
              onChanged: (value) {
                setState(() => _agreeToContact = value ?? false);
              },
              contentPadding: EdgeInsets.zero,
            ),
            SizedBox(height: AppSpacing.lg),

            // Submit Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _handleSubmit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1B3A5C),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                ),
                child: Text(
                  'Submit Interest',
                  style: context.textStyles.labelLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }
}
