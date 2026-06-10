// Entry point aplikasi apotek — setup providers, routing, dan tema
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'app/app_router.dart';
import 'core/theme/app_theme.dart';
import 'providers/provider_auth.dart';
import 'providers/provider_antrian.dart';
import 'providers/provider_obat.dart';
import 'providers/provider_eresep.dart';

// Entry point aplikasi Flutter
void main() {
  // Pastikan binding Flutter sudah siap sebelum runApp
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp()); // jalankan widget root aplikasi
}

// Widget root aplikasi — setup AuthProvider, GoRouter, dan MultiProvider
// StatefulWidget agar AuthProvider dibuat sekali dan di-share ke GoRouter
class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // AuthProvider dibuat di sini agar instance yang sama dipakai oleh
  // GoRouter (refreshListenable) dan Provider tree (ChangeNotifierProvider.value)
  late final AuthProvider _authProvider; // auth state global
  late final GoRouter _router; // router instance

  @override
  void initState() {
    super.initState();
    _authProvider = AuthProvider()..init();
    _router = createAppRouter(_authProvider);
  }

  @override
  Widget build(BuildContext context) {
    // MultiProvider — daftarkan semua provider di satu tempat
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: _authProvider), // .value karena instance sudah dibuat
        ChangeNotifierProvider(create: (_) => AntrianProvider()), // provider antrian
        ChangeNotifierProvider(create: (_) => ObatProvider()), // provider obat
        ChangeNotifierProvider(create: (_) => EResepProvider()), // provider e-resep
      ],
      child: MaterialApp.router(
        title: 'Apotek Kelompok 4',
        debugShowCheckedModeBanner: false,
        // Tema terpusat dari AppTheme
        theme: AppTheme.lightTheme,
        // Router dari go_router dengan auth refresh
        routerConfig: _router,
      ),
    );
  }
}
