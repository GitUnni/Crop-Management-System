<%@page import="java.sql.*, java.util.*"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>

<%
    String currentUser = (String) session.getAttribute("username");
    String receiver = request.getParameter("receiver");
    String message = request.getParameter("message");

    if (currentUser != null && receiver != null && message != null && !message.trim().isEmpty()) {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/crop?useSSL=false&allowPublicKeyRetrieval=true", "root", "windows");

            String query = "INSERT INTO messages (sender_username, receiver_username, message_text) VALUES (?, ?, ?)";
            PreparedStatement pst = con.prepareStatement(query);
            pst.setString(1, currentUser);
            pst.setString(2, receiver);
            pst.setString(3, message);
            pst.executeUpdate();

            con.close();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
%>
