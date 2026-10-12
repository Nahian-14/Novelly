import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// Thin wrapper around Firebase Auth. Every screen talks to auth through
/// this class instead of calling `FirebaseAuth.instance` directly, so all
/// our sign-in/sign-up/sign-out logic lives in one place.
///
/// Email/password and Google sign-in both end up as a Firebase [User]. Once
/// we have that, [ApiService] (see api_service.dart) takes the Firebase ID
/// token and syncs/fetches the matching profile from our own backend,
/// which is the thing that actually lives in MongoDB.
class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  /// Fires whenever the signed-in user changes (sign in, sign out, token
  /// refresh). `main.dart` listens to this to decide whether to show the
  /// login screen or the signed-in home screen.
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  /// The currently signed-in Firebase user, or null if nobody is signed in.
  User? get currentUser => _firebaseAuth.currentUser;

  /// Signs in with email + password. Throws a [FirebaseAuthException] on
  /// failure (wrong password, no such user, etc.) — callers should catch
  /// that and show `e.message` to the user.
  Future<User?> signInWithEmail({
    required String email,
    required String password,
  }) async {
    final credential = await _firebaseAuth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    return credential.user;
  }

  /// Creates a brand-new Firebase account with email + password, and sets
  /// the account's display name to [name]. Throws a [FirebaseAuthException]
  /// on failure (email already in use, weak password, etc.).
  Future<User?> registerWithEmail({
    required String name,
    required String email,
    required String password,
  }) async {
    final credential = await _firebaseAuth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    await credential.user?.updateDisplayName(name.trim());
    await credential.user?.reload();
    return _firebaseAuth.currentUser;
  }

  /// Runs the Google sign-in flow and signs the result into Firebase.
  /// Returns null if the user cancels the Google account picker.
  Future<User?> signInWithGoogle() async {
    final googleUser = await _googleSignIn.signIn();
    if (googleUser == null) {
      // User backed out of the Google account picker — not an error.
      return null;
    }

    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final userCredential = await _firebaseAuth.signInWithCredential(
      credential,
    );
    return userCredential.user;
  }

  /// Sends a password-reset email through Firebase.
  Future<void> sendPasswordResetEmail(String email) {
    return _firebaseAuth.sendPasswordResetEmail(email: email.trim());
  }

  /// Signs out of both Firebase and Google (so the Google account picker
  /// shows up again next time, instead of silently reusing the last pick).
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _firebaseAuth.signOut();
  }
}
