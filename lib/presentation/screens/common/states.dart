import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/routing/route_names.dart';
import '../auth/_auth_widgets.dart';
import 'state_scaffold.dart';

/// Mockup 44 — Empty: no cooks in this area.
class NoCooksScreen extends StatelessWidget {
  const NoCooksScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return StateScaffold(
      title: 'Padosi',
      headline: 'No cooks here yet',
      body: "We're onboarding home chefs in your area. "
          'Get notified when they go live.',
      iconChild: const Text('🍰'),
      primaryLabel: 'Notify me',
      primaryVariant: AuthBtnVariant.ghost,
      onPrimary: () => Navigator.pop(context),
    );
  }
}

/// Mockup 45 — Empty cart.
class EmptyCartScreen extends StatelessWidget {
  const EmptyCartScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return StateScaffold(
      title: 'Padosi',
      headline: 'Your cart is empty',
      body: 'Browse home cooks near you and add something delicious.',
      iconChild: const Text('🛒'),
      primaryLabel: 'Explore cooks',
      onPrimary: () => Navigator.pushNamedAndRemoveUntil(
        context,
        RouteNames.discover,
        (_) => false,
      ),
    );
  }
}

/// Mockup 46 — No search results.
class NoResultsScreen extends StatelessWidget {
  const NoResultsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return StateScaffold(
      title: 'Padosi',
      headline: 'No matches',
      body: 'Try a different dish, cook or cuisine — or clear your filters.',
      iconChild: const Text('🔍'),
      primaryLabel: 'Clear filters',
      primaryVariant: AuthBtnVariant.ghost,
      onPrimary: () => Navigator.pop(context),
    );
  }
}

/// Mockup 47 — Payment failed.
class PaymentFailedScreen extends StatelessWidget {
  const PaymentFailedScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return StateScaffold(
      title: 'Payment',
      showBack: true,
      headline: 'Payment failed',
      body: "Your money wasn't deducted. If it was, it's refunded in 3–5 days.",
      iconChild: const Icon(Icons.close_rounded),
      iconShape: BoxShape.circle,
      iconBg: AppColors.violetSoft,
      iconColor: AppColors.error,
      primaryLabel: 'Try again',
      onPrimary: () => Navigator.pop(context),
      secondaryLabel: 'Another method',
      onSecondary: () =>
          Navigator.pushReplacementNamed(context, RouteNames.paymentMethod),
    );
  }
}

/// Mockup 48 — Offline.
class OfflineScreen extends StatelessWidget {
  const OfflineScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return StateScaffold(
      title: 'Padosi',
      headline: "You're offline",
      body: 'Check your connection — your cart is saved and waiting.',
      iconChild: const Text('📡'),
      primaryLabel: 'Retry',
      onPrimary: () => Navigator.pop(context),
    );
  }
}

/// Mockup 49 — No rider available.
class NoRiderScreen extends StatelessWidget {
  const NoRiderScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return StateScaffold(
      title: 'Your order',
      showBack: true,
      headline: 'Finding a rider…',
      body: "All riders are busy right now. We'll keep trying, "
          'or you can switch to pickup.',
      iconChild: const Text('🛵'),
      iconBg: AppColors.tier1Soft,
      iconColor: AppColors.tier1,
      primaryLabel: 'Switch to pickup',
      onPrimary: () => Navigator.pop(context),
      secondaryLabel: 'Keep waiting',
      onSecondary: () => Navigator.pop(context),
    );
  }
}
