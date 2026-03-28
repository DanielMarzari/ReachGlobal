import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../nav.dart';
import '../theme.dart';

extension TextStyleContext on BuildContext {
  TextTheme get textStyles => Theme.of(this).textTheme;
}

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  late TextEditingController _fullNameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _passwordController;
  late TextEditingController _confirmPasswordController;
  late TextEditingController _emergencyNameController;
  late TextEditingController _emergencyPhoneController;
  late TextEditingController _churchNameController;

  bool _isPartOfChurch = false;
  String? _selectedTShirtSize;
  Set<String> _selectedSkills = {};

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

  final List<String> _tShirtSizes = ['XS', 'S', 'M', 'L', 'XL', 'XXL'];

  @override
  void initState() {
    super.initState();
    _fullNameController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
    _emergencyNameController = TextEditingController();
    _emergencyPhoneController = TextEditingController();
    _churchNameController = TextEditingController();
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _emergencyNameController.dispose();
    _emergencyPhoneController.dispose();
    _churchNameController.dispose();
    super.dispose();
  }

  void _handleCreateAccount() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Account created! Welcome to Lighthouse.'),
        duration: const Duration(seconds: 2),
      ),
    );
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        context.go(AppRoutes.volunteerDashboard);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Create Account',
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

            // Password
            Text(
              'Password',
              style: context.textStyles.labelSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: AppSpacing.xs),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                hintText: 'Enter a strong password',
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

            // Confirm Password
            Text(
              'Confirm Password',
              style: context.textStyles.labelSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: AppSpacing.xs),
            TextField(
              controller: _confirmPasswordController,
              obscureText: true,
              decoration: InputDecoration(
                hintText: 'Confirm password',
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

            // Emergency Contact Name
            Text(
              'Emergency Contact Name',
              style: context.textStyles.labelSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: AppSpacing.xs),
            TextField(
              controller: _emergencyNameController,
              decoration: InputDecoration(
                hintText: 'Jane Doe',
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

            // Emergency Contact Phone
            Text(
              'Emergency Contact Phone',
              style: context.textStyles.labelSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: AppSpacing.xs),
            TextField(
              controller: _emergencyPhoneController,
              decoration: InputDecoration(
                hintText: '(555) 987-6543',
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

            // T-Shirt Size
            Text(
              'T-Shirt Size',
              style: context.textStyles.labelSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: AppSpacing.xs),
            DropdownButtonFormField<String>(
              value: _selectedTShirtSize,
              items: _tShirtSizes.map((size) {
                return DropdownMenuItem(
                  value: size,
                  child: Text(size),
                );
              }).toList(),
              onChanged: (value) {
                setState(() => _selectedTShirtSize = value);
              },
              decoration: InputDecoration(
                hintText: 'Select your size',
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

            // Church Team Checkbox
            CheckboxListTile(
              title: Text(
                'I am part of a church team',
                style: context.textStyles.bodyMedium,
              ),
              value: _isPartOfChurch,
              onChanged: (value) {
                setState(() => _isPartOfChurch = value ?? false);
              },
              contentPadding: EdgeInsets.zero,
            ),

            // Church Name (if checked)
            if (_isPartOfChurch) ...[
              SizedBox(height: AppSpacing.md),
              Text(
                'Church Name',
                style: context.textStyles.labelSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: AppSpacing.xs),
              TextField(
                controller: _churchNameController,
                decoration: InputDecoration(
                  hintText: 'First Baptist Church of Dallas',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                ),
              ),
            ],
            SizedBox(height: AppSpacing.lg),

            // Create Account Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _handleCreateAccount,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1B3A5C),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                ),
                child: Text(
                  'Create Account',
                  style: context.textStyles.labelLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            SizedBox(height: AppSpacing.md),

            // Sign In Link
            Center(
              child: RichText(
                text: TextSpan(
                  text: "Already have an account? ",
                  style: context.textStyles.bodySmall,
                  children: [
                    WidgetSpan(
                      child: GestureDetector(
                        onTap: () => context.go(AppRoutes.login),
                        child: Text(
                          'Sign in',
                          style: context.textStyles.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ),
                  ],
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
