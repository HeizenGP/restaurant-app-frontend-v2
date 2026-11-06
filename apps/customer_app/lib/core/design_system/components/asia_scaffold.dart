import 'package:flutter/material.dart';

import '../foundations/asia_spacing.dart';
import '../theme/asia_theme.dart';
import 'asia_header.dart';

class AsiaScaffold extends StatelessWidget {
  const AsiaScaffold({
    required this.body,
    this.header,
    this.title,
    this.subtitle,
    this.showBack = false,
    this.onBack,
    this.onToggleTheme,
    this.isDark = false,
    this.onCartTap,
    this.cartCount = 0,
    this.tableNumber,
    this.userInitials,
    this.onUserTap,
    this.bottomNavigationBar,
    this.floatingActionButton,
    this.bottomAction,
    this.isScrollable = true,
    this.padding = const EdgeInsets.symmetric(horizontal: 16.0),
    super.key,
  });

  final Widget body;
  final Widget? header;
  final String? title;
  final String? subtitle;
  final bool showBack;
  final VoidCallback? onBack;
  final VoidCallback? onToggleTheme;
  final bool isDark;
  final VoidCallback? onCartTap;
  final int cartCount;
  final String? tableNumber;
  final String? userInitials;
  final VoidCallback? onUserTap;
  final Widget? bottomNavigationBar;
  final Widget? floatingActionButton;
  final Widget? bottomAction;
  final bool isScrollable;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final AsiaTheme theme = context.asiaTheme;

    final Widget effectiveHeader = header ??
        (title != null || showBack || onCartTap != null || onToggleTheme != null
            ? AsiaHeader(
                title: title,
                subtitle: subtitle,
                showBack: showBack,
                onBack: onBack,
                onToggleTheme: onToggleTheme,
                isDark: isDark,
                onCartTap: onCartTap,
                cartCount: cartCount,
                tableNumber: tableNumber,
                userInitials: userInitials,
                onUserTap: onUserTap,
              )
            : const SizedBox.shrink());

    return Scaffold(
      backgroundColor: theme.bg,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            final Widget constrainedBody = Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: AsiaSpacing.maxContentWidth,
                ),
                child: Column(
                  children: <Widget>[
                    effectiveHeader,
                    Expanded(
                      child: isScrollable
                          ? SingleChildScrollView(
                              padding: padding,
                              physics: const BouncingScrollPhysics(),
                              child: body,
                            )
                          : Padding(padding: padding, child: body),
                    ),
                    if (bottomAction != null)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                        child: bottomAction!,
                      ),
                  ],
                ),
              ),
            );

            return constrainedBody;
          },
        ),
      ),
      bottomNavigationBar: bottomNavigationBar != null
          ? Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: AsiaSpacing.maxContentWidth,
                ),
                child: bottomNavigationBar,
              ),
            )
          : null,
      floatingActionButton: floatingActionButton,
    );
  }
}

