import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/people/entities/person.dart';
import '../molecules/md_app_widget_preview.dart';
import 'people_template.dart';
import 'preview_samples.dart';

Widget _people(AsyncValue<List<Person>> people) {
  return MdAppWidgetPreview(
    child: PeopleTemplate(people: people, onRetry: () {}, onAddPerson: () {}),
  );
}

@Preview(
  name: 'People — your people',
  group: 'templates',
  size: previewPhoneSize,
)
Widget peopleTemplatePreview() => _people(AsyncData(PreviewSamples.people));

@Preview(name: 'People — empty', group: 'templates', size: previewPhoneSize)
Widget peopleTemplateEmptyPreview() => _people(const AsyncData([]));
