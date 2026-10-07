# Webshop class diagram

This diagram describes the Java classes developed for the grade-3 webshop. Constructors, most getters, private helpers, and the password-hash command-line utility are omitted for readability.

## Java classes

```mermaid
classDiagram
    direction TB

    class Product {
        -int id
        -String name
        -String description
        -int price
    }

    class CartItem {
        -Product product
        -int quantity
        +getProduct() Product
        +getQuantity() int
        +getSubtotal() long
    }

    class Cart {
        -Map items
        +add(Product product, int quantity) void
        +updateQuantity(int productId, int quantity) void
        +remove(int productId) void
        +getItems() List~CartItem~
        +getItemCount() int
        +getTotal() long
    }

    class User {
        -int id
        -String username
        -String passwordHash
    }

    class ProductService {
        -ProductDao productDao
        +getProducts() List~ProductDTO~
    }

    class CartService {
        -ProductDao productDao
        -Cart cart
        +add(int productId, int quantity) void
        +update(int productId, int quantity) void
        +remove(int productId) void
        +getSnapshot() CartDTO
    }

    class AuthService {
        -UserDao userDao
        +authenticate(String username, String password) UserDTO
        +register(String username, String password, String confirmation) UserDTO
    }

    class ProductDao {
        +findAll() List~Product~
        +findById(int id) Product
    }

    class UserDao {
        +findByUsername(String username) User
        +create(String username, String passwordHash) User
    }

    class Database {
        +getConnection() Connection
    }

    class Passwords {
        +hash(char[] password) String
        +verify(char[] password, String stored) boolean
    }

    class ProductDTO {
        -int id
        -String name
        -String description
        -int price
    }
    class UserDTO {
        -int id
        -String username
    }
    class CartItemDTO {
        -int productId
        -String name
        -int price
        -int quantity
        -long subtotal
    }
    class CartDTO {
        -List items
        -int itemCount
        -long total
    }
    ProductService ..> ProductDTO : returns snapshots
    AuthService ..> UserDTO : returns safe identity
    CartService ..> CartDTO : returns snapshot
    CartDTO "1" *-- "0..*" CartItemDTO : contains

    Cart "1" *-- "0..*" CartItem : owns
    CartItem --> "1" Product : references

    ProductService --> "1" ProductDao : holds
    CartService --> "1" ProductDao : holds
    AuthService --> "1" UserDao : holds

    CartService "1" *-- "1" Cart : owns
    AuthService ..> Passwords : hashes and verifies
    AuthService ..> User : verifies internally

    ProductDao ..> Database : opens connection
    UserDao ..> Database : opens connection
    ProductDao ..> Product : creates from rows
    UserDao ..> User : creates from rows
```

The `items` field is a `Map<Integer, CartItem>`, abbreviated to `Map` for Mermaid compatibility. `Database.getConnection()`, `Passwords.hash()`, and `Passwords.verify()` are static methods. Public no-argument constructors on the service classes allow their use with `jsp:useBean`. DTOs have final fields, getters, and no setters.

## Relationship notation

| Notation | Meaning | Example |
| --- | --- | --- |
| `+` | Public member | `Cart.getTotal()` |
| `-` | Private field | `Product.price` |
| Solid arrow | Navigable association: an object holds a reference | `CartItem` holds a `Product` |
| Dashed arrow | Dependency: a class uses another class | `AuthService` calls `Passwords` |
| Filled diamond | Composition: a whole owns its parts | A `Cart` owns its `CartItem` entries |
| `1` | Exactly one | Each cart item references one product |
| `0..*` | Zero or more | A cart may be empty or contain multiple entries |

The same product ID appears at most once in a cart's map. Adding it again increases the existing quantity. A product can exist independently of any cart, so the relationship from `CartItem` to `Product` is an association rather than composition.

The cart stores `CartItem` objects with fixed product/quantity fields. Updating a quantity replaces the entry. Cart operations are synchronized to protect access to the same cart object from concurrent requests.

## Relationship to the three layers

JSP files are presentation resources, not Java source classes written for this application, so they are described separately rather than represented as invented controller classes.

| Layer | Components | Responsibility |
| --- | --- | --- |
| Presentation | `products.jsp`, `cart-action.jsp`, `cart.jsp`, `login.jsp`, `checkout-account.jsp`, `logout.jsp`, JSP fragments, CSS and JavaScript | HTTP input/output, page rendering, redirects, and session management |
| Business/domain | `ProductService`, `CartService`, `AuthService`, `Cart`, `CartItem`, `Product`, `User`, `Passwords` | Coordinate operations, validate business rules, authenticate users, and represent domain data |
| Data access | `ProductDao`, `UserDao`, `Database` | Execute SQL through JDBC and map database rows to Java objects |

DAOs return models to services. Services copy selected values into immutable DTOs for presentation; no JSP receives a `Product`, `User`, or `CartItem` model. DTOs are transfer contracts, not a separate fourth layer. `Passwords` is a standard-Java utility used by authentication logic. There is no `ProductServlet` or custom controller class in the current implementation.

### Presentation entry points

| Resource | Collaborators / behavior |
| --- | --- |
| `products.jsp` | Calls `ProductService` to retrieve products renders cards and shared dialogs |
| `cart-action.jsp` | Validates the HTTP method/form token, calls `CartService`, and redirects |
| `cart.jsp` | Reads a cart DTO snapshot and displays account forms or demo delivery/payment sections |
| `login.jsp` | Calls `AuthService.authenticate()` sets identification attributes after success |
| `checkout-account.jsp` | Calls `AuthService.authenticate()` or `register()` preserves the cart on success |
| `logout.jsp` | Validates the request and invalidates the session |
| `checkout.jsp` | Redirects to the checkout interface in `cart.jsp` |
| `cart-session.jspf` | Retrieves/creates the session-scoped `CartService`, gets a `CartDTO` snapshot, and manages the form token |

## Request examples for the presentation

**List products:** `products.jsp` calls `ProductService.getProducts()`. The service calls `ProductDao.findAll()`. The DAO opens a JDBC connection through `Database`, executes its query, and creates `Product` objects. The service copies each model to a `ProductDTO`; the JSP displays that snapshot list.

**Add a product:** `cart-action.jsp` reads the product ID and quantity and calls `CartService.add()`. The service uses `ProductDao.findById()` to retrieve the server-side product and price, then calls `Cart.add()`. The cart validates quantities and updates its entries. The JSP redirects the browser after the operation.

**Log in:** A JSP passes credentials to `AuthService.authenticate()`. The service retrieves a `User` through `UserDao` and verifies the password through `Passwords`. On success, the service returns a `UserDTO` containing only ID and username. The JSP changes the session ID and stores the user ID and username. The existing cart is retained the password hash is not stored in the session.

**Register:** `checkout-account.jsp` calls `AuthService.register()`. The service validates the input and hashes the password, then calls `UserDao.create()`. The DAO inserts the account and returns its generated ID with the user data. The service converts the returned model to a `UserDTO` before the JSP establishes the authenticated session.

## State and scope

- `CartService` is session-scoped and owns a private `Cart`; separate sessions have separate carts.
- `ProductService` and `AuthService` are page-scoped. `CartService` is session-scoped. All are independent of servlet APIs.
- Services hold DAO references DAOs open and close connections per operation instead of retaining a shared connection field.
- Users and products are stored in PostgreSQL. Cart items are held in the HTTP session and are not persisted in the database.
- Prices use integer SEK values. Subtotals and totals use `long`.
- Delivery and payment sections are a demo. There are no order, stock, payment-processing, or role-management classes.
