import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class SurahDetailPage extends StatefulWidget {

  final int nomorSurah;

  const SurahDetailPage({
    super.key,
    required this.nomorSurah,
  });

  @override
  State<SurahDetailPage> createState() => _SurahDetailPageState();
}

class _SurahDetailPageState extends State<SurahDetailPage> {

  // FETCH DETAIL SURAH
  Future<Map<String, dynamic>> fetchDetailSurah() async {

    final response = await http.get(

      Uri.parse(
        'https://equran.id/api/v2/surat/${widget.nomorSurah}',
      ),
    );

    if (response.statusCode == 200) {

      return json.decode(response.body)['data'];

    } else {

      throw Exception('Gagal memuat detail surah');
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor: const Color(0xFFF5FAF9),

      appBar: AppBar(
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),

      body: FutureBuilder<Map<String, dynamic>>(

        future: fetchDetailSurah(),

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
          if (snapshot.hasError) {

            return Center(
              child: Text(
                'Error: ${snapshot.error}',
              ),
            );
          }

          // DATA KOSONG
          if (!snapshot.hasData) {

            return const Center(
              child: Text('Data tidak ditemukan'),
            );
          }

          final surah = snapshot.data!;
          final ayatList = surah['ayat'];

          return Column(

            children: [

              // HEADER SURAH
              Container(

                width: double.infinity,

                padding: const EdgeInsets.all(20),

                color: Colors.teal,

                child: Column(

                  children: [

                    Text(
                      surah['namaLatin'],

                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      surah['arti'],

                      style: const TextStyle(
                        color: Colors.white70,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      '${surah['tempatTurun']} • ${surah['jumlahAyat']} Ayat',

                      style: const TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),

              // LIST AYAT
              Expanded(

                child: ListView.builder(

                  padding: const EdgeInsets.all(16),

                  itemCount: ayatList.length,

                  itemBuilder: (context, index) {

                    final ayat = ayatList[index];

                    return Card(

                      margin: const EdgeInsets.only(bottom: 16),

                      elevation: 0,

                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),

                      child: Padding(

                        padding: const EdgeInsets.all(16),

                        child: Column(

                          crossAxisAlignment: CrossAxisAlignment.start,

                          children: [

                            // NOMOR AYAT
                            Container(

                              width: 35,
                              height: 35,

                              alignment: Alignment.center,

                              decoration: BoxDecoration(
                                color: Colors.teal.shade50,
                                shape: BoxShape.circle,
                              ),

                              child: Text(
                                ayat['nomorAyat'].toString(),

                                style: const TextStyle(
                                  color: Colors.teal,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),

                            const SizedBox(height: 16),

                            // TEKS ARAB
                            Align(

                              alignment: Alignment.centerRight,

                              child: Text(

                                ayat['teksArab'],

                                textAlign: TextAlign.right,

                                style: const TextStyle(
                                  fontSize: 28,
                                  height: 2,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),

                            const SizedBox(height: 16),

                            // LATIN
                            Text(

                              ayat['teksLatin'],

                              style: const TextStyle(
                                fontStyle: FontStyle.italic,
                                fontSize: 14,
                              ),
                            ),

                            const SizedBox(height: 12),

                            // TERJEMAHAN
                            Text(

                              ayat['teksIndonesia'],

                              style: const TextStyle(
                                fontSize: 16,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}