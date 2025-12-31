import 'package:dak_louk/data/tables/users_table.dart';
import 'package:dak_louk/data/tables/merchants_table.dart';
import 'package:dak_louk/data/tables/product_categories_table.dart';
import 'package:dak_louk/data/tables/products_table.dart';
import 'package:dak_louk/data/tables/product_category_maps_table.dart';
import 'package:dak_louk/data/tables/product_medias_table.dart';
import 'package:dak_louk/data/tables/posts_table.dart';
import 'package:dak_louk/data/tables/post_products_table.dart';
import 'package:dak_louk/data/tables/promo_medias_table.dart';
import 'package:dak_louk/data/tables/post_likes_table.dart';
import 'package:dak_louk/data/tables/post_saves_table.dart';
import 'package:dak_louk/data/tables/livestreams_table.dart';
import 'package:dak_louk/data/tables/live_stream_products_table.dart';
import 'package:dak_louk/data/tables/livestream_chats_table.dart';
import 'package:dak_louk/data/tables/chatrooms_table.dart';
import 'package:dak_louk/data/tables/chats_table.dart';
import 'package:dak_louk/data/tables/carts_table.dart';
import 'package:dak_louk/data/tables/orders_table.dart';
import 'package:dak_louk/data/tables/order_products_table.dart';
import 'package:dak_louk/data/tables/reviews_table.dart';
import 'package:dak_louk/data/tables/followers_table.dart';

// Tables.users.cols.userId - user_id

class Tables {
  // for generic usage at base repo
  static String get id => 'id';

  // all tables
  static const users = UsersTable();
  static const merchants = MerchantsTable();
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
