import 'package:dak_louk/utils/db/tables/users_table.dart';
import 'package:dak_louk/utils/db/tables/products_table.dart';
import 'package:dak_louk/utils/db/tables/posts_table.dart';
import 'package:dak_louk/utils/db/tables/carts_table.dart';
import 'package:dak_louk/utils/db/tables/chats_table.dart';
import 'package:dak_louk/utils/db/tables/chatrooms_table.dart';
import 'package:dak_louk/utils/db/tables/livestreams_table.dart';
import 'package:dak_louk/utils/db/tables/livestream_chats_table.dart';
import 'package:dak_louk/utils/db/tables/product_progress_table.dart';
import 'package:dak_louk/utils/db/tables/reviews_table.dart';
import 'package:dak_louk/utils/db/tables/medias_table.dart';

// Tables.users.cols.userId - user_id

class Tables {
  // for generic usage at base repo
  static const String id = 'id';

  // all tables
  static const users = UsersTable();
  static const products = ProductsTable();
  static const posts = PostsTable();
  static const carts = CartsTable();
  static const chats = ChatsTable();
  static const chatRooms = ChatRoomsTable();
  static const liveStreams = LiveStreamsTable();
  static const liveStreamChats = LiveStreamChatsTable();
  static const productProgress = ProductProgressTable();
  static const reviews = ReviewsTable();
  static const medias = MediasTable();

  const Tables();
}

// contract for all db tables to make sure it provides its table name and its cols

abstract class DbTable<T extends BaseCols> {
  String get tableName;
  T get cols;
}

// base columns that all tables have to avoid repitition like id, createdAt and updated At cols

abstract class BaseCols {
  const BaseCols();
  String get id => idCol;
  String get createdAt => createdAtCol;
  String get updatedAt => updatedAtCol;

  static const String idCol = 'id';
  static const String createdAtCol = 'created_at';
  static const String updatedAtCol = 'updated_at';
}
