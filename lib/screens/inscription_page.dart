import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user.dart';
import '../services/auth_service.dart';
import 'login_page.dart';

class InscriptionPage extends StatefulWidget {
  const InscriptionPage({super.key});

  @override
  State<InscriptionPage> createState() => _InscriptionPageState();
}

class _InscriptionPageState extends State<InscriptionPage> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isMale = true;
  bool _isFemale = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    // Do not store a remote default avatar; UI will show local asset based on gender
    String? imageUrl;

    String gender;
    if (_isMale) {
      gender = 'Homme';
    } else if (_isFemale) {
      gender = 'Femme';
    } else {
      gender = 'Homme'; // Fallback default
    }

    final user = Users(
      photo: imageUrl,
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
      gender: gender, // Add gender to user object
    );

    final authService = Provider.of<AuthService>(context, listen: false);
    final success = await authService.register(user);

    setState(() {
      _isLoading = false;
    });

    if (success) {
      Navigator.of(context).popUntil((route) => route.isFirst);
    } else {
      final err = authService.lastError ?? 'Inscription échouée';
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(err), backgroundColor: Colors.red));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF007A33)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Inscription',
          style: TextStyle(
            color: Color(0xFF007A33),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // const SizedBox(height: 10),

                // Logo
                Center(
                  child: Image.asset(
                    'images/logo2.webp',
                    width: 180,
                    height: 180,
                  ),
                ),

                // const SizedBox(height: 10),

                // Title
                Text(
                  'Créez votre compte',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF007A33),
                    fontFamily: 'Cocon',
                  ),
                ),

                const SizedBox(height: 8),

                const SizedBox(height: 12),
                // Gender selection checkboxes
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Genre:',
                      style: TextStyle(
                        color: Color(0xFF007A33),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        // Male option
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _isMale = true;
                                _isFemale = false;
                              });
                            },
                            child: Container(
                              height: 100,
                              margin: EdgeInsets.only(right: 8),
                              // decoration: BoxDecoration(
                              //   color:
                              //       _isMale
                              //           ? Color(0xFF007A33).withOpacity(0.1)
                              //           : Colors.grey[50],
                              //   borderRadius: BorderRadius.circular(20),
                              //   border: Border.all(
                              //     color:
                              //         _isMale
                              //             ? Color(0xFF007A33)
                              //             : Colors.grey[300]!,
                              //     width: _isMale ? 2 : 1,
                              //   ),
                              //   boxShadow: [
                              //     BoxShadow(
                              //       color: Colors.black12,
                              //       blurRadius: 4,
                              //       offset: Offset(0, 2),
                              //     ),
                              //   ],
                              // ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 50,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      color:
                                          _isMale
                                              ? Color(0xFF007A33)
                                              : Colors.grey[400],
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.male,
                                      color: Colors.white,
                                      size: 30,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Homme',
                                    style: TextStyle(
                                      color:
                                          _isMale
                                              ? Color(0xFF007A33)
                                              : Colors.grey[700],
                                      fontWeight:
                                          _isMale
                                              ? FontWeight.bold
                                              : FontWeight.normal,
                                      fontSize: 14,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  if (_isMale)
                                    Icon(
                                      Icons.check_circle,
                                      color: Color(0xFF007A33),
                                      size: 16,
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        // Female option
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _isFemale = true;
                                _isMale = false;
                              });
                            },
                            child: Container(
                              height: 100,
                              margin: EdgeInsets.only(left: 8),

                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 50,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      color:
                                          _isFemale
                                              ? Color(0xFF007A33)
                                              : Colors.grey[400],
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.female,
                                      color: Colors.white,
                                      size: 30,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Femme',
                                    style: TextStyle(
                                      color:
                                          _isFemale
                                              ? Color(0xFF007A33)
                                              : Colors.grey[700],
                                      fontWeight:
                                          _isFemale
                                              ? FontWeight.bold
                                              : FontWeight.normal,
                                      fontSize: 14,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  if (_isFemale)
                                    Icon(
                                      Icons.check_circle,
                                      color: Color(0xFF007A33),
                                      size: 16,
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 20),
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Nom complet',
                    labelStyle: const TextStyle(color: Color(0xFF007A33)),
                    prefixIcon: const Icon(
                      Icons.person,
                      color: Color(0xFF007A33),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: const BorderSide(color: Color(0xFF007A33)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: const BorderSide(
                        color: Color(0xFF007A33),
                        width: 2,
                      ),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer votre nom';
                    }
                    if (value.length < 2) {
                      return 'Le nom doit contenir au moins 2 caractères';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 20),

                // Email Field
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    labelStyle: const TextStyle(color: Color(0xFF007A33)),
                    prefixIcon: const Icon(
                      Icons.email,
                      color: Color(0xFF007A33),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: const BorderSide(color: Color(0xFF007A33)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: const BorderSide(
                        color: Color(0xFF007A33),
                        width: 2,
                      ),
                    ),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer votre email';
                    }
                    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                      return 'Veuillez entrer un email valide';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 20),

                // Password Field
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Mot de passe',
                    labelStyle: const TextStyle(color: Color(0xFF007A33)),
                    prefixIcon: const Icon(
                      Icons.lock,
                      color: Color(0xFF007A33),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: const Color(0xFF007A33),
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: const BorderSide(color: Color(0xFF007A33)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: const BorderSide(
                        color: Color(0xFF007A33),
                        width: 2,
                      ),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer un mot de passe';
                    }
                    if (value.length < 6) {
                      return 'Le mot de passe doit contenir au moins 6 caractères';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 20),

                // Confirm Password Field
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: _obscureConfirmPassword,
                  decoration: InputDecoration(
                    labelText: 'Confirmer le mot de passe',
                    labelStyle: const TextStyle(color: Color(0xFF007A33)),
                    prefixIcon: const Icon(
                      Icons.lock_outline,
                      color: Color(0xFF007A33),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirmPassword
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: const Color(0xFF007A33),
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureConfirmPassword = !_obscureConfirmPassword;
                        });
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: const BorderSide(color: Color(0xFF007A33)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: const BorderSide(
                        color: Color(0xFF007A33),
                        width: 2,
                      ),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez confirmer votre mot de passe';
                    }
                    if (value != _passwordController.text) {
                      return 'Les mots de passe ne correspondent pas';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 30),

                // Register Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _register,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF007A33),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      elevation: 0,
                    ),
                    child:
                        _isLoading
                            ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                            : const Text(
                              'S\'inscrire',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                  ),
                ),

                const SizedBox(height: 20),

                // Login Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Vous avez déjà un compte? ',
                      style: TextStyle(color: Colors.grey),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LoginPage(),
                          ),
                        );
                      },
                      child: const Text(
                        'Se connecter',
                        style: TextStyle(
                          color: Color(0xFF007A33),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
