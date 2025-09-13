<%@ page import="java.sql.*" %>
<%
    // Define database connection parameters
    String dbURL = "jdbc:mysql://localhost:3306/crop?useSSL=false&allowPublicKeyRetrieval=true";
    String dbUser = "root";
    String dbPass = "windows";
    
    try {
        int requestId = Integer.parseInt(request.getParameter("requestId"));
        String status = request.getParameter("status");
        String notes = request.getParameter("notes"); // Get the failure reason notes
        
        Class.forName("com.mysql.cj.jdbc.Driver");
        Connection conn = DriverManager.getConnection(dbURL, dbUser, dbPass);
        conn.setAutoCommit(false);
        
        try {
            // Get the sale request details
            String getRequestQuery = "SELECT farmer_id, crop_name, quantity, unit FROM crop_sales_requests WHERE request_id = ?";
            PreparedStatement getRequestPst = conn.prepareStatement(getRequestQuery);
            getRequestPst.setInt(1, requestId);
            ResultSet rs = getRequestPst.executeQuery();
            
            if (rs.next() && status.equals("Completed")) {
                // Update cropInfo table - modified to handle multiple rows
                String updateCropQuery = "UPDATE cropInfo SET yield_quantity = CASE " +
                                      "WHEN yield_quantity >= ? THEN yield_quantity - ? " +
                                      "ELSE yield_quantity END " +
                                      "WHERE farmer_id = ? AND crop_name = ? AND yield_unit = ? " +
                                      "AND yield_quantity > 0 " +
                                      "ORDER BY yield_quantity DESC";
                                      
                PreparedStatement updateCropPst = conn.prepareStatement(updateCropQuery);
                updateCropPst.setDouble(1, rs.getDouble("quantity"));
                updateCropPst.setDouble(2, rs.getDouble("quantity"));
                updateCropPst.setInt(3, rs.getInt("farmer_id"));
                updateCropPst.setString(4, rs.getString("crop_name"));
                updateCropPst.setString(5, rs.getString("unit"));
                int rowsUpdated = updateCropPst.executeUpdate();
                
                if (rowsUpdated > 0) {
                    // Update transaction status
                    String updateStatusQuery = "UPDATE crop_sales_requests SET transaction_status = ? WHERE request_id = ?";
                    PreparedStatement updateStatusPst = conn.prepareStatement(updateStatusQuery);
                    updateStatusPst.setString(1, status);
                    updateStatusPst.setInt(2, requestId);
                    updateStatusPst.executeUpdate();
                    
                    conn.commit();
                    out.print("Success: Transaction completed and inventory updated");
                } else {
                    conn.rollback();
                    out.print("Error: Failed to update crop inventory");
                }
            } else {
                // Update the status and notes for failed transactions
                String updateStatusQuery;
                PreparedStatement updateStatusPst;
                
                if (status.equals("Failed") && notes != null && !notes.trim().isEmpty()) {
                    // Update both status and notes
                    updateStatusQuery = "UPDATE crop_sales_requests SET transaction_status = ?, transaction_notes = ? WHERE request_id = ?";
                    updateStatusPst = conn.prepareStatement(updateStatusQuery);
                    updateStatusPst.setString(1, status);
                    updateStatusPst.setString(2, notes);
                    updateStatusPst.setInt(3, requestId);
                } else {
                    // Just update the status
                    updateStatusQuery = "UPDATE crop_sales_requests SET transaction_status = ? WHERE request_id = ?";
                    updateStatusPst = conn.prepareStatement(updateStatusQuery);
                    updateStatusPst.setString(1, status);
                    updateStatusPst.setInt(2, requestId);
                }
                
                updateStatusPst.executeUpdate();
                conn.commit();
                out.print("Success: Transaction status updated");
            }
            
            // Close resources
            rs.close();
            getRequestPst.close();
            
        } catch (SQLException e) {
            conn.rollback();
            throw e;
        } finally {
            conn.setAutoCommit(true);
            if (conn != null) conn.close();
        }
    } catch (Exception e) {
        out.print("Error: " + e.getMessage());
        e.printStackTrace(); // Add this for debugging
    }
%>