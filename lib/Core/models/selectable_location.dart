/// Represents a location prepared for selection in the UI, including its category.
class SelectableLocation {
  final String locationId;
  final String name;
  final String category;

  SelectableLocation({
    required this.locationId,
    required this.name,
    required this.category,
  });

  /// Creates a SelectableLocation instance from a JSON map.
  /// Assumes the API sends the Guid as a string for 'locationId'.
  /// Dart does not support GUID but supports UUID. But it is String type.
  /// If 'category' is null or missing, it defaults to "Uncategorized".
  factory SelectableLocation.fromJson(Map<String, dynamic> json) {
    final locationIdString = json['locationId'] as String?;
    final nameString = json['name'] as String?;
    // Default to "Uncategorized" if category is null or not a string
    final categoryString = (json['category'] as String?) ?? 'Uncategorized';

    if (locationIdString == null) {
      throw FormatException(
        "Missing or invalid 'locationId' in SelectableLocation JSON: value was ${json['locationId']}",
      );
    }
    if (nameString == null) {
      throw FormatException(
        "Missing 'name' in SelectableLocation JSON: value was ${json['name']}",
      );
    }

    // No longer need to parse Uuid, locationIdString is used directly.
    // The try-catch for Uuid.parse is removed.
    return SelectableLocation(
      locationId: locationIdString,
      name: nameString,
      category: categoryString,
    );
  }

  /// Converts this SelectableLocation instance to a JSON map.
  Map<String, dynamic> toJson() {
    return {'locationId': locationId, 'name': name, 'category': category};
  }

  @override
  String toString() {
    return 'SelectableLocation(id: $locationId, name: $name, category: $category)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SelectableLocation && other.locationId == locationId;
  }

  @override
  int get hashCode => locationId.hashCode;
}
