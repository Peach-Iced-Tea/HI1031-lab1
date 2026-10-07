<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.List,se.kth.webshop.dto.CartItemDTO" %>
<%@ include file="/WEB-INF/views/cart-session.jspf" %>

<%!
    private String escapeHtml(String value) {
        if (value == null) {
            return "";
        }

        return value.replace("&", "&amp;")
                    .replace("<", "&lt;")
                    .replace(">", "&gt;")
                    .replace("\"", "&quot;")
                    .replace("'", "&#39;");
    }
%>

<%
    response.setHeader("Cache-Control", "no-store");

    boolean signedIn = session.getAttribute("userId") != null;
    List<CartItemDTO> checkoutItems = cartView.getItems();

    long checkoutTotal = cartView.getTotal();
    int checkoutCount = cartView.getItemCount();

    String accountErrorCode = request.getParameter("accountError");
    String accountErrorMessage = null;

    if ("credentials".equals(accountErrorCode)) {
        accountErrorMessage = "Incorrect username or password.";
    } else if ("registration".equals(accountErrorCode)) {
        accountErrorMessage =
            "Could not create the account. The username may be taken. "
            + "Check the username rules and make sure both passwords match.";
    } else if ("unavailable".equals(accountErrorCode)) {
        accountErrorMessage =
            "Account services are temporarily unavailable. Please try again.";
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Checkout — Webshop</title>

    <link rel="stylesheet" href="css/shop.css">
    <link rel="stylesheet" href="css/checkout.css">
</head>
<body>
    <header class="site-header">
        <div class="site-header-inner">
            <a href="products.jsp" class="site-brand">
                <span class="brand-mark" aria-hidden="true">W</span>
                Webshop
            </a>

            <nav class="header-actions" aria-label="Checkout navigation">
                <a href="products.jsp" class="button button-secondary">
                    Continue shopping
                </a>

                <% if (signedIn) { %>
                    <form action="logout.jsp" method="post"
                          class="inline-form">
                        <input type="hidden" name="token"
                               value="<%= cartToken %>">
                        <button type="submit" class="button button-secondary">
                            Log out
                        </button>
                    </form>
                <% } else if (!checkoutItems.isEmpty()) { %>
                    <a href="#checkout-account"
                       class="button button-secondary">Log in</a>
                <% } %>
            </nav>
        </div>
    </header>

    <main class="page-container">
        <div class="checkout-intro">
            <p class="eyebrow">YOUR SELECTION</p>
            <h1>Checkout</h1>
            <p>Review your items and prepare your delivery.</p>
        </div>

        <% if (request.getParameter("cartError") != null) { %>
            <p class="notice notice-error" role="alert">
                Could not update the cart.
                Quantities must be between 1 and 99 per product.
            </p>
        <% } %>

        <% if (checkoutItems.isEmpty()) { %>
            <section class="empty-state">
                <h2>Your cart is empty</h2>
                <p>Find something you like and come back here.</p>
                <a href="products.jsp" class="button button-primary">
                    Browse products
                </a>
            </section>
        <% } else { %>
            <div class="checkout-layout">
                <div class="checkout-main">

                    <% if (!signedIn) { %>
                        <section class="checkout-card"
                                 id="checkout-account"
                                 aria-labelledby="account-title">

                            <p class="eyebrow">01 · YOUR ACCOUNT</p>
                            <h2 id="account-title">Let’s get you signed in.</h2>
                            <p class="checkout-muted">
                                Sign in or create an account to continue.
                                Your cart will stay with you.
                            </p>

                            <% if (accountErrorMessage != null) { %>
                                <p class="notice notice-error" role="alert">
                                    <%= escapeHtml(accountErrorMessage) %>
                                </p>
                            <% } %>

                            <form action="checkout-account.jsp" method="post"
                                  class="login-form">
                                <input type="hidden" name="token"
                                       value="<%= cartToken %>">
                                <input type="hidden" name="action"
                                       value="login">

                                <label>
                                    Username
                                    <input name="username"
                                           autocomplete="username"
                                           maxlength="50" required>
                                </label>

                                <label>
                                    Password
                                    <input type="password" name="password"
                                           autocomplete="current-password"
                                           maxlength="256" required>
                                </label>

                                <button class="button button-primary"
                                        type="submit">
                                    Sign in and continue
                                </button>
                            </form>

                            <details class="register-details"
                                <%= "registration".equals(accountErrorCode)
                                        ? "open" : "" %>>
                                <summary>New here? Create an account</summary>

                                <form action="checkout-account.jsp"
                                      method="post" class="login-form">
                                    <input type="hidden" name="token"
                                           value="<%= cartToken %>">
                                    <input type="hidden" name="action"
                                           value="register">

                                    <label>
                                        Choose a username
                                        <input name="username"
                                               autocomplete="username"
                                               pattern="[A-Za-z0-9_]{3,50}"
                                               minlength="3" maxlength="50"
                                               aria-describedby="username-help"
                                               required>
                                    </label>
                                    <small id="username-help">
                                        3–50 letters, numbers, or underscores.
                                        Usernames are case-sensitive.
                                    </small>

                                    <label>
                                        Choose a password
                                        <input type="password" name="password"
                                               autocomplete="new-password"
                                               minlength="15" maxlength="256"
                                               aria-describedby="password-help"
                                               required>
                                    </label>
                                    <small id="password-help">
                                        Use at least 15 characters.
                                        A memorable passphrase works well.
                                    </small>

                                    <label>
                                        Repeat password
                                        <input type="password"
                                               name="confirmation"
                                               autocomplete="new-password"
                                               minlength="15" maxlength="256"
                                               required>
                                    </label>

                                    <button class="button button-primary"
                                            type="submit">
                                        Create account and continue
                                    </button>
                                </form>
                            </details>
                        </section>

                        <p class="checkout-muted">
                            Delivery and payment options appear after sign-in.
                        </p>

                    <% } else { %>
                        <p class="checkout-signed-in">
                            Signed in as
                            <strong>
                                <%= escapeHtml(
                                    (String) session.getAttribute("username")
                                ) %>
                            </strong>
                        </p>

                        <section class="checkout-card"
                                 aria-labelledby="delivery-title">
                            <p class="eyebrow">01 · DELIVERY</p>
                            <h2 id="delivery-title">Where should it go?</h2>

                            <div class="delivery-fields">
                                <label class="field-wide">
                                    Full name
                                    <input type="text"
                                           autocomplete="shipping name"
                                           maxlength="100">
                                </label>

                                <label class="field-wide">
                                    Email address
                                    <input type="email"
                                           autocomplete="shipping email"
                                           maxlength="254">
                                </label>

                                <label class="field-wide">
                                    Street address
                                    <input type="text"
                                           autocomplete="shipping address-line1"
                                           maxlength="200">
                                </label>

                                <label>
                                    Postal code
                                    <input type="text"
                                           autocomplete="shipping postal-code"
                                           maxlength="20">
                                </label>

                                <label>
                                    City
                                    <input type="text"
                                           autocomplete="shipping address-level2"
                                           maxlength="100">
                                </label>

                                <label class="field-wide">
                                    Country
                                    <select autocomplete="shipping country">
                                        <option value="SE">Sweden</option>
                                        <option value="NO">Norway</option>
                                        <option value="DK">Denmark</option>
                                        <option value="FI">Finland</option>
                                    </select>
                                </label>
                            </div>
                        </section>

                        <section class="checkout-card"
                                 aria-labelledby="payment-title">
                            <p class="eyebrow">02 · PAYMENT</p>
                            <h2 id="payment-title">Choose a payment method</h2>

                            <fieldset class="payment-options">
                                <legend class="checkout-muted">
                                    Demo options — no payment will be taken.
                                </legend>

                                <label class="payment-option">
                                    <input type="radio" name="payment"
                                           value="card" checked>
                                    <span>
                                        <strong>Card</strong>
                                        <small>Debit or credit card</small>
                                    </span>
                                </label>

                                <label class="payment-option">
                                    <input type="radio" name="payment"
                                           value="swish">
                                    <span>
                                        <strong>Swish</strong>
                                        <small>Pay using your phone</small>
                                    </span>
                                </label>

                                <label class="payment-option">
                                    <input type="radio" name="payment"
                                           value="invoice">
                                    <span>
                                        <strong>Invoice</strong>
                                        <small>Pay after delivery</small>
                                    </span>
                                </label>
                            </fieldset>
                        </section>
                    <% } %>
                </div>

                <aside class="checkout-card order-summary"
                       aria-labelledby="summary-title">
                    <p class="eyebrow">YOUR CART</p>
                    <h2 id="summary-title">Order summary</h2>
                    <p class="checkout-muted">
                        <%= checkoutCount %> items
                    </p>

                    <ul class="checkout-items">
                        <% for (CartItemDTO item : checkoutItems) { %>
                            <li class="checkout-item">
                                <div class="checkout-item-heading">
                                    <h3>
                                        <%= escapeHtml(
                                            item.getName()
                                        ) %>
                                    </h3>
                                    <strong>
                                        <%= item.getSubtotal() %> SEK
                                    </strong>
                                </div>

                                <p class="checkout-muted">
                                    <%= item.getPrice() %> SEK each
                                </p>

                                <div class="checkout-item-controls">
                                    <form action="cart-action.jsp" method="post"
                                          class="checkout-update">
                                        <input type="hidden" name="token"
                                               value="<%= cartToken %>">
                                        <input type="hidden" name="action"
                                               value="update">
                                        <input type="hidden" name="returnTo"
                                               value="cart">
                                        <input type="hidden" name="productId"
                                               value="<%= item.getProductId() %>">

                                        <label>
                                            Quantity
                                            <input type="number" name="quantity"
                                                   value="<%= item.getQuantity() %>"
                                                   min="1" max="99" required>
                                        </label>

                                        <button type="submit"
                                                class="button button-secondary">
                                            Update
                                        </button>
                                    </form>

                                    <form action="cart-action.jsp" method="post">
                                        <input type="hidden" name="token"
                                               value="<%= cartToken %>">
                                        <input type="hidden" name="action"
                                               value="remove">
                                        <input type="hidden" name="returnTo"
                                               value="cart">
                                        <input type="hidden" name="productId"
                                               value="<%= item.getProductId() %>">

                                        <button type="submit"
                                                class="checkout-remove">
                                            Remove
                                        </button>
                                    </form>
                                </div>
                            </li>
                        <% } %>
                    </ul>

                    <div class="checkout-total">
                        <span>Items total</span>
                        <strong><%= checkoutTotal %> SEK</strong>
                    </div>

                    <p class="checkout-muted checkout-demo-note">
                        Demo checkout. Ordering and payment are not enabled.
                    </p>

                    <% if (signedIn) { %>
                        <button type="button"
                                class="button button-primary checkout-submit"
                                disabled>
                            Place order
                        </button>
                    <% } else { %>
                        <a href="#checkout-account"
                           class="button button-primary checkout-submit">
                            Sign in to continue
                        </a>
                    <% } %>
                </aside>
            </div>
        <% } %>
    </main>
</body>
</html>