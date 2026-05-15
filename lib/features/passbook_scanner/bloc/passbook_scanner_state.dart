import 'package:equatable/equatable.dart';
import '../models/bank_details.dart';

abstract class PassbookScannerState extends Equatable {
  @override
  List<Object?> get props => [];
}

class PassbookScannerInitial extends PassbookScannerState {}

class PassbookScannerScanning extends PassbookScannerState {}

class PassbookScannerSuccess extends PassbookScannerState {
  final BankDetails details;
  final String imagePath;

  PassbookScannerSuccess({required this.details, required this.imagePath});

  @override
  List<Object?> get props => [details, imagePath];
}

class PassbookScannerFailure extends PassbookScannerState {
  final String message;

  PassbookScannerFailure(this.message);

  @override
  List<Object?> get props => [message];
}
