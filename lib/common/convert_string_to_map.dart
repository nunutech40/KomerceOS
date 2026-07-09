Map<String, dynamic> parseStringToMap(String input) {
  try {
    // Remove the curly braces
    input = input.substring(1, input.length - 1);

    // Split by commas to get each key-value pair
    List<String> pairs = input.split(', ');
    Map<String, dynamic> map = {};

    for (var pair in pairs) {
      // Split each pair into key and value by the first colon
      var splitIndex = pair.indexOf(':');
      var key = pair.substring(0, splitIndex).trim();
      var value = pair.substring(splitIndex + 1).trim();
      map[key] = value;
    }

    return map;
  } catch (e) {
    // debugPrint("Faa: $e");
    return {};
  }
}
