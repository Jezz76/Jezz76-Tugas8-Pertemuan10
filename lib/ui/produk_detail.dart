import 'package:flutter/material.dart';
import 'package:tokokita/model/produk.dart';
import 'package:tokokita/ui/produk_form.dart';

// ignore: must_be_immutable
class ProdukDetail extends StatefulWidget {
  Produk? produk;

  ProdukDetail({Key? key, this.produk}) : super(key: key);

  @override
  _ProdukDetailState createState() => _ProdukDetailState();
}

class _ProdukDetailState extends State<ProdukDetail> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Detail Produk - Jes'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Product Card
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      // Icon Produk
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.shopping_bag,
                          size: 80,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Info Produk
                      _buildInfoRow(
                        icon: Icons.qr_code,
                        label: 'Kode Produk',
                        value: widget.produk!.kodeProduk!,
                        color: Colors.blue,
                      ),
                      const Divider(height: 32),
                      _buildInfoRow(
                        icon: Icons.inventory,
                        label: 'Nama Produk',
                        value: widget.produk!.namaProduk!,
                        color: Colors.green,
                      ),
                      const Divider(height: 32),
                      _buildInfoRow(
                        icon: Icons.attach_money,
                        label: 'Harga',
                        value: 'Rp ${_formatCurrency(widget.produk!.hargaProduk)}',
                        color: Colors.orange,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Tombol Aksi
              _tombolHapusEdit(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatCurrency(int amount) {
    return amount.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        );
  }

  Widget _tombolHapusEdit() {
    return Row(
      children: [
        // Tombol Edit
        Expanded(
          child: ElevatedButton.icon(
            icon: const Icon(Icons.edit),
            label: const Padding(
              padding: EdgeInsets.symmetric(vertical: 14.0),
              child: Text(
                'EDIT',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProdukForm(produk: widget.produk!),
                ),
              );
            },
          ),
        ),
        const SizedBox(width: 12),
        // Tombol Hapus
        Expanded(
          child: ElevatedButton.icon(
            icon: const Icon(Icons.delete),
            label: const Padding(
              padding: EdgeInsets.symmetric(vertical: 14.0),
              child: Text(
                'HAPUS',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () => confirmHapus(),
          ),
        ),
      ],
    );
  }

  void confirmHapus() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: const [
              Icon(Icons.warning, color: Colors.red, size: 28),
              SizedBox(width: 12),
              Text('Konfirmasi Hapus'),
            ],
          ),
          content: const Text(
            'Apakah Anda yakin ingin menghapus produk ini?',
            style: TextStyle(fontSize: 16),
          ),
          actions: [
            // Tombol Batal
            TextButton(
              child: const Text('BATAL'),
              onPressed: () => Navigator.pop(context),
            ),
            // Tombol Hapus
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('HAPUS'),
              onPressed: () {
                // Simulasi hapus berhasil
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Produk berhasil dihapus!'),
                    backgroundColor: Colors.green,
                  ),
                );
                Navigator.pop(context); // Tutup dialog
                Navigator.pop(context); // Kembali ke list
              },
            ),
          ],
        );
      },
    );
  }
}
