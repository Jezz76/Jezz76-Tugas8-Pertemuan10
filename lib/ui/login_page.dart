import 'package:flutter/material.dart';
import 'package:tokokita/ui/registrasi_page.dart';
import 'package:tokokita/ui/produk_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _obscurePassword = true;
  final _emailTextboxController = TextEditingController();
  final _passwordTextboxController = TextEditingController();

  @override
  void dispose() {
    _emailTextboxController.dispose();
    _passwordTextboxController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[50],
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Card(
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Logo/Icon
                    Icon(
                      Icons.shopping_bag,
                      size: 80,
                      color: Theme.of(context).primaryColor,
                    ),
                    const SizedBox(height: 16),
                    // Title
                    Text(
                      'Login - Jes',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColor,
                          ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Selamat datang di TokoGW',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    _emailTextField(),
                    const SizedBox(height: 16),
                    _passwordTextField(),
                    const SizedBox(height: 24),
                    _buttonLogin(),
                    const SizedBox(height: 16),
                    _menuRegistrasi(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Membuat Textbox email
  Widget _emailTextField() {
    return TextFormField(
      decoration: InputDecoration(
        labelText: 'Email',
        prefixIcon: const Icon(Icons.email),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      keyboardType: TextInputType.emailAddress,
      controller: _emailTextboxController,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Email harus diisi';
        }
        // simple email validation
        final email = value.trim();
        final regex = RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}");
        if (!regex.hasMatch(email)) {
          return 'Email tidak valid';
        }
        return null;
      },
    );
  }

  // Membuat Textbox password
  Widget _passwordTextField() {
    return TextFormField(
      decoration: InputDecoration(
        labelText: 'Password',
        prefixIcon: const Icon(Icons.lock),
        suffixIcon: IconButton(
          icon: Icon(
            _obscurePassword ? Icons.visibility : Icons.visibility_off,
          ),
          onPressed: () {
            setState(() {
              _obscurePassword = !_obscurePassword;
            });
          },
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      keyboardType: TextInputType.text,
      obscureText: _obscurePassword,
      controller: _passwordTextboxController,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Password harus diisi';
        }
        return null;
      },
    );
  }

  // Membuat Tombol Login
  Widget _buttonLogin() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      child: const Text(
        'Login',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
      onPressed: () async {
        final isValid = _formKey.currentState?.validate() ?? false;
        if (!isValid) return;

        setState(() {
          _isLoading = true;
        });

        // Simulasi proses login
        await Future.delayed(const Duration(seconds: 1));

        setState(() {
          _isLoading = false;
        });

        // Navigate ke ProdukPage setelah login berhasil
        if (!mounted) return;
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Login berhasil!'),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const ProdukPage()),
        );
      },
    );
  }

  // Membuat menu untuk membuka halaman registrasi
  Widget _menuRegistrasi() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Belum punya akun? ',
          style: TextStyle(color: Colors.grey[600]),
        ),
        InkWell(
          child: Text(
            'Registrasi',
            style: TextStyle(
              color: Theme.of(context).primaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const RegistrasiPage()),
            );
          },
        ),
      ],
    );
  }
}
