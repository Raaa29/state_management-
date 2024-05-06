import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart'; // Import library for Flutter BLoC pattern
import 'package:http/http.dart'
    as http; // Import HTTP client library for making network requests
import 'dart:convert'; // Import for encoding and decoding JSON data
import 'package:url_launcher/url_launcher.dart'; // Import for launching URLs

// Cubit untuk mengelola negara yang dipilih dan daftar universitas yang ditampilkan.
class UniversityCubit extends Cubit<List<Universitas>> {
  UniversityCubit() : super([]); // Inisialisasi Cubit dengan list kosong

  // Memperbarui daftar universitas berdasarkan negara yang dipilih.
  void updateUniversities(String country) async {
    final universities = await _fetchUniversitasList(
        country); // Panggil method untuk fetch daftar universitas
    emit(universities); // Emit list universitas yang telah di-fetch
  }

  // Mengambil data daftar universitas dari server.
  Future<List<Universitas>> _fetchUniversitasList(String country) async {
    final response = await http.get(Uri.parse(
        'http://universities.hipolabs.com/search?country=$country')); // Panggil API untuk mendapatkan data universitas

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(
          response.body); // Decode response body JSON menjadi list dynamic
      return data
          .map((json) => Universitas.fromJson(json))
          .toList(); // Mapping data JSON menjadi objek Universitas
    } else {
      throw Exception(
          'Failed to fetch universities'); // Handle jika gagal fetching data
    }
  }
}

class Universitas {
  final String nama; // Variabel nama universitas
  final String situs; // Variabel situs web universitas

  Universitas(
      {required this.nama,
      required this.situs}); // Constructor dengan parameter wajib

  factory Universitas.fromJson(Map<String, dynamic> json) {
    return Universitas(
      nama: json['name'] ??
          'Nama Tidak Tersedia', // Set nama universitas, jika null set default string
      situs: json['web_pages'] != null && json['web_pages'].isNotEmpty
          ? json['web_pages'][0] // Ambil situs web pertama jika ada
          : 'Website Tidak Tersedia', // Jika tidak ada situs web
    );
  }
}

class UniversitasList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UniversityCubit, List<Universitas>>(
      builder: (context, state) {
        if (state.isEmpty) {
          return Center(
            child:
                CircularProgressIndicator(), // Tampilkan indikator loading jika data kosong
          );
        } else {
          return ListView.builder(
            itemCount: state.length, // Hitung jumlah item universitas
            itemBuilder: (context, index) {
              final universitas = state[index]; // Ambil objek universitas
              return ListTile(
                title: Text(universitas.nama), // Tampilkan nama universitas
                subtitle:
                    Text(universitas.situs), // Tampilkan situs universitas
                onTap: () {
                  launch(universitas
                      .situs); // Buka situs web universitas ketika di-tap
                },
              );
            },
          );
        }
      },
    );
  }
}

void main() {
  runApp(MyApp()); // Jalankan aplikasi Flutter
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: BlocProvider(
        create: (context) => UniversityCubit()
          ..updateUniversities(
              'Indonesia'), // Buat dan sediakan UniversityCubit dengan negara default 'Indonesia'
        child: HomePage(), // Tampilkan HomePage sebagai child aplikasi
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Daftar Universitas'), // Judul halaman
        actions: [
          BlocBuilder<UniversityCubit, List<Universitas>>(
            builder: (context, state) {
              return DropdownButton<String>(
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    context.read<UniversityCubit>().updateUniversities(
                        newValue); // Panggil updateUniversities ketika dropdown dipilih
                  }
                },
                items: <String>[
                  'Indonesia',
                  'Malaysia',
                  'Singapura',
                  'Thailand',
                  'Brunei Darussalam',
                  'Vietnam',
                  'Filipina',
                  'Myanmar',
                  'Kamboja',
                  'Laos',
                ].map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
      body: UniversitasList(), // Tampilkan widget UniversitasList di body
    );
  }
}
