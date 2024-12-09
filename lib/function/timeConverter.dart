DateTime convertToJakartaTime(String matchDate, String matchTime) {
  // Parse the date and time in UTC
  DateTime utcTime = DateTime.parse('$matchDate $matchTime');

  // Adjust by subtracting 1 hour, then add 7 hours to convert to GMT+7 (Jakarta time)
  return utcTime.add(Duration(hours: 6));
}
