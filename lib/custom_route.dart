import 'package:flutter/material.dart';
//import 'transition_route_observer.dart';
class FadePageRoute<T> extends MaterialPageRoute<T> {
  FadePageRoute({
    WidgetBuilder builder,
    RouteSettings settings,
  }) : super(
    builder: builder,
    settings: settings,
  );

  @override Duration get transitionDuration => const Duration(milliseconds: 600);

  @override
  Widget buildTransitions(
      BuildContext context,
      Animation<double> animation,
      Animation<double> secondaryAnimation,
      Widget child,
      ) {
      return child;
  }
}