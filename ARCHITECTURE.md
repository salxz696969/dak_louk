# Dak Louk - Architecture Guide

Dak Louk is a Flutter marketplace app with a clean, layered architecture designed for scalability and maintainability.

## 🏗️ Architecture Overview

The app follows a **Domain-Driven Design (DDD)** approach with clear separation of concerns:

```
UI Layer (Screens/Widgets)
    ↓
Services Layer (Business Logic)
    ↓
Repository Layer (Data Access)
    ↓
Database Layer (SQLite + ORM)
```

### Data Flow

1. **UI** triggers actions and displays data
2. **Services** handle business logic and orchestrate data operations
3. **Repositories** manage database queries and transformations
4. **Database** stores data with automatic schema management

## 📊 Models Architecture

The app uses **three types of models** for different purposes:

### 🔍 Raw Models (`lib/domain/models/raw/`)

**What they are**: The exact row from your database table - truthful representation of what's stored

- **Fields**: Match database columns exactly, no more, no less
- **Optional fields**: None - everything the DB requires
- **Methods**: Zero - just pure data storage
- **Like**: The source data from your database, unchanged

```dart
class ProductModel extends Cacheable {
  final int id;
  final int merchantId;
  final String name;
  final String? description; // Optional in DB
  final double price;
  final int quantity;
  final DateTime createdAt;
  final DateTime updatedAt;
  // No methods - just holds what the DB gives us
}
```

### 🎨 View Models (`lib/domain/models/view_models/`)

**What they are**: What the UI needs to render, read-only - like what a web API would send to the frontend

- **Fields**: Flattened and UI-friendly, may combine multiple sources
- **Optional fields**: Many can be null for flexibility
- **Business logic**: Getters and computed properties for display
- **Composition**: May contain other VMs or stay flat
- **Like**: The final JSON a web API sends to display in the browser

```dart
class PostVM extends Cacheable {
  final PostMerchantVM merchant;    // Nested for UI convenience
  final List<PostProductVM> products; // Easy to loop in UI
  final int likesCount;             // Pre-computed for display
  final bool isLiked;               // UI state for heart icon

  bool get isPopular => likesCount > 100; // UI logic
}
```

### 📤 DTOs (`lib/domain/models/dto/`)

**What they are**: The data your API needs for create/update operations - input contracts

- **Fields**: Only what the operation requires, nothing extra
- **Optional fields**: Based on what's required vs optional for the operation
- **Validation ready**: Perfect for form validation and API input
- **Types**: `Create<Entity>DTO`, `Update<Entity>DTO`
- **Like**: The JSON payload your API expects in POST/PUT requests

```dart
class CreateProductDTO {
  final String name;           // Required for creation
  final String? description;   // Optional for creation
  final double price;          // Required
  final int quantity;          // Required
  // Only the fields needed to create a product
}
```

### Why This Separation Makes Sense

- **Raw Models** = Your database's truth, never changes
- **View Models** = Your UI's language, optimized for display
- **DTOs** = Your API's contracts, validated input/output

This means you can change your database schema without breaking the UI, update the UI without touching the database, and modify APIs without affecting business logic.

## 🔧 Services Layer

Services contain **business logic** and orchestrate operations:

### User Services (`lib/domain/services/user/`)

- Handle user-specific operations
- Use `AppSession.instance.userId` for filtering

### Merchant Services (`lib/domain/services/merchant/`)

- Handle merchant-specific operations
- Use `AppSession.instance.merchantId` for filtering
- **Current Status**: Placeholder implementations

### Service Structure

```dart
class ProductService {
  final ProductRepository _repository;

  // Business logic methods
  Future<ProductVM> createProduct(CreateProductDTO dto) async {
    // Validation logic
    // Repository calls
    // Data transformation
    return ProductVM.fromRaw(rawProduct);
  }
}
```

## 🗄️ Database & ORM

### Tables (`lib/data/tables/`)

Each entity has a table definition class:

```dart
class ProductsTable implements DbTable<ProductsCols> {
  const ProductsTable();
  @override
  String get tableName => 'products';
  @override
  ProductsCols get cols => ProductsCols();
}

class ProductsCols extends BaseCols {
  static const String merchantIdCol = 'merchant_id';
  static const String nameCol = 'name';
  // ... more columns
}
```

### ORM System (`lib/core/utils/orm.dart`)

Custom query builder for type safety:

```dart
// Instead of raw SQL strings:
Clauses.where.eq(Tables.products.cols.merchantId, merchantId)

// Builds: WHERE merchant_id = ?
```

### Repository Pattern (`lib/data/repositories/`)

Uses a generic `BaseRepository<T>` that handles most CRUD operations automatically:

**Base Repository Methods** (ready to use):

- `getById(int id)` - Get single record
- `getAll()` - Get all records
- `insert(T model)` - Create new record
- `update(T model)` - Update existing record
- `delete(int id)` - Delete record
- `queryThisTable()` - Custom queries with filtering

**What you implement per repository**:

```dart
class ProductRepository extends BaseRepository<ProductModel> {
  // Just these two methods - BaseRepository handles the rest!
  @override
  ProductModel fromMap(Map<String, dynamic> map) {
    return ProductModel(/* convert DB map to object */);
  }

  @override
  Map<String, dynamic> toMap(ProductModel model) {
    return {/* convert object to DB map */};
  }
}
```

The BaseRepository uses generics so you can focus on just the data conversion logic.

## 🎯 Current Implementation Status

### ✅ **Completed Features**

- **Authentication Flow**: Login/Signup for users and merchants
- **User Side**: Full CRUD for products, posts, cart, orders
- **Database Schema**: Complete SQLite setup with all tables
- **UI Components**: Reusable widgets for products, posts, cart
- **Architecture**: Clean layered structure with proper separation

### 🚧 **Current Focus: Merchant Side**

- **Services**: Structure ready, placeholder implementations
- **UI Screens**: Placeholder screens created
- **Next Steps**: Implement service methods and build UI to display merchant data
- **Goal**: Complete the merchant dashboard and management features

### 🔄 **How to Add New Features**

For new features, follow the same pattern:

1. **If you need new tables**: Create new table columns, raw models, and repositories
2. **For the current merchant side**: Repositories and models are already built - just implement the service methods and create the view models that services should return
3. **UI**: Build screens that catch and render the service data nicely

The architecture is designed to grow - when you need something new, you know exactly where it goes and how it connects.

#### Adding a New Entity (when needed)

**Step 1: Create Raw Model**

```dart
// lib/domain/models/raw/review_model.dart
class ReviewModel extends Cacheable {
  final int id;
  final int userId;
  final int merchantId;
  final String text;
  final double rating;
  // ... other fields
}
```

**Step 2: Create View Model**

```dart
// lib/domain/models/view_models/review_vm.dart
class ReviewVM extends Cacheable {
  final String userName;
  final String merchantName;
  final String text;
  final double rating;
  final DateTime createdAt;

  // UI helpers
  String get formattedDate => // format logic
  IconData get starIcon => // rating display logic
}
```

**Step 3: Create DTOs**

```dart
// lib/domain/models/dto/review_dto.dart
class CreateReviewDTO {
  final int merchantId;
  final String text;
  final double rating;
}
```

**Step 4: Create Database Table**

```dart
// lib/data/tables/reviews_table.dart
class ReviewsTable implements DbTable<ReviewsCols> {
  // Table definition
}
```

**Step 5: Create Repository**

```dart
// lib/data/repositories/review_repo.dart
class ReviewRepository extends BaseRepository<ReviewModel> {
  // CRUD implementations
}
```

**Step 6: Create Service**

```dart
// lib/domain/services/review_service.dart
class ReviewService {
  // Business logic
}
```

**Step 7: Create UI**

```dart
// lib/ui/widgets/reviews/review_item.dart
class ReviewItem extends StatelessWidget {
  // UI component
}
```

#### 2. **Add Business Logic**

```dart
class ReviewService {
  Future<ReviewVM> createReview(CreateReviewDTO dto) async {
    // 1. Validate input
    // 2. Check user permissions
    // 3. Call repository
    // 4. Transform to VM
    // 5. Return result
  }

  Future<List<ReviewVM>> getMerchantReviews(int merchantId) async {
    // Business logic for filtering/sorting
  }
}
```

#### 3. **Add UI Screen**

```dart
class ReviewsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<ReviewVM>>(
      future: _reviewService.getMerchantReviews(merchantId),
      builder: (context, snapshot) {
        // Handle loading, error, success states
      },
    );
  }
}
```

## 💾 **Cache System**

The app uses a Redis-style in-memory cache for performance:

### How It Works

- **Cacheable Objects**: All models extend `Cacheable` for cache support
- **Automatic Caching**: Database results and service view models get cached automatically
- **Key-Value Storage**: Simple key-value pairs like Redis
- **TTL Support**: Cache entries can expire (not fully implemented in services yet)

### Cache Layers

1. **Database Cache**: Raw query results from repositories
2. **Service Cache**: Processed view models from services (planned)
3. **UI Cache**: Widget-level caching for expensive operations

### Usage Example

```dart
// Automatic caching happens behind the scenes
final products = await _productRepository.queryThisTable();
// Results are cached for future calls

// Service layer can cache view models too
final productVMs = await _productService.getAllProducts();
// This could cache the processed view models
```

The cache system prevents redundant database calls and speeds up repeated operations, just like how Redis caches web app data.

## 🚀 **Key Benefits**

1. **Scalability**: Easy to add new features without breaking existing code
2. **Testability**: Each layer can be tested independently
3. **Maintainability**: Clear separation makes bugs easier to find
4. **Type Safety**: Strong typing prevents runtime errors
5. **Performance**: Efficient database queries with proper indexing
6. **Developer Experience**: Consistent patterns across the codebase

## 📝 **Development Guidelines**

- **Always use the layered approach**: UI → Service → Repository → Database
- **Create all three model types** for new entities
- **Use DTOs** for all create/update operations
- **Filter by user/merchant ID** in services for security
- **Handle errors gracefully** with proper error types
- **Write placeholder implementations** first, then fill them in

This architecture ensures the app can grow from a simple marketplace to a complex e-commerce platform while maintaining code quality and developer productivity.
