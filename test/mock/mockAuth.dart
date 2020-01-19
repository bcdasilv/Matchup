import 'package:firebase_auth/firebase_auth.dart';
import 'package:matchup/bizlogic/authentication.dart';

class MockAuth implements BaseAuth{
  bool _didAttemptSignUp = false;

  bool _didAttemptSignIn = false;

  bool get getDidAttemptSignIn => _didAttemptSignIn;

  bool get getDidAttemptSignUp => _didAttemptSignIn;

  @override
  Future<FirebaseUser> getCurrentUser() {
    // TODO: implement getCurrentUser
    return null;
  }

  @override
  Future<bool> isEmailVerified() {
    // TODO: implement isEmailVerified
    return null;
  }

  @override
  Future<void> sendEmailVerification() {
    // TODO: implement sendEmailVerification
    return null;
  }

  @override
  Future<String> signIn(String email, String password) async{
    _didAttemptSignIn = true;
    if (email == "foo@gmail.com" && password == "123456"){
      return '123456789';
    }
    return null;
  }

  @override
  Future<void> signOut() {
    // TODO: implement signOut
    return null;
  }

  @override
  Future<String> signUp(String email, String password) {
    _didAttemptSignUp = true;
    return null;
  }

}