import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'login.dart';

class Signup extends StatefulWidget {
  const Signup({Key? key}) : super(key: key);

  @override
  _SignupState createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool agreedToTerms = false;

  Future<String> signUpWithEmailPassword(String email, String password) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email,
          password: password
      );
      User? user = userCredential.user;
      print('User signed up: ${user?.uid}');
      return "";
    } on FirebaseAuthException catch (e) {
      print('Error signing up: $e');
      return e.message!;
    }
  }

  void showSignupFailedDialog(BuildContext context, String error) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Signup Failed'),
          content: Text(error),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  void showIncorrectUsernamePasswordDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Incorrect input'),
          content: const Text('Please enter your email/password, and try again.'),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: ThemeData(
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xDED04646), // Background color for app bar.
        ),
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: Colors.deepOrange, // Background color for the app.
        ),
      ),
      home: Scaffold(
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Sign up with Healthify", style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
            const SizedBox(height: 30),
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                hintText: "Email",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(20.0)),
                prefixIcon: const Icon(Icons.email),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: passwordController,
              obscureText: false,
              decoration: InputDecoration(
                hintText: "Password",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(20.0)),
                prefixIcon: const Icon(Icons.password),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Checkbox(
                  value: agreedToTerms,
                  onChanged: (value) {
                    setState(() {
                      agreedToTerms = value ?? false;
                    });
                  },
                ),
                const Text(
                  "I agree to share my Recording Points with other users.",
                  style: TextStyle(fontSize: 14),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () async {
                String email = emailController.text;
                String password = passwordController.text;
                if (email.isEmpty || password.isEmpty || !email.contains('@') || !email.contains('.')) {
                  showIncorrectUsernamePasswordDialog(context);
                } else if (!agreedToTerms) {
                  showSignupFailedDialog(context, "Please agree to terms before proceeding with signup");
                } else {
                  String signupResult = await signUpWithEmailPassword(
                      email, password);
                  if (signupResult.isEmpty) {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) =>
                        const MaterialApp(
                          localizationsDelegates: AppLocalizations
                              .localizationsDelegates,
                          supportedLocales: AppLocalizations.supportedLocales,
                          home: Scaffold(
                            body: Login(),
                          ),
                        )));
                  } else {
                    showSignupFailedDialog(context, signupResult);
                  }
                }
              },
              child: const Text("Signup", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.deepOrange)),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const Text("Already have an account?", style: TextStyle(fontSize: 14)),
                TextButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => Login()),
                  ),
                  child: Text("Login", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo[400])),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}