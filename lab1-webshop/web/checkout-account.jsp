<%@ page contentType="text/html; charset=UTF-8"
         pageEncoding="UTF-8"
         trimDirectiveWhitespaces="true" %>
<%@ page import="se.kth.webshop.model.User" %>
<%@ include file="/WEB-INF/views/cart-session.jspf" %>

<jsp:useBean id="authService"
             class="se.kth.webshop.service.AuthService"
             scope="page" />

<%
    request.setCharacterEncoding("UTF-8");
    response.setHeader("Cache-Control", "no-store");

    if (!"POST".equals(request.getMethod())) {
        response.setHeader("Allow", "POST");
        response.sendError(405);
        return;
    }

    if (!cartToken.equals(request.getParameter("token"))) {
        response.sendError(403);
        return;
    }

    String error = null;

    // An already authenticated session doesn't need to sign in again.
    if (session.getAttribute("userId") == null) {
        try {
            String action = request.getParameter("action");
            User user;

            if ("register".equals(action)) {
                user = authService.register(
                    request.getParameter("username"),
                    request.getParameter("password"),
                    request.getParameter("confirmation")
                );
            } else if ("login".equals(action)) {
                user = authService.authenticate(
                    request.getParameter("username"),
                    request.getParameter("password")
                );
            } else {
                response.sendError(400);
                return;
            }

            if (user == null) {
                error = "credentials";
            } else {
                request.changeSessionId();

                session.setAttribute("userId", user.getId());
                session.setAttribute("username", user.getUsername());
                session.setAttribute(
                    "cartToken",
                    java.util.UUID.randomUUID().toString()
                );
            }
        } catch (IllegalArgumentException e) {
            error = "registration";
        } catch (IllegalStateException e) {
            application.log("Checkout authentication failed.", e);
            error = "unavailable";
        }
    }

    String location = request.getContextPath() + "/cart.jsp";

    if (error != null) {
        location += "?accountError=" + error + "#checkout-account";
    }

    response.setStatus(303);
    response.setHeader("Location", location);
    return;
%>