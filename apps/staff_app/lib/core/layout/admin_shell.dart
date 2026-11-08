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

const List<AdminNavItem> kNavItems = <AdminNavItem>[
  AdminNavItem(
    path: '/dashboard',
    label: 'Dashboard',
    icon: LucideIcons.layoutDashboard,
  ),
  AdminNavItem(
    path: '/orders',
    label: 'Pedidos',
    icon: LucideIcons.shoppingBag,
  ),
  AdminNavItem(
    path: '/products',
    label: 'Productos',
    icon: LucideIcons.utensils,
  ),
  AdminNavItem(
    path: '/inventory',
    label: 'Inventario',
    icon: LucideIcons.boxes,
  ),
  AdminNavItem(
    path: '/tables',
    label: 'Mesas',
    icon: LucideIcons.armchair,
  ),
  AdminNavItem(
    path: '/payments',
    label: 'Pagos & Caja',
    icon: LucideIcons.creditCard,
  ),
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

  Widget _buildTopBar(BuildContext context, String currentRoute, bool isDesktop) {
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
        border: Border(
          bottom: BorderSide(color: tokens.border, width: 1.0),
        ),
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
          // User Badge
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
                      user.displayName.isNotEmpty ? user.displayName[0].toUpperCase() : 'U',
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
              icon: Icon(
                Icons.logout_rounded,
                size: 20,
                color: tokens.error,
              ),
              onPressed: () => _confirmLogout(context),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDesktopSidebar(BuildContext context, String currentRoute) {
    final AsiaThemeTokens tokens = context.tokens;
    final double width = _sidebarCollapsed ? 76.0 : 250.0;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: width,
      decoration: BoxDecoration(
        color: tokens.sidebar,
        border: Border(
          right: BorderSide(color: tokens.border, width: 1.0),
        ),
      ),
      child: Column(
        children: <Widget>[
          // Logo Header
          Container(
            height: 64,
            padding: const EdgeInsets.symmetric(horizontal: AsiaSpacing.md),
            alignment: Alignment.centerLeft,
            child: Row(
              children: <Widget>[
                KairoAdminLogo(compact: _sidebarCollapsed),
                if (!_sidebarCollapsed) const Spacer(),
                IconButton(
                  icon: Icon(
                    _sidebarCollapsed
                        ? Icons.chevron_right_rounded
                        : Icons.chevron_left_rounded,
                    size: 20,
                    color: tokens.textTertiary,
                  ),
                  onPressed: () => setState(() => _sidebarCollapsed = !_sidebarCollapsed),
                ),
              ],
            ),
          ),
          Divider(color: tokens.border.withValues(alpha: 0.5), height: 1),
          const SizedBox(height: AsiaSpacing.md),
          // Nav items list
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              children: kNavItems.map((AdminNavItem item) {
                if (item.adminOnly && !widget.authController.isAdmin) {
                  return const SizedBox.shrink();
                }
                final bool isSelected = currentRoute.startsWith(item.path);
                return _buildNavItemTile(
                  context: context,
                  item: item,
                  isSelected: isSelected,
                  collapsed: _sidebarCollapsed,
                );
              }).toList(),
            ),
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
                  const KairoAdminLogo(),
                  const Spacer(),
                  IconButton(
                    icon: Icon(Icons.close_rounded, color: tokens.textSecondary),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            Divider(color: tokens.border, height: 1),
            const SizedBox(height: AsiaSpacing.md),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                children: kNavItems.map((AdminNavItem item) {
                  if (item.adminOnly && !widget.authController.isAdmin) {
                    return const SizedBox.shrink();
                  }
                  final bool isSelected = currentRoute.startsWith(item.path);
                  return _buildNavItemTile(
                    context: context,
                    item: item,
                    isSelected: isSelected,
                    collapsed: false,
                    onTapExtra: () => Navigator.of(context).pop(),
                  );
                }).toList(),
              ),
            ),
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

    return Padding(
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
              vertical: 11,
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
              mainAxisAlignment:
                  collapsed ? MainAxisAlignment.center : MainAxisAlignment.start,
              children: <Widget>[
                Icon(item.icon, size: 20, color: fg),
                if (!collapsed) ...<Widget>[
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      item.label,
                      style: AsiaTypography.bodyMedium.copyWith(
                        color: isSelected
                            ? (isDark ? tokens.textPrimary : tokens.brandCrimson)
                            : tokens.textSecondary,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
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
  }

  void _confirmLogout(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (BuildContext ctx) => AlertDialog(
        title: const Text('Cerrar Sesión'),
        content: const Text('¿Estás seguro de que deseas salir del panel administrativo?'),
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
