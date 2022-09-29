// Desc: description
// Modified: 2022-09-29T18:29:57.850Z

import 'package:flutter/material.dart';
import 'package:my_used_pots/constants.dart';

AppBar brandedAppBar({List<Widget>? actions}) => AppBar(
      title: const Text(appDisplayName),
      actions: actions,
    );

Padding standardPadding(Widget? child, {double multiplier = 1}) =>
    Padding(padding: EdgeInsets.all(multiplier * 8), child: child);
