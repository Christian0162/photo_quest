/// A single instruction/photo the creator wants captured.
class DraftShot {
  const DraftShot({required this.instruction, this.shotType = 'group'});

  final String instruction;
  final String shotType;
}
