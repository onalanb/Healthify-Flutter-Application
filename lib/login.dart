import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/signup.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'healhify_app.dart';

class Login extends StatelessWidget {

  const Login({Key? key}) : super(key: key);

  Future<bool> loginWithEmailPassword(String email, String password) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email,
          password: password
      );
      User? user = userCredential.user;
      print('User signed in: ${user?.uid}');
      return true;
    } catch (e) {
      print('Error signing in: $e');
      return false;
    }
  }

  // Sign in anonymously
  Future<void> loginAnonymously() async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance.signInAnonymously();
      // Access the signed-in user via userCredential.user
      User? user = userCredential.user;
      print('Anonymous user signed in: ${user?.uid}');
    } catch (e) {
      print('Error signing in anonymously: $e');
    }
  }

  void showLoginFailedDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Login Failed'),
          content: const Text('Please make sure you are signed up, check your email/password, and try again.'),
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
    TextEditingController emailController = TextEditingController();
    TextEditingController passwordController = TextEditingController();
    // For easier testing.
    // emailController.text = 'baran.onalan@gmail.com';
    // passwordController.text = 'password';

    return MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: ThemeData(
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xDED04646), // Background color for app bar.
          ),
          colorScheme: ColorScheme.fromSwatch(
            primarySwatch: Colors.deepOrange,  // Background color for the app.
          ),
        ),
      home: Scaffold(
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Welcome to Healthify", style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
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
              obscureText: true,
              decoration: InputDecoration(
                hintText: "Password",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(20.0)),
                prefixIcon: const Icon(Icons.password),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () async {
                String email = emailController.text;
                String password = passwordController.text;
                bool successfulLogin = await loginWithEmailPassword(email, password);
                if (successfulLogin) {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => MaterialApp(
                              localizationsDelegates: AppLocalizations.localizationsDelegates,
                              supportedLocales: AppLocalizations.supportedLocales,
                              home: Scaffold(
                                body: HealthifyApp(),
                              ),
                            )));
                } else {
                  showLoginFailedDialog(context);
                }
              },
              child: const Text("Login", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.deepOrange)),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const Text("Don't have an account?", style: TextStyle(fontSize: 14)),
                TextButton(
                  onPressed: () => Navigator.push(context,
                      MaterialPageRoute(builder: (context) => Signup())),
                  child: Text("SignUp", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo[400])),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const Text("Or you can launch app as", style: TextStyle(fontSize: 14)),
                TextButton(
                  onPressed: () async {
                    await loginAnonymously();
                    Navigator.push(context, MaterialPageRoute(builder: (context) => MaterialApp(
                      localizationsDelegates: AppLocalizations.localizationsDelegates,
                      supportedLocales: AppLocalizations.supportedLocales,
                      home: Scaffold(
                        body: HealthifyApp(),
                      ),
                    )));
                  },
                  child: Text("Anonymous", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo[400])),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}