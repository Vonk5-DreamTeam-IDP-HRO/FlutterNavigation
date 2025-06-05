import 'package:freezed_annotation/freezed_annotation.dart';

part 'create_route_dto.freezed.dart';
part 'create_route_dto.g.dart';

/// Data Transfer Object for creating new routes via API
///
/// This maps exactly to the C# CreateRouteDto from your ASP.NET Core API.
/// Used when POSTing new route data to `/api/route` endpoint.
///
/// **API Mapping:**
/// - Maps to `Routeplanner_API.DTO.Route.CreateRouteDto`
/// - Validates against `[Required]` and `[StringLength(255)]` attributes
/// - `createdBy` will be populated server-side from authenticated user context
///
/// **Validation Rules:**
/// - `name`: Required, max 255 characters (enforced by API)
/// - `isPrivate`: Required boolean, defaults to true for privacy
/// - `description`: Optional field for route details
/// - `createdBy`: Optional in DTO, set by backend service layer
///
/// **Example Usage:**
/// ```dart
/// final createRouteDto = CreateRouteDto(
///   name: "Weekend City Tour",
///   description: "A scenic route through downtown Rotterdam",
///   isPrivate: false,
/// );
/// ```
@freezed
abstract class CreateRouteDto with _$CreateRouteDto {
  const factory CreateRouteDto({
    /// Name of the route to create
    ///
    /// **Validation:** Required, max 255 characters
    /// **API Mapping:** Maps to C# `[Required][StringLength(255)] string Name`
    ///
    /// Examples: "Morning Jog Route", "Historic City Center Tour"
    required String name,

    /// Optional description providing route details
    ///
    /// **API Mapping:** Maps to C# `string? Description`
    ///
    /// Can include route highlights, difficulty level, estimated duration, etc.
    /// Examples: "A peaceful 5km route along the waterfront with cafe stops"
    String? description,

    /// Privacy setting for route visibility
    ///
    /// **Validation:** Required boolean
    /// **API Mapping:** Maps to C# `[Required] bool IsPrivate`
    /// **Default:** `true` for user privacy
    ///
    /// - `true`: Only creator can see the route
    /// - `false`: Route is publicly discoverable
    @Default(true) bool isPrivate,

    /// Optional creator identifier
    ///
    /// **API Behavior:** Will be overridden by backend service layer
    /// **Security:** Backend extracts user ID from JWT authentication token
    /// **API Mapping:** Maps to C# `Guid? CreatedBy`
    ///
    /// Note: This field is included for API compatibility but the backend
    /// service will populate it from the authenticated user context.
    String? createdBy,

    /// List of location IDs that make up the route
    /// **API Mapping:** Maps to C# `ICollection<Guid> LocationIds`
    /// **Validation:** Minimum length of 2 locations required
    @Default([]) List<String> locationIds,
  }) = _CreateRouteDto;

  /// Creates CreateRouteDto from JSON
  ///
  /// **API Integration:** Used when receiving route data from forms or API responses
  ///
  /// Handles conversion from Map<String, dynamic> typically received from:
  /// - HTTP request bodies
  /// - Form submissions
  /// - Local storage serialization
  factory CreateRouteDto.fromJson(Map<String, dynamic> json) =>
      _$CreateRouteDtoFromJson(json);
}

/// Validation extension for CreateRouteDto
///
/// Provides client-side validation that mirrors the backend API validation rules.
/// Use these methods before sending requests to catch validation errors early.
extension CreateRouteDtoValidation on CreateRouteDto {
  /// Validates the route name field
  ///
  /// **Rules:**
  /// - Cannot be empty (API [Required] attribute)
  /// - Cannot exceed 255 characters (API [StringLength(255)] attribute)
  ///
  /// **Returns:** Error message if invalid, null if valid
  String? validateName() {
    if (name.trim().isEmpty) {
      return 'Route name is required';
    }
    if (name.length > 255) {
      return 'Route name must be 255 characters or less';
    }
    return null;
  }

  /// Validates the description field
  ///
  /// **Rules:**
  /// - Optional field, max 1000 characters (API [StringLength(1000)] attribute)
  ///
  /// **Returns:** Error message if invalid, null if valid
  String? validateDescription() {
    if (description != null && description!.length > 1000) {
      return 'Description must be 1000 characters or less';
    }
    return null;
  }

  /// Validates the location IDs
  ///
  /// **Rules:**
  /// - Must have at least 2 locations (API [MinLength(2)] attribute)
  ///
  /// **Returns:** Error message if invalid, null if valid
  String? validateLocationIds() {
    if (locationIds.length < 2) {
      return 'At least 2 locations are required for a route';
    }
    return null;
  }

  /// Checks if the entire DTO passes all validation rules
  ///
  /// **Usage:** Call before sending API requests to ensure data validity
  ///
  /// **Returns:** `true` if all fields are valid, `false` otherwise
  ///
  /// **Example:**
  /// ```dart
  /// if (createRouteDto.isValid()) {
  ///   await routeService.createRoute(createRouteDto);
  /// } else {
  ///   // Handle validation errors
  /// }
  /// ```
  bool isValid() {
    return validateName() == null &&
        validateDescription() == null &&
        validateLocationIds() == null;
  }

  /// Gets all current validation errors
  ///
  /// **Returns:** List of validation error messages
  /// **Usage:** Display all validation issues to user at once
  ///
  /// **Example:**
  /// ```dart
  /// final errors = createRouteDto.getValidationErrors();
  /// if (errors.isNotEmpty) {
  ///   showErrorDialog(errors.join('\n'));
  /// }
  /// ```
  List<String> getValidationErrors() {
    final errors = <String>[];

    final nameError = validateName();
    if (nameError != null) errors.add(nameError);

    final descriptionError = validateDescription();
    if (descriptionError != null) errors.add(descriptionError);

    final locationIdsError = validateLocationIds();
    if (locationIdsError != null) errors.add(locationIdsError);

    return errors;
  }
}
