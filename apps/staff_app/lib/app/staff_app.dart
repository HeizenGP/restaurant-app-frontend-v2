import 'package:flutter/material.dart';

import '../core/api_environment.dart';

class StaffApp extends StatelessWidget {
  const StaffApp({required this.environment, super.key});

  final ApiEnvironment environment;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: _TechnicalBootstrapView(environment: environment),
      title: 'Chifa ASIA Staff',
    );
  }
}

class _TechnicalBootstrapView extends StatelessWidget {
  const _TechnicalBootstrapView({required this.environment});

  final ApiEnvironment environment;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Text('Chifa ASIA · Staff App'),
            Text('API: ${environment.baseUri}'),
          ],
        ),
      ),
    );
  }
}
