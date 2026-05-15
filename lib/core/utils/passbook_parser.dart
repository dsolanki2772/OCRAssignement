import '../../features/passbook_scanner/models/bank_details.dart';

class PassbookParser {
  static BankDetails parsePassbook(String rawText) {
    String accountHolderName = "Unknown";
    String accountNumber = "";
    String? ifscCode;

    List<String> lines = rawText.split('\n');

    // Extract IFSC Code
    RegExp ifscRegex = RegExp(r'\b[A-Z]{4}0[A-Z0-9]{6}\b', caseSensitive: false);
    Match? ifscMatch = ifscRegex.firstMatch(rawText);
    if (ifscMatch != null) {
      ifscCode = ifscMatch.group(0)!.toUpperCase();
    }

    //  Extract Account Number
    RegExp accountRegex = RegExp(r'\b\d{9,18}\b');
    Iterable<Match> accountMatches = accountRegex.allMatches(rawText);
    
    int maxLength = 0;
    for (Match match in accountMatches) {
      String rawPotential = match.group(0)!;
      // Correct common OCR misreads: O/o -> 0, I/l -> 1
      String corrected = rawPotential
          .replaceAll(RegExp(r'[Oo]'), '0')
          .replaceAll(RegExp(r'[Il]'), '1');
          
      if (corrected.length > maxLength) {
        maxLength = corrected.length;
        accountNumber = corrected;
      }
    }

    // Extract Name
    for (String line in lines) {
      String cleanLine = line.trim();
      if (cleanLine.isEmpty) continue;

      // If line contains "Name" or "Holder", the name might be on the same line or next line
      // If line contains "Name" or "Holder", the name might be on the same line or next line
      if (RegExp(r'(Name|Holder|Mr\.|Ms\.|Mrs\.|A/C)', caseSensitive: false).hasMatch(cleanLine)) {
        // Try to extract from this line first
        String namePart = cleanLine.replaceAll(RegExp(r'^(Name|Holder|Account|A/C|:|Mr\.|Ms\.|Mrs\.|[\s/])+', caseSensitive: false), '').trim();
        // Also remove any remaining labels
        namePart = namePart.replaceAll(RegExp(r'(Name|Holder|Account|A/C|:)', caseSensitive: false), '').trim();
        
        if (namePart.length > 3 && !RegExp(r'\d').hasMatch(namePart)) {
          accountHolderName = namePart;
          break;
        }
      }
    }

    // Fallback name search if not found
    if (accountHolderName == "Unknown") {
      for (String line in lines) {
        String cleanLine = line.trim();
        if (cleanLine.length > 5 && RegExp(r'^[A-Z ]+$').hasMatch(cleanLine)) {
          if (!cleanLine.contains("BANK") && !cleanLine.contains("BRANCH") && !cleanLine.contains("IFSC")) {
             accountHolderName = cleanLine;
             break;
          }
        }
      }
    }

    return BankDetails(
      accountHolderName: accountHolderName,
      accountNumber: accountNumber,
      ifscCode: ifscCode,
    );
  }
}
