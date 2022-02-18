
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Globales extends InheritedWidget {
  const Globales({
    Key? key,
    required this.data,
    required Widget child,
  }) : super(key: key, child: child);

  final Map<String, dynamic> data;

  static Globales of(BuildContext context) {
    final Globales? result = context.dependOnInheritedWidgetOfExactType<Globales>();
    assert(result != null, 'No FrogColor found in context');
    return result!;
  }

  @override
  bool updateShouldNotify(Globales old) => data != old.data;
}