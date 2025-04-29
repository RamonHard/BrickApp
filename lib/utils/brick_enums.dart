enum AccountType { LandLord, TruckDriver, Client }

extension ParseAccountTypeToString on AccountType {
  String toStringAbbr() {
    switch (this) {
      case AccountType.LandLord:
        return "L";
      case AccountType.TruckDriver:
        return "N";
      case AccountType.Client:
        return "C";
    }
  }
}