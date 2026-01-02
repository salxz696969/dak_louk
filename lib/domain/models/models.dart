library domain;

// Cache
part '../../data/cache/cacheable.dart';

// Enums
part '../../core/enums/progress_status_enum.dart';
part '../../core/enums/product_category_enum.dart';

// Raw Models
part 'raw/cart_model.dart';
part 'raw/user_model.dart';
part 'raw/merchant_model.dart';
part 'raw/product_model.dart';
part 'raw/product_category_model.dart';
part 'raw/order_model.dart';
part 'raw/order_product_model.dart';
part 'raw/post_model.dart';
part 'raw/post_product_model.dart';
part 'raw/post_like_model.dart';
part 'raw/post_save_model.dart';
part 'raw/follower_model.dart';
part 'raw/chat_model.dart';
part 'raw/chat_room_model.dart';
part 'raw/promo_media_model.dart';
part 'raw/live_stream_model.dart';
part 'raw/live_stream_chat_model.dart';
part 'raw/review_model.dart';
part 'raw/product_media_model.dart';
part 'raw/product_category_map_model.dart';

// View Models
part 'view_models/cart_vm.dart';
part 'view_models/user_vm.dart';
part 'view_models/product_vm.dart';
part 'view_models/product_media_vm.dart';
part 'view_models/promo_media_vm.dart';
part 'view_models/order_vm.dart';
part 'view_models/post_vm.dart';
part 'view_models/chat_vm.dart';
part 'view_models/chat_room_vm.dart';
part 'view_models/live_stream_vm.dart';
part 'view_models/live_stream_chat_vm.dart';
part 'view_models/review_vm.dart';
part 'view_models/merchant_vm.dart';
part 'view_models/merchant_profile/merchant_posts_vm.dart';
part 'view_models/merchant_profile/merchant_livestreams_vm.dart';
part 'view_models/merchant_profile/merchant_products_vm.dart';
part 'view_models/profile/user_profile_vm.dart';
part 'view_models/profile/user_profile_liked_saved_posts_vm.dart';

part 'dto/cart_dto.dart';
part 'dto/product_dto.dart';
part 'dto/order_dto.dart';
part 'dto/post_dto.dart';
part 'dto/post_save_dto.dart';
part 'dto/chat_dto.dart';
part 'dto/chat_room_dto.dart';
part 'dto/live_stream_dto.dart';
part 'dto/live_stream_chat_dto.dart';
part 'dto/review_dto.dart';
part 'dto/user_dto.dart';

// Auth DTOs
part 'dto/auth/log_in_dto.dart';
part 'dto/auth/sign_up_dto.dart';
