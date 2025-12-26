class Users {
  // col names
  static const String tableName = 'users';
  static const String id = 'id ';
  static const String username = 'username ';
  static const String passwordHash = 'password_hash';
  static const String profileImageUrl = 'profile_image_url';
  static const String rating = 'rating';
  static const String bio = 'bio';
  static const String role = 'role';
  static const String createdAt = 'created_at';
  static const String updatedAt = 'updated_at';

  // operation on col names
  const Users();
}

class Tables {
  static const Users users = Users();
  
}

class Where {
  static const String id = 'id = ?';
  static const String userId = 'user_id = ?';
  static const String productId = 'product_id = ?';
  static const String chatRoomId = 'chat_room_id = ?';
  static const String liveStreamId = 'live_stream_id = ?';
  static const String targetUserId = 'target_user_id = ?';
  static const String text = 'text = ?';
  static const String rating = 'rating = ?';
  static const String createdAt = 'created_at = ?';
  static const String updatedAt = 'updated_at = ?';
  static const String status = 'status = ?';
  static const String category = 'category = ?';
  static const String price = 'price = ?';
  static const String quantity = 'quantity = ?';
  static const String imageUrl = 'image_url = ?';
  static const String title = 'title = ?';
  static const String description = 'description = ?';
  static const String role = 'role = ?';

  static String and(List<String> where) {
    return where.join(' AND ');
  }

  static String or(List<String> where) {
    return where.join(' OR ');
  }

  static String not(String where) {
    return 'NOT $where';
  }

  static String like(String column, String value) {
    return '$column LIKE %$value%';
  }

  static String notLike(String column, String value) {
    return '$column NOT LIKE %$value%';
  }

  static String inValues(String column, List<String> values) {
    return '$column IN (${values.join(',')})';
  }

  static String notInValues(String column, List<String> values) {
    return '$column NOT IN (${values.join(',')})';
  }

  static String between(String column, String start, String end) {
    return '$column BETWEEN $start AND $end';
  }

  static String notBetween(String column, String start, String end) {
    return '$column NOT BETWEEN $start AND $end';
  }

  static String isNull(String column) {
    return '$column IS NULL';
  }

  static String isNotNull(String column) {
    return '$column IS NOT NULL';
  }

  static String isTrue(String column) {
    return '$column IS TRUE';
  }

  static String isFalse(String column) {
    return '$column IS FALSE';
  }

  static String isNotTrue(String column) {
    return '$column IS NOT TRUE';
  }

  static String isNotFalse(String column) {
    return '$column IS NOT FALSE';
  }
}
