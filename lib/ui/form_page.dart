import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/buku_bloc.dart';

class FormPage extends StatefulWidget {
  final Map<String, dynamic>? data;
  const FormPage({super.key, this.data});
  @override
  State<FormPage> createState() => _FormPageState();
}

class _FormPageState extends State<FormPage> {
  final _judul = TextEditingController();
  final _harga = TextEditingController();
  final _jumlah = TextEditingController();
  final _tgl = TextEditingController(); // Variabel yang benar adalah _tgl
  final _vol = TextEditingController();
  final _penulis = TextEditingController();
  final _penerbit = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.data != null) {
      _judul.text = widget.data!['judul'];
      _harga.text = widget.data!['harga'].toString();
      _jumlah.text = widget.data!['jumlah'].toString();
      _tgl.text = widget.data!['tanggal_masuk'];
      _vol.text = widget.data!['volume'].toString();
      _penulis.text = widget.data!['penulis'];
      _penerbit.text = widget.data!['penerbit'];
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF5D4037),
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _tgl.text =
            "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      });
    }
  }

  void _save() {
    final Map<String, String> data = {
      'judul': _judul.text,
      'harga': _harga.text,
      'jumlah': _jumlah.text,
      'tanggal_masuk': _tgl.text,
      'volume': _vol.text,
      'penulis': _penulis.text,
      'penerbit': _penerbit.text,
    };

    if (widget.data != null) {
      data['id'] = widget.data!['id'].toString();
      context.read<BukuBloc>().add(EditBukuEvent(data));
    } else {
      context.read<BukuBloc>().add(AddBukuEvent(data));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.data == null ? "Tambah Buku" : "Edit Buku"),
      ),
      body: BlocListener<BukuBloc, BukuState>(
        listener: (context, state) {
          if (state is BukuOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Data Berhasil Disimpan")),
            );
            Navigator.pop(context);
          } else if (state is BukuError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle("Informasi Buku"),
              _buildInput(_judul, "Judul Buku", Icons.book),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildInput(
                      _harga,
                      "Harga",
                      Icons.attach_money,
                      isNumber: true,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildInput(
                      _jumlah,
                      "Stok",
                      Icons.inventory,
                      isNumber: true,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              _buildSectionTitle("Detail & Logistik"),

              TextField(
                controller: _tgl,
                readOnly: true,
                onTap: () => _selectDate(context),
                decoration: const InputDecoration(
                  labelText: "Tanggal Masuk",
                  prefixIcon: Icon(Icons.calendar_today, color: Colors.brown),
                  suffixIcon: Icon(Icons.arrow_drop_down),
                ),
              ),
              const SizedBox(height: 16),

              _buildInput(_vol, "Volume", Icons.library_books, isNumber: true),
              const SizedBox(height: 16),
              _buildInput(_penulis, "Penulis", Icons.person),
              const SizedBox(height: 16),
              _buildInput(_penerbit, "Penerbit", Icons.business),

              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _save,
                  child: const Text("SIMPAN DATA"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Color(0xFF5D4037),
        ),
      ),
    );
  }

  Widget _buildInput(
    TextEditingController ctrl,
    String label,
    IconData icon, {
    bool isNumber = false,
  }) {
    return TextField(
      controller: ctrl,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.brown),
      ),
    );
  }
}
