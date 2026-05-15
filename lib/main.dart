import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/theme/app_theme.dart';
import 'features/card_scanner/bloc/card_scanner_bloc.dart';
import 'features/passbook_scanner/bloc/passbook_scanner_bloc.dart';
import 'features/home/presentation/pages/home_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const OCRScannerApp());
}

class OCRScannerApp extends StatelessWidget {
  const OCRScannerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => CardScannerBloc()),
        BlocProvider(create: (_) => PassbookScannerBloc()),
      ],
      child: MaterialApp(
        title: 'OCR Scanner',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        home: const HomePage(),
      ),
    );
  }
}
