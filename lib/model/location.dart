class Location {
  double longitude;
  double latitude;

  Location(this.latitude, this.longitude);

  factory Location.fromMap(Map<String, double> map) =>
      Location(map['latitude'], map['longitude']);
}

class MockLocation {
  int longitude;
  int latitude;

  MockLocation(this.latitude, this.longitude);

  factory MockLocation.fromLocation(Location location) => MockLocation((location.latitude * 1e6).toInt(), (location.longitude * 1e6).toInt());
}
