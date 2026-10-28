import 'package:flutter/material.dart';

import '../../../app/theme/theme_mode_controller.dart';
import '../foundations/app_spacing.dart';
import 'chifa_app_header.dart';

class ChifaPageScaffold extends StatelessWidget {
  const ChifaPageScaffold({
    required this.title,
    required this.subtitle,
    required this.child,
    required this.themeModeController,
    this.pageKey,
    this.contentGap = 14,
    this.initials = 'C',
    this.avatarPath,
    this.onAvatarPressed,
    this.safeBottom = false,
    this.onBackPressed,
    this.showBackButton,
    this.onCartPressed,
    this.cartItemCount = 0,
    this.onNotificationPressed,
    this.tableLabel,
    super.key,
  });

  final String title;
  final String subtitle;
  final Widget child;
  final ThemeModeController themeModeController;
  final Key? pageKey;
  final double contentGap;
  final String initials;
  final String? avatarPath;
  final VoidCallback? onAvatarPressed;
  final bool safeBottom;
  final VoidCallback? onBackPressed;
  final bool? showBackButton;
  final VoidCallback? onCartPressed;
  final int cartItemCount;
  final VoidCallback? onNotificationPressed;
  final String? tableLabel;

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return SafeArea(
      bottom: safeBottom,
      child: SingleChildScrollView(
        key: pageKey,
        padding: const EdgeInsets.only(bottom: AppSpacing.xl),
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: AppSpacing.mobilePageMaxWidth,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 10, 18, 0),
                  child: ChifaAppHeader(
                    isDarkMode: isDarkMode,
                    onToggleTheme: themeModeController.toggle,
                    initials: initials,
                    avatarPath: avatarPath,
                    onAvatarPressed: onAvatarPressed,
                    onBackPressed: onBackPressed,
                    showBackButton: showBackButton,
                    onCartPressed: onCartPressed,
                    cartItemCount: cartItemCount,
                    onNotificationPressed: onNotificationPressed,
                    tableLabel: tableLabel,
                  ),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.screenGutter,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      ConstrainedBox(
                        constraints: const BoxConstraints(minHeight: 42),
                        child: Padding(
                          padding: const EdgeInsets.only(left: 1),
                          child: Align(
                            alignment: Alignment.topLeft,
                            child: Semantics(
                              header: true,
                              child: Text(
                                title,
                                style: Theme.of(context).textTheme.displayLarge,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      ConstrainedBox(
                        constraints: const BoxConstraints(minHeight: 37),
                        child: Padding(
                          padding: const EdgeInsets.only(left: 1),
                          child: Align(
                            alignment: Alignment.topLeft,
                            child: Text(
                              subtitle,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: contentGap),
                      child,
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
