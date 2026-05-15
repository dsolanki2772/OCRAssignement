import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import '../../../core/utils/card_parser.dart';
import 'card_scanner_event.dart';
import 'card_scanner_state.dart';

class CardScannerBloc extends Bloc<CardScannerEvent, CardScannerState> {
  final _textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);

  CardScannerBloc() : super(CardScannerInitial()) {
    on<ScanCard>(_onScanCard);
    on<ResetScanner>((event, emit) => emit(CardScannerInitial()));
  }

  Future<void> _onScanCard(ScanCard event, Emitter<CardScannerState> emit) async {
    emit(CardScannerScanning());
    try {
      final inputImage = InputImage.fromFilePath(event.imagePath);
      final RecognizedText recognizedText = await _textRecognizer.processImage(inputImage);
      
      // Log for debugging purposes
      print("OCR Recognized Text: \n${recognizedText.text}");
      
      final details = CardParser.parseCard(recognizedText.text);
      
      if (details.cardNumber.isEmpty) {
        emit(CardScannerFailure("Could not detect a valid card number. Please try again."));
      } else {
        emit(CardScannerSuccess(details: details, imagePath: event.imagePath));
      }
    } catch (e) {
      emit(CardScannerFailure("Scan failed: ${e.toString()}"));
    }
  }

  @override
  Future<void> close() {
    _textRecognizer.close();
    return super.close();
  }
}
