# Dak Louk - Technical Architecture Document

Dak Louk is a Flutter marketplace application implementing a clean, layered architecture with role-based user flows (user and merchant), comprehensive caching, and a custom ORM system.

## Table of Contents

1. [Core & Foundations](#1-core--foundations)
2. [Models & Data Representation](#2-models--data-representation)
3. [Data Layer](#3-data-layer)
4. [Caching System](#4-caching-system)
5. [Service Layer](#5-service-layer)
6. [UI Architecture](#6-ui-architecture)
7. [UX & Interaction Patterns](#7-ux--interaction-patterns)
8. [Media & Platform Integrations](#8-media--platform-integrations)
9. [Theming & Visual System](#9-theming--visual-system)

---

## 1. Core & Foundations

### 1.1 App Lifecycle & Initialization

The application follows a singleton-based initialization pattern:

- **Entry Point**: `main.dart` ensures `WidgetsFlutterBinding` is initialized before `AppSession.instance.init()`
- **Session Initialization**: `AppSession` loads persisted session data from `SharedPreferences` on app start
- **Database Initialization**: `AppDatabase` uses lazy initialization - database is created on first access
- **Database Reset**: Database is deleted and recreated on every app restart (development mode behavior)

**Key Design Decisions**:

- Singleton pattern for `AppSession` and `AppDatabase` ensures single source of truth
- Session persistence via `SharedPreferences` allows seamless app restarts
- Database deletion on restart simplifies development but should be removed in production

### 1.2 Session Management (`AppSession`)

`AppSession` is a singleton managing authentication state and role-based identity:

**Session State**:

- `userId` / `merchantId`: Current authenticated entity ID
- `username` / `merchantUsername`: Display names
- `role`: `Role.user` or `Role.merchant` enum
- `phone`, `address`: User-specific fields (null for merchants)

**Session Methods**:

- `init()`: Loads persisted session from `SharedPreferences`
- `login()`: Authenticates via email/password, sets appropriate session fields
- `signUpUser()`: Creates new user account and initializes session
- `logout()`: Clears all session data and persisted preferences

**Role-Based Behavior**:

- Merchants have `merchantId` 
- Users have `userId` 
- Session determines which services and UI flows are accessible (via constructor checking in services)

### 1.3 Role-Based Flows

The application implements two distinct user experiences:

**User Flow** (`UserScaffold`):

- Home (posts feed), Live Streams, Orders, Chat Rooms, Profile
- Can browse products, add to cart, place orders
- Can like/save posts, chat with merchants
- Can view merchant profiles

**Merchant Flow** (`MerchantScaffold`):

- Orders management, Products management, Posts management, Live Streams, Chat Rooms
- Can create/edit/delete products and posts
- Can manage orders (accept, deliver, complete, cancel)
- Can create live streams with featured products
- Can chat with users

**Navigation Separation**:

- `UserScaffold` and `MerchantScaffold` are separate root widgets
- `MyApp` routes to appropriate scaffold based on `AppSession.instance.role`
- Bottom navigation bars differ per role (`UserTabs` vs `MerchantTabs`)

### 1.4 Global Error Model

**Error Type Enum** (`ErrorType`):
Comprehensive error categorization:

- **Data/Persistence**: `NOT_FOUND`, `ALREADY_EXISTS`, `DB_ERROR`, `CACHE_ERROR`, `CORRUPTED_DATA`
- **Input/Validation**: `INVALID_INPUT`, `MISSING_INPUT`, `INVALID_STATE`
- **Auth/Authorization**: `UNAUTHORIZED`, `SESSION_EXPIRED`, `FORBIDDEN`
- **Domain/Business**: `OPERATION_NOT_ALLOWED`, `LIMIT_REACHED`
- **Fallback**: `INTERNAL_ERROR`, `UNKNOWN`

**AppError Class**:

```dart
class AppError implements Exception {
  final ErrorType type;
  String? message;
}
```

**Error Propagation Strategy**:

- Errors are thrown as `AppError` instances from repositories and services
- Services catch non-`AppError` exceptions and wrap them in `AppError` with appropriate type
- UI layers catch errors and display user-friendly messages
- Error messages are logged via `debugPrint` for debugging

**Error Handling Patterns**:

- Repositories: Wrap SQLite exceptions in `DB_ERROR`
- Services: Validate inputs, check permissions, wrap domain errors
- UI: Use `FutureBuilder` error states or try-catch with `SnackBar` messages

---

## 2. Models & Data Representation

### 2.1 Three Model Types

The architecture uses three distinct model types to separate concerns:

**Raw Models** (`lib/domain/models/raw/`):

- **Purpose**: Exact representation of database rows
- **Characteristics**:
  - Fields match database columns exactly
  - All required fields are non-nullable (except DB-nullable columns)
  - No business logic, no computed properties
  - Extend `Cacheable` for cache compatibility
- **Example**: `ProductModel` with `id`, `merchantId`, `name`, `description`, `price`, `quantity`, `createdAt`, `updatedAt`

**View Models** (`lib/domain/models/view_models/`):

- **Purpose**: UI-optimized data structures
- **Characteristics**:
  - Flattened or nested structures for easy UI consumption
  - Pre-computed fields (e.g., `likesCount`, `isLiked`, `isSaved`)
  - Nested VMs for related data (e.g., `PostVM` contains `PostMerchantVM` and `List<PostProductVM>`)
  - Many optional fields for flexibility
  - Extend `Cacheable` for service-level caching
- **Example**: `PostVM` with nested `merchant`, `products`, `likesCount`, `isLiked`, `isSaved`

**DTOs** (`lib/domain/models/dto/`):

- **Purpose**: Input contracts for create/update operations
- **Characteristics**:
  - Only fields needed for the operation
  - Optional fields based on operation requirements
  - No IDs (except for update operations referencing existing entities)
  - Validation-ready structure
- **Example**: `CreateProductDTO` with `name`, `description?`, `price`, `quantity`

### 2.2 Model Responsibilities & Boundaries

**Raw Models**:

- Owned by: Repository layer
- Used by: Repositories (fromMap/toMap), Services (as input to View Model construction)
- Never exposed to UI directly

**View Models**:

- Owned by: Service layer
- Used by: Services (return values), UI (display data)
- Never stored in database

**DTOs**:

- Owned by: Service layer (input contracts)
- Used by: UI (form data), Services (validation and transformation)
- Never stored in database

### 2.3 Mapping & Transformation Patterns

**Repository → Raw Model**:

- `fromMap(Map<String, dynamic>)`: Converts database row to Raw Model
- Handles type conversions (e.g., `DateTime.parse()` for timestamps)
- Uses table column constants for type-safe field access

**Raw Model → View Model**:

- Factory constructors: `PostVM.fromRaw(PostModel raw, {...})`
- Services orchestrate multiple repository calls to gather related data
- Services compute derived fields (counts, flags) before constructing VMs

**DTO → Raw Model**:

- Services construct Raw Models from DTOs in create/update operations
- Services add system fields (timestamps, IDs) not present in DTOs
- Services validate DTO fields before transformation

**Example Transformation Flow**:

```
UI Form → CreateProductDTO → ProductService.createProduct()
→ ProductModel (Raw) → ProductRepository.insert()
→ Database Row → ProductRepository.fromMap()
→ ProductModel (Raw) → ProductVM.fromRaw()
→ ProductVM → UI Display
```

---

## 3. Data Layer

### 3.1 SQLite Schema Design

**Database**: Single SQLite database (`marketplace.db`)

**Schema Characteristics**:

- 21 tables covering users, merchants, products, posts, orders, chats, live streams
- Foreign key constraints with `ON DELETE CASCADE` for referential integrity
- Unique constraints on junction tables (many-to-many relationships)
- CHECK constraints for enum-like values (e.g., order status, media type)
- Timestamps stored as ISO8601 strings (not INTEGER)

**Table Relationships**:

- **Users** → **Merchants** (1:1, merchants reference users)
- **Merchants** → **Products** (1:many)
- **Products** ↔ **Categories** (many:many via `product_category_maps`)
- **Merchants** → **Posts** (1:many)
- **Posts** ↔ **Products** (many:many via `post_products`)
- **Users** → **Carts** (1:many)
- **Users** → **Orders** (1:many)
- **Orders** → **Order Products** (1:many)
- **Users** ↔ **Merchants** (chat rooms, many:many via `chat_rooms`)

**Trade-offs**:

- **Pros**: Simple, single-file database; easy to backup/restore; good for offline-first
- **Cons**: No built-in migrations (schema changes require app update); limited query optimization; no concurrent write optimization

### 3.2 Table Definitions

**Table Structure Pattern**:
Each table has:

1. **Table Class**: Implements `DbTable<T>` interface

   ```dart
   class ProductsTable implements DbTable<ProductsCols> {
     String get tableName => 'products';
     ProductsCols get cols => ProductsCols();
   }
   ```

2. **Columns Class**: Extends `BaseCols`
   ```dart
   class ProductsCols extends BaseCols {
     static const String merchantIdCol = 'merchant_id';
     String get merchantId => merchantIdCol;
   }
   ```

**BaseCols** provides common columns:

- `id`: Primary key
- `createdAt`: Creation timestamp
- `updatedAt`: Last update timestamp

**Benefits**:

- Type-safe column references (no magic strings)
- IDE autocomplete for column names
- Centralized column name management
- Easy refactoring

### 3.3 Custom ORM / Query Builder

**Clauses System** (`lib/core/utils/orm.dart`):

**Where Clauses**:

```dart
Clauses.where.eq(column, value)           // WHERE column = ?
Clauses.where.and([condition1, condition2]) // WHERE condition1 AND condition2
Clauses.where.or([condition1, condition2])  // WHERE condition1 OR condition2
Clauses.where.gt(column, value)           // WHERE column > ?
Clauses.where.inVal(column, [v1, v2])      // WHERE column IN (?, ?)
Clauses.where.between(column, start, end)  // WHERE column BETWEEN ? AND ?
```

**OrderBy Clauses**:

```dart
Clauses.orderBy.asc(column)                // ORDER BY column ASC
Clauses.orderBy.desc(column)               // ORDER BY column DESC
Clauses.orderBy.caseWhen(column, cases)    // Custom CASE WHEN ordering
Clauses.orderBy.thenBy(orderByClause)      // Multiple ordering
```

**Like Clauses**:

```dart
Clauses.like.like(column, value)          // WHERE column LIKE '%value%'
```

**Design Decisions**:

- Immutable clause objects (each method returns new instance)
- Parameterized queries (prevents SQL injection)
- Type-safe column references via table column classes
- Fluent API for complex queries

**Limitations**:

- No JOIN support (requires multiple queries)
- No subquery support
- No aggregate functions (COUNT, SUM, etc.) - handled in application code

### 3.4 Repository Pattern

**BaseRepository<T>** (`lib/data/repositories/base_repo.dart`):

**Abstract Interface** (`BaseRepositoryInterface<T>`):

- `getAll()`: Get all records
- `getById(int id)`: Get single record
- `insert(T model)`: Create record
- `update(T model)`: Update record
- `delete(int id)`: Delete record
- `queryThisTable({where, args, orderBy, limit, offset})`: Custom queries
- `fromMap(Map)`: Convert DB row to model
- `toMap(T)`: Convert model to DB row
- `tableName`: Table name getter

**BaseRepository Implementation**:

- Provides default CRUD implementations
- Automatic caching integration (see Caching System)
- Error wrapping (catches exceptions, wraps in `AppError`)
- Type-safe generic operations

**Concrete Repositories**:
Each repository extends `BaseRepository<RawModel>` and implements:

- `fromMap()`: Database row → Raw Model
- `toMap()`: Raw Model → Database row
- `tableName`: Returns table name

**Example**:

```dart
class ProductRepository extends BaseRepository<ProductModel> {
  @override
  String get tableName => Tables.products.tableName;

  @override
  ProductModel fromMap(Map<String, dynamic> map) { /* ... */ }

  @override
  Map<String, dynamic> toMap(ProductModel model) { /* ... */ }
}
```

**Custom Repository Methods**:
Some repositories add domain-specific methods:

- `UserRepository.getUserByEmailAndPassword()`: Authentication query
- `MerchantRepository.getMerchantByEmailAndPassword()`: Authentication query

### 3.5 Generic Usage & Type Safety

**Type Safety Strategies**:

- Generic `BaseRepository<T>` ensures compile-time type checking
- Table column constants prevent typos in column names
- Raw Models enforce database schema compliance
- DTOs enforce input validation contracts

**Type Casting**:

- Cache system uses `Cacheable` base class (non-generic)
- Repositories cast cached values: `_expectMany(cached).cast<T>()`
- Type safety guaranteed by architecture (cache keys are repository-scoped)

---

## 4. Caching System

### 4.1 Cacheable Type Design

**Cacheable Base Class**:

```dart
sealed class Cacheable {}
```

**Purpose**:

- Marker interface for types that can be cached
- All Raw Models and View Models extend `Cacheable`
- Enables type-safe cache value storage

**CacheValue Wrapper**:

```dart
sealed class CacheValue {
  Cacheable? get single;
  List<Cacheable>? get many;
}

class Single extends CacheValue { final Cacheable data; }
class Many extends CacheValue { final List<Cacheable> data; }
```

**Design Rationale**:

- Mimics TypeScript union types (`Single<T> | Many<T>`)
- Allows cache to store both single items and lists
- Type-safe access via `single` and `many` getters

### 4.2 Repository-Level Auto-Caching

**Automatic Caching in BaseRepository**:

**Read Operations**:

- `getAll()`: Caches with key `repo:{tableName}:all`
- `getById(id)`: Caches with key `repo:{tableName}:{id}`
- `queryThisTable()`: Caches with key based on query parameters

**Write Operations**:

- `insert()`: Updates cache for new item and invalidates `:all` cache
- `update()`: Updates cache for item and refreshes `:all` cache
- `delete()`: Removes item cache and refreshes `:all` cache

**Cache Key Structure**:

- Format: `repo:{tableName}:{suffix}`
- Suffixes: `all`, `{id}`, `query:{where}:{args}:{orderBy}:{limit}:{offset}`

**Cache Lookup Flow**:

1. Check cache existence
2. If exists, return cached value (cast to expected type)
3. If not, query database
4. Cache result before returning

### 4.3 Service-Level Cache Ownership

**Service Cache Keys**:

- Format: `service:{role}:{userId/merchantId}:{entity}:{operation}:{params}`
- Examples:
  - `service:user:1:cart:getCarts`
  - `service:merchant:5:product:getAllProductsForCurrentMerchant`
  - `service:user:1:post:getAllPosts:all:100`

**Service Caching Pattern**:

```dart
Future<List<CartVM>> getCarts() async {
  final cacheKey = '$_baseCacheKey:getCarts';
  if (_cache.exists(cacheKey)) {
    return _cache.expectMany(_cache.get(cacheKey)).cast<CartVM>().toList();
  }
  // ... fetch and transform data ...
  _cache.set(cacheKey, Many(cartVMs));
  return cartVMs;
}
```

**Service Cache Scope**:

- Services cache View Models (processed data)
- Repository cache stores Raw Models (raw data)
- Two-layer caching: raw data + processed data

### 4.4 Cache Invalidation Strategies

**Repository-Level Invalidation**:

- Write operations automatically invalidate affected caches
- `update()` refreshes both item cache and list cache
- `delete()` removes item cache and refreshes list cache

**Service-Level Invalidation**:

- Manual invalidation on write operations
- Pattern-based invalidation for cross-role effects:
  ```dart
  _cache.delByPattern('service:user:*:product:*'); // Invalidate all user product caches
  ```

**Cross-Role Invalidation**:

- Merchant operations invalidate user caches (e.g., product update invalidates user product views)
- User operations invalidate merchant caches (e.g., order creation invalidates merchant order lists)
- Pattern matching via `delByPattern()` using wildcards

**Example**:

```dart
// Merchant updates product
await _productRepository.update(product);
_cache.delByPattern('service:user:*:product:*'); // Invalidate all user product caches
_cache.del('$_baseCacheKey:getAllProductsForCurrentMerchant');
```

### 4.5 Design Risks & Safeguards

**Risks**:

1. **Memory Growth**: No TTL, cache grows indefinitely
2. **Stale Data**: Manual invalidation can be missed
3. **Type Safety**: Cache uses non-generic `Cacheable`, requires casting
4. **Cache Key Collisions**: No namespace enforcement beyond naming conventions

**Safeguards**:

1. **Scoped Keys**: Repository and service keys are prefixed to avoid collisions
2. **Architectural Guarantees**: Cache keys are repository/service-scoped, ensuring type safety by construction
3. **Explicit Invalidation**: Services must manually invalidate on writes (enforces awareness)
4. **Error Handling**: Cache access errors throw `CACHE_ERROR` (fail-safe behavior)

**Future Improvements**:

- TTL support for automatic expiration
- Cache size limits with LRU eviction
- Cache hit/miss metrics
- Persistent cache (disk-based) for app restarts

---

## 5. Service Layer

### 5.1 Service Responsibilities vs Repository Responsibilities

**Repository Responsibilities**:

- Database CRUD operations
- Raw Model ↔ Database mapping
- Query execution
- Basic filtering and sorting
- No business logic

**Service Responsibilities**:

- Business logic and validation
- Multi-repository orchestration
- Raw Model → View Model transformation
- Permission checks (user/merchant ownership)
- Cache management
- Error handling and wrapping

**Example**:

```dart
// Repository: Simple data access
Future<ProductModel?> getById(int id) async { /* ... */ }

// Service: Business logic + orchestration
Future<ProductVM?> getProductById(int id) async {
  // 1. Check permissions
  // 2. Fetch from repository
  // 3. Fetch related data (media, categories)
  // 4. Transform to View Model
  // 5. Cache result
  // 6. Return
}
```

### 5.2 Transaction Boundaries

**Current Implementation**:

- **No explicit transactions**: Each repository operation is independent
- **Implicit transactions**: SQLite wraps each `insert/update/delete` in a transaction
- **Multi-step operations**: Services perform multiple repository calls sequentially

**Example Multi-Step Operation**:

```dart
Future<PostVM?> createPost(CreatePostDTO dto) async {
  // Step 1: Insert post
  final postId = await _postRepository.insert(postModel);

  // Step 2: Insert post-product relationships
  for (final productId in dto.productIds!) {
    await _postProductsRepository.insert(relationModel);
  }

  // Step 3: Insert promo media
  for (final media in dto.promoMedias!) {
    await _promoMediaRepository.insert(mediaModel);
  }

  // If any step fails, previous steps are not rolled back
}
```

**Trade-offs**:

- **Pros**: Simple, no transaction management complexity
- **Cons**: Partial failures can leave inconsistent state
- **Mitigation**: Foreign key constraints prevent orphaned records

**Future Improvement**: Add explicit transaction support for multi-step operations

### 5.3 Read vs Write Orchestration

**Read Operations**:

- Services fetch from multiple repositories
- Services join data in application code (no SQL JOINs)
- Services compute derived fields (counts, flags)
- Services transform to View Models

**Example Read Orchestration**:

```dart
Future<List<PostVM>> getAllPosts() async {
  // 1. Fetch posts
  final posts = await _postRepository.queryThisTable();

  // 2. Fetch all likes and saves (batch)
  final postLikes = await _postLikeRepository.queryThisTable();
  final postSaves = await _postSaveRepository.queryThisTable();

  // 3. For each post, fetch related data
  final enrichedPosts = await Future.wait(
    posts.map((post) async {
      final merchant = await _merchantRepository.getById(post.merchantId);
      final products = await _fetchPostProducts(post.id);
      // ... compute counts, flags ...
      return PostVM.fromRaw(post, ...);
    }),
  );

  return enrichedPosts;
}
```

**Write Operations**:

- Services validate input (DTOs)
- Services check permissions
- Services perform sequential repository calls
- Services invalidate caches

### 5.4 Error Wrapping & Domain Error Handling

**Error Wrapping Pattern**:

```dart
try {
  // Repository or business logic
} catch (e) {
  if (e is AppError) {
    rethrow; // Preserve domain errors
  }
  throw AppError(
    type: ErrorType.DB_ERROR, // Wrap unknown errors
    message: 'Failed to get products: ${e.toString()}',
  );
}
```

**Domain Error Handling**:

- Services validate business rules and throw `OPERATION_NOT_ALLOWED`
- Services check permissions and throw `UNAUTHORIZED` or `FORBIDDEN`
- Services check existence and throw `NOT_FOUND`
- Services check duplicates and throw `ALREADY_EXISTS`

**Example**:

```dart
Future<void> deleteCart(int id) async {
  final cart = await _cartRepository.getById(id);
  if (cart == null) {
    throw AppError(type: ErrorType.NOT_FOUND, message: 'Cart not found');
  }
  if (cart.userId != currentUserId) {
    throw AppError(type: ErrorType.UNAUTHORIZED, message: 'Unauthorized');
  }
  await _cartRepository.delete(id);
}
```

### 5.5 Session-Aware Service Behavior

**Service Initialization**:

- Services check `AppSession.instance.isLoggedIn` in constructor
- Services throw `UNAUTHORIZED` if not logged in
- Services extract `userId` or `merchantId` from session

**User Services**:

```dart
class CartService {
  late final currentUserId;
  late final String _baseCacheKey;

  CartService() {
    if (AppSession.instance.isLoggedIn) {
      currentUserId = AppSession.instance.userId;
      _baseCacheKey = 'service:user:$currentUserId:cart';
    } else {
      throw AppError(type: ErrorType.UNAUTHORIZED, message: 'Unauthorized');
    }
  }
}
```

**Merchant Services**:

```dart
class ProductService {
  late final currentMerchantId;

  ProductService() {
    if (AppSession.instance.isLoggedIn &&
        AppSession.instance.merchantId != null) {
      currentMerchantId = AppSession.instance.merchantId;
    } else {
      throw AppError(type: ErrorType.UNAUTHORIZED, message: 'Unauthorized');
    }
  }
}
```

**Filtering by Session**:

- Services automatically filter data by `userId` or `merchantId`
- Prevents unauthorized data access
- Ensures users only see their own data

---

## 6. UI Architecture

### 6.1 Screen & Widget Organization

**Directory Structure**:

```
lib/ui/
  screens/
    user/          # User-facing screens
    merchant/      # Merchant-facing screens
    auth_screen.dart
  widgets/
    user/          # User-specific widgets
    merchant/      # Merchant-specific widgets
    common/        # Shared widgets
    auth/          # Authentication widgets
```

**Screen Patterns**:

- Screens are `StatefulWidget` when they need local state
- Screens use `FutureBuilder` for async data loading
- Screens delegate UI rendering to reusable widgets

**Widget Patterns**:

- Widgets are organized by feature (posts, products, cart, etc.)
- Complex widgets are split into smaller sub-widgets
- Shared widgets live in `common/` directory

### 6.2 Navigation Strategy

**Navigation Methods**:

- **MaterialPageRoute**: Standard Flutter navigation
- **Argument Passing**: Constructor parameters (no named routes)
- **Callbacks**: Parent widgets pass callbacks to child widgets for updates

**Navigation Examples**:

```dart
// Navigate with arguments
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => PostDetailScreen(postId: post.id),
  ),
);

// Navigate with callback
PostItem(
  post: post,
  onPostUpdated: (updatedPost) {
    setState(() { /* update local state */ });
  },
);
```

**Navigation Hierarchy**:

- Root: `MyApp` → `AuthScreen` or `UserScaffold` / `MerchantScaffold`
- Scaffolds: Tab-based navigation with `BottomNavigationBar`
- Screens: Push new routes for detail views
- Bottom Sheets: Modal overlays for forms and actions

### 6.3 ViewModel Usage in UI

**ViewModel Flow**:

1. UI calls service method (returns `Future<ViewModel>`)
2. `FutureBuilder` handles async state
3. UI renders ViewModel data

**Example**:

```dart
FutureBuilder<List<PostVM>>(
  future: _postService.getAllPosts(category: selectedCategory),
  builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return CircularProgressIndicator();
    } else if (snapshot.hasError) {
      return Text('Error: ${snapshot.error}');
    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
      return Text('No posts found.');
    }
    final posts = snapshot.data!;
    return ListView.builder(
      itemBuilder: (context, index) => PostItem(post: posts[index]),
    );
  },
)
```

**ViewModel Benefits**:

- Pre-computed fields reduce UI computation
- Nested VMs simplify widget tree
- Type-safe data access

### 6.4 State Boundaries & Rebuild Strategy

**State Management**:

- **Local State**: `StatefulWidget` with `setState()` for UI-only state
- **No Global State**: No state management library (Provider, Bloc, etc.)
- **Service Instances**: Services are instantiated per widget (not singletons)

**State Boundaries**:

- Each screen/widget manages its own state
- Parent widgets pass data to children via constructors
- Children notify parents via callbacks

**Rebuild Strategy**:

- `setState()` triggers local rebuilds
- `FutureBuilder` rebuilds on future completion
- Optimistic updates: Update UI immediately, sync with backend later

**Example Optimistic Update**:

```dart
void handlePostLike() async {
  setState(() {
    isLiked = !isLiked;
    likesCount += isLiked ? 1 : -1;
  });
  try {
    if (isLiked) {
      await _postLikeService.likePost(widget.post.id);
    } else {
      await _postLikeService.unlikePost(widget.post.id);
    }
  } catch (e) {
    // Rollback on error
    setState(() {
      isLiked = !isLiked;
      likesCount += isLiked ? 1 : -1;
    });
  }
}
```

### 6.5 FutureBuilder Usage & Async UI Patterns

**FutureBuilder Pattern**:

- Used for all async data loading
- Handles three states: loading, error, success
- Empty state handling (no data)

**Common Pattern**:

```dart
FutureBuilder<T>(
  future: _service.getData(),
  builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return CircularProgressIndicator();
    } else if (snapshot.hasError) {
      return Text('Error: ${snapshot.error}');
    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
      return Text('No data found.');
    }
    return _buildContent(snapshot.data!);
  },
)
```

**Nested FutureBuilders**:

- Used when data depends on previous data
- Example: Post detail → Similar posts

**Async Patterns**:

- Services return `Future<T>` or `Future<List<T>>`
- UI always uses `FutureBuilder` for async operations
- No manual `async/await` in `build()` methods

---

## 7. UX & Interaction Patterns

### 7.1 Bottom Sheet Usage

**Bottom Sheets for Forms**:

- Create/edit forms use `showModalBottomSheet`
- `isScrollControlled: true` for full-screen forms
- `Padding` with `MediaQuery.viewInsets.bottom` for keyboard handling

**Example**:

```dart
showModalBottomSheet(
  context: context,
  isScrollControlled: true,
  builder: (context) => Padding(
    padding: EdgeInsets.only(
      bottom: MediaQuery.of(context).viewInsets.bottom,
    ),
    child: PostCreateForm(onSaved: (post) { /* ... */ }),
  ),
);
```

**Bottom Sheets for Selectors**:

- Product selectors, media pickers use bottom sheets
- `showDragHandle: true` for better UX
- `enableDrag: true` for dismissible sheets

**Bottom Sheets for Actions**:

- Action menus (edit, delete) use bottom sheets
- Confirmation dialogs for destructive actions

### 7.2 Dismissible Patterns & Safeguards

**Dismissible Widgets**:

- Not currently used (no swipe-to-delete)
- Future: Add `Dismissible` for cart items, posts, etc.

**Modal Dismissal**:

- Bottom sheets are dismissible by default
- `isDismissible: true` allows swipe-down dismissal
- Confirmation dialogs prevent accidental dismissal

**Safeguards**:

- Delete operations require confirmation dialog
- Form validation prevents invalid submissions
- Optimistic updates with rollback on error

### 7.3 Empty States vs Error States

**Empty States**:

- Shown when data is successfully loaded but empty
- Message: "No posts found.", "No products found.", etc.
- Centered text with simple message

**Error States**:

- Shown when `FutureBuilder` has error
- Message: "Error: {error message}"
- Usually just text, no retry button (user must refresh)

**Loading States**:

- `CircularProgressIndicator` during data fetch
- Centered in view

**State Priority**:

1. Loading (while fetching)
2. Error (if fetch fails)
3. Empty (if fetch succeeds but no data)
4. Content (if data exists)

### 7.4 Loading Indicators & Skeleton Decisions

**Loading Indicators**:

- `CircularProgressIndicator` for all async operations
- Centered in view during loading
- No skeleton screens (future improvement)

**Loading Patterns**:

- Full-screen loading for initial data load
- Inline loading for pagination (future)
- Button loading states (future)

**Future Improvements**:

- Skeleton screens for better perceived performance
- Shimmer effects for loading states
- Progressive loading (show partial data while fetching more)

---

## 8. Media & Platform Integrations

### 8.1 Media Picker Design

**MediaPicker Class** (`lib/core/media/media_picker.dart`):

- Wraps `image_picker` package
- Supports images and videos
- Handles both camera and gallery sources

**Media Storage**:

- Media files stored in app documents directory
- Path: `{appDocumentsDir}/media/{timestamp}.{ext}`
- Files are copied (not moved) to preserve originals

**MediaPickerSheet**:

- Bottom sheet UI for media source selection
- Options: Gallery or Camera
- Returns file path or null if cancelled

**Usage Pattern**:

```dart
final imagePath = await MediaPickerSheet.show(
  context,
  type: MediaType.image,
  folder: 'products',
);
```

### 8.2 File Handling & Storage Decisions

**File Storage Strategy**:

- **Local Files**: Stored in app documents directory
- **Database**: Only file paths stored (not binary data)
- **Assets**: Static assets in `assets/` directory

**File Path Storage**:

- Raw Models store file paths as strings
- View Models include file paths for UI display
- DTOs accept file paths for create/update

**Trade-offs**:

- **Pros**: Database stays small, files can be managed separately
- **Cons**: File paths can become invalid if files are deleted externally

### 8.3 Video Player Usage

**Video Player Integration**:

- Uses `video_player` package
- Supports asset videos (for live streams)
- `VideoPlayerController` manages playback

**Live Stream Implementation**:

```dart
_controller = VideoPlayerController.asset(livestream.streamUrl)
  ..initialize().then((_) {
    setState(() {});
    _controller.play();
  });
```

**Video Player Features**:

- Play/pause on tap
- Full-screen video support (`FullscreenVideoScreen`)
- Asset-based videos (not network streams)

**Limitations**:

- Currently uses asset videos (simulated live streams)
- No network streaming support
- No live chat integration with video playback

### 8.4 Live Stream Chat Animations

**Real-Time Feel (Simulated)**:

- `LiveStreamChat` widget simulates real-time chat
- Uses `Timer.periodic` to add messages one by one
- `AnimatedList` for smooth message insertion animations

**Animation Pattern**:

```dart
Timer.periodic(Duration(milliseconds: 1000), (timer) {
  _visibleChats.insert(0, chats[_index]);
  _listKey.currentState?.insertItem(0, duration: Duration(milliseconds: 600));
  _index++;
});
```

**Visual Design**:

- Messages appear from bottom with `SizeTransition`
- Reverse list (newest at bottom)
- Semi-transparent background for readability
- Username highlighted in green

**Future Improvements**:

- Real WebSocket integration
- Message persistence
- User input for live chat

---

## 9. Theming & Visual System

### 9.1 Theme Setup

**Theme Configuration** (`MyApp`):

```dart
ThemeData(
  scaffoldBackgroundColor: Color.fromARGB(255, 250, 255, 246),
  colorScheme: ColorScheme.fromSeed(
    seedColor: Color.fromARGB(255, 99, 175, 76),
    primary: Color.fromARGB(255, 34, 99, 51),
    secondary: Color.fromARGB(255, 56, 141, 32),
  ),
  useMaterial3: true,
)
```

**Color Strategy**:

- Green-based color scheme (marketplace/nature theme)
- Material 3 design system
- Consistent colors across user and merchant experiences

### 9.2 Consistency Between User & Merchant Experiences

**Shared Components**:

- `Navbar`: Shared bottom navigation component
- `Appbar`: Shared app bar component (with role-specific titles)
- Theme: Same theme for both experiences

**Role-Specific Components**:

- `UserScaffold` vs `MerchantScaffold`: Different tab structures
- `MerchantAppBar`: Different styling (dark background)
- Role-specific widgets in `widgets/user/` and `widgets/merchant/`

**Visual Consistency**:

- Same color scheme
- Same typography
- Same spacing and padding
- Same interaction patterns (buttons, cards, etc.)

---

## Conclusion

Dak Louk implements a clean, layered architecture with clear separation of concerns. The three-model pattern (Raw Models, DTOs, View Models) provides flexibility and type safety. The custom ORM and repository pattern simplify data access while maintaining type safety. The caching system improves performance but requires careful invalidation management. The service layer orchestrates business logic and enforces permissions. The UI layer uses standard Flutter patterns with `FutureBuilder` for async operations.

**Key Strengths**:

- Clear architecture with well-defined layers
- Type-safe data access and transformations
- Comprehensive error handling
- Role-based access control
- Performance optimization via caching

**Areas for Improvement**:

- Transaction support for multi-step operations
- Dependency injection for better testability
- TTL and size limits for cache
- Skeleton screens for better UX
- Real-time features (WebSocket integration)

The architecture is designed to scale from a simple marketplace to a complex e-commerce platform while maintaining code quality and developer productivity.
