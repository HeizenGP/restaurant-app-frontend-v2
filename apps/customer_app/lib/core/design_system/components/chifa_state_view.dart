import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'chifa_button.dart';
import 'chifa_card.dart';

enum ChifaStateKind { loading, empty, error, success }

class ChifaStateView extends StatelessWidget {
  const ChifaStateView({
    required this.kind,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
    super.key,
  });

  final ChifaStateKind kind;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  IconData get _icon => switch (kind) {
    ChifaStateKind.loading => LucideIcons.clock3,
    ChifaStateKind.empty => LucideIcons.info,
    ChifaStateKind.error => LucideIcons.circleAlert,
    ChifaStateKind.success => LucideIcons.circleCheck,
  };

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Semantics(
          container: true,
          liveRegion:
              kind == ChifaStateKind.loading || kind == ChifaStateKind.error,
          label: '$title. $message',
          excludeSemantics: true,
          child: ChifaCard(
            icon: _icon,
            title: title,
            subtitle: message,
            minimumHeight: 95,
          ),
        ),
        if (actionLabel != null && onAction != null) ...<Widget>[
          const SizedBox(height: 16),
          ChifaButton(label: actionLabel!, onPressed: onAction),
        ],
      ],
    );
  }
}
