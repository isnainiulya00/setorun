import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'surah_detail_page.dart';

class QuranPage extends StatefulWidget {
  const QuranPage({super.key});

  @override
  State<QuranPage> createState() => _QuranPageState();
}

class _QuranPageState extends State<QuranPage> {

  // Fetch daftar surah
  Future<List<dynamic>> fetchSurah() async {

    final response = await http.get(
      Uri.parse('https://equran.id/api/v2/surat'),
    );

    if (response.statusCode == 200) {

      return json.decode(response.body)['data'];

    } else {

      throw Exception('Gagal memuat daftar surah');
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor: const Color(0xFFF5FAF9),

      appBar: AppBar(
        title: const Text(
          'Al-Qur\'an',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),

        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        elevation: 0,
      ),

      body: FutureBuilder<List<dynamic>>(
        future: fetchSurah(),

        builder: (context, snapshot) {

          // LOADING
          if (snapshot.connectionState == ConnectionState.waiting) {

            return const Center(
              child: CircularProgressIndicator(
                color: Colors.teal,
              ),
            );
          }

          // ERROR
          else if (snapshot.hasError) {

            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [

                  const Icon(
                    Icons.wifi_off,
                    size: 50,
                    color: Colors.grey,
                  ),

                  const SizedBox(height: 16),

                  Text(
                    'Error: ${snapshot.error}',
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          // DATA KOSONG
          else if (!snapshot.hasData || snapshot.data!.isEmpty) {

            return const Center(
              child: Text('Data surah tidak ditemukan'),
            );
          }

          // DATA ADA
          final listSurah = snapshot.data!;

          return ListView.builder(

            padding: const EdgeInsets.all(16),

            itemCount: listSurah.length,

            itemBuilder: (context, index) {

              final surah = listSurah[index];

              return Card(

                margin: const EdgeInsets.only(bottom: 12),

                elevation: 0,

                color: Colors.white,

                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),

                  side: BorderSide(
                    color: Colors.teal.shade100,
                  ),
                ),

                child: ListTile(

                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),

                  // NOMOR SURAH
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

                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.teal,
                      ),
                    ),
                  ),

                  // NAMA LATIN
                  title: Text(
                    surah['namaLatin'],

                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),

                  // TEMPAT TURUN
                  subtitle: Text(
                    '${surah['tempatTurun']} • ${surah['jumlahAyat']} Ayat',

                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 12,
                    ),
                  ),

                  // NAMA ARAB
                  trailing: Text(
                    surah['nama'],

                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal,
                    ),
                  ),

                  // PINDAH KE DETAIL
                  onTap: () {

                    Navigator.push(

                      context,

                      MaterialPageRoute(

                        builder: (context) => SurahDetailPage(
                          nomorSurah: surah['nomor'],
                        ),
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