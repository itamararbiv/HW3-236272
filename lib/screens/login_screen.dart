import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/firebase_notifier.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _loginFailedSnackBar =
  const SnackBar(content: Text('There was an error logging into the app.'));
  final _loginSuccessSnackBar =
  const SnackBar(content: Text('Login Successful!'));
  final _signUpSuccessSnackBar =
  const SnackBar(content: Text('Register Successful!, Login In Process.'));
  final _signUpFailedSnackBar = const SnackBar(
      content: Text('There was an error with signUp to the app.'));

  bool validPasswordCheck = true;

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController passwordVerifyController = TextEditingController();

  void loginUserIn() async {
    debugPrint("User trying to login...");
    debugPrint(emailController.text.trim());
    await context.read<FirebaseNotifier>().signIn(
        emailController.text.trim(),
        passwordController.text.trim());
    if (!mounted) {
      return;
    }
    debugPrint(context
        .read<FirebaseNotifier>()
        .currentUserEmail);
    if (context
        .read<FirebaseNotifier>()
        .currentUserEmail !=
        "") {
      debugPrint(emailController.text.trim());

      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      Navigator.pop(context);
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context)
          .showSnackBar(_loginSuccessSnackBar);
    } else {
      debugPrint(emailController.text.trim());

      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context)
          .showSnackBar(_loginFailedSnackBar);
    }
  }

  void registerUser() async {
    debugPrint("User trying to sign up...");
    String registerEmail =
    emailController.text.trim();
    if (passwordVerifyController.text
        .trim() ==
        passwordController.text.trim()) {
      Navigator.pop(context);
      User? signUpResult = await context
          .read<FirebaseNotifier>()
          .signUp(registerEmail,
          passwordController.text.trim());
      if (!mounted) {
        return;
      }
      if (signUpResult != null) {
        ScaffoldMessenger.of(context)
            .showSnackBar(
            _signUpSuccessSnackBar);
        loginUserIn();
      }
      else {
        ScaffoldMessenger.of(context)
            .showSnackBar(
            _signUpFailedSnackBar);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    debugPrint("Built Login Screen");
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: LayoutBuilder(
        builder: (context, constraints) =>
            Column(children: [
              const SizedBox(height: 25),
              const Align(
                alignment: Alignment.center,
                child: Text(
                  'Welcome, Have Fun!',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 15),
              TextFieldContainer(
                child: TextFormField(
                  controller: emailController,
                  autofillHints: const [AutofillHints.email],
                  onEditingComplete: () => TextInput.finishAutofillContext(),
                  decoration: const InputDecoration(
                      contentPadding: EdgeInsets.symmetric(vertical: 3.0),
                      border: InputBorder.none,
                      icon: Icon(
                        Icons.email,
                        color: Colors.blue,
                      ),
                      labelText: 'Email'),
                ),
              ),
              TextFieldContainer(
                child: TextFormField(
                  controller: passwordController,
                  obscureText: true,
                  onEditingComplete: () => TextInput.finishAutofillContext(),
                  decoration: const InputDecoration(
                      contentPadding: EdgeInsets.symmetric(vertical: 3.0),
                      border: InputBorder.none,
                      icon: Icon(
                        Icons.lock,
                        color: Colors.blue,
                      ),
                      labelText: 'Password'),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter Password';
                    }
                    return null;
                  },
                ),
              ),
              ElevatedButton(
                onPressed: context
                    .watch<FirebaseNotifier>()
                    .signInStatus
                    ? null
                    : loginUserIn,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 95.0, vertical: 10.0),
                  shape: const StadiumBorder(),
                  backgroundColor: Colors.red,
                ),
                child: const Text('Login'),
              )
              ,
              const SizedBox(height: 5),
              ElevatedButton(
                onPressed: () async {
                  showModalBottomSheet<void>(
                    // isScrollControlled: true,
                    context: context,
                    builder: (BuildContext context) {
                      return Form(
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        child: SingleChildScrollView(
                          child: AnimatedPadding(
                            padding: MediaQuery
                                .of(context)
                                .viewInsets,
                            duration: const Duration(milliseconds: 100),
                            curve: Curves.decelerate,
                            child: Column(
                              children: <Widget>[
                                Container(
                                  color: Colors.green,
                                  child: const Material(
                                    child: ListTile(
                                      title: Text(
                                          'Please confirm your password below:'),
                                    ),
                                  ),
                                ),
                                TextFieldContainer(
                                  child: TextFormField(
                                    controller: passwordVerifyController,
                                    obscureText: true,
                                    onEditingComplete: () =>
                                        TextInput.finishAutofillContext(),
                                    decoration: const InputDecoration(
                                        contentPadding:
                                        EdgeInsets.symmetric(vertical: 3.0),
                                        border: InputBorder.none,
                                        icon: Icon(
                                          Icons.password,
                                          color: Colors.blue,
                                        ),
                                        labelText: 'Password Again...'),
                                    validator: (value) {
                                      if (value != null &&
                                          value !=
                                              passwordController.text.trim()) {
                                        return "Passwords must match";
                                      } else {
                                        return null;
                                      }
                                    },
                                  ),
                                ),
                                Container(
                                    padding: const EdgeInsets.all(10),
                                    child: ElevatedButton(
                                        onPressed: registerUser,
                                        style: ElevatedButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 40.0, vertical: 10.0),
                                          shape: const StadiumBorder(),
                                          backgroundColor: Colors.blue,
                                        ),
                                        child: const Text(
                                          "Confirm",
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 12),
                                        ))),
                              ],
                            ),)
                          ,
                        )
                        ,
                      );
                    }

                    ,

                  );
                }, style: ElevatedButton.styleFrom(padding: const EdgeInsets
                  .symmetric(horizontal: 40.0
                  ,
                  vertical: 10.0
              )
                ,
                shape: const StadiumBorder()
                ,
                backgroundColor: Colors.blue,)
                ,
                child: const Text("New user? Click to sign up "
                  ,
                  style: TextStyle
                    (
                      color: Colors.white, fontSize: 12
                  )
                  ,
                )
                ,
              )
              ,
              const SizedBox(height: 15),
            ]),
      ),
    );
  }
}

class TextFieldContainer extends StatelessWidget {
  final Widget child;

  const TextFieldContainer({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery
        .of(context)
        .size;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      width: size.width * 0.8,
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(29),
      ),
      child: child,
    );
  }
}
