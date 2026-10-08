enum PriceTier {
  retail,
  wholesale,
  dealer;

  String get label {
    switch (this) {
      case PriceTier.retail:
        return 'RETAIL';
      case PriceTier.wholesale:
        return 'WHOLESALE';
      case PriceTier.dealer:
        return 'DEALER';
    }
  }

  String get displayName {
    switch (this) {
      case PriceTier.retail:
        return 'Retail';
      case PriceTier.wholesale:
        return 'Wholesale';
      case PriceTier.dealer:
        return 'Dealer';
    }
  }
}
