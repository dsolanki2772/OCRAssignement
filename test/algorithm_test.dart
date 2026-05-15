import 'package:flutter_test/flutter_test.dart';
import 'package:ocr_scanner/core/utils/luhn_validator.dart';
import 'package:ocr_scanner/core/utils/card_parser.dart';
import 'package:ocr_scanner/core/utils/passbook_parser.dart';

void main() {
  group('Luhn Validator Tests', () {
    test('should validate a correct card number', () {
      expect(LuhnValidator.isValidCard('79927398713'), true);
    });

    test('should invalidate an incorrect card number', () {
      expect(LuhnValidator.isValidCard('79927398710'), false);
    });

    test('should handle spaces and hyphens', () {
      expect(LuhnValidator.isValidCard('7992-7398-713'), true);
      expect(LuhnValidator.isValidCard('7992 7398 713'), true);
    });
  });

  group('Card Parser Tests', () {
    test('should extract card details from raw text', () {
      const rawText = '''
        VISA DEBIT
        1234 5678 1234 5670
        VALID THRU 12/25
        JOHN DOE
      ''';
      // Note: 1234 5678 1234 5670 is a valid Luhn number (sum 40)
      // 1*2 + 2 + 3*2 + 4 + 5*2 + 6 + 7*2 + 8 + 1*2 + 2 + 3*2 + 4 + 5*2 + 6 + 7*2 + 0
      // 2+2+6+4+10(1)+6+14(5)+8+2+2+6+4+10(1)+6+14(5)+0 = 2+2+6+4+1+6+5+8+2+2+6+4+1+6+5+0 = 60. Valid.
      
      final details = CardParser.parseCard(rawText);
      expect(details.cardNumber, '1234567812345670');
      expect(details.expiryDate, '12/25');
      expect(details.cardHolderName, 'JOHN DOE');
    });

    test('should handle different expiry formats', () {
      const rawText = 'EXP 12-24 \n 4532 1234 5678 1237'; // 4532... is also valid luhn
      final details = CardParser.parseCard(rawText);
      expect(details.expiryDate, '12-24');
    });
  });

  group('Passbook Parser Tests', () {
    test('should extract bank details from raw text', () {
      const rawText = '''
        STATE BANK OF INDIA
        BRANCH: MUMBAI
        IFSC: SBIN0001234
        A/C HOLDER: JANE SMITH
        A/C NO: 123456789012
      ''';
      
      final details = PassbookParser.parsePassbook(rawText);
      expect(details.accountNumber, '123456789012');
      expect(details.ifscCode, 'SBIN0001234');
      expect(details.accountHolderName, 'JANE SMITH');
    });

    test('should extract name from noisy text', () {
      const rawText = '''
        Some Noise
        HOLDER NAME: BOB WILSON
        9876543210
        Random Text
      ''';
      final details = PassbookParser.parsePassbook(rawText);
      expect(details.accountHolderName, 'BOB WILSON');
      expect(details.accountNumber, '9876543210');
    });
  });
}
