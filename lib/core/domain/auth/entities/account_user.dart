/// The signed-in account, as far as the UI needs to know. Passwords and
/// tokens never leave the auth repository.
class AccountUser {
  const AccountUser({required this.id, required this.email});

  final String id;
  final String email;
}
