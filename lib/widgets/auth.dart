
import 'package:flutter_twitter/flutter_twitter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
// import 'dart:convert';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  //get http => null;

  FirebaseAuth auth() => _auth;
  Stream<User> get authStateChanges => _auth.authStateChanges();
  // _auth.idTokenChanges();
  GoogleSignIn _googleSignIn = GoogleSignIn();

  TwitterLogin _twitterSignIn = TwitterLogin(
    consumerKey: '2roApBM7n1ONkGN3hJD7d4Eb8',
    consumerSecret: 'p1fj9LufFZnbvDmjbUkAlsD3OBN4ZGVfdabLXLBGWJTcaJSNIp',
  );

  bool userLoggedIn = false;
  String email, password;
  String userImage, userInfo, message, userID;

  // Create account with Email & Password

  Future createAccountWithEmailAndPassword() async {
    assert(email != null && password != null);
    UserCredential result = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    User user = result.user;
    userLoggedIn = true;
    userInfo = user.email;
    userID = user.uid;
    message = 'You created new account successfully';
  }

  // Sign in with Email & Password

  Future signInWithEmailAndPassword() async {
    try{
    assert(email != null && password != null);
    UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email, password: password);
    User user = result.user;

    userLoggedIn = true;
    userInfo = user.email;
    userID = user.uid;
    message = 'Welcome to your account';
    }
    on FirebaseAuthException catch(e){
      return e.message;
    }
  }

  // Sign in with Google

  Future signInWithGoogle() async {
    final GoogleSignInAccount googleSignInAccount =
        await _googleSignIn.signIn();
    final GoogleSignInAuthentication googleSignInAuthentication =
        await googleSignInAccount.authentication;

    final AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleSignInAuthentication.accessToken,
      idToken: googleSignInAuthentication.idToken,
    );

    final UserCredential authResult =
        await _auth.signInWithCredential(credential);
    final User user = authResult.user;

    assert(!user.isAnonymous);
    assert(await user.getIdToken() != null);

    final User currentUser = _auth.currentUser;

    assert(user.uid == currentUser.uid);

    userLoggedIn = true;
    userImage = currentUser.photoURL;
    userInfo = currentUser.displayName;
    message = 'You signed in with Google';
  }

  // Sign in with Facebook

  // Future signInWithFacebook() async {
  //   final FacebookLoginResult result = await _fbSignIn.logIn(["email"]);
  //   final String token = result.accessToken.token;
  //   assert(token != null);
  //   // final response = await http.get(
  //   //     'https://graph.facebook.com/v2.12/me?fields=name,first_name,last_name,email&access_token=$token');
  //   final profile = jsonDecode(response.body);

  //   userLoggedIn = true;
  //   userInfo = profile['name'];
  //   message = 'You signed in with Facebook';
  // }

  // Sign in with Twitter

  Future signInWithTwitter() async {
    final TwitterLoginResult result = await _twitterSignIn.authorize();

    switch (result.status) {
      case TwitterLoginStatus.loggedIn:
        TwitterSession session = result.session;
        userLoggedIn = true;
        userInfo = session.username;
        message = 'You signed in with Twitter';
        break;

      case TwitterLoginStatus.cancelledByUser:
        print('Cancelled by user');
        break;

      case TwitterLoginStatus.error:
        print(result.errorMessage);
        break;
    }
  }

  // Sign out

  Future signOut() async {
    if (userLoggedIn) {
      await _auth.signOut();
      await _googleSignIn.signOut();
      await _twitterSignIn.logOut();
      userImage = null;
      userInfo = null;
      message = null;
      userLoggedIn = false;
      userID = null;
      email = null;
    }
  }
}
