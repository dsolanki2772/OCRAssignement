import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import '../../../core/utils/passbook_parser.dart';
import 'passbook_scanner_event.dart';
import 'passbook_scanner_state.dart';

class PassbookScannerBloc extends Bloc<PassbookScannerEvent, PassbookScannerState> {
  final _textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);

  PassbookScannerBloc() : super(PassbookScannerInitial()) {
    on<ScanPassbook>(_onScanPassbook);
    on<ResetPassbookScanner>((event, emit) => emit(PassbookScannerInitial()));
  }

  Future<void> _onScanPassbook(ScanPassbook event, Emitter<PassbookScannerState> emit) async {
    emit(PassbookScannerScanning());
    try {
      final inputImage = InputImage.fromFilePath(event.imagePath);
      final RecognizedText recognizedText = await _textRecognizer.processImage(inputImage);
      
      final details = PassbookParser.parsePassbook(recognizedText.text);
      
      if (details.accountNumber.isEmpty) {
        emit(PassbookScannerFailure("Could not detect account number. Please ensure the document is clear."));
      } else {
        emit(PassbookScannerSuccess(details: details, imagePath: event.imagePath));
      }
    } catch (e) {
      emit(PassbookScannerFailure("Scan failed: ${e.toString()}"));
    }
  }

  @override
  Future<void> close() {
    _textRecognizer.close();
    return super.close();
  }
}
