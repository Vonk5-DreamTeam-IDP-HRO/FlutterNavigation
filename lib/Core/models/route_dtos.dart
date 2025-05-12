import 'package:flutter/foundation.dart';

// Data Transfer Object for creating a new route.
@immutable
class CreateRouteDto {
  final String name;
  final String? description;
  final List<int> locationIds;

  const CreateRouteDto({
    required this.name,
    this.description,
    required this.locationIds,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      if (description != null) 'description': description,
      'locationIds': locationIds,
    };
  }
}
