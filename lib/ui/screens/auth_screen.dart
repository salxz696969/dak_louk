import 'package:dak_louk/core/enums/role_enum.dart';
import 'package:dak_louk/domain/services/auth_service.dart';
import 'package:dak_louk/domain/models/models.dart';
import 'package:dak_louk/ui/widgets/merchant/merchant_scaffold.dart';
import 'package:dak_louk/ui/widgets/user/user_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:dak_louk/ui/widgets/auth/log_in.dart';
import 'package:dak_louk/ui/widgets/auth/sign_up.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool isLogIn = false;
  final AuthService _authService = AuthService();
  void handleSignUp(SignUpDTO dto) async {
    await _authService.signUpUser(dto);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const UserScaffold()),
    );
  }

  void handleLogIn(LogInDTO dto) async {
    final role = await _authService.login(dto);
    if (role == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid email or password')),
      );
    } else if (role == Role.user) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const UserScaffold()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MerchantScaffold()),
      );
    }
  }

  void handleSwitchTab() {
    setState(() {
      isLogIn = !isLogIn;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Welcome',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 40),
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => isLogIn = true),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            color: isLogIn
                                ? Theme.of(context).colorScheme.secondary
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Log In',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: isLogIn ? Colors.white : Colors.grey[600],
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => isLogIn = false),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            color: !isLogIn
                                ? Theme.of(context).colorScheme.secondary
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Sign Up',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: !isLogIn ? Colors.white : Colors.grey[600],
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              if (isLogIn) LogIn(onLogIn: handleLogIn),
              if (!isLogIn) SignUp(onSignUp: handleSignUp),
            ],
          ),
        ),
      ),
    );
  }
}
