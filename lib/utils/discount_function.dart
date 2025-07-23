double applyDiscount(double originalPrice, double percentage) {
  final discountAmount = originalPrice * (percentage / 100);
  return originalPrice - discountAmount;
}
