import 'package:dak_louk/utils/db/tables/users_table.dart';
import 'package:dak_louk/utils/db/tables/product_categories_table.dart';
import 'package:dak_louk/utils/db/tables/products_table.dart';
import 'package:dak_louk/utils/db/tables/product_category_maps_table.dart';
import 'package:dak_louk/utils/db/tables/product_medias_table.dart';
import 'package:dak_louk/utils/db/tables/posts_table.dart';
import 'package:dak_louk/utils/db/tables/post_products_table.dart';
import 'package:dak_louk/utils/db/tables/promo_medias_table.dart';
import 'package:dak_louk/utils/db/tables/post_likes_table.dart';
import 'package:dak_louk/utils/db/tables/post_saves_table.dart';
import 'package:dak_louk/utils/db/tables/livestreams_table.dart';
import 'package:dak_louk/utils/db/tables/live_stream_products_table.dart';
import 'package:dak_louk/utils/db/tables/livestream_chats_table.dart';
import 'package:dak_louk/utils/db/tables/chatrooms_table.dart';
import 'package:dak_louk/utils/db/tables/chats_table.dart';
import 'package:dak_louk/utils/db/tables/carts_table.dart';
import 'package:dak_louk/utils/db/tables/orders_table.dart';
import 'package:dak_louk/utils/db/tables/order_products_table.dart';
import 'package:dak_louk/utils/db/tables/reviews_table.dart';
import 'package:dak_louk/utils/db/tables/followers_table.dart';

// Tables.users.cols.userId - user_id

class Tables {
  // for generic usage at base repo
  static String get id => 'id';

  // all tables
  static const users = UsersTable();
  static const productCategories = ProductCategoriesTable();
  static const products = ProductsTable();
  static const productCategoryMaps = ProductCategoryMapsTable();
  static const productMedias = ProductMediasTable();
  static const posts = PostsTable();
  static const postProducts = PostProductsTable();
  static const promoMedias = PromoMediasTable();
  static const postLikes = PostLikesTable();
  static const postSaves = PostSavesTable();
  static const liveStreams = LiveStreamsTable();
  static const liveStreamProducts = LiveStreamProductsTable();
  static const liveStreamChats = LiveStreamChatsTable();
  static const chatRooms = ChatRoomsTable();
  static const chats = ChatsTable();
  static const carts = CartsTable();
  static const orders = OrdersTable();
  static const orderProducts = OrderProductsTable();
  static const reviews = ReviewsTable();
  static const followers = FollowersTable();

  const Tables();
}

// contract for all db tables to make sure it provides its table name and its cols

abstract class DbTable<T> {
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

// base columns for tables that only have id and created_at (no updated_at)
abstract class BaseColsCreatedOnly {
  const BaseColsCreatedOnly();
  String get id => idCol;
  String get createdAt => createdAtCol;

  static const String idCol = 'id';
  static const String createdAtCol = 'created_at';
}
