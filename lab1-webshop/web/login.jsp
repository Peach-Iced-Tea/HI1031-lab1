<%@ page contentType="text/html; charset=UTF-8"
         pageEncoding="UTF-8"
         trimDirectiveWhitespaces="true" %>
<%@ page import="se.kth.webshop.dto.UserDTO" %>
<%@ include file="/WEB-INF/views/cart-session.jspf" %>

<jsp:useBean id="authService"
             class="se.kth.webshop.service.AuthService"
             scope="page" />

<%
    request.setCharacterEncoding("UTF-8");
    response.setHeader("Cache-Control", "no-store");

    String next = "checkout".equals(request.getParameter("next"))
            ? "checkout" : "products";

    String loginError = null;
    String errorCode = null;

    if ("POST".equals(request.getMethod())) {
        if (!cartToken.equals(request.getParameter("token"))) {
            response.sendError(403);
            return;
        }

        try {
            UserDTO user = authService.authenticate(
                request.getParameter("username"),
                request.getParameter("password")
            );

            if (user == null) {
                loginError = "Incorrect username or password.";
                errorCode = "invalid";
            } else {
                request.changeSessionId();

                session.setAttribute("userId", user.getId());
                session.setAttribute("username", user.getUsername());

                session.setAttribute(
                    "cartToken",
                    java.util.UUID.randomUUID().toString()
                );

                response.setStatus(303);
                response.setHeader(
                    "Location",
                    request.getContextPath() + "/" + next + ".jsp"
                );
                return;
            }
        } catch (IllegalStateException e) {
            application.log("Login failed.", e);
            loginError = "Login is temporarily unavailable. Please try again.";
            errorCode = "unavailable";
        }

        if ("modal".equals(request.getParameter("presentation"))) {
            response.setStatus(303);
            response.setHeader(
                "Location",
                request.getContextPath()
                    + "/products.jsp?login=open&loginError="
                    + errorCode + "&next=" + next
            );
            return;
        }
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Log in — Webshop</title>
    <link rel="stylesheet" href="css/shop.css">
</head>
<body>
    <main class="login-page">
        <a href="products.jsp" class="login-back">← Continue shopping</a>

        <section class="login-page-card" aria-labelledby="login-title">
            <p class="eyebrow">YOUR ACCOUNT</p>
            <h1 id="login-title">Welcome back.</h1>

            <p class="login-description">
                <% if ("checkout".equals(next)) { %>
                    Please log in to continue to the checkout overview.
                <% } else { %>
                    Log in to your account. Your cart stays with you.
                <% } %>
            </p>

            <% if (loginError != null) { %>
                <p class="notice notice-error" role="alert">
                    <%= loginError %>
                </p>
            <% } %>

            <form action="login.jsp" method="post" class="login-form">
                <input type="hidden" name="token" value="<%= cartToken %>">
                <input type="hidden" name="next" value="<%= next %>">

                <label>
                    Username
                    <input type="text" name="username"
                           autocomplete="username"
                           maxlength="50" required autofocus>
                </label>

                <label>
                    Password
                    <input type="password" name="password"
                           autocomplete="current-password"
                           maxlength="256" required>
                </label>

                <button type="submit" class="button button-primary">
                    Log in
                </button>
            </form>
        </section>
    </main>
</body>
</html>