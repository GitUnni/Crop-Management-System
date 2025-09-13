<%@page import="java.sql.*, java.util.*"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>

<%
    String currentUser = (String) session.getAttribute("username");
    String receiver = request.getParameter("receiver");

    if (currentUser != null && receiver != null) {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/crop?useSSL=false&allowPublicKeyRetrieval=true", "root", "windows");

            String query = "SELECT * FROM messages WHERE (sender_username = ? AND receiver_username = ?) OR (sender_username = ? AND receiver_username = ?) ORDER BY timestamp";
            PreparedStatement pst = con.prepareStatement(query);
            pst.setString(1, currentUser);
            pst.setString(2, receiver);
            pst.setString(3, receiver);
            pst.setString(4, currentUser);
            ResultSet rs = pst.executeQuery();

            while (rs.next()) {
                String sender = rs.getString("sender_username");
                String message = rs.getString("message_text");
%>
                <div><strong><%= sender %>:</strong> <%= message %></div>
<%
            }
            con.close();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
%>
