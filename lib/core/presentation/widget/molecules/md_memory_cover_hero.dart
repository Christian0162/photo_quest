import 'package:flutter/material.dart';

/// Lets a memory's cover photo fly from its card into the Memory detail, so
/// opening a memory feels like picking up the print. See design system §33,
/// §49.
///
/// Home and Memories live in separate, always-mounted tabs; the inactive
/// tab has tickers off, and its heroes are switched off too so two cards
/// never claim the same tag.
class MdMemoryCoverHero extends StatelessWidget {
  const MdMemoryCoverHero({
    super.key,
    required this.memoryId,
    required this.child,
  });

  final String memoryId;
  final Widget child;

  static Object tagFor(String memoryId) => 'memory-cover-$memoryId';

  @override
  Widget build(BuildContext context) {
    return HeroMode(
      enabled: TickerMode.valuesOf(context).enabled,
      child: Hero(
        tag: tagFor(memoryId),
        // Fly the already-decoded image that's leaving, not the one still
        // loading at the destination, so the flight never blinks.
        flightShuttleBuilder: (context, animation, direction, from, to) {
          final hero =
              (direction == HeroFlightDirection.push ? from : to).widget
                  as Hero;
          return hero.child;
        },
        child: child,
      ),
    );
  }
}
