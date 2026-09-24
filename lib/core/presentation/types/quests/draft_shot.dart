/// A single instruction/photo the creator wants captured. See CLAUDE.md
/// §17-19.
class DraftShot {
  const DraftShot({required this.instruction, this.shotType = 'group'});

  final String instruction;
  final String shotType;
}
