/// What has been typed into the "Add someone" sheet so far.
class AddPersonDraft {
  const AddPersonDraft({this.name = '', this.type = 'family'});

  final String name;
  final String type;

  String get trimmedName => name.trim();
  bool get canSubmit => trimmedName.isNotEmpty;

  AddPersonDraft copyWith({String? name, String? type}) =>
      AddPersonDraft(name: name ?? this.name, type: type ?? this.type);
}
