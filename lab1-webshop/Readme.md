# HI1031 - Lab 1 Webshop

A small but stylized webshop built with JSP, Java, and JDBC for the Java enterprise lab. The application uses a three-layer architecture and targets the grade-3 requirements: user identification, a shopping cart, and adding/viewing cart contents.

Guests can browse products and edit their cart. The checkout page offers login and registration, signed-in users see delivery fields and demo payment options. Checkout does not create orders or process payments.

## Technology

- Java 27
- Apache Tomcat 11 in Docker
- PostgreSQL 17 in Docker
- JSP for presentation and HTTP request handling
- JDBC with the PostgreSQL driver for database access
- Maven for dependency management and WAR packaging
- Plain CSS and JavaScript for styling and dialogs

The application does not use Spring, Hibernate, or custom servlet classes. JSP pages are compiled into servlets internally by Tomcat. Password hashing uses standard Java APIs (`java.security` and `javax.crypto`).

## Requirements

- JDK 27 available on `PATH`
- Maven available on `PATH`
- Docker Desktop running with Linux containers and Docker Compose
- Internet access for the first dependency download and Docker image build

The commands below use PowerShell. Run them from the project directory containing `pom.xml` and `compose.yaml`.

```powershell
java -version
mvn -version
docker compose version
```

Maven must report Java 27. A separate local Tomcat or PostgreSQL installation is not required.

## First-time setup

### 1. Configure the environment

Clone the repository and open its project directory. Copy the example configuration:

```powershell
Copy-Item .env.example .env
```

Edit `.env` with a local development password:

```dotenv
POSTGRES_DB="Your Postgress Database"
POSTGRES_USER="Your Postgress Username"
POSTGRES_PASSWORD="Your Local Password"
```

Keep `.env` out of version control. PostgreSQL initialization variables apply when its data volume is first created, editing this file later does not change an existing database account's password.

### 2. Build and start

```powershell
mvn package
```

After `BUILD SUCCESS`:

```powershell
docker compose up -d --build
docker compose ps
```

Wait for the database to be healthy and Tomcat to start. Maven produces `target/deploy/lab1-webshop.war`, Docker mounts that directory into Tomcat's `webapps` directory.

### 3. Initialize the database

The SQL scripts are applied manually, container startup does not run them automatically in this configuration.

Before running `002-users.sql`, inspect any optional test-user `INSERT`. If it contains a password-hash placeholder, either remove that optional `INSERT` and register through the website, or generate a valid hash and replace the placeholder:

```powershell
java -cp target/classes se.kth.webshop.security.Passwords
```

The utility prompts for a password and prints its salt/hash string. Do not put plaintext passwords in the SQL file.

Apply the scripts:

```powershell
docker compose cp ./sql/001-products.sql db:/tmp/001-products.sql
docker compose exec db psql -U {POSTGRES_USER} -d {POSTGRES_DB} -v ON_ERROR_STOP=1 -f /tmp/001-products.sql

docker compose cp ./sql/002-users.sql db:/tmp/002-users.sql
docker compose exec db psql -U {POSTGRES_USER} -d {POSTGRES_DB} -v ON_ERROR_STOP=1 -f /tmp/002-users.sql
```

fill in `{POSTGRES_USER}` and `{POSTGRES_DB}` in these commands based on the values in `.env`.

### 4. Open the shop

[Open the webshop](http://localhost:8081/lab1-webshop/products.jsp).

To create an account, add a product, open **Review cart & checkout**, and expand **Create an account**. Usernames contain 3–50 letters, numbers, or underscores and are case-sensitive. New passwords require at least 15 characters and matching confirmation.

No pre-existing account is required to browse or use the guest cart.

## Connections

| Connection | Address |
| --- | --- |
| Browser to Tomcat | `http://localhost:8081` |
| Windows database client to PostgreSQL | Host `localhost`, port `5433` |
| Tomcat container to PostgreSQL | `jdbc:postgresql://db:5432/webshop` |

The database name in the JDBC URL follows `POSTGRES_DB`. Docker Compose supplies `DB_URL`, `DB_USER`, and `DB_PASSWORD` to the Java application. Inside the Tomcat container, `db` is the database service hostname, `localhost` would refer to Tomcat's own container.

## Development and shutdown

Rebuild after source or JSP changes:

```powershell
mvn package
```

Tomcat detects the updated WAR and redeploys it. Allow a few seconds before refreshing the browser. Redeployment may reset login and cart sessions. Saving a source file alone does not rebuild the WAR.

For a clean build, stop Tomcat first because `mvn clean` removes the mounted build output:

```powershell
docker compose stop tomcat
mvn clean package
```

After a successful build:

```powershell
docker compose up -d --force-recreate tomcat
```

Useful commands:

```powershell
docker compose logs --tail=100 tomcat
docker compose logs --tail=100 db
docker compose down
```

`docker compose down` retains the PostgreSQL data volume. Adding `-v` deletes that volume and its database contents.

## Three-layer architecture

| Layer | Main components | Responsibility |
| --- | --- | --- |
| Presentation | JSP pages/fragments, CSS, JavaScript | Render pages, receive forms, manage HTTP/session interactions, redirect after actions |
| Business/domain | `ProductService`, `CartService`, `AuthService`, domain models, `Passwords` | Coordinate operations, validate credentials and quantities, manage cart contents and totals |
| Data access | `ProductDao`, `UserDao`, `Database` | Execute SQL through JDBC and map results to Java objects |

For example adding an item follows `cart-action.jsp` -> `CartService` -> `ProductDao` -> PostgreSQL. The service obtains the product from the DAO and adds it to the session's `Cart`. The JSP then redirects the browser.

SQL belongs in DAOs not JSP pages. Services and models do not depend on servlet classes. Separate MVC controllers are not used in this implementation.

### Main Java classes

| Class | Purpose |
| --- | --- |
| `Product` | Product ID, name, description, and integer price in SEK |
| `CartItem` | Product, quantity, and subtotal |
| `Cart` | Cart entries, quantity limits, item count, and total |
| `User` | User data and stored password hash passed to authentication logic |
| `ProductService` | Provides the product list |
| `CartService` | Coordinates adding, updating, and removing cart items |
| `AuthService` | Authenticates users and validates registration |
| `ProductDao` | Retrieves all products or a product by ID |
| `UserDao` | Looks up and creates users |
| `Database` | Opens JDBC connections using environment variables |
| `Passwords` | Creates and verifies salted PBKDF2 password hashes |

Source code is in `src/se/kth/webshop/`. Web resources are in `web/`, shared JSP fragments in `web/WEB-INF/views/` and database setup scripts in `sql/`.

## Class diagram

See [the class diagram and architecture explanation](docs/class-diagram.md).

## Testing

See [the manual test record](docs/testing.md).

## Database and session behavior

The `products` table contains product IDs, unique names, descriptions and non-negative prices. The `users` table contains user IDs, unique usernames and password hashes. Exact column definitions are in the SQL scripts.

The HTTP session stores the cart, form token, and after login also the user ID and username. Password hashes are not stored in the session.

- Guests can browse, add, update and remove items.
- Adding the same product increases its quantity, each product is limited to 1–99 units. This is a validation rule not stock tracking.
- Prices are obtained on the server when products are added not accepted from form fields.
- Java prices use whole SEK (`int`) while subtotals and totals use `long`.
- Login and successful registration rotate the session ID and form token while preserving the cart.
- Logout invalidates the session and clears the session cart.
- Carts are not persisted in PostgreSQL or restored across independent sessions.

## Security measures

- Password hashing uses PBKDF2-HMAC-SHA256 with 600,000 iterations, random 16-byte salts and 256-bit derived hashes.
- JDBC queries use prepared statements for user-supplied values.
- State-changing forms use POST and a session form token.
- Redirect destinations are restricted to known local pages.
- Product text and displayed usernames are HTML-escaped.
- Invalid credentials produce a generic error, database exceptions are logged on the server.

This is a local teaching application not a production-ready commerce service. For example it has no login rate limiting or way of account recovery.

## Implemented features and limitations

Implemented features include product cards, a session cart with a side panel, quantity editing/removal, login and logout, account registration, a login modal and a styled checkout overview.

Delivery fields and payment methods are demonstrations only. Delivery entries are not saved and reset on page reload. No orders are created and no payments are processed. There is no stock tracking, transactional ordering, user administration, role system or product/category administration.

## Manual verification

Run these checks against the submitted version and record the results separately:

- Start from a fresh clone and initialize an empty database using this README.
- Browse and edit the cart without logging in.
- Add the same item twice, verify quantity and total, then remove it.
- Submit invalid quantities and an unknown product ID, confirm server-side rejection.
- Refresh after a cart action, confirm the action is not repeated.
- Test valid and invalid login credentials.
- Register an account, test duplicate usernames and mismatched passwords.
- Confirm login preserves the guest cart and logout clears it.
- Verify a private browser window has an independent session.
- Confirm signed-in checkout shows delivery/payment options without submitting an order.
- Confirm database errors produce a friendly message rather than SQL details in the page.

## Troubleshooting

| Symptom | Check |
| --- | --- |
| `release version 27 not supported` | Run `mvn -version`, Maven must use JDK 27 |
| Product list fails to load | Check the SQL initialization, database health, credentials and Tomcat logs |
| Database password fails after editing `.env` | The existing database password must also be changed, environment changes alone do not update it |
| Page not found after starting | Check for `target/deploy/lab1-webshop.war` and successful deployment in Tomcat logs |
| Old CSS remains visible | Hard-refresh the browser after rebuilding |
| An old form returns HTTP 403 | Reload the page, login rotates the form token making old forms stale |
| Port already in use | Check host ports 8081 and 5433 and adjust the Compose mappings if needed |
