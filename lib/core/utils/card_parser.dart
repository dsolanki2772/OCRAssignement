import '../../features/card_scanner/models/card_details.dart';
import 'luhn_validator.dart';

class CardParser {
  static CardDetails parseCard(String rawText) {
    String cardNumber = "";
    String expiryDate = "";
    String? cardHolderName;

    // Split text into lines for better processing
    List<String> lines = rawText.split('\n');

    // 1. Extract Card Number (Robust Sliding Window Approach)
    // First, clean common OCR misreads in the whole text
    String cleanedText = rawText
        .replaceAll(RegExp(r'[Oo]'), '0')
        .replaceAll(RegExp(r'[Il]'), '1');
    
    // Extract only digits
    String digitsOnly = cleanedText.replaceAll(RegExp(r'\D'), '');

    if (digitsOnly.length >= 13) {
      // Check every possible substring, prioritizing standard lengths (16, 15)
      bool found = false;
      List<int> lengthsToCheck = [16, 15, 13, 14, 17, 18, 19];
      
      for (int len in lengthsToCheck) {
        if (found) break;
        if (digitsOnly.length < len) continue;
        
        for (int i = 0; i <= digitsOnly.length - len; i++) {
          String potential = digitsOnly.substring(i, i + len);
          if (LuhnValidator.isValidCard(potential)) {
            cardNumber = potential;
            found = true;
            break;
          }
        }
      }
    }

    // Fallback: If no valid card found in sliding window, try the original lines 
    // (though sliding window usually covers it)
    if (cardNumber.isEmpty) {
      RegExp cardRegex = RegExp(r'(?:\d[ -]*?){13,19}');
      Iterable<Match> cardMatches = cardRegex.allMatches(cleanedText);
      for (Match match in cardMatches) {
        String potentialNumber = match.group(0)!.replaceAll(RegExp(r'\D'), '');
        if (LuhnValidator.isValidCard(potentialNumber)) {
          cardNumber = potentialNumber;
          break;
        }
      }
    }

    // 2. Extract Expiry Date
    // Heuristic: Often follows keywords like "EXP", "VAL", "THRU"
    String textForExpiry = cleanedText.toUpperCase();
    
    // Pattern 1: MM / YY (with any separator or optional spaces)
    RegExp expiryRegexFlexible = RegExp(r'(0[1-9]|1[0-2])\s*[/\-]\s*(\d{2,4})');
    
    // Try to find near keywords first
    int expIndex = textForExpiry.indexOf(RegExp(r'(EXP|VAL|THRU|VALID|UNTIL)'));
    if (expIndex != -1) {
      String sub = textForExpiry.substring(expIndex, (expIndex + 30).clamp(0, textForExpiry.length));
      Match? match = expiryRegexFlexible.firstMatch(sub);
      if (match != null) {
        expiryDate = match.group(0)!;
      }
    }

    // If not found near keyword, search globally with flexible regex
    if (expiryDate.isEmpty) {
      Match? match = expiryRegexFlexible.firstMatch(textForExpiry);
      if (match != null) {
        expiryDate = match.group(0)!;
      }
    }

    // Fallback: Look for 4-digit sequences that look like MMYY (e.g. 1225)
    // but only if they are NOT part of the card number
    if (expiryDate.isEmpty) {
      RegExp pureDigitExpiry = RegExp(r'(0[1-9]|1[0-2])(\d{2})');
      Iterable<Match> matches = pureDigitExpiry.allMatches(digitsOnly);
      for (Match m in matches) {
        String potential = m.group(0)!;
        // Ensure it's not part of the already found card number
        if (!cardNumber.contains(potential)) {
          expiryDate = "${potential.substring(0, 2)}/${potential.substring(2)}";
          break;
        }
      }
    }

    // 3. Extract Card Holder Name
    // This is heuristic-based. Names usually don't have numbers.
    // We filter out lines that are likely card numbers or expiry dates.
    for (String line in lines) {
      String cleanLine = line.trim();
      if (cleanLine.isEmpty) continue;

      // Skip lines with many digits
      if (RegExp(r'\d{3,}').hasMatch(cleanLine)) continue;

      // Skip common card labels
      if (RegExp(r'(VISA|MASTERCARD|AMEX|DISCOVER|VALID|THRU|EXP|CARD|HOLDER)', caseSensitive: false).hasMatch(cleanLine)) continue;

      // Check if it looks like a name (at least two words, only letters)
      if (RegExp(r'^[A-Z ]{3,30}$', caseSensitive: true).hasMatch(cleanLine)) {
        cardHolderName = cleanLine;
        // Usually name is a single line, if we found something that looks like it, we take the first one found that's not a label
        break;
      }
    }

    return CardDetails(
      cardNumber: cardNumber,
      expiryDate: expiryDate.replaceAll(' ', '').replaceAll('-', '/'),
      cardHolderName: cardHolderName,
      isValid: cardNumber.isNotEmpty && expiryDate.isNotEmpty,
    );
  }
}
