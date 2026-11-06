import 'package:flutter/material.dart';

abstract final class AsiaRadii {
  static const double xs = 6.0;
  static const double sm = 10.0;
  static const double md = 14.0;
  static const double card = 18.0;
  static const double lg = 22.0;
  static const double pill = 999.0;

  static const Radius rXs = Radius.circular(xs);
  static const Radius rSm = Radius.circular(sm);
  static const Radius rMd = Radius.circular(md);
  static const Radius rCard = Radius.circular(card);
  static const Radius rLg = Radius.circular(lg);
  static const Radius rPill = Radius.circular(pill);

  static const BorderRadius brXs = BorderRadius.all(rXs);
  static const BorderRadius brSm = BorderRadius.all(rSm);
  static const BorderRadius brMd = BorderRadius.all(rMd);
  static const BorderRadius brCard = BorderRadius.all(rCard);
  static const BorderRadius brLg = BorderRadius.all(rLg);
  static const BorderRadius brPill = BorderRadius.all(rPill);
}

