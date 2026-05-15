import 'package:equatable/equatable.dart';
import '../models/card_details.dart';

abstract class CardScannerState extends Equatable {
  @override
  List<Object?> get props => [];
}

class CardScannerInitial extends CardScannerState {}

class CardScannerScanning extends CardScannerState {}

class CardScannerSuccess extends CardScannerState {
  final CardDetails details;
  final String imagePath;

  CardScannerSuccess({required this.details, required this.imagePath});

  @override
  List<Object?> get props => [details, imagePath];
}

class CardScannerFailure extends CardScannerState {
  final String message;

  CardScannerFailure(this.message);

  @override
  List<Object?> get props => [message];
}
