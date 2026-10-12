/// The three account types Novelly supports, matching the "Register as"
/// dropdown already in register.dart (_accountTypes).
enum UserRole { writer, publisher, coverArtist, writerAndPublisher }

UserRole userRoleFromLabel(String label) {
  switch (label) {
    case 'Publisher':
      return UserRole.publisher;
    case 'Cover Artist':
      return UserRole.coverArtist;
    case 'Writer and Publisher':
      return UserRole.writerAndPublisher;
    case 'Writer':
    default:
      return UserRole.writer;
  }
}

String userRoleToLabel(UserRole role) {
  switch (role) {
    case UserRole.publisher:
      return 'Publisher';
    case UserRole.coverArtist:
      return 'Cover Artist';
    case UserRole.writerAndPublisher:
      return 'Writer and Publisher';
    case UserRole.writer:
      return 'Writer';
  }
}

/// The MongoDB-backed profile for a signed-in user, returned by our own
/// backend server (see backend/src/routes/users.js). This is separate
/// from Firebase's own User object (which only knows uid/email/
/// displayName) — this is "the rest" of the profile: role, and whatever
/// else gets added later (bio, royaltyInfo, portfolio, etc.).
class AppUser {
  final String uid;
  final String name;
  final String email;
  final UserRole role;

  const AppUser({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
  });

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      uid: json['uid'] as String,
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      role: userRoleFromLabel(json['role'] as String? ?? 'Writer'),
    );
  }
}
