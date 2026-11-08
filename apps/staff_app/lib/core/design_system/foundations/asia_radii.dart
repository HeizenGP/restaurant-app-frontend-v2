import 'package:flutter/material.dart';

abstract final class AsiaRadii {
  static const Radius smRadius = Radius.circular(6.0);
  static const Radius mdRadius = Radius.circular(10.0);
  static const Radius lgRadius = Radius.circular(16.0);
  static const Radius xlRadius = Radius.circular(24.0);
  static const Radius pillRadius = Radius.circular(999.0);

  static const BorderRadius sm = BorderRadius.all(smRadius);
  static const BorderRadius md = BorderRadius.all(mdRadius);
  static const BorderRadius lg = BorderRadius.all(lgRadius);
  static const BorderRadius xl = BorderRadius.all(xlRadius);
  static const BorderRadius pill = BorderRadius.all(pillRadius);
}
