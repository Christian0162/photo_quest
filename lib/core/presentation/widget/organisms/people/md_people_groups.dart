import 'package:flutter/material.dart';

import '../../../../../config/constant/app_spacing.dart';
import '../../../../domain/people/entities/person.dart';
import '../../atoms/common/md_fade_slide_in.dart';
import '../../molecules/common/md_tile_grid.dart';
import '../../molecules/people/md_self_card.dart';
import '../../molecules/people/md_person_group_header.dart';
import '../../molecules/people/md_person_tile.dart';
import '../../molecules/people/md_add_person_card.dart';

/// "You" up top, then one group per relationship, then a way to add
/// someone. Built eagerly — a private circle is a handful of people — so
/// the stagger plays once instead of replaying on scroll.
class MdPeopleGroups extends StatelessWidget {
  const MdPeopleGroups({
    super.key,
    required this.people,
    required this.onAddPerson,
  });

  final List<Person> people;
  final VoidCallback onAddPerson;

  static const _groupOrder = ['partner', 'family', 'friend', 'pet', 'other'];

  static String _groupOf(Person person) =>
      _groupOrder.contains(person.type) ? person.type : 'other';

  @override
  Widget build(BuildContext context) {
    final self = people.where((p) => p.type == 'self').firstOrNull;
    final others = people.where((p) => p.type != 'self').toList();
    final groups = [
      for (final type in _groupOrder)
        (type, others.where((p) => _groupOf(p) == type).toList()),
    ].where((g) => g.$2.isNotEmpty);

    var order = 1;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (self != null) ...[
          MdFadeSlideIn(
            key: ValueKey(self.id),
            order: order++,
            child: MdSelfCard(person: self, circleSize: others.length),
          ),
          const SizedBox(height: AppSpacing.xl),
        ],
        for (final (type, members) in groups) ...[
          MdFadeSlideIn(
            key: ValueKey('group-$type'),
            order: order++,
            child: MdPersonGroupHeader(type: type, count: members.length),
          ),
          const SizedBox(height: AppSpacing.ms),
          MdTileGrid(
            children: [
              for (final person in members)
                MdFadeSlideIn(
                  key: ValueKey(person.id),
                  order: order++,
                  child: MdPersonTile(person: person),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
        ],
        MdFadeSlideIn(
          key: const ValueKey('add-person'),
          order: order,
          child: MdAddPersonCard(onTap: onAddPerson),
        ),
      ],
    );
  }
}
