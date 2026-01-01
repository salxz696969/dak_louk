import 'package:flutter/material.dart';
import 'package:dak_louk/domain/models/models.dart';

class SignUp extends StatefulWidget {
  final Function(SignUpDTO) onSignUp;
  const SignUp({super.key, required this.onSignUp});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  String email = '';
  String username = '';
  String password = '';
  String profileImageUrl = '';
  String bio = '';
  final TextEditingController emailController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController profileImageUrlController =
      TextEditingController();
  final TextEditingController bioController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: usernameController,
          decoration: InputDecoration(
            labelText: 'Username',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            prefixIcon: const Icon(Icons.person_outline),
          ),
          onChanged: (value) => setState(() => username = value),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: emailController,
          decoration: InputDecoration(
            labelText: 'Email',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            prefixIcon: const Icon(Icons.email_outlined),
          ),
          keyboardType: TextInputType.emailAddress,
          onChanged: (value) => setState(() => email = value),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: passwordController,
          decoration: InputDecoration(
            labelText: 'Password',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            prefixIcon: const Icon(Icons.lock_outline),
          ),
          obscureText: true,
          onChanged: (value) => setState(() => password = value),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: profileImageUrlController,
          decoration: InputDecoration(
            labelText: 'Profile Image URL (Optional)',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            prefixIcon: const Icon(Icons.image_outlined),
          ),
          onChanged: (value) => setState(() => profileImageUrl = value),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: bioController,
          decoration: InputDecoration(
            labelText: 'Bio (Optional)',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            prefixIcon: const Icon(Icons.info_outline),
          ),
          maxLines: 2,
          onChanged: (value) => setState(() => bio = value),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              final dto = SignUpDTO(
                username: usernameController.text,
                email: emailController.text,
                password: passwordController.text,
                profileImageUrl: profileImageUrlController.text,
                bio: bioController.text,
              );
              widget.onSignUp(dto);
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Sign Up',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    );
  }
}
