import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/buku_bloc.dart';
import '../ui/form_page.dart';
import 'dialog_popup.dart';

class BookCard extends StatelessWidget {
  final Map<String, dynamic> buku;

  const BookCard({super.key, required this.buku});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.brown.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => FormPage(data: buku)),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Gambar Cover
                Container(
                  width: 70,
                  height: 100,
                  decoration: BoxDecoration(
                    color: const Color(0xFF8D6E63),
                    borderRadius: BorderRadius.circular(12),
                    image: const DecorationImage(
                      image: NetworkImage("https://via.placeholder.com/150"),
                      fit: BoxFit.cover,
                      opacity: 0.2,
                    ),
                  ),
                  child: const Center(
                    child: Icon(Icons.menu_book, color: Colors.white, size: 30),
                  ),
                ),
                const SizedBox(width: 16),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        buku['judul'],
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          height: 1.2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "Penulis: ${buku['penulis']}",
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.grey,
                        ),
                      ),
                      Text(
                        "Penerbit: ${buku['penerbit']}",
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          _buildChip(
                            "Rp${buku['harga']}",
                            Colors.green,
                            Icons.attach_money,
                          ),
                          const SizedBox(width: 8),
                          _buildChip(
                            "Stok: ${buku['jumlah']}",
                            Colors.orange,
                            Icons.inventory_2_outlined,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                IconButton(
                  icon: const Icon(
                    Icons.delete_outline_rounded,
                    color: Colors.redAccent,
                  ),
                  onPressed: () {
                    DialogPopup.showConfirmation(
                      context: context,
                      title: "Hapus Buku?",
                      message: "Data '${buku['judul']}' akan dihapus permanen.",
                      confirmText: "Hapus",
                      confirmColor: Colors.red,
                      onConfirm: () {
                        context.read<BukuBloc>().add(
                          DeleteBukuEvent(buku['id'].toString()),
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChip(String label, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
