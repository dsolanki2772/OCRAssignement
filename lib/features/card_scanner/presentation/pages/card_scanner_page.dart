import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../bloc/card_scanner_bloc.dart';
import '../../bloc/card_scanner_event.dart';
import '../../bloc/card_scanner_state.dart';

class CardScannerPage extends StatelessWidget {
  const CardScannerPage({super.key});

  Future<void> _pickImage(BuildContext context, ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: source,
      maxWidth: 1200,
      maxHeight: 1200,
      imageQuality: 90,
    );

    if (pickedFile != null && context.mounted) {
      context.read<CardScannerBloc>().add(ScanCard(pickedFile.path));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Card Scanner")),
      body: BlocBuilder<CardScannerBloc, CardScannerState>(
        builder: (context, state) {
          if (state is CardScannerInitial) {
            return _buildInitial(context);
          } else if (state is CardScannerScanning) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is CardScannerSuccess) {
            return _buildSuccess(context, state);
          } else if (state is CardScannerFailure) {
            return _buildFailure(context, state);
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildInitial(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.camera_alt_outlined, size: 80, color: Theme.of(context).primaryColor),
          const SizedBox(height: 24),
          Text(
            "Scan your Card",
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          const Text(
            "Place your credit or debit card within the frame to automatically extract details.",
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _pickImage(context, ImageSource.camera),
                  icon: const Icon(Icons.camera),
                  label: const Text("Camera"),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _pickImage(context, ImageSource.gallery),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: BorderSide(color: Theme.of(context).primaryColor),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: const Icon(Icons.photo_library),
                  label: const Text("Gallery"),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSuccess(BuildContext context, CardScannerSuccess state) {
    final details = state.details;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.file(
              File(state.imagePath),
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 32),
          const Text("Extracted Information", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 16),
          _InfoTile(label: "Card Number", value: details.maskedCardNumber),
          _InfoTile(label: "Expiry Date", value: details.expiryDate),
          _InfoTile(label: "Card Holder", value: details.cardHolderName ?? "Not Found"),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => context.read<CardScannerBloc>().add(ResetScanner()),
              child: const Text("Scan Another"),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFailure(BuildContext context, CardScannerFailure state) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(state.message, textAlign: TextAlign.center),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.read<CardScannerBloc>().add(ResetScanner()),
              child: const Text("Try Again"),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final String label;
  final String value;

  const _InfoTile({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
