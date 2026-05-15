import 'package:equatable/equatable.dart';

abstract class CardScannerEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class ScanCard extends CardScannerEvent {
  final String imagePath;

  ScanCard(this.imagePath);

  @override
  List<Object?> get props => [imagePath];
}

class ResetScanner extends CardScannerEvent {}
