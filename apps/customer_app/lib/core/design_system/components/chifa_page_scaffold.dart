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
    this.safeBottom = false,
    super.key,
  });

  final String title;
  final String subtitle;
  final Widget child;
  final ThemeModeController themeModeController;
  final Key? pageKey;
  final bool safeBottom;

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return SafeArea(
      bottom: safeBottom,
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          return SingleChildScrollView(
            key: pageKey,
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.screenGutter,
              10,
              AppSpacing.screenGutter,
              AppSpacing.xl,
            ),
            child: Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: AppSpacing.contentMaxWidth,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    ChifaAppHeader(
                      isDarkMode: isDarkMode,
                      onToggleTheme: themeModeController.toggle,
                    ),
                    const SizedBox(height: 20),
                    Semantics(
                      header: true,
                      child: Text(
                        title,
                        style: Theme.of(context).textTheme.displayLarge,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                    child,
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
