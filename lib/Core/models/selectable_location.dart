/// Represents a location prepared for selection in the UI, including its category.
class SelectableLocation {
  final int locationId;
  final String name;
  final String category; // Default to 'Uncategorized' if null

  SelectableLocation({
    required this.locationId,
    required this.name,
    required this.category,
  });

  @override
  String toString() {
    return 'SelectableLocation(id: $locationId, name: $name, category: $category)';
  }

  // Optional: Add equals and hashCode if using Sets or Maps effectively
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SelectableLocation && other.locationId == locationId;
  }

  @override
  int get hashCode => locationId.hashCode;
}
