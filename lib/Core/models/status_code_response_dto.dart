enum StatusCodeResponse {
  success,
  created,
  badRequest,
  unauthorized,
  notFound,
  noContent,
  internalServerError;

  int get code {
    switch (this) {
      case StatusCodeResponse.success:
        return 200;
      case StatusCodeResponse.created:
        return 201;
      case StatusCodeResponse.noContent:
        return 204;
      case StatusCodeResponse.badRequest:
        return 400;
      case StatusCodeResponse.unauthorized:
        return 401;
      case StatusCodeResponse.notFound:
        return 404;
      case StatusCodeResponse.internalServerError:
        return 500;
    }
  }

  static StatusCodeResponse fromCode(int code) {
    switch (code) {
      case 200:
        return StatusCodeResponse.success;
      case 201:
        return StatusCodeResponse.created;
      case 204:
        return StatusCodeResponse.noContent;
      case 400:
        return StatusCodeResponse.badRequest;
      case 401:
        return StatusCodeResponse.unauthorized;
      case 404:
        return StatusCodeResponse.notFound;
      case 500:
      default:
        return StatusCodeResponse.internalServerError;
    }
  }
}

class StatusCodeResponseDto<T> {
  final StatusCodeResponse statusCodeResponse;
  final String? message;
  final T? data;

  StatusCodeResponseDto({
    required this.statusCodeResponse,
    this.message,
    this.data,
  });

  factory StatusCodeResponseDto.fromJson(Map<String, dynamic> json) {
    return StatusCodeResponseDto(
      statusCodeResponse: _parseStatusCode(json['statusCodeResponse']),
      message: json['message'] as String?,
      data: json['data'],
    );
  }

  static StatusCodeResponse _parseStatusCode(dynamic value) {
    if (value is int) {
      return StatusCodeResponse.fromCode(value);
    } else if (value is String) {
      try {
        final cleanValue =
            value.replaceAll('StatusCodeResponse.', '').toLowerCase();
        return StatusCodeResponse.values.firstWhere(
          (e) => e.toString().split('.').last.toLowerCase() == cleanValue,
          orElse: () => StatusCodeResponse.internalServerError,
        );
      } catch (_) {
        return StatusCodeResponse.internalServerError;
      }
    }
    return StatusCodeResponse.internalServerError;
  }

  bool get isSuccess =>
      statusCodeResponse == StatusCodeResponse.success ||
      statusCodeResponse == StatusCodeResponse.created;
}
