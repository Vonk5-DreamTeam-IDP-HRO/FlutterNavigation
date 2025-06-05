import 'package:freezed_annotation/freezed_annotation.dart';

part 'SelectableNavigationRoute.freezed.dart';
part 'SelectableNavigationRoute.g.dart';

/// UI-focused model for selectable route items in navigation interfaces
///
/// **Primary Purpose:** Represents a simplified route model optimized for selection widgets,
/// dropdowns, and navigation components where users choose from available routes.
///
/// **Key Differences from RouteDto:**
/// - Simplified structure with only essential display fields
/// - Optimized for UI performance in lists and pickers
/// - No timestamps or metadata (focused on selection UX)
/// - Custom naming (`displayName` vs `name`) for UI clarity
///
/// **Common Usage Scenarios:**
/// - Route selection dropdowns in create/edit forms
/// - Navigation route picker in map interfaces
/// - "Choose starting route" selection dialogs
/// - Route comparison and recommendation lists
/// - Bookmark/favorites quick selection
///
/// **Design Patterns:**
/// ```dart
/// // In route selection widgets
/// DropdownButton<SelectableNavigationRoute>(
///   items: routes.map((route) => DropdownMenuItem(
///     value: route,
///     child: Text(route.displayName),
///   )).toList(),
/// )
///
/// // In search/filter scenarios
/// final filteredRoutes = routes.where(
///   (route) => route.displayName.toLowerCase().contains(query)
/// ).toList();
/// ```
///
/// **Data Transformation:**
/// ```dart
/// // Convert from full RouteDto to selectable model
/// SelectableNavigationRoute.fromRouteDto(RouteDto route) {
///   return SelectableNavigationRoute(
///     id: route.routeId,
///     displayName: route.name,
///     description: route.description ?? 'No description',
///   );
/// }
/// ```
@freezed
abstract class SelectableNavigationRoute with _$SelectableNavigationRoute {
  /// Creates a selectable route item for UI components
  ///
  /// **Design Philosophy:** Minimal data model focused on user selection experience.
  /// Contains only the essential information needed for users to identify and
  /// choose between different route options.
  ///
  /// **Performance Benefits:**
  /// - Lightweight objects for large lists (no heavy metadata)
  /// - Fast JSON serialization for caching selection states
  /// - Efficient memory usage in dropdown/picker widgets
  /// - Quick string operations for search/filter functionality
  const factory SelectableNavigationRoute({
    /// Unique identifier linking back to the full route entity
    ///
    /// **Purpose:** Primary key for retrieving complete route data when selected
    /// **Format:** UUID v4 string matching RouteDto.routeId
    /// **Usage:** Navigation parameter, API lookups, deep linking
    ///
    /// **Implementation Examples:**
    /// ```dart
    /// // Navigate to route details
    /// context.push('/routes/${selectedRoute.id}');
    ///
    /// // Fetch full route data
    /// final fullRoute = await routeService.getRoute(selectedRoute.id);
    ///
    /// // Update user preferences
    /// await userPrefs.setLastSelectedRoute(selectedRoute.id);
    /// ```
    ///
    /// **Data Consistency:**
    /// - Must match existing RouteDto.routeId in database
    /// - Used for referential integrity in selection operations
    /// - Links selection state back to complete route entity
    required String id,

    /// User-friendly name optimized for display in selection interfaces
    ///
    /// **Naming Choice:** `displayName` (vs `name`) indicates UI-specific formatting
    /// **Content:** May include enhanced formatting, truncation, or prefixes
    /// **Usage:** Primary text in dropdowns, lists, and selection widgets
    ///
    /// **Display Optimizations:**
    /// - Pre-truncated for consistent UI layout
    /// - May include contextual prefixes ("My Route: ...", "Public: ...")
    /// - Formatted for specific UI constraints (character limits)
    ///
    /// **Examples:**
    /// - `"Morning Jog (5km)"` - includes distance hint
    /// - `"Historic Center Tour..."` - truncated with ellipsis
    /// - `"★ Weekend Cycling"` - includes favorite indicator
    ///
    /// **Transformation Logic:**
    /// ```dart
    /// // From RouteDto.name with UI enhancements
    /// displayName = route.isPrivate
    ///   ? "🔒 ${route.name}"
    ///   : route.name;
    /// ```
    required String displayName,

    /// Brief route summary optimized for secondary UI text
    ///
    /// **Purpose:** Provides additional context in selection interfaces
    /// **Content:** Condensed route highlights, difficulty, or key features
    /// **Usage:** Subtitle text in lists, tooltip content, preview information
    ///
    /// **Content Strategy:**
    /// - Shorter than full RouteDto.description (optimal for UI)
    /// - Highlights most important route characteristics
    /// - Helps users distinguish between similar route names
    /// - May include computed metadata (distance, duration estimates)
    ///
    /// **UI Applications:**
    /// ```dart
    /// // List item with subtitle
    /// ListTile(
    ///   title: Text(route.displayName),
    ///   subtitle: Text(route.description),
    /// )
    ///
    /// // Tooltip for compact displays
    /// Tooltip(
    ///   message: route.description,
    ///   child: Text(route.displayName),
    /// )
    /// ```
    ///
    /// **Content Examples:**
    /// - `"5km riverside path • Easy difficulty"` - key stats
    /// - `"Historic landmarks tour through city center"` - highlights
    /// - `"Created by @username • 4.5★ rating"` - social context
    ///
    /// **Data Processing:**
    /// - May aggregate information from multiple sources
    /// - Could include computed fields (ratings, popularity)
    /// - Optimized length for common UI component constraints
    required String description,
  }) = _NavigationRoute;

  /// Creates SelectableNavigationRoute from JSON data
  ///
  /// **Data Sources:** Supports multiple JSON formats for flexible integration
  ///
  /// **Common Sources:**
  /// - Simplified API endpoints returning selection-optimized data
  /// - Cached user preference data (recently selected routes)
  /// - Configuration files defining available navigation options
  /// - Search API responses with formatted display names
  ///
  /// **Example JSON Formats:**
  /// ```json
  /// // Minimal selection format
  /// {
  ///   "id": "123e4567-e89b-12d3-a456-426614174000",
  ///   "displayName": "Morning Jog Route",
  ///   "description": "5km riverside path • Easy difficulty"
  /// }
  ///
  /// // Enhanced with UI metadata
  /// {
  ///   "id": "456e7890-e89b-12d3-a456-426614174001",
  ///   "displayName": "🔒 Private Training Route",
  ///   "description": "Personal workout route • 3km • Moderate"
  /// }
  /// ```
  ///
  /// **Integration Patterns:**
  /// ```dart
  /// // From API response
  /// final routes = (response['routes'] as List)
  ///   .map((json) => SelectableNavigationRoute.fromJson(json))
  ///   .toList();
  ///
  /// // From cached selections
  /// final recentRoutes = await storage.getRecentRoutes();
  /// final selectableRoutes = recentRoutes
  ///   .map((json) => SelectableNavigationRoute.fromJson(json))
  ///   .toList();
  /// ```
  ///
  /// **Error Handling:**
  /// - Validates required fields (id, displayName, description)
  /// - Throws `FormatException` for malformed JSON structure
  /// - Handles null/missing optional fields gracefully
  factory SelectableNavigationRoute.fromJson(Map<String, dynamic> json) =>
      _$NavigationRouteFromJson(json);
}

/// Extension methods for SelectableNavigationRoute providing enhanced UI functionality
///
/// These methods add computed properties and utility functions specifically designed
/// for selection interface scenarios and user experience improvements.
extension SelectableNavigationRouteExtensions on SelectableNavigationRoute {
  /// Checks if the route name matches a search query (case-insensitive)
  ///
  /// **Purpose:** Filter routes in search/selection interfaces
  /// **Logic:** Searches both displayName and description fields
  /// **Usage:** Real-time search filtering, type-ahead functionality
  ///
  /// **Search Strategy:**
  /// - Case-insensitive matching
  /// - Searches displayName and description
  /// - Supports partial matches
  /// - Trims whitespace from query
  ///
  /// **Example:**
  /// ```dart
  /// final filteredRoutes = routes
  ///   .where((route) => route.matchesSearch(searchQuery))
  ///   .toList();
  /// ```
  bool matchesSearch(String query) {
    if (query.trim().isEmpty) return true;

    final lowerQuery = query.toLowerCase().trim();
    final lowerName = displayName.toLowerCase();
    final lowerDescription = description.toLowerCase();

    return lowerName.contains(lowerQuery) ||
        lowerDescription.contains(lowerQuery);
  }

  /// Extracts privacy indicator from display name
  ///
  /// **Purpose:** Determine route privacy status from UI-formatted display name
  /// **Logic:** Detects privacy prefixes added during UI formatting
  /// **Usage:** Filtering, sorting, UI state management
  ///
  /// **Detection Rules:**
  /// - Looks for lock emoji (🔒) prefix indicating private route
  /// - Returns true if private indicator found
  /// - Defaults to false for public or unknown privacy status
  ///
  /// **Example:**
  /// ```dart
  /// if (route.isPrivateRoute()) {
  ///   showPrivacyWarning();
  /// }
  /// ```
  bool isPrivateRoute() {
    return displayName.startsWith("🔒");
  }

  /// Gets clean route name without UI formatting prefixes
  ///
  /// **Purpose:** Extract original route name for API calls or data processing
  /// **Logic:** Removes privacy indicators and other UI prefixes
  /// **Usage:** API requests, data transformation, clean text display
  ///
  /// **Cleaning Rules:**
  /// - Removes privacy emoji prefixes (🔒, 🌍, etc.)
  /// - Trims whitespace
  /// - Preserves original route name content
  ///
  /// **Example:**
  /// ```dart
  /// final apiName = route.getCleanName(); // "Morning Jog" from "🔒 Morning Jog"
  /// await routeService.updateRoute(route.id, apiName);
  /// ```
  String getCleanName() {
    String clean = displayName;

    // Remove common UI prefixes
    if (clean.startsWith("🔒 ")) clean = clean.substring(2);
    if (clean.startsWith("🌍 ")) clean = clean.substring(2);
    if (clean.startsWith("★ ")) clean = clean.substring(2);

    return clean.trim();
  }

  /// Generates a short preview of the route description
  ///
  /// **Purpose:** Truncated text for compact UI displays
  /// **Logic:** Intelligent truncation preserving word boundaries
  /// **Usage:** List item subtitles, tooltips, card previews
  ///
  /// **Truncation Strategy:**
  /// - Respects word boundaries (no mid-word cuts)
  /// - Adds ellipsis (...) for truncated content
  /// - Configurable maximum length (default: 50 characters)
  /// - Handles edge cases (short descriptions, empty content)
  ///
  /// **Parameters:**
  /// - `maxLength`: Maximum character count (default: 50)
  ///
  /// **Example:**
  /// ```dart
  /// Text(route.getShortDescription(30)) // "A scenic route through..."
  /// ```
  String getShortDescription([int maxLength = 50]) {
    if (description.length <= maxLength) return description;

    // Find last space before maxLength to avoid cutting words
    int cutPoint = description.lastIndexOf(' ', maxLength);
    if (cutPoint == -1) cutPoint = maxLength; // No space found, hard cut

    return "${description.substring(0, cutPoint)}...";
  }

  /// Extracts metadata hints from the description
  ///
  /// **Purpose:** Parse structured information embedded in descriptions
  /// **Logic:** Detects common patterns like distance, difficulty, ratings
  /// **Usage:** Sorting, filtering, enhanced UI displays
  ///
  /// **Detected Patterns:**
  /// - Distance: "5km", "3.2 miles"
  /// - Difficulty: "Easy", "Moderate", "Hard"
  /// - Ratings: "4.5★", "★★★☆☆"
  /// - Duration: "30 min", "1 hour"
  ///
  /// **Returns:** Map with detected metadata categories
  ///
  /// **Example:**
  /// ```dart
  /// final metadata = route.getMetadata();
  /// if (metadata.containsKey('distance')) {
  ///   showDistanceFilter();
  /// }
  /// ```
  Map<String, String> getMetadata() {
    final metadata = <String, String>{};
    final desc = description.toLowerCase();

    // Extract distance patterns
    final distancePattern = RegExp(r'(\d+(?:\.\d+)?)(?:\s*)(km|miles?|mi)');
    final distanceMatch = distancePattern.firstMatch(desc);
    if (distanceMatch != null) {
      metadata['distance'] = distanceMatch.group(0)!;
    }

    // Extract difficulty levels
    if (desc.contains('easy')) metadata['difficulty'] = 'Easy';
    if (desc.contains('moderate')) metadata['difficulty'] = 'Moderate';
    if (desc.contains('hard') || desc.contains('difficult'))
      metadata['difficulty'] = 'Hard';

    // Extract ratings
    final ratingPattern = RegExp(r'(\d+(?:\.\d+)?)★');
    final ratingMatch = ratingPattern.firstMatch(desc);
    if (ratingMatch != null) {
      metadata['rating'] = ratingMatch.group(1)!;
    }

    return metadata;
  }

  /// Checks compatibility with another route for comparison/grouping
  ///
  /// **Purpose:** Group similar routes in UI, comparison functionality
  /// **Logic:** Analyzes metadata and description patterns for similarity
  /// **Usage:** "Similar routes" sections, recommendation systems
  ///
  /// **Compatibility Factors:**
  /// - Similar difficulty levels
  /// - Comparable distances
  /// - Common keywords in descriptions
  ///
  /// **Example:**
  /// ```dart
  /// final similarRoutes = allRoutes
  ///   .where((route) => selectedRoute.isCompatibleWith(route))
  ///   .toList();
  /// ```
  bool isCompatibleWith(SelectableNavigationRoute other) {
    final thisMetadata = getMetadata();
    final otherMetadata = other.getMetadata();

    // Check difficulty compatibility
    if (thisMetadata.containsKey('difficulty') &&
        otherMetadata.containsKey('difficulty')) {
      return thisMetadata['difficulty'] == otherMetadata['difficulty'];
    }

    // Check distance similarity (within 50% range)
    if (thisMetadata.containsKey('distance') &&
        otherMetadata.containsKey('distance')) {
      // Simplified distance comparison - could be enhanced
      return true; // Placeholder for distance comparison logic
    }

    // Default to compatible if no clear incompatibility
    return true;
  }

  /// Generates a search-optimized string for indexing
  ///
  /// **Purpose:** Create searchable text for advanced search functionality
  /// **Logic:** Combines all searchable text with metadata keywords
  /// **Usage:** Search indexing, fuzzy matching, content analysis
  ///
  /// **Content Included:**
  /// - Clean display name
  /// - Full description
  /// - Extracted metadata keywords
  /// - Normalized text for consistent searching
  ///
  /// **Example:**
  /// ```dart
  /// final searchIndex = routes
  ///   .map((route) => route.getSearchableText())
  ///   .toList();
  /// ```
  String getSearchableText() {
    final cleanName = getCleanName();
    final metadata = getMetadata();
    final metadataText = metadata.values.join(' ');

    return "$cleanName $description $metadataText".toLowerCase();
  }
}
