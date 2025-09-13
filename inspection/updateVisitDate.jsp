<%@page import="java.sql.*, java.util.*"%>
<%@page contentType="text/plain" pageEncoding="UTF-8"%>
<%
    int id = Integer.parseInt(request.getParameter("id"));
    String visitDate = request.getParameter("visitDate");

    if (visitDate != null && !visitDate.trim().isEmpty()) {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/crop?useSSL=false&allowPublicKeyRetrieval=true", "root", "windows");
            String query = "UPDATE AgronomistVisit SET visit_date = ? WHERE id = ?";
            PreparedStatement ps = con.prepareStatement(query);
            ps.setString(1, visitDate);
            ps.setInt(2, id);
            ps.executeUpdate();
            con.close();
            out.print("Booking confirmed!");
        } catch (Exception e) {
            e.printStackTrace();
            out.print("Error occurred while confirming booking. Please try again.");
        }
    } 
    else 
    {
        out.print("Visit date cannot be empty.");
    }
%>
