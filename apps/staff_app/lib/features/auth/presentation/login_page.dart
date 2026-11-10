import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/design_system/components/admin_button.dart';
import '../../../core/design_system/components/admin_text_field.dart';
import '../../../core/design_system/components/kairo_logo.dart';
import '../../../core/design_system/foundations/asia_colors.dart';
import '../../../core/design_system/foundations/asia_radii.dart';
import '../../../core/design_system/foundations/asia_spacing.dart';
import '../../../core/design_system/foundations/asia_typography.dart';
import '../../../core/layout/breakpoints.dart';
import '../application/auth_controller.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({
    required this.authController,
    this.onToggleTheme,
    super.key,
  });

  final AuthController authController;
  final VoidCallback? onToggleTheme;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;
    final bool success = await widget.authController.login(
      _emailController.text,
      _passwordController.text,
    );
    if (success && mounted) {
      context.go('/dashboard');
    }
  }

  @override
  Widget build(BuildContext context) {
    final AsiaThemeTokens tokens = context.tokens;
    final bool isDesktop = Breakpoints.isDesktop(context);
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: tokens.canvas,
      body: Stack(
        children: <Widget>[
          Row(
            children: <Widget>[
              if (isDesktop) _buildBrandShowcase(context, isDark),
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(AsiaSpacing.xl),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 440),
                      child: _buildLoginCard(context),
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (widget.onToggleTheme != null)
            Positioned(
              top: AsiaSpacing.lg,
              right: AsiaSpacing.lg,
              child: Container(
                decoration: BoxDecoration(
                  color: tokens.cardElevated,
                  borderRadius: AsiaRadii.pill,
                  border: Border.all(color: tokens.border),
                ),
                child: IconButton(
                  tooltip: isDark
                      ? 'Cambiar a Tema Claro'
                      : 'Cambiar a Tema Oscuro',
                  icon: Icon(
                    isDark
                        ? Icons.light_mode_outlined
                        : Icons.dark_mode_outlined,
                    size: 20,
                    color: tokens.textSecondary,
                  ),
                  onPressed: widget.onToggleTheme,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBrandShowcase(BuildContext context, bool isDark) {
    final AsiaThemeTokens tokens = context.tokens;

    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(AsiaSpacing.xxxl),
        decoration: BoxDecoration(
          color: isDark ? tokens.sidebar : tokens.cardElevated,
          border: Border(right: BorderSide(color: tokens.border, width: 1.0)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            const KairoAdminLogo(subtitle: 'ALTA COCINA ASIÁTICA'),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Excelencia y precisión en cada servicio gastronómico.',
                  style: AsiaTypography.displayLarge.copyWith(
                    color: tokens.textPrimary,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: AsiaSpacing.lg),
                Text(
                  'Gestión integral de pedidos multicanal, mesas en salón, tickets de cocina en tiempo real, inventario de insumos y reportes operativos.',
                  style: AsiaTypography.bodyLarge.copyWith(
                    color: tokens.textSecondary,
                    height: 1.6,
                  ),
                ),
              ],
            ),
            Row(
              children: <Widget>[
                Icon(
                  LucideIcons.shieldCheck,
                  size: 16,
                  color: tokens.brandGold,
                ),
                const SizedBox(width: 8),
                Text(
                  'Acceso seguro para administradores y personal autorizado',
                  style: AsiaTypography.caption.copyWith(
                    color: tokens.textTertiary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoginCard(BuildContext context) {
    final AsiaThemeTokens tokens = context.tokens;

    return ListenableBuilder(
      listenable: widget.authController,
      builder: (BuildContext context, _) {
        final bool isLoading = widget.authController.isLoading;
        final String? errorMessage = widget.authController.errorMessage;

        return Container(
          decoration: BoxDecoration(
            color: tokens.card,
            borderRadius: AsiaRadii.xl,
            border: Border.all(color: tokens.border),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          padding: const EdgeInsets.all(AsiaSpacing.xxl),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const Center(child: KairoAdminLogo(compact: false)),
                const SizedBox(height: AsiaSpacing.xl),
                Text(
                  'Iniciar Sesión',
                  style: AsiaTypography.displaySmall.copyWith(
                    color: tokens.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),
                Text(
                  'Ingresa tus credenciales del personal de KAIRO',
                  style: AsiaTypography.bodySmall.copyWith(
                    color: tokens.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AsiaSpacing.xl),
                if (errorMessage != null) ...<Widget>[
                  Container(
                    padding: const EdgeInsets.all(AsiaSpacing.md),
                    decoration: BoxDecoration(
                      color: tokens.error.withValues(alpha: 0.1),
                      borderRadius: AsiaRadii.md,
                      border: Border.all(
                        color: tokens.error.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      children: <Widget>[
                        Icon(
                          Icons.error_outline_rounded,
                          size: 18,
                          color: tokens.error,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            errorMessage,
                            style: AsiaTypography.caption.copyWith(
                              color: tokens.error,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AsiaSpacing.lg),
                ],
                AdminTextField(
                  controller: _emailController,
                  label: 'Correo Electrónico',
                  hintText: 'admin@kairo.pe',
                  prefixIcon: LucideIcons.mail,
                  keyboardType: TextInputType.emailAddress,
                  validator: (String? val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Por favor ingresa tu correo.';
                    }
                    if (!val.contains('@')) {
                      return 'Correo electrónico inválido.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AsiaSpacing.lg),
                AdminTextField(
                  controller: _passwordController,
                  label: 'Contraseña',
                  hintText: '••••••••',
                  prefixIcon: LucideIcons.lock,
                  isPassword: true,
                  onSubmitted: (_) => _handleLogin(),
                  validator: (String? val) {
                    if (val == null || val.isEmpty) {
                      return 'Por favor ingresa tu contraseña.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AsiaSpacing.xl),
                AdminButton(
                  label: 'Ingresar al Sistema',
                  icon: LucideIcons.logIn,
                  size: AdminButtonSize.lg,
                  isFullWidth: true,
                  isLoading: isLoading,
                  onPressed: _handleLogin,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
