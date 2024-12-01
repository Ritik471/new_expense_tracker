import 'package:flutter/material.dart';
import '/Authentication/login.dart';
import '/models/sqlite.dart';
import '/models/users.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});
  static const String name = '/signup';

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final username = TextEditingController();
  final password = TextEditingController();
  final confirmPassword = TextEditingController();
  final formKey = GlobalKey<FormState>();

  bool isVisible = false;
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDarkMode
                ? [Colors.black, Colors.deepPurple]
                : [Colors.deepPurpleAccent, Colors.blueAccent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
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
                      "Register New Account",
                      style: TextStyle(
                        fontSize: 35,
                        fontWeight: FontWeight.bold,
                        color: isDarkMode ? Colors.white : Colors.black,
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Username field
                    Container(
                      margin: const EdgeInsets.all(8),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 15, vertical: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.white.withOpacity(0.2),
                      ),
                      child: TextFormField(
                        controller: username,
                        style: TextStyle(
                            color: isDarkMode ? Colors.white : Colors.black),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return "Username is required";
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          icon: Icon(Icons.person,
                              color: isDarkMode ? Colors.white : Colors.black),
                          border: InputBorder.none,
                          hintText: "Username",
                          hintStyle: TextStyle(color: isDarkMode ? Colors.white70 : Colors.black45),
                        ),
                      ),
                    ),

                    // Password field
                    Container(
                      margin: const EdgeInsets.all(8),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 15, vertical: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.white.withOpacity(0.2),
                      ),
                      child: TextFormField(
                        controller: password,
                        style: TextStyle(
                            color: isDarkMode ? Colors.white : Colors.black),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return "Password is required";
                          }
                          return null;
                        },
                        obscureText: !isVisible,
                        decoration: InputDecoration(
                          icon: Icon(Icons.lock,
                              color: isDarkMode ? Colors.white : Colors.black),
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

                    // Confirm Password field
                    Container(
                      margin: const EdgeInsets.all(8),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 15, vertical: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.white.withOpacity(0.2),
                      ),
                      child: TextFormField(
                        controller: confirmPassword,
                        style: TextStyle(
                            color: isDarkMode ? Colors.white : Colors.black),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return "Password is required";
                          } else if (password.text != confirmPassword.text) {
                            return "Passwords don't match";
                          }
                          return null;
                        },
                        obscureText: !isVisible,
                        decoration: InputDecoration(
                          icon: Icon(Icons.lock,
                              color: isDarkMode ? Colors.white : Colors.black),
                          border: InputBorder.none,
                          hintText: "Confirm Password",
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

                    const SizedBox(height: 20),

                    // Loading indicator or Sign up button
                    isLoading
                        ? CircularProgressIndicator(
                            color: isDarkMode ? Colors.white : Colors.black)
                        : Container(
                            height: 55,
                            width: MediaQuery.of(context).size.width * .9,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: Colors.orangeAccent,
                            ),
                            child: TextButton(
                              onPressed: () {
                                if (formKey.currentState!.validate()) {
                                  setState(() {
                                    isLoading = true;
                                  });

                                  final db = DatabaseHelper();
                                  db
                                      .signup(Users(
                                          usrName: username.text,
                                          usrPassword: password.text))
                                      .whenComplete(() {
                                    setState(() {
                                      isLoading = false;
                                    });
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const LoginScreen()),
                                    );
                                  });
                                }
                              },
                              child: Text(
                                "SIGN UP",
                                style: TextStyle(
                                  color:
                                      isDarkMode ? Colors.black : Colors.white,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                          ),

                    // Sign in button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Already have an account?",
                          style: TextStyle(
                              color: isDarkMode ? Colors.white : Colors.black),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const LoginScreen()),
                            );
                          },
                          child: const Text(
                            "LOGIN",
                            style: TextStyle(color: Colors.orangeAccent),
                          ),
                        ),
                      ],
                    ),
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
