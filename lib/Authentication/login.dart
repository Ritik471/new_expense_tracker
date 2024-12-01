import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import '../models/sqlite.dart';
import '/Authentication/signup.dart';
import '/models/users.dart';
import '../screens/category_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  static const String name = '/login';

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final username = TextEditingController();
  final password = TextEditingController();
  bool isVisible = false;
  bool isLoginTrue = false;
  bool isLoading = false; // To show loading spinner
  final db = DatabaseHelper();
  final formKey = GlobalKey<FormState>();

  // Biometric Auth
  final LocalAuthentication auth = LocalAuthentication();
  bool _canCheckBiometrics = false;
  List<BiometricType> _availableBiometrics = [];
  bool _isAuthenticated = false;
  bool _useBiometric = false; // To toggle between password and biometric

  @override
  void initState() {
    super.initState();
    _checkBiometricSupport();
  }

  Future<void> _checkBiometricSupport() async {
    try {
      bool canCheckBiometrics = await auth.canCheckBiometrics;
      List<BiometricType> availableBiometrics = await auth.getAvailableBiometrics();
      setState(() {
        _canCheckBiometrics = canCheckBiometrics;
        _availableBiometrics = availableBiometrics;
      });
    } catch (e) {
      print("Error checking biometric support: $e");
    }
  }

  Future<void> _authenticateWithBiometrics() async {
    try {
      bool authenticated = await auth.authenticate(
        localizedReason: 'Authenticate to access your account',
        options: const AuthenticationOptions(
          biometricOnly: true, // Use only biometrics
        ),
      );
      setState(() {
        _isAuthenticated = authenticated;
      });
      if (authenticated) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const CategoryScreen()),
        );
      }
    } catch (e) {
      print("Error during biometric authentication: $e");
    }
  }

  login() async {
    try {
      setState(() {
        isLoading = true;
      });

      var response = await db.login(
        Users(usrName: username.text.trim(), usrPassword: password.text.trim()),
      );

      setState(() {
        isLoading = false;
      });

      if (response == true) {
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const CategoryScreen()),
        );
      } else {
        setState(() {
          isLoginTrue = true;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      _showErrorDialog("An error occurred while logging in.");
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            child: const Text('Okay'),
            onPressed: () {
              Navigator.of(ctx).pop();
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Check the current theme (light or dark)
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // Define gradients for light and dark mode
    const lightModeGradient = LinearGradient(
      colors: [Colors.deepPurpleAccent,Colors.blueAccent],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    const darkModeGradient = LinearGradient(
      colors: [Colors.deepPurple, Colors.black],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: isDarkMode ? darkModeGradient : lightModeGradient,
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "Login Here",
                      style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: isDarkMode ? Colors.white : Colors.black,
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Toggle between biometric and password login
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Use Biometric?",
                          style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
                        ),
                        Switch(
                          value: _useBiometric,
                          onChanged: (value) {
                            setState(() {
                              _useBiometric = value;
                            });
                          },
                        ),
                      ],
                    ),

                    if (!_useBiometric) ...[
                      // Username field
                      Container(
                        margin: const EdgeInsets.all(8),
                        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.white.withOpacity(0.2),
                        ),
                        child: TextFormField(
                          controller: username,
                          style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
                          validator: (value) {
                            if (value!.isEmpty) {
                              return "Username is required";
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            icon: Icon(Icons.person, color: isDarkMode ? Colors.white : Colors.black),
                            border: InputBorder.none,
                            hintText: "Username",
                            hintStyle: TextStyle(color: isDarkMode ? Colors.white70 : Colors.black45),
                          ),
                        ),
                      ),

                      // Password field
                      Container(
                        margin: const EdgeInsets.all(8),
                        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.white.withOpacity(0.2),
                        ),
                        child: TextFormField(
                          controller: password,
                          style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
                          validator: (value) {
                            if (value!.isEmpty) {
                              return "Password is required";
                            }
                            return null;
                          },
                          obscureText: !isVisible,
                          decoration: InputDecoration(
                            icon: Icon(Icons.lock, color: isDarkMode ? Colors.white : Colors.black),
                            border: InputBorder.none,
                            hintText: "Password",
                            hintStyle: TextStyle(color: isDarkMode ? Colors.white70 : Colors.black45),
                            suffixIcon: IconButton(
                              onPressed: () {
                                setState(() {
                                  isVisible = !isVisible;
                                });
                              },
                              icon: Icon(
                                isVisible
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: isDarkMode ? Colors.white70 : Colors.black45,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],

                    const SizedBox(height: 20),

                    // Loading indicator or Login button
                    isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Column(
                            children: [
                              if (!_useBiometric)
                                Container(
                                  height: 55,
                                  width: MediaQuery.of(context).size.width * .9,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    color: Colors.orangeAccent,
                                  ),
                                  child: TextButton(
                                    onPressed: () {
                                      if (formKey.currentState!.validate()) {
                                        login();
                                      }
                                    },
                                    child: const Text(
                                      "LOGIN",
                                      style: TextStyle(color: Colors.white, fontSize: 18),
                                    ),
                                  ),
                                ),

                              if (_useBiometric && _canCheckBiometrics)
                                TextButton.icon(
                                  onPressed: _authenticateWithBiometrics,
                                  icon: const Icon(Icons.fingerprint, color: Colors.white),
                                  label: const Text(
                                    "Login with Fingerprint",
                                    style: TextStyle(color: Colors.orangeAccent),
                                  ),
                                ),
                            ],
                          ),

                    // Sign up button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Don't have an account?",
                          style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const SignUp()),
                            );
                          },
                          child: const Text("SIGN UP", style: TextStyle(color: Colors.orangeAccent)),
                        ),
                      ],
                    ),

                    // Error message display
                    if (isLoginTrue)
                      const Text(
                        "Username or password is incorrect",
                        style: TextStyle(color: Colors.red),
                      )
                    else
                      const SizedBox(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
