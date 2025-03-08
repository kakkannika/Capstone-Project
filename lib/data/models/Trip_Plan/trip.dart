class Trip {
  List<String?> destinations;
  DateTime startDate;
  DateTime? returnDate;

  Trip({
    required this.destinations,
    required this.startDate,
    this.returnDate,
  });
}
