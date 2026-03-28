import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme.dart';

class DonationTypeCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool selected;

  const DonationTypeCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.selected,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: AppSpacing.paddingLg,
        decoration: BoxDecoration(
          color: selected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(
            color: selected ? Theme.of(context).colorScheme.primary : Theme.of(context).dividerColor,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0x0D000000),
              blurRadius: selected ? 4 : 2,
              offset: Offset(0, selected ? 2 : 1),
            )
          ],
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: selected ? Theme.of(context).colorScheme.onPrimary : Theme.of(context).colorScheme.primary,
              size: 32,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              title,
              style: context.textStyles.labelLarge?.bold.copyWith(
                color: selected ? Theme.of(context).colorScheme.onPrimary : null,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              subtitle,
              style: context.textStyles.bodySmall?.copyWith(
                color: selected ? Theme.of(context).colorScheme.onPrimary : Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class AmountChip extends StatelessWidget {
  final String amount;
  final bool selected;

  const AmountChip({
    super.key,
    required this.amount,
    required this.selected,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        decoration: BoxDecoration(
          color: selected ? Theme.of(context).colorScheme.secondary : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: selected ? Theme.of(context).colorScheme.secondary : Theme.of(context).dividerColor,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          amount,
          style: context.textStyles.titleSmall?.bold.copyWith(
            color: selected ? Theme.of(context).colorScheme.onSecondary : null,
          ),
        ),
      ),
    );
  }
}

class ImpactStatDonation extends StatelessWidget {
  final IconData icon;
  final String label;
  final String desc;

  const ImpactStatDonation({
    super.key,
    required this.icon,
    required this.label,
    required this.desc,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: const BoxDecoration(
            color: Color(0xFFF0F4F0),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: Theme.of(context).colorScheme.primary,
            size: 24,
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: context.textStyles.bodyMedium?.semiBold,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                desc,
                style: context.textStyles.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class DonationFlowScreen extends StatelessWidget {
  const DonationFlowScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: AppSpacing.paddingLg,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  border: Border(
                    bottom: BorderSide(color: Theme.of(context).dividerColor),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => context.pop(),
                    ),
                    Text(
                      "Support Relief",
                      style: context.textStyles.titleMedium?.bold,
                    ),
                    const SizedBox(width: 40),
                  ],
                ),
              ),
              Container(
                height: 160,
                margin: AppSpacing.paddingLg,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppRadius.xl),
                ),
                clipBehavior: Clip.antiAlias,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset(
                      "assets/images/volunteers_rebuilding_house_after_storm_christian_relief_gray_1774661718633.jpg",
                      fit: BoxFit.cover,
                    ),
                    Container(
                      padding: AppSpacing.paddingLg,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            Color(0xAA000000),
                            Colors.transparent,
                          ],
                        ),
                      ),
                      alignment: Alignment.bottomLeft,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Current Mission: Hurricane Helena",
                            style: context.textStyles.labelSmall?.bold.copyWith(color: Colors.white),
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            "Help families return home",
                            style: context.textStyles.headlineSmall?.bold.copyWith(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: AppSpacing.horizontalLg,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      "How would you like to help?",
                      style: context.textStyles.titleMedium?.bold,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    const Row(
                      children: [
                        DonationTypeCard(
                          icon: Icons.payments_rounded,
                          title: "Monetary",
                          subtitle: "Quickest impact",
                          selected: true,
                        ),
                        SizedBox(width: AppSpacing.md),
                        DonationTypeCard(
                          icon: Icons.inventory_2_rounded,
                          title: "Materials",
                          subtitle: "Tools & Supplies",
                          selected: false,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Container(
                margin: AppSpacing.horizontalLg,
                padding: AppSpacing.paddingLg,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(AppRadius.xl),
                  border: Border.all(color: Theme.of(context).dividerColor),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x08000000),
                      blurRadius: 2,
                      offset: Offset(0, 1),
                    )
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      "Select Amount (USD)",
                      style: context.textStyles.labelLarge?.semiBold.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    const Row(
                      children: [
                        AmountChip(amount: "\$25", selected: false),
                        SizedBox(width: AppSpacing.md),
                        AmountChip(amount: "\$50", selected: true),
                        SizedBox(width: AppSpacing.md),
                        AmountChip(amount: "\$100", selected: false),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    TextField(
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: "Custom Amount",
                        hintText: "Enter other amount",
                        prefixIcon: const Icon(Icons.attach_money),
                        filled: true,
                        fillColor: Theme.of(context).scaffoldBackgroundColor,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppRadius.md),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
                      child: Divider(color: Theme.of(context).dividerColor),
                    ),
                    Text(
                      "Your \$50 Impact:",
                      style: context.textStyles.labelSmall?.bold.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    const ImpactStatDonation(
                      icon: Icons.home_repair_service,
                      label: "Repair Kit",
                      desc: "Provides shingles and nails for one roof patch.",
                    ),
                    const SizedBox(height: AppSpacing.md),
                    const ImpactStatDonation(
                      icon: Icons.water_drop,
                      label: "Clean Water",
                      desc: "Provides 2 weeks of water for a family of four.",
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Padding(
                padding: AppSpacing.horizontalLg,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      "Payment Method",
                      style: context.textStyles.titleMedium?.bold,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Container(
                      padding: AppSpacing.paddingMd,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                        border: Border.all(color: Theme.of(context).dividerColor),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.credit_card,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Text(
                              "Visa ending in 4242",
                              style: context.textStyles.bodyMedium,
                            ),
                          ),
                          Icon(
                            Icons.expand_more,
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.favorite_border,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Text(
                              "Make this a tribute gift",
                              style: context.textStyles.bodyMedium,
                            ),
                          ],
                        ),
                        Switch(
                          value: false,
                          onChanged: (val) {},
                          activeColor: Theme.of(context).colorScheme.primary,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              Padding(
                padding: AppSpacing.horizontalLg,
                child: Column(
                  children: [
                    FilledButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Donation processed successfully!')),
                        );
                        context.pop();
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Theme.of(context).colorScheme.onPrimary,
                        minimumSize: const Size.fromHeight(56),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.lg),
                        ),
                        elevation: 2,
                      ),
                      child: const Text("Complete \$50 Donation"),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.lock_outline,
                          size: 14,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Text(
                          "Secure encrypted transaction",
                          style: context.textStyles.labelSmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                margin: AppSpacing.paddingLg,
                padding: AppSpacing.paddingLg,
                decoration: BoxDecoration(
                  color: const Color(0xFFF9FBF9),
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                ),
                child: Column(
                  children: [
                    Text(
                      "Lighthouse is a 501(c)(3) nonprofit.",
                      style: context.textStyles.labelSmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      "100% of your disaster gift goes to the field.",
                      style: context.textStyles.labelSmall?.bold.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }
}
