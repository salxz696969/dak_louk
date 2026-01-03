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

**Purpose**: Pure database representation

- **Fields**: Exactly match database table columns
- **No logic**: Only data, no methods or getters
- **Optional fields**: None - all fields required
- **Example**: `UserModel`, `ProductModel`, `OrderModel`

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

  // No methods, just data
}
```

### 🎨 View Models (`lib/domain/models/view_models/`)

**Purpose**: UI-ready data with presentation logic

- **Fields**: Flattened and UI-optimized
- **Business logic**: Getters, computed properties
- **Optional fields**: Many fields can be null for flexibility
- **Composition**: May contain other VMs or be flat
- **Example**: `PostVM`, `CartVM`, `OrderVM`

```dart
class PostVM extends Cacheable {
  final PostMerchantVM merchant;    // Nested VM
  final List<PostProductVM> products; // List of VMs
  final int likesCount;             // Computed field
  final bool isLiked;               // UI state

  // Business logic methods
  bool get isPopular => likesCount > 100;
}
```

### 📤 DTOs (`lib/domain/models/dto/`)

**Purpose**: Data Transfer Objects for operations

- **Fields**: Only what APIs need
- **No logic**: Pure data containers
- **Validation**: Input validation ready
- **Types**: `Create<Entity>DTO`, `Update<Entity>DTO`
- **Example**: `CreateProductDTO`, `UpdateOrderDTO`

```dart
class CreateProductDTO {
  final String name;
  final String? description; // Optional for creation
  final double price;
  final int quantity;

  // No methods, just data
}
```

### Why Three Types?

1. **Raw Models** = Database truth
2. **View Models** = UI presentation layer
3. **DTOs** = API contracts

This separation allows:

- **Database changes** without affecting UI
- **UI changes** without affecting database
- **API changes** without affecting business logic
- **Easy testing** of each layer independently

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

Each entity has a repository with CRUD operations:

```dart
class ProductRepository extends BaseRepository<ProductModel> {
  @override
  ProductModel fromMap(Map<String, dynamic> map) {
    return ProductModel(/* map to object */);
  }

  @override
  Map<String, dynamic> toMap(ProductModel model) {
    return {/* object to map */};
  }
}
```

## 🎯 Current Implementation Status

### ✅ **Completed Features**

- **Authentication Flow**: Login/Signup for users and merchants
- **User Side**: Full CRUD for products, posts, cart, orders
- **Database Schema**: Complete SQLite setup with all tables
- **UI Components**: Reusable widgets for products, posts, cart

### 🚧 **Merchant Side** (Placeholders)

- **Services**: Basic structure with placeholder implementations
- **UI Screens**: Empty placeholder screens
- **Integration**: Ready for implementation

### 🔄 **How to Add New Features**

#### 1. **Add a New Entity** (e.g., Reviews)

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
