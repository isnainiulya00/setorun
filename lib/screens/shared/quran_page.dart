import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'placeholder_screen.dart';

class QuranPage extends StatefulWidget {
  const QuranPage({super.key});

  @override
  State<QuranPage> createState() => _QuranPageState();
}

class _QuranPageState extends State<QuranPage> {
  
  // Fungsi untuk mengambil data dari API EQuran
  Future<List<dynamic>> fetchSurah() async {
    final response = await http.get(Uri.parse('https://equran.id/api/v2/surat'));

    if (response.statusCode == 200) {
      // Jika server mengembalikan response OK (200), parse JSON-nya
      return json.decode(response.body)['data'];
    } else {
      // Jika gagal, lempar error
      throw Exception('Gagal memuat daftar Surah');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5FAF9), // Warna background khas Setorun
      appBar: AppBar(
        title: const Text('Al-Qur\'an', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      // FutureBuilder digunakan untuk menangani proses loading data dari internet
      body: FutureBuilder<List<dynamic>>(
        future: fetchSurah(),
        builder: (context, snapshot) {
          // 1. Jika data masih loading
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.teal),
            );
          } 
          // 2. Jika terjadi error (misal: tidak ada internet)
          else if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.wifi_off, size: 48, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text('Gagal memuat data: ${snapshot.error}', textAlign: TextAlign.center),
                ],
              ),
            );
          } 
          // 3. Jika data kosong
          else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Data Surah tidak ditemukan'));
          }

          // 4. Jika data berhasil didapatkan
          final listSurah = snapshot.data!;
          
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: listSurah.length,
            itemBuilder: (context, index) {
              final surah = listSurah[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.teal.shade100),
                ),
                color: Colors.white,
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  
                  // Nomor Surah dalam lingkaran
                  leading: Container(
                    width: 42,
                    height: 42,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.teal.shade50,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      surah['nomor'].toString(),
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.teal),
                    ),
                  ),
                  
                  // Nama Surah (Latin)
                  title: Text(
                    surah['namaLatin'],
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  
                  // Tempat turun & jumlah ayat
                  subtitle: Text(
                    '${surah['tempatTurun']} • ${surah['jumlahAyat']} Ayat',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                  ),
                  
                  // Nama Surah (Arab)
                  trailing: Text(
                    surah['nama'],
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal,
                    ),
                  ),
                  
                  onTap: () {
                    // ROUTING KE DETAIL SURAH
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PlaceholderScreen(title: 'Surah ${surah['namaLatin']}'),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}