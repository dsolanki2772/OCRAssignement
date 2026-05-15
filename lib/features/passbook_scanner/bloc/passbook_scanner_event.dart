import 'package:equatable/equatable.dart';

abstract class PassbookScannerEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class ScanPassbook extends PassbookScannerEvent {
  final String imagePath;

  ScanPassbook(this.imagePath);

  @override
  List<Object?> get props => [imagePath];
}

class ResetPassbookScanner extends PassbookScannerEvent {}
