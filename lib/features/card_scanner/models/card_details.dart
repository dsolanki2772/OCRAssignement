class CardDetails {
  final String cardNumber;
  final String expiryDate;
  final String? cardHolderName;
  final bool isValid;

  CardDetails({
    required this.cardNumber,
    required this.expiryDate,
    this.cardHolderName,
    required this.isValid,
  });

  String get maskedCardNumber {
    if (cardNumber.length < 4) return cardNumber;
    final lastFour = cardNumber.substring(cardNumber.length - 4);
    return "XXXX XXXX XXXX $lastFour";
  }

  @override
  String toString() {
    return 'CardDetails(cardNumber: $cardNumber, expiryDate: $expiryDate, cardHolderName: $cardHolderName, isValid: $isValid)';
  }
}
