import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

@immutable
class CustomerDestination {
  const CustomerDestination({
    required this.label,
    required this.path,
    required this.icon,
    required this.semanticKey,
  });

  final String label;
  final String path;
  final IconData icon;
  final Key semanticKey;
}

const List<CustomerDestination> customerDestinations = <CustomerDestination>[
  CustomerDestination(
    label: 'Inicio',
    path: '/',
    icon: LucideIcons.house,
    semanticKey: Key('nav-inicio'),
  ),
  CustomerDestination(
    label: 'Menú',
    path: '/menu',
    icon: LucideIcons.utensilsCrossed,
    semanticKey: Key('nav-menu'),
  ),
  CustomerDestination(
    label: 'Pedidos',
    path: '/pedidos',
    icon: LucideIcons.receiptText,
    semanticKey: Key('nav-pedidos'),
  ),
  CustomerDestination(
    label: 'Cuenta',
    path: '/cuenta',
    icon: LucideIcons.userRound,
    semanticKey: Key('nav-cuenta'),
  ),
];
