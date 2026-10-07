<%@ page contentType="text/html; charset=UTF-8"
         pageEncoding="UTF-8"
         trimDirectiveWhitespaces="true" %>
<%@ include file="/WEB-INF/views/cart-session.jspf" %>

<%
    if (!"POST".equals(request.getMethod())) {
        response.setHeader("Allow", "POST");
        response.sendError(405);
        return;
    }

    if (!cartToken.equals(request.getParameter("token"))) {
        response.sendError(403);
        return;
    }

    // Only allow these two local destinations.
    String destination = "products".equals(request.getParameter("returnTo"))
            ? "products.jsp"
            : "cart.jsp";

    String error = null;

    try {
        int productId = Integer.parseInt(request.getParameter("productId"));
        String action = request.getParameter("action");

        if ("add".equals(action)) {
            int quantity = Integer.parseInt(request.getParameter("quantity"));
            cartService.add(productId, quantity);
        } else if ("update".equals(action)) {
            int quantity = Integer.parseInt(request.getParameter("quantity"));
            cartService.update(productId, quantity);
        } else if ("remove".equals(action)) {
            cartService.remove(productId);
        } else {
            throw new IllegalArgumentException("Unknown cart action.");
        }
    } catch (IllegalArgumentException e) {
        error = "invalid";
    } catch (IllegalStateException e) {
        application.log("Cart operation failed.", e);
        error = "unavailable";
    }

    String location = request.getContextPath() + "/" + destination;

    if ("products.jsp".equals(destination)) {
        boolean addedSuccessfully =
                "add".equals(request.getParameter("action")) && error == null;

        if (addedSuccessfully) {
            location += "?notice=added";
        } else {
            // Updates, removals, and errors keep the panel open.
            location += "?cart=open";

            if (error != null) {
                location += "&cartError=" + error;
            }
        }
    } else if (error != null) {
        location += "?cartError=" + error;
    }
    response.setStatus(303);
    response.setHeader("Location", location);
    return;
%>