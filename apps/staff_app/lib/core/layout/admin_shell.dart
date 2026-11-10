import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../features/auth/application/auth_controller.dart';
import '../../features/auth/domain/auth_models.dart';
import '../design_system/components/kairo_logo.dart';
import '../design_system/foundations/asia_colors.dart';
import '../design_system/foundations/asia_radii.dart';
import '../design_system/foundations/asia_spacing.dart';
import '../design_system/foundations/asia_typography.dart';
import 'breakpoints.dart';

class AdminNavItem {
  const AdminNavItem({
    required this.path,
    required this.label,
    required this.icon,
    this.adminOnly = false,
  });

  final String path;
  final String label;
  final IconData icon;
  final bool adminOnly;
}

class AdminNavSection {
  const AdminNavSection({required this.title, required this.items});

  final String title;
  final List<AdminNavItem> items;
}

const AdminNavItem kDashboardItem = AdminNavItem(
  path: '/dashboard',
  label: 'Dashboard',
  icon: LucideIcons.layoutGrid,
);

const List<AdminNavSection> kNavSections = <AdminNavSection>[
  AdminNavSection(
    title: 'OPERACIÓN DIARIA',
    items: <AdminNavItem>[
      AdminNavItem(path: '/tables', label: 'Mesas', icon: LucideIcons.armchair),
      AdminNavItem(
        path: '/orders',
        label: 'Pedidos',
        icon: LucideIcons.shoppingBag,
      ),
      AdminNavItem(path: '/payments', label: 'Caja', icon: LucideIcons.wallet),
    ],
  ),
  AdminNavSection(
    title: 'GESTIÓN DEL RESTAURANTE',
    items: <AdminNavItem>[
      AdminNavItem(
        path: '/products',
        label: 'Carta y productos',
        icon: LucideIcons.bookOpen,
      ),
      AdminNavItem(
        path: '/inventory',
        label: 'Inventario',
        icon: LucideIcons.box,
      ),
    ],
  ),
  AdminNavSection(
    title: 'ADMINISTRACIÓN',
    items: <AdminNavItem>[
      AdminNavItem(
        path: '/staff',
        label: 'Personal',
        icon: LucideIcons.users,
        adminOnly: true,
      ),
      AdminNavItem(
        path: '/reports',
        label: 'Reportes',
        icon: LucideIcons.barChart3,
        adminOnly: true,
      ),
      AdminNavItem(
        path: '/settings',
        label: 'Configuración',
        icon: LucideIcons.settings,
        adminOnly: true,
      ),
    ],
  ),
];

List<AdminNavItem> get kNavItems => <AdminNavItem>[
  kDashboardItem,
  for (final AdminNavSection section in kNavSections) ...section.items,
];

class AdminShell extends StatefulWidget {
  const AdminShell({
    required this.child,
    required this.authController,
    required this.isDarkMode,
    required this.onToggleTheme,
    super.key,
  });

  final Widget child;
  final AuthController authController;
  final bool isDarkMode;
  final VoidCallback onToggleTheme;

  @override
  State<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends State<AdminShell> {
  bool _sidebarCollapsed = false;

  @override
  Widget build(BuildContext context) {
    final AsiaThemeTokens tokens = context.tokens;
    final bool isDesktop = Breakpoints.isDesktop(context);
    final String currentRoute = GoRouterState.of(context).matchedLocation;

    return Scaffold(
      backgroundColor: tokens.canvas,
      drawer: isDesktop ? null : _buildMobileDrawer(context, currentRoute),
      body: Row(
        children: <Widget>[
          if (isDesktop) _buildDesktopSidebar(context, currentRoute),
          Expanded(
            child: Column(
              children: <Widget>[
                _buildTopBar(context, currentRoute, isDesktop),
                Expanded(child: widget.child),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar(
    BuildContext context,
    String currentRoute,
    bool isDesktop,
  ) {
    final AsiaThemeTokens tokens = context.tokens;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final StaffUser? user = widget.authController.currentUser;

    String sectionTitle = 'KAIRO Admin';
    for (final AdminNavItem item in kNavItems) {
      if (currentRoute.startsWith(item.path)) {
        sectionTitle = item.label;
        break;
      }
    }

    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: AsiaSpacing.lg),
      decoration: BoxDecoration(
        color: tokens.card,
        border: Border(bottom: BorderSide(color: tokens.border, width: 1.0)),
      ),
      child: Row(
        children: <Widget>[
          if (!isDesktop) ...<Widget>[
            Builder(
              builder: (BuildContext ctx) => IconButton(
                icon: Icon(Icons.menu_rounded, color: tokens.textPrimary),
                onPressed: () => Scaffold.of(ctx).openDrawer(),
              ),
            ),
            const SizedBox(width: AsiaSpacing.sm),
          ],
          Text(
            sectionTitle,
            style: AsiaTypography.headingLarge.copyWith(
              color: tokens.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const Spacer(),
          // Environment Indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: tokens.brandCrimson.withValues(alpha: 0.1),
              borderRadius: AsiaRadii.pill,
              border: Border.all(
                color: tokens.brandCrimson.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Container(
                  width: 7,
                  height: 7,
                  decoration: BoxDecoration(
                    color: tokens.success,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  'API ACTIVA',
                  style: AsiaTypography.caption.copyWith(
                    color: tokens.brandCrimson,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AsiaSpacing.md),
          // Theme Toggle
          IconButton(
            tooltip: isDark ? 'Cambiar a Tema Claro' : 'Cambiar a Tema Oscuro',
            icon: Icon(
              isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
              size: 20,
              color: tokens.textSecondary,
            ),
            onPressed: widget.onToggleTheme,
          ),
          const SizedBox(width: AsiaSpacing.sm),
          // User Badge in TopBar
          if (user != null) ...<Widget>[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: tokens.cardElevated,
                borderRadius: AsiaRadii.md,
                border: Border.all(color: tokens.border),
              ),
              child: Row(
                children: <Widget>[
                  CircleAvatar(
                    radius: 14,
                    backgroundColor: tokens.brandCrimson.withValues(alpha: 0.2),
                    child: Text(
                      user.displayName.isNotEmpty
                          ? user.displayName[0].toUpperCase()
                          : 'U',
                      style: AsiaTypography.caption.copyWith(
                        color: tokens.brandCrimson,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (isDesktop) ...<Widget>[
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          user.displayName,
                          style: AsiaTypography.caption.copyWith(
                            color: tokens.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          user.roles.isNotEmpty
                              ? user.roles.first.displayName
                              : 'Personal',
                          style: AsiaTypography.caption.copyWith(
                            color: tokens.textTertiary,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 8),
                  ],
                ],
              ),
            ),
            const SizedBox(width: AsiaSpacing.xs),
            IconButton(
              tooltip: 'Cerrar Sesión',
              icon: Icon(Icons.logout_rounded, size: 20, color: tokens.error),
              onPressed: () => _confirmLogout(context),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDesktopSidebar(BuildContext context, String currentRoute) {
    final AsiaThemeTokens tokens = context.tokens;
    final double width = _sidebarCollapsed ? 76.0 : 256.0;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: width,
      decoration: BoxDecoration(
        color: tokens.sidebar,
        border: Border(right: BorderSide(color: tokens.border, width: 1.0)),
      ),
      child: Column(
        children: <Widget>[
          // Logo Header (Preservando el logo del negocio)
          Container(
            height: 68,
            padding: const EdgeInsets.symmetric(horizontal: AsiaSpacing.md),
            alignment: Alignment.centerLeft,
            child: Row(
              children: <Widget>[
                KairoAdminLogo(
                  compact: _sidebarCollapsed,
                  subtitle: 'ADMINISTRACIÓN',
                ),
                if (!_sidebarCollapsed) const Spacer(),
                IconButton(
                  tooltip: _sidebarCollapsed ? 'Expandir' : 'Colapsar',
                  icon: Icon(
                    _sidebarCollapsed
                        ? LucideIcons.panelLeftOpen
                        : LucideIcons.panelLeftClose,
                    size: 19,
                    color: tokens.textTertiary,
                  ),
                  onPressed: () =>
                      setState(() => _sidebarCollapsed = !_sidebarCollapsed),
                ),
              ],
            ),
          ),
          Divider(color: tokens.border.withValues(alpha: 0.5), height: 1),

          // Scrollable Sections
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              children: <Widget>[
                // 1. Dashboard
                _buildNavItemTile(
                  context: context,
                  item: kDashboardItem,
                  isSelected: currentRoute.startsWith(kDashboardItem.path),
                  collapsed: _sidebarCollapsed,
                ),
                const SizedBox(height: 6),
                Divider(color: tokens.border.withValues(alpha: 0.5), height: 1),
                const SizedBox(height: 6),

                // 2. Sections
                for (final AdminNavSection section in kNavSections) ...<Widget>[
                  if (!_sidebarCollapsed) ...<Widget>[
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 12,
                        right: 12,
                        top: 10,
                        bottom: 6,
                      ),
                      child: Text(
                        section.title,
                        style: AsiaTypography.caption.copyWith(
                          color: tokens.textTertiary,
                          fontWeight: FontWeight.w700,
                          fontSize: 10.5,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                  ] else ...<Widget>[const SizedBox(height: 6)],
                  for (final AdminNavItem item in section.items) ...<Widget>[
                    if (!item.adminOnly || widget.authController.isAdmin)
                      _buildNavItemTile(
                        context: context,
                        item: item,
                        isSelected: currentRoute.startsWith(item.path),
                        collapsed: _sidebarCollapsed,
                      ),
                  ],
                  const SizedBox(height: 6),
                  Divider(
                    color: tokens.border.withValues(alpha: 0.5),
                    height: 1,
                  ),
                  const SizedBox(height: 6),
                ],
              ],
            ),
          ),

          // Pinned User Footer
          Divider(color: tokens.border.withValues(alpha: 0.5), height: 1),
          _buildSidebarFooter(context, tokens, _sidebarCollapsed),
        ],
      ),
    );
  }

  Widget _buildSidebarFooter(
    BuildContext context,
    AsiaThemeTokens tokens,
    bool collapsed,
  ) {
    final StaffUser? user = widget.authController.currentUser;
    final String roleTitle = user != null && user.roles.isNotEmpty
        ? (user.isSuperAdmin
              ? 'Administrador'
              : (user.isAdmin ? 'Administrador' : user.roles.first.displayName))
        : 'Administrador';

    if (collapsed) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Tooltip(
              message: '$roleTitle\nKAIRO · Panel de gestión',
              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: tokens.brandCrimson.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Icon(
                  LucideIcons.user,
                  size: 20,
                  color: tokens.brandCrimson,
                ),
              ),
            ),
            const SizedBox(height: 8),
            IconButton(
              tooltip: 'Cerrar Sesión',
              icon: Icon(
                LucideIcons.logOut,
                size: 18,
                color: tokens.textSecondary,
              ),
              onPressed: () => _confirmLogout(context),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: <Widget>[
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: tokens.brandCrimson.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Icon(LucideIcons.user, size: 20, color: tokens.brandCrimson),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  roleTitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AsiaTypography.bodyMedium.copyWith(
                    color: tokens.textPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'KAIRO · Panel de gestión',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AsiaTypography.caption.copyWith(
                    color: tokens.textTertiary,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Cerrar Sesión',
            icon: Icon(
              LucideIcons.logOut,
              size: 18,
              color: tokens.textSecondary,
            ),
            onPressed: () => _confirmLogout(context),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileDrawer(BuildContext context, String currentRoute) {
    final AsiaThemeTokens tokens = context.tokens;

    return Drawer(
      backgroundColor: tokens.sidebar,
      child: SafeArea(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(AsiaSpacing.lg),
              child: Row(
                children: <Widget>[
                  const KairoAdminLogo(subtitle: 'ADMINISTRACIÓN'),
                  const Spacer(),
                  IconButton(
                    icon: Icon(
                      Icons.close_rounded,
                      color: tokens.textSecondary,
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            Divider(color: tokens.border, height: 1),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                children: <Widget>[
                  _buildNavItemTile(
                    context: context,
                    item: kDashboardItem,
                    isSelected: currentRoute.startsWith(kDashboardItem.path),
                    collapsed: false,
                    onTapExtra: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(height: 6),
                  Divider(
                    color: tokens.border.withValues(alpha: 0.5),
                    height: 1,
                  ),
                  const SizedBox(height: 6),
                  for (final AdminNavSection section
                      in kNavSections) ...<Widget>[
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 12,
                        right: 12,
                        top: 10,
                        bottom: 6,
                      ),
                      child: Text(
                        section.title,
                        style: AsiaTypography.caption.copyWith(
                          color: tokens.textTertiary,
                          fontWeight: FontWeight.w700,
                          fontSize: 10.5,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                    for (final AdminNavItem item in section.items) ...<Widget>[
                      if (!item.adminOnly || widget.authController.isAdmin)
                        _buildNavItemTile(
                          context: context,
                          item: item,
                          isSelected: currentRoute.startsWith(item.path),
                          collapsed: false,
                          onTapExtra: () => Navigator.of(context).pop(),
                        ),
                    ],
                    const SizedBox(height: 6),
                    Divider(
                      color: tokens.border.withValues(alpha: 0.5),
                      height: 1,
                    ),
                    const SizedBox(height: 6),
                  ],
                ],
              ),
            ),
            Divider(color: tokens.border, height: 1),
            _buildSidebarFooter(context, tokens, false),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItemTile({
    required BuildContext context,
    required AdminNavItem item,
    required bool isSelected,
    required bool collapsed,
    VoidCallback? onTapExtra,
  }) {
    final AsiaThemeTokens tokens = context.tokens;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    final Color fg = isSelected ? tokens.brandCrimson : tokens.textSecondary;
    final Color bg = isSelected
        ? (isDark
              ? tokens.brandCrimson.withValues(alpha: 0.12)
              : tokens.sidebarSelected)
        : Colors.transparent;

    final Widget tile = Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: AsiaRadii.md,
          onTap: () {
            onTapExtra?.call();
            context.go(item.path);
          },
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: collapsed ? 0 : 12,
              vertical: 10,
            ),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: AsiaRadii.md,
              border: isSelected
                  ? Border.all(
                      color: tokens.brandCrimson.withValues(alpha: 0.3),
                      width: 1.0,
                    )
                  : null,
            ),
            child: Row(
              mainAxisAlignment: collapsed
                  ? MainAxisAlignment.center
                  : MainAxisAlignment.start,
              children: <Widget>[
                Icon(item.icon, size: 20, color: fg),
                if (!collapsed) ...<Widget>[
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      item.label,
                      style: AsiaTypography.bodyMedium.copyWith(
                        color: isSelected
                            ? (isDark
                                  ? tokens.textPrimary
                                  : tokens.brandCrimson)
                            : tokens.textPrimary,
                        fontWeight: isSelected
                            ? FontWeight.w700
                            : FontWeight.w500,
                        fontSize: 13.5,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );

    if (collapsed) {
      return Tooltip(message: item.label, child: tile);
    }
    return tile;
  }

  void _confirmLogout(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (BuildContext ctx) => AlertDialog(
        title: const Text('Cerrar Sesión'),
        content: const Text(
          '¿Estás seguro de que deseas salir del panel administrativo?',
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: context.tokens.error,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.of(ctx).pop();
              widget.authController.logout().then((_) {
                if (context.mounted) {
                  context.go('/login');
                }
              });
            },
            child: const Text('Salir'),
          ),
        ],
      ),
    );
  }
}
