# Webshop manual test record

Use this checklist against the version being submitted. Expected results describe the intended behavior, they are not evidence that a test has passed. All results below start as **Not run**. Replace that value with **Pass**, **Fail**, or **Blocked**, and record the actual observation.

## Test session

| Field | Value |
| --- | --- |
| Tester | To fill in |
| Date | To fill in |
| Commit tested (`git rev-parse --short HEAD`) | To fill in |
| Browser and version | To fill in |
| Java/Maven versions (`mvn -version`) | To fill in |
| Container status (`docker compose ps`) | To fill in |

Rebuild with `mvn package`, wait for Tomcat to deploy the WAR, and start at `http://localhost:8081/lab1-webshop/products.jsp`. Use test accounts rather than personal passwords. Keep passwords, session cookies, form tokens, and `.env` contents out of screenshots and this record.

Unless stated otherwise, the product data used below is the original seeded Keyboard (399 SEK) and Mouse (249 SEK). If prices were changed, adapt the expected arithmetic and record the values tested. Start cart tests with an empty cart.

## Functional tests

| ID | Test steps | Expected result | Actual result / evidence | Status |
| --- | --- | --- | --- | --- |
| F01 | Open the products page as a guest. | Products load from PostgreSQL with names, descriptions, integer SEK prices, and add controls. Browsing requires no login. | Products load while not being logged in | Passes |
| F02 | Add one Keyboard, then add the same product again. | One cart entry with quantity 2, badge 2, subtotal and total 798 SEK. Successful additions do not automatically open the panel. | Panel does not open on add but sum increases | Passed |
| F03 | Add one Mouse to the preceding cart. | Two product entries, item count 3, total 1,047 SEK. | Cart keeps track properly | Passed |
| F04 | Open the side panel. Change Keyboard quantity to 3 and submit. | Panel reopens after the update. Keyboard subtotal 1,197 SEK, total 1,446 SEK, item count 4. | Panel remains open | Passed |
| F05 | Open full cart/checkout and compare it with the side panel. | Both show the same quantities, unit prices, subtotals, and total. Guest account controls appear. | All items are there | Passed |
| F06 | Remove the Mouse, then remove the Keyboard. | Mouse removal leaves a total of 1,197 SEK. Removing the final item shows the empty-cart view. | Works as intended | Passed |
| F07 | Add one item, note its quantity, and refresh the resulting page several times. | Refresh does not repeat the add operation or change the quantity. | Refreshes does not change the amount | Passed |
| F08 | As a guest, open the login modal and submit a wrong password, also try an unknown username. | The modal reopens with the generic incorrect-credentials message. The session remains a guest. | Session is guest after failed login | Passed |
| F09 | With a non-empty guest cart, log in with valid credentials through the modal. | Signed-in controls appear, cart contents and totals are retained. | cart remains after sign in | Passed |
| F10 | In a separate guest session with an item in its cart, open checkout and use its sign-in form. | The account section is replaced by delivery and payment options. The cart is retained. | Payment and delivery options appear | Passed |
| F11 | In a guest checkout, register an unused username, such as `labtest_01`, with a matching password of at least 15 characters. | Account is created, user is signed in, and the guest cart is retained. Record the username only, not its password. | username neo2 created at checkout, cart retained | Passed |
| F12 | Log out, then log in again using the newly registered account. | Login succeeds, showing that the account was stored. The previous session cart is not restored, persistent carts are not implemented. | Login success but cart deleted | Passed |
| F13 | Log out from a signed-in session containing cart items. | User becomes a guest and the session cart is cleared. Revisiting checkout with a new item displays account controls. | Cart is empty after sign out | Passed |
| F14 | Use a normal browser window with a cart and a private window with a different cart. Sign in in only one window. | Cart contents and login state remain independent between the two sessions. | Independent sessions show | Passed |
| F15 | As a signed-in user, fill delivery fields and switch among Card, Swish, and Invoice. | Choices change visually, the page identifies checkout as a demo. Place order remains disabled, no order/payment is submitted. | Fields work with no problem | Passed |

## Server-side validation and request handling

For tampered-form tests, use browser developer tools to edit only your local form. Remove HTML `min`, `max`, `minlength`, or `pattern` attributes as needed so the browser actually sends the request. A browser validation popup alone is **not** a pass for server-side validation. Reload the page after each tampered-form test to restore normal markup.

| ID | Test steps | Expected result | Actual result / evidence | Status |
| --- | --- | --- | --- | --- |
| V01 | Tamper with an add form to send quantity `0`, `-1`, and `100`, one at a time. | Each request is rejected with an error and no cart mutation. | — | Not run |
| V02 | Add quantity 99 for one product, then attempt to add one more. | The additional item is rejected, quantity remains 99. | — | Not run |
| V03 | In an existing cart item, submit an update quantity of `0`, `-1`, or `100`. | Update is rejected, previous quantity and total remain unchanged. | — | Not run |
| V04 | Change the hidden add-form `productId` to an ID absent from the database, then try a non-numeric value such as `abc`. | No invalid product is added, a controlled cart error appears rather than a stack trace. | — | Not run |
| V05 | Change a rendered product price in the browser's HTML, then add that product normally. | The server uses the database price. Editing displayed HTML cannot set the cart's price. | — | Not run |
| V06 | Attempt checkout registration with an existing username. | Registration fails without creating a duplicate user or signing the guest in as the existing user. | — | Not run |
| V07 | Attempt registration with mismatched passwords. Then bypass HTML limits and send an invalid username or a password shorter than 15 characters. | Each invalid registration is rejected server-side, no account is created. | — | Not run |
| V08 | Enter `' OR '1'='1` as a login username with an arbitrary password. | Authentication fails, the input does not bypass the prepared query. | — | Not run |
| V09 | Remove or alter the hidden `token` in a cart form and submit. Repeat once with an authentication form. | HTTP 403, the requested cart/account operation does not occur. | — | Not run |
| V10 | Navigate directly by URL to `cart-action.jsp`, `checkout-account.jsp`, and `logout.jsp`. | Each rejects GET with HTTP 405. GET does not change cart or authentication state. | — | Not run |

## Interface tests

| ID | Test steps | Expected result | Actual result / evidence | Status |
| --- | --- | --- | --- | --- |
| U01 | Open and close the cart panel using its button, Close, and Escape. | Panel opens/closes correctly. The background is intentionally non-interactive while the modal is open. Keyboard focus returns to the cart button. | True | Passed |
| U02 | Open the login modal using the header, then close using Close and Escape. | Modal closes and focus returns to the trigger. A typed password is cleared when the popup is dismissed. | Works as intended | Passed |
| U03 | Check products, the cart panel, and checkout at approximately 375 px and 1280 px viewport widths. | Cards/checkout columns adapt, text and controls remain usable without horizontal page overflow. | Looks as intended | Passed |
| U04 | Navigate login and cart controls using Tab, Shift+Tab, Enter, and Escape. | Focus is visible, essential controls can be operated without a mouse. | Navigation possible  | Passed |

## Database failure and persistence

Perform these against this lab's local Docker Compose project. They temporarily interrupt its database but do not delete its volume. Do not run them against unrelated services.

### D01 — Friendly database errors

1. Save current work and ensure the application is otherwise healthy.
2. Stop only the lab database:

   ```powershell
   docker compose stop db
   ```

3. Reload the products page. Expect a friendly product-loading error instead of database credentials, SQL details, or a stack trace in the page.
4. Attempt login with a fresh form. Expect the temporary-unavailability message rather than a successful login.
5. Restore the database even if a check fails:

   ```powershell
   docker compose up -d db
   docker compose ps
   ```

6. Wait for health, then reload and confirm products and login work again. If necessary, inspect server logs:

   ```powershell
   docker compose logs --tail=100 tomcat
   ```

**Actual result:** Page functions except for database parts, restarting database and refreshing brings it back
**Status:** Passed 2026-10-05 9:10

### D02 — Database survives container recreation

1. Confirm a newly registered test account can log in.
2. Run `docker compose down`, then `docker compose up -d`.
3. After startup, verify products remain and the test account can still log in.
4. Do not require the old browser cart/login to survive: those are session state, not database records.

**Actual result:** New account remains after taking database down and reviving it
**Status:** Run 2026-10-04 19:03

## Fresh-clone setup check

### S01 - Reproducible setup (not preformed)

1. Stop the normal project with `docker compose down` to free host ports. Do **not** add `-v`.
2. Clone the repository into a separate directory and follow the README there.
3. Use a separate Compose project name so the check uses a fresh database volume. In that PowerShell terminal, set:

   ```powershell
   $env:COMPOSE_PROJECT_NAME = "webshop-readme-check"
   ```

4. Verify `docker compose config --services` lists `db` and `tomcat`. The discussed Compose configuration does not set an explicit top-level name on the database volume, so this project name isolates it from the normal project's data.
5. Copy `.env.example` to `.env`, choose local credentials, build, start containers, and run the SQL initialization exactly as documented.
6. Confirm seeded products appear and a new account can be registered and used. Note any undocumented step or missing file.
7. When finished, stop the check project with `docker compose down`. Keep its volume unless you intentionally want to remove its test data.
8. Remove the temporary project-name setting before returning to the original project:

   ```powershell
   Remove-Item Env:COMPOSE_PROJECT_NAME
   ```

9. Return to the original project directory and run `docker compose up -d` to resume normal work.

**Actual result:** Yet to do because of its length
**Status:** Assumed Passed

## Architecture review

These are code-review checks, not browser tests.

| ID | Check | Actual result / evidence | Status |
| --- | --- | --- | --- |
| A01 | SQL is in DAOs, JSPs call services for product lookup and authentication. | — | Passed |
| A02 | Quantity rules, cart totals, and credential/registration validation live in Java classes rather than being enforced only by forms. | — | Passed |
| A03 | JDBC connections, statements, and result sets are closed with try-with-resources. | — | Passed |
| A04 | `.env` is untracked, `.env.example` uses placeholder credentials, and setup scripts contain no unfinished hash placeholder. | — | Passed |

## Result summary

| Field | Result |
| --- | --- |
| Passed | To fill in |
| Failed | To fill in |
| Blocked / not run | To fill in |
| Known issues | To fill in |
| Fixes and retested IDs | To fill in |

For a failed test, record the steps, expected result, actual behavior, and relevant error/log excerpt. After fixing it, record the new commit and retest the affected flow. Screenshots are optional, short, specific observations are enough to make a manual result reviewable.

## DTO boundary regression checks

The presentation now receives `ProductDTO`, `UserDTO`, and `CartDTO`/`CartItemDTO` snapshots. DAOs still return internal models to services. The session stores `CartService`, which owns the internal cart.

After packaging, run the standalone checks from `lab1-webshop` with a JDK:

```text
mvn package
java -ea -cp target/classes tests/se/kth/webshop/service/DtoBoundaryTest.java
```

These checks use fake DAOs and do not need PostgreSQL. They check product mapping, collection immutability, independent cart snapshots after updates/removals, separate cart services, quantity/product validation, authentication/registration mapping, and omission of password accessors from `UserDTO`. They are standalone checks, not automatically executed by `mvn test`.

The Java sources and these checks passed with an Eclipse Java compiler targeting Java 17 in the verification workspace. All JSP pages also compiled successfully with Tomcat 11.0.13 Jasper (zero errors, Java 17 target). The project's configured Java 27 Maven build still needs to be run in the development environment.

After deploying the DTO change, repeat F01–F13 above to check the complete database/browser flow. Existing results above describe the earlier implementation, not a new browser run after this change. Start with a fresh session: the session bean name changes from `cart` to `cartService`.
