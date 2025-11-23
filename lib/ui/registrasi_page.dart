import 'package:flutter/material.dart';

class RegistrasiPage extends StatefulWidget {
  const RegistrasiPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _RegistrasiPageState createState() => _RegistrasiPageState();
}

class _RegistrasiPageState extends State<RegistrasiPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  final _namaTextboxController = TextEditingController();
  final _emailTextboxController = TextEditingController();
  final _passwordTextboxController = TextEditingController();

  @override
  void dispose() {
    _namaTextboxController.dispose();
    _emailTextboxController.dispose();
    _passwordTextboxController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[50],
      appBar: AppBar(
        title: const Text('Registrasi - Jes'),
        centerTitle: true,
        elevation: 0,
      ),
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
                    // Icon
                    Icon(
                      Icons.person_add,
                      size: 70,
                      color: Theme.of(context).primaryColor,
                    ),
                    const SizedBox(height: 16),
                    // Title
                    Text(
                      'Buat Akun Baru',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColor,
                          ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Daftar untuk memulai',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    _namaTextField(),
                    const SizedBox(height: 16),
                    _emailTextField(),
                    const SizedBox(height: 16),
                    _passwordTextField(),
                    const SizedBox(height: 16),
                    _passwordKonfirmasiTextField(),
                    const SizedBox(height: 24),
                    _buttonRegistrasi(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Membuat Textbox Nama
  Widget _namaTextField() {
    return TextFormField(
      decoration: InputDecoration(
        labelText: 'Nama Lengkap',
        prefixIcon: const Icon(Icons.person),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      keyboardType: TextInputType.text,
      controller: _namaTextboxController,
      validator: (value) {
        if (value == null || value.trim().length < 3) {
          return 'Nama harus diisi minimal 3 karakter';
        }
        return null;
      },
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
        if (value == null || value.length < 6) {
          return 'Password harus diisi minimal 6 karakter';
        }
        return null;
      },
    );
  }

  // membuat textbox Konfirmasi Password
  Widget _passwordKonfirmasiTextField() {
    return TextFormField(
      decoration: InputDecoration(
        labelText: 'Konfirmasi Password',
        prefixIcon: const Icon(Icons.lock_outline),
        suffixIcon: IconButton(
          icon: Icon(
            _obscureConfirmPassword ? Icons.visibility : Icons.visibility_off,
          ),
          onPressed: () {
            setState(() {
              _obscureConfirmPassword = !_obscureConfirmPassword;
            });
          },
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      keyboardType: TextInputType.text,
      obscureText: _obscureConfirmPassword,
      validator: (value) {
        if (value == null || value != _passwordTextboxController.text) {
          return 'Konfirmasi Password tidak sama';
        }
        return null;
      },
    );
  }

  // Membuat Tombol Registrasi
  Widget _buttonRegistrasi() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      child: const Text(
        'Registrasi',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
      onPressed: () async {
        final isValid = _formKey.currentState?.validate() ?? false;
        if (!isValid) return;

        setState(() {
          _isLoading = true;
        });

        // Simulasi proses registrasi
        await Future.delayed(const Duration(seconds: 1));

        setState(() {
          _isLoading = false;
        });

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Registrasi berhasil! Silakan login.'),
            backgroundColor: Colors.green,
          ),
        );

        // Kembali ke halaman login setelah registrasi berhasil
        Navigator.pop(context);
      },
    );
  }
}
