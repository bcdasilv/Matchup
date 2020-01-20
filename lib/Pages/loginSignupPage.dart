import 'package:flutter/material.dart';
import 'package:matchup/bizlogic/authProvider.dart';
import 'package:matchup/bizlogic/authentication.dart';
import 'package:matchup/bizlogic/emailValidator.dart';
import 'package:matchup/bizlogic/passwordValidator.dart';
import 'package:matchup/bizlogic/validator.dart';
import 'userInfoEntryPage.dart';
import 'homepage.dart';

class LogInSignupPage extends StatefulWidget {
  final String userId;
  final VoidCallback loginCallback;
  final VoidCallback logoutCallback;

  LogInSignupPage({this.userId, this.loginCallback, this.logoutCallback});
  
  @override
  _LogInSignupPageState createState() => _LogInSignupPageState();
}

class _LogInSignupPageState extends State<LogInSignupPage> {
  _LogInSignupPageState();
  TextStyle style = TextStyle(fontFamily: 'Montserrat', fontSize: 20.0);
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  String _email;
  String _password;
  String _errorMessage;

  bool _isLoginForm;
  bool _isLoading;
  final _formKey = new GlobalKey<FormState>();

  @override
  void initState() {
    _errorMessage = "";
    _isLoading = false;
    _isLoginForm = true;
    super.initState();
  }

  void resetForm(){
    _formKey.currentState.reset();
    _errorMessage = "";
    _email = null;
    _password = null;
    emailController.clear();
    passwordController.clear();
  }

  void toggleFormMode() {
    resetForm();
    setState(() {
      _isLoginForm = !_isLoginForm;
    });
  } 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
          body: Stack(
          children: <Widget>[
            _showLogInForm(),
          ],
        ));
  }

  Widget showEmailField(){
    Validator emailValidator = EmailValidator();
    return Padding(
      padding: EdgeInsets.fromLTRB(0.0, 150.0, 10.0, 0.0),
      child: new TextFormField(
          key: Key('email'),
          obscureText: false,
          maxLines: 1,
          style: style,
          autofocus: false,
          controller: emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
              hintText: "Email",
              icon: new Icon(Icons.mail, 
              color: Colors.blueGrey,
              )),
          validator: (value) => emailValidator.validate(value),
          onSaved: (value) => _email = emailValidator.save(value),
      ),
    );
  } 

  Widget showPasswordField(){
    Validator passwordValidator = PasswordValidator();
    return Padding(
      padding: EdgeInsets.fromLTRB(0.0, 15.0, 10.0, 0.0),
      child: new TextFormField(
          key: Key('password'),
          maxLines: 1,
          obscureText: true,
          autofocus: false,
          style: style,
          controller: passwordController,
          decoration: InputDecoration(
              //contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
              hintText: "Password",
              icon: new Icon(Icons.lock,
              color: Colors.blueGrey
              )),
          validator: (value) => passwordValidator.validate(value),
          onSaved: (value) => _password = passwordValidator.save(value),
      ),
    );
  }

  Widget showLogInButton(){
    return new Padding(
        padding: EdgeInsets.fromLTRB(20.0, 45.0, 20.0, 0.0),
        child: SizedBox(
          height: 40.0,
          child: new RaisedButton(
            key: Key('login'),
            elevation: 5.0,
            shape: new RoundedRectangleBorder(
                borderRadius: new BorderRadius.circular(30.0)),
            color: Colors.deepOrange,
            child: new Text(_isLoginForm ? 'Login' : 'Create account',
                style: new TextStyle(fontSize: 20.0, color: Colors.white)),
            onPressed: validateAndSubmit,
          ),
        ));
  }
  
  Widget showSwitchButton(){
        return new FlatButton(
          key: Key('switch between login/singup'),
        child: new Text(
            _isLoginForm ? 'Create an account' : 'Have an account? Sign in',
            style: new TextStyle(fontSize: 18.0, fontWeight: FontWeight.w300)),
        onPressed: toggleFormMode);
  }
  Widget showLogo(){
    return SizedBox(
      child: Image(
        key: Key('logo'),
        image: AssetImage('assets/images/logo.png'),
      ),
      height: 200,
      width: 400,
    );
  }

  Widget showErrorMessage() {
    if (_errorMessage.length > 0 && _errorMessage != null) {
      return new Text(
        _errorMessage,
        style: TextStyle(
            fontSize: 13.0,
            color: Colors.red,
            height: 1.0,
            fontWeight: FontWeight.w300),
      );
    } else {
      return new Container(
        height: 0.0,
      );
    }
  }

// Check if form is valid before perform login or signup
  bool validateAndSave() {
    final form = _formKey.currentState;
    if (form.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  // Perform login or signup
  void validateAndSubmit() async {
    final BaseAuth auth = AuthProvider.of(context).auth;
    setState(() {
      _errorMessage = "";
      _isLoading = true;
    });
    if (validateAndSave()) {
      print("passed validate and save");
      String userId = "";
      try {
        if (_isLoginForm) {
          print("calling sign in function");
          userId = await auth.signIn(_email, _password);
          print('Signed in: $userId');
        } else {
          userId = await auth.signUp(_email, _password);
          //widget.auth.sendEmailVerification();
          //_showVerifyEmailSentDialog();
          print('Signed up user: $userId');
        }
        setState(() {
          _isLoading = false;
        });

        if (userId != null && userId.length > 0 && _isLoginForm) {
          // found user, collect their data information from the data base and initialize the users info
          // this can be done in the login call back
          widget.loginCallback();
        }
        // successfully logged in and heading to user info entry page
        else if (_isLoginForm == false){
          // push a home page first 
          Navigator.push(context,
          MaterialPageRoute(builder: (context) => HomePage(logoutCallback: widget.logoutCallback))
          );
          // push a info entry page second so that once the form is completed, info entry is popped to the homepage
          Navigator.push(context,
          MaterialPageRoute(builder: (context) => UserInfoEntryPage(logoutCallback: widget.logoutCallback))
          );
        }
      } catch (e) {
        print('Error: $e');
        print("IN ERROR HANDLER");
        setState(() {
          _isLoading = false;
          _errorMessage = e.message;
          _formKey.currentState.reset();
        });
      }
    }
  }

  Widget _showLogInForm() {
     return Container(
        padding: EdgeInsets.all(16.0),
        child: new Form(
          key: _formKey,
          child: new ListView(
            shrinkWrap: true,
            children: <Widget>[
              showLogo(),
              showEmailField(),
              showPasswordField(),
              showLogInButton(),
              showSwitchButton(),
              showErrorMessage(),
            ],
          ),
        ));
  }
}