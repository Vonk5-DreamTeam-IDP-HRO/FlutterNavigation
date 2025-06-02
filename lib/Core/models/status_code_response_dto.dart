enum StatusCodeResponse {
  success(200),
  created(201),
  noContent(204),
  badRequest(400),
  unauthorized(401),
  notFound(404),
  internalServerError(500);

  final int code;
  const StatusCodeResponse(this.code);

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
        return StatusCodeResponse.internalServerError;
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
}
