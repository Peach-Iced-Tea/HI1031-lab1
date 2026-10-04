<%@ page contentType="text/html; charset=UTF-8"
         pageEncoding="UTF-8"
         trimDirectiveWhitespaces="true" %>
<%
    response.setHeader("Cache-Control", "no-store");

    if (!"POST".equals(request.getMethod())) {
        response.setHeader("Allow", "POST");
        response.sendError(405);
        return;
    }

    String expectedToken = (String) session.getAttribute("cartToken");

    if (expectedToken == null
            || !expectedToken.equals(request.getParameter("token"))) {
        response.sendError(403);
        return;
    }

    session.invalidate();

    response.setStatus(303);
    response.setHeader(
        "Location",
        request.getContextPath() + "/products.jsp"
    );
    return;
%>