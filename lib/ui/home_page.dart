import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/auth_bloc.dart';
import '../blocs/buku_bloc.dart';
import '../widgets/book_card.dart';
import '../widgets/dialog_popup.dart';
import 'form_page.dart';
import 'login_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _keyword = "";
  String _sortBy = 'Judul (A-Z)';

  @override
  void initState() {
    super.initState();
    context.read<BukuBloc>().add(LoadBukuEvent());
  }

  // --- Logic Search & Sort ---
  List<dynamic> _processList(List<dynamic> originalList) {
    var filtered = originalList.where((buku) {
      final searchLower = _keyword.toLowerCase();
      return buku['judul'].toString().toLowerCase().contains(searchLower) ||
          buku['penulis'].toString().toLowerCase().contains(searchLower);
    }).toList();

    filtered.sort((a, b) {
      if (_sortBy == 'Harga (Termurah)')
        return int.parse(
          a['harga'].toString(),
        ).compareTo(int.parse(b['harga'].toString()));
      if (_sortBy == 'Harga (Termahal)')
        return int.parse(
          b['harga'].toString(),
        ).compareTo(int.parse(a['harga'].toString()));
      if (_sortBy == 'Tanggal (Terbaru)')
        return b['tanggal_masuk'].compareTo(a['tanggal_masuk']);
      if (_sortBy == 'Penulis (A-Z)')
        return a['penulis'].toString().compareTo(b['penulis'].toString());
      if (_sortBy == 'Penerbit (A-Z)')
        return a['penerbit'].toString().compareTo(b['penerbit'].toString());
      return a['judul'].toString().compareTo(b['judul'].toString());
    });
    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5DC),
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: BlocBuilder<BukuBloc, BukuState>(
              builder: (context, state) {
                if (state is BukuLoading)
                  return const Center(child: CircularProgressIndicator());
                if (state is BukuLoaded) {
                  final displayList = _processList(state.bukuList);
                  if (displayList.isEmpty) return _buildEmptyState();
                  return ListView.builder(
                    padding: const EdgeInsets.only(
                      top: 10,
                      bottom: 80,
                      left: 16,
                      right: 16,
                    ),
                    itemCount: displayList.length,
                    itemBuilder: (context, index) =>
                        BookCard(buku: displayList[index]),
                  );
                }
                return const Center(child: Text("Memuat Data..."));
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF5D4037),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text("Tambah Buku", style: TextStyle(color: Colors.white)),
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const FormPage()),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 50, left: 20, right: 20, bottom: 30),
      decoration: const BoxDecoration(
        color: Color(0xFF5D4037),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Halo, Admin",
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  Text(
                    "Inventaris ArgaMart",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              IconButton(
                onPressed: () {
                  DialogPopup.showConfirmation(
                    context: context,
                    title: "Konfirmasi Logout",
                    message: "Apakah Anda yakin ingin keluar dari aplikasi?",
                    confirmText: "Logout",
                    confirmColor: const Color(0xFF5D4037),
                    onConfirm: () {
                      context.read<AuthBloc>().add(LogoutEvent());
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginPage()),
                      );
                    },
                  );
                },
                icon: const Icon(Icons.logout, color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildSearchAndFilter(),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilter() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _searchCtrl,
            onChanged: (value) => setState(() => _keyword = value),
            decoration: InputDecoration(
              hintText: "Cari Judul / Penulis...",
              prefixIcon: const Icon(Icons.search, color: Colors.brown),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(horizontal: 20),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
          ),
          child: PopupMenuButton<String>(
            icon: const Icon(Icons.sort, color: Color(0xFF5D4037)),
            onSelected: (value) => setState(() => _sortBy = value),
            itemBuilder: (context) => [
              _item('Judul (A-Z)', Icons.sort_by_alpha),
              _item('Penulis (A-Z)', Icons.person),
              _item('Harga (Termurah)', Icons.arrow_downward),
              _item('Harga (Termahal)', Icons.arrow_upward),
            ],
          ),
        ),
      ],
    );
  }

  PopupMenuItem<String> _item(String v, IconData i) => PopupMenuItem(
    value: v,
    child: Row(
      children: [Icon(i, size: 18), const SizedBox(width: 10), Text(v)],
    ),
  );

  Widget _buildEmptyState() {
    return Center(
      child: Text(
        "Data tidak ditemukan",
        style: TextStyle(color: Colors.brown.withOpacity(0.5)),
      ),
    );
  }
}
