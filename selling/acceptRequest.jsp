<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.sql.*" %>
<%
    response.setContentType("text/plain");
    
    try {
        int requestId = Integer.parseInt(request.getParameter("requestId"));
        String pickupTime = request.getParameter("pickupTime");
        Integer supplierId = (Integer) session.getAttribute("supplier_id");
        
        if (supplierId == null) {
            out.print("Error: Supplier session not found. Please log in again.");
            return;
        }

        Class.forName("com.mysql.cj.jdbc.Driver");
        Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/crop?useSSL=false&allowPublicKeyRetrieval=true", "root", "windows");
        
        // Use transaction to ensure atomicity
        con.setAutoCommit(false);
        
        try {
            // First check if request is still pending
            String checkQuery = "SELECT status FROM crop_sales_requests WHERE request_id = ?";
            PreparedStatement checkPst = con.prepareStatement(checkQuery);
            checkPst.setInt(1, requestId);
            ResultSet rs = checkPst.executeQuery();
            
            if (rs.next() && rs.getString("status").equals("Pending")) {
                // Update the request
                String updateQuery = "UPDATE crop_sales_requests SET supplier_id = ?, status = 'Accepted', time_of_pickup = ? WHERE request_id = ?";
                PreparedStatement updatePst = con.prepareStatement(updateQuery);
                updatePst.setInt(1, supplierId);
                updatePst.setString(2, pickupTime);
                updatePst.setInt(3, requestId);
                
                int rowsAffected = updatePst.executeUpdate();
                
                if (rowsAffected > 0) {
                    con.commit();
                    out.print("Success! You have accepted the request and set pickup time.");
                } else {
                    con.rollback();
                    out.print("Error: Failed to update request.");
                }
            } else {
                con.rollback();
                out.print("This request has already been accepted by another supplier.");
            }
        } catch (SQLException e) {
            con.rollback();
            throw e;
        } finally {
            con.setAutoCommit(true);
            con.close();
        }
    } catch (Exception e) {
        out.print("Error: " + e.getMessage());
    }
%>