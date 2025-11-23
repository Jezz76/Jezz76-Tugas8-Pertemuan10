import 'package:flutter/material.dart';
import 'package:tokokita/model/produk.dart';

// ignore: must_be_immutable
class ProdukForm extends StatefulWidget {
  Produk? produk;

  ProdukForm({Key? key, this.produk}) : super(key: key);

  @override
  _ProdukFormState createState() => _ProdukFormState();
}

class _ProdukFormState extends State<ProdukForm> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String judul = "Tambah Produk - Jes";
  String tombolSubmit = "SIMPAN";
  final _kodeProdukTextboxController = TextEditingController();
  final _namaProdukTextboxController = TextEditingController();
  final _hargaProdukTextboxController = TextEditingController();

  @override
  void initState() {
    super.initState();
    isUpdate();
  }

  void isUpdate() {
    if (widget.produk != null) {
      setState(() {
        judul = "Ubah Produk - Jes";
        tombolSubmit = "UBAH";
        _kodeProdukTextboxController.text = widget.produk!.kodeProduk!;
        _namaProdukTextboxController.text = widget.produk!.namaProduk!;
        _hargaProdukTextboxController.text =
            widget.produk!.hargaProduk.toString();
      });
    } else {
      judul = "Tambah Produk - Jes";
      tombolSubmit = "SIMPAN";
    }
  }

  @override
  void dispose() {
    _kodeProdukTextboxController.dispose();
    _namaProdukTextboxController.dispose();
    _hargaProdukTextboxController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(judul),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Icon
                    Icon(
                      widget.produk != null ? Icons.edit : Icons.add_box,
                      size: 60,
                      color: Theme.of(context).primaryColor,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      widget.produk != null
                          ? 'Edit Informasi Produk'
                          : 'Tambah Produk Baru',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColor,
                          ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    _kodeProdukTextField(),
                    const SizedBox(height: 16),
                    _namaProdukTextField(),
                    const SizedBox(height: 16),
                    _hargaProdukTextField(),
                    const SizedBox(height: 24),
                    _buttonSubmit(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Membuat Textbox Kode Produk
  Widget _kodeProdukTextField() {
    return TextFormField(
      decoration: InputDecoration(
        labelText: 'Kode Produk',
        hintText: 'Contoh: PRD001',
        prefixIcon: const Icon(Icons.qr_code),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      keyboardType: TextInputType.text,
      controller: _kodeProdukTextboxController,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Kode Produk harus diisi';
        }
        return null;
      },
    );
  }

  // Membuat Textbox Nama Produk
  Widget _namaProdukTextField() {
    return TextFormField(
      decoration: InputDecoration(
        labelText: 'Nama Produk',
        hintText: 'Contoh: Laptop ASUS',
        prefixIcon: const Icon(Icons.inventory),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      keyboardType: TextInputType.text,
      controller: _namaProdukTextboxController,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Nama Produk harus diisi';
        }
        return null;
      },
    );
  }

  // Membuat Textbox Harga Produk
  Widget _hargaProdukTextField() {
    return TextFormField(
      decoration: InputDecoration(
        labelText: 'Harga',
        hintText: 'Contoh: 5000000',
        prefixIcon: const Icon(Icons.attach_money),
        prefixText: 'Rp ',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      keyboardType: TextInputType.number,
      controller: _hargaProdukTextboxController,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Harga harus diisi';
        }
        if (int.tryParse(value) == null) {
          return 'Harga harus berupa angka';
        }
        return null;
      },
    );
  }

  // Membuat Tombol Simpan/Ubah
  Widget _buttonSubmit() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return ElevatedButton.icon(
      icon: Icon(widget.produk != null ? Icons.save : Icons.add),
      label: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14.0),
        child: Text(
          tombolSubmit,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      onPressed: () async {
        final isValid = _formKey.currentState?.validate() ?? false;
        if (!isValid) return;

        setState(() {
          _isLoading = true;
        });

        // Simulasi proses simpan/ubah
        await Future.delayed(const Duration(seconds: 1));

        setState(() {
          _isLoading = false;
        });

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$tombolSubmit berhasil!'),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.pop(context);
      },
    );
  }
}
