import 'package:bag_flow/services/user_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  // Firebase Auth instance
  final FirebaseAuth _auth;

  // If no instance is passed, use a default one
  AuthService({FirebaseAuth? auth}) : _auth = auth ?? FirebaseAuth.instance;

  // Stream emits values over time like a live feed/subscription whenever something changes
  // In this case, if user is logged-in or not
  Stream<User?> authStateChanges() {
    return _auth.authStateChanges();
  }

  // If someone is logged in, you get a User; otherwise, null
  User? get currentUser => _auth.currentUser;

  Future<UserCredential> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    return await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password.trim(),
    );
  }

  Future<UserCredential> signInWithEmail({
    required String email,
    required String password,
  }) async {
    return await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password.trim(),
    );
  }

  Future<void> sendPasswordResetEmail({required String email}) async {
    await _auth.sendPasswordResetEmail(email: email.trim());
  }

  // Logs out of both features 
  Future<void> signOut() async {
    await GoogleSignIn().signOut();
    await _auth.signOut(); 
  }

  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required Function(PhoneAuthCredential credential) verificationCompleted,
    required Function(FirebaseAuthException e) verificationFailed,
    required Function(String verificationId, int? resendToken) codeSent,
    required Function(String verificationId) codeAutoRetrievalTimeout,
  }) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: verificationCompleted,
      verificationFailed: verificationFailed,
      codeSent: codeSent,
      codeAutoRetrievalTimeout: codeAutoRetrievalTimeout,
    );
  }

  // Proof of identity 
  Future<UserCredential> signInWithCredential(AuthCredential credential) async {
    return await _auth.signInWithCredential(credential);
  }

  Future<UserCredential> verifyOTP({
    required String verificationId,
    required String smsCode,
  }) async {
    final credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: smsCode,
    );

    return await _auth.signInWithCredential(credential);
  }

  Future<UserCredential> signInWithGoogle() async {
    // A GoogleSignInAccount exists if successful
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    if (googleUser == null) {
      throw FirebaseAuthException(
        code: 'google-sign-in-cancelled',
        message: 'Google sign-in was cancelled',
      );
    }

    // Get the authentication tokens from the Google account the user picked 
    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    return await _auth.signInWithCredential(credential);
  }
}
