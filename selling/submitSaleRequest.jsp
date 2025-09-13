<%@ page import="java.sql.*" %>
<%
    response.setContentType("text/plain");
    String dbURL = "jdbc:mysql://localhost:3306/crop?useSSL=false&allowPublicKeyRetrieval=true";
    String dbUser = "root";
    String dbPass = "windows";

    String cropName = request.getParameter("cropName");
    String quantityStr = request.getParameter("quantity");
    String unit = request.getParameter("unit");
    String priceStr = request.getParameter("price");
    
    if (cropName != null && quantityStr != null && unit != null && priceStr != null) {
        try {
            double quantity = Double.parseDouble(quantityStr);
            double price = Double.parseDouble(priceStr);
            Integer farmerId = (Integer) session.getAttribute("farmer_id");
            
            if (farmerId == null) {
                out.print("error: Farmer ID not found in session");
                return;
            }
            
            Class.forName("com.mysql.cj.jdbc.Driver");
            Connection conn = DriverManager.getConnection(dbURL, dbUser, dbPass);
            conn.setAutoCommit(false);
            
            try {
                // Check available quantity
                String checkQuery = "SELECT SUM(yield_quantity) as total_quantity " +
                                  "FROM cropInfo " +
                                  "WHERE farmer_id = ? AND crop_name = ? AND yield_unit = ?";
                PreparedStatement checkPst = conn.prepareStatement(checkQuery);
                checkPst.setInt(1, farmerId);
                checkPst.setString(2, cropName);
                checkPst.setString(3, unit);
                ResultSet rs = checkPst.executeQuery();
                
                if (rs.next() && rs.getDouble("total_quantity") >= quantity) {
                    // Insert sale request
                    String insertQuery = "INSERT INTO crop_sales_requests (farmer_id, crop_name, quantity, unit, negotiable_price) VALUES (?, ?, ?, ?, ?)";
                    PreparedStatement insertPst = conn.prepareStatement(insertQuery);
                    insertPst.setInt(1, farmerId);
                    insertPst.setString(2, cropName);
                    insertPst.setDouble(3, quantity);
                    insertPst.setString(4, unit);
                    insertPst.setDouble(5, price);
                    insertPst.executeUpdate();
                    conn.commit();
                    out.print("success");
                } else {
                    conn.rollback();
                    out.print("error: Insufficient quantity available");
                }
            } catch (SQLException e) {
                conn.rollback();
                throw e;
            } finally {
                conn.setAutoCommit(true);
                conn.close();
            }
        } catch (Exception e) {
            out.print("error: " + e.getMessage());
        }
    } else {
        out.print("error: All fields are required");
    }
%>