<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.List,se.kth.webshop.dto.ProductDTO" %>
<%@ include file="/WEB-INF/views/cart-session.jspf" %>

<jsp:useBean id="productService"
             class="se.kth.webshop.service.ProductService"
             scope="page" />

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

    List<ProductDTO> products = List.of();
    boolean loadFailed = false;

    try {
        products = productService.getProducts();
    } catch (IllegalStateException e) {
        application.log("Failed to load the product list.", e);
        response.setStatus(500);
        loadFailed = true;
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Webshop — Products</title>

    <link rel="stylesheet" href="css/shop.css">
    <link rel="stylesheet" href="css/cart.css">
    <script src="js/cart.js" defer></script>
    <script src="js/login.js" defer></script>
</head>
<body>
    <%@ include file="/WEB-INF/views/header.jspf" %>

    <main class="page-container">
        <section class="catalog-intro" aria-labelledby="catalog-title">
            <p class="eyebrow">THE COLLECTION</p>
            <h1 id="catalog-title">Find your next everyday essential.</h1>
            <p class="intro-description">
                Browse our products and build your cart.
                You can log in when you’re ready to continue.
            </p>
        </section>

        <noscript>
            <p><a href="cart.jsp">View and edit your cart</a></p>
        </noscript>

        <% if (request.getParameter("cartError") != null) { %>
            <p class="notice notice-error" role="alert">
                Could not update the cart. Check the product and quantity
                (maximum 99 per product), or try again.
            </p>
        <% } else if ("added".equals(request.getParameter("notice"))) { %>
            <p class="notice notice-success" role="status">
                Product added to your cart.
                <a href="cart.jsp">View cart</a>
            </p>
        <% } %>

        <div class="section-heading">
            <h2>Our products</h2>
            <% if (!loadFailed) { %>
                <span><%= products.size() %> products</span>
            <% } %>
        </div>

        <% if (loadFailed) { %>
            <div class="empty-state">
                <h3>Products are temporarily unavailable</h3>
                <p>Please try refreshing the page in a moment.</p>
            </div>
        <% } else if (products.isEmpty()) { %>
            <div class="empty-state">
                <h3>Nothing here just yet</h3>
                <p>Our products will appear here when available.</p>
            </div>
        <% } else { %>
            <div class="product-grid">
                <% for (ProductDTO product : products) { %>
                    <article class="product-card">
                        <div class="product-card-body">
                            <h3><%= escapeHtml(product.getName()) %></h3>

                            <p class="product-description">
                                <%= escapeHtml(product.getDescription()) %>
                            </p>

                            <p class="product-price">
                                <%= product.getPrice() %>
                                <span>SEK</span>
                            </p>

                            <form action="cart-action.jsp" method="post"
                                  class="product-form">
                                <input type="hidden" name="token"
                                       value="<%= cartToken %>">
                                <input type="hidden" name="action" value="add">
                                <input type="hidden" name="returnTo"
                                       value="products">
                                <input type="hidden" name="productId"
                                       value="<%= product.getId() %>">

                                <label class="quantity-field">
                                    Quantity
                                    <input type="number" name="quantity"
                                           value="1" min="1" max="99" required>
                                </label>

                                <button type="submit"
                                        class="button button-primary">
                                    Add to cart
                                </button>
                            </form>
                        </div>
                    </article>
                <% } %>
            </div>
        <% } %>
    </main>

    <footer class="site-footer">
        <p>Webshop · Java lab project</p>
    </footer>

    <%@ include file="/WEB-INF/views/cart-panel.jspf" %>
    <%@ include file="/WEB-INF/views/login-modal.jspf" %>
</body>
</html>