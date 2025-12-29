// ai assited in generating the types of erros and helped define, hwoever, only a few will be used most often

enum ErrorType {
  // =======================
  // Data / Persistence
  // =======================

  /// Requested data does not exist or cannot be found locally
  /// Example: querying an entity by ID that does not exist
  NOT_FOUND,

  /// Attempted to create data that already exists
  /// Example: inserting a record with a unique constraint violation
  ALREADY_EXISTS,

  /// Generic database-related failure
  /// Example: SQLite exception, migration issue, query failure
  DB_ERROR,

  /// Cache layer failure or inconsistency
  /// Example: cache read/write error, unexpected cache state
  CACHE_ERROR,

  /// Stored data is invalid, unreadable, or inconsistent
  /// Example: corrupted rows, incompatible schema, invalid serialized data
  CORRUPTED_DATA,

  // =======================
  // Input / Validation
  // =======================

  /// Provided input does not meet expected format or constraints
  /// Example: negative quantity, invalid value type
  INVALID_INPUT,

  /// Required input data is missing
  /// Example: null or empty required fields
  MISSING_INPUT,

  /// Operation is not valid in the current state
  /// Example: updating a completed order, deleting a locked entity
  INVALID_STATE,

  // =======================
  // Authentication / Authorization
  // =======================

  /// User is not authenticated or session is missing
  /// Example: accessing protected data without a valid session
  UNAUTHORIZED,

  /// Existing session is no longer valid
  /// Example: local session expired or invalidated
  SESSION_EXPIRED,

  /// User is authenticated but lacks permission for the operation
  /// Example: modifying another user's data
  FORBIDDEN,

  // =======================
  // Domain / Business rules
  // =======================

  /// Operation is not allowed based on business rules
  /// Example: checkout with empty cart, invalid workflow step
  OPERATION_NOT_ALLOWED,

  /// A defined limit has been exceeded
  /// Example: max quantity reached, rate limit triggered
  LIMIT_REACHED,

  // =======================
  // Fallback
  // =======================

  /// Unexpected internal failure
  /// Example: unhandled exception, logic error
  INTERNAL_ERROR,

  /// Unknown or uncategorized error
  /// Example: error does not match any known type
  UNKNOWN,
}

class AppError {
  final ErrorType type;
  // for custom messages
  String? message;

  AppError({required this.type, this.message = ''});
}
