<%@ page import="java.sql.*" %>
<%
    String dbURL = "jdbc:mysql://localhost:3306/crop?useSSL=false&allowPublicKeyRetrieval=true";
    String dbUser = "root";
    String dbPass = "windows";
    
    try {
        int requestId = Integer.parseInt(request.getParameter("requestId"));
        double soldPrice = Double.parseDouble(request.getParameter("soldPrice"));
        
        Class.forName("com.mysql.cj.jdbc.Driver");
        Connection conn = DriverManager.getConnection(dbURL, dbUser, dbPass);
        
        String updateQuery = "UPDATE crop_sales_requests SET sold_price = ? WHERE request_id = ?";
        PreparedStatement pst = conn.prepareStatement(updateQuery);
        pst.setDouble(1, soldPrice);
        pst.setInt(2, requestId);
        
        int rowsUpdated = pst.executeUpdate();
        
        if (rowsUpdated > 0) {
            out.print("Success: Sold price updated");
        } else {
            out.print("Error: Failed to update sold price");
        }
        
        pst.close();
        conn.close();
        
    } catch (Exception e) {
        out.print("Error: " + e.getMessage());
        e.printStackTrace();
    }
%>
