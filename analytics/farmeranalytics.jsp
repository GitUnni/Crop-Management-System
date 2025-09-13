<%@page import="java.sql.*" %>
<%@page import="java.io.*,java.util.*"%>

<!DOCTYPE html>
<html lang="en">
<head>
    <style>
        body {
            font-family: Arial, sans-serif;
            background-color: #f9f9f9;
            margin: 0;
            padding: 20px;
        }
        h2 {
            color: #333;
        }
        table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 20px;
        }
        th, td {
            padding: 12px;
            text-align: left;
            border-bottom: 1px solid #ddd;
        }
        th {
            background-color: #4CAF50;
            color: white;
        }
        tr:nth-child(even) {
            background-color: #f2f2f2;
        }
        tr:hover {
            background-color: #ddd;
        }
        .container {
            background-color: #fff;
            padding: 20px;
            border-radius: 8px;
            box-shadow: 0 0 10px rgba(0, 0, 0, 0.1);
            max-width: 800px;
            margin: auto;
        }
        .total-profit, .total-spent {
            background-color: #e7f5e6;
            padding: 15px;
            border: 1px solid #d4e7d3;
            border-radius: 5px;
            color: #333;
            margin-top: 20px;
        }
    </style>
</head>
<body>
    <div class="container">
        <%
            String act = request.getParameter("submit"); 
            Integer farmerId = (Integer) session.getAttribute("farmer_id");

            if (farmerId == null) {
                out.println("<h2>Farmer ID not found in session. Please log in again.</h2>");
            } else {
                if (act != null && act.equals("Crop Analytics")) {
                    try {
                        Class.forName("com.mysql.cj.jdbc.Driver");
                        Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/crop?useSSL=false&allowPublicKeyRetrieval=true", "root", "windows");
                        
                        // Modified query to get total sales where transaction_status is 'Completed'
                        String totalSalesQuery = "SELECT SUM(COALESCE(sold_price, 0)) AS total_sales " +
                                               "FROM crop_sales_requests " +
                                               "WHERE farmer_id=? AND transaction_status='Completed'";
                        PreparedStatement pstTotalSales = con.prepareStatement(totalSalesQuery);
                        pstTotalSales.setInt(1, farmerId);
                        ResultSet rsTotalSales = pstTotalSales.executeQuery();
                        
                        // Modified query to get crop details using crop_name instead of crop_id
                        String cropDetailsQuery = 
                            "SELECT csr.crop_name, " +
                            "COALESCE(csr.sold_price, csr.negotiable_price) as price, " +
                            "ci.quality, " +
                            "DATE_FORMAT(ci.planting_date, '%d-%b-%Y') AS formatted_planting_date, " +
                            "csr.transaction_status, " +
                            "(SELECT quality FROM cropInfo " +
                            " WHERE farmer_id = csr.farmer_id AND crop_name = csr.crop_name " +
                            " ORDER BY planting_date DESC LIMIT 1) as latest_quality, " +
                            "(SELECT DATE_FORMAT(planting_date, '%d-%b-%Y') " +
                            " FROM cropInfo " +
                            " WHERE farmer_id = csr.farmer_id AND crop_name = csr.crop_name " +
                            " ORDER BY planting_date DESC LIMIT 1) as latest_planting_date " +
                            "FROM crop_sales_requests csr " +
                            "LEFT JOIN cropInfo ci ON ci.farmer_id = csr.farmer_id " +
                            "AND ci.crop_name = csr.crop_name " +
                            "WHERE csr.farmer_id = ? " +
                            "ORDER BY csr.request_date DESC";
                        
                        PreparedStatement pstCropDetails = con.prepareStatement(cropDetailsQuery);
                        pstCropDetails.setInt(1, farmerId);
                        ResultSet rsCropDetails = pstCropDetails.executeQuery();
                        
                        // Display total sales
                        if (rsTotalSales.next()) {
                            double totalSales = rsTotalSales.getDouble("total_sales");
                            out.println("<h3><a href='farmeranalytics.html' style='color: green; text-decoration: underline; cursor: pointer;'>Click here to view other options</a></h3>");
                            out.println("<div class='total-profit'><h2>Total Sales made by the farmer: Rs " + totalSales + "</h2></div>");
                        }
                        
                        // Display individual crop details
                        out.println("<h2>Sales earned through each individual crop:</h2>");
                        out.println("<table>");
                        out.println("<tr><th>Crop Name</th><th>Price</th><th>Quality</th><th>Planted On</th><th>Status</th></tr>");
                        
                        boolean hasData = false;
                        while (rsCropDetails.next()) {
                            hasData = true;
                            String cropName = rsCropDetails.getString("crop_name");
                            double price = rsCropDetails.getDouble("price");
                            String quality = rsCropDetails.getString("latest_quality");
                            String plantingDate = rsCropDetails.getString("latest_planting_date");
                            String transactionStatus = rsCropDetails.getString("transaction_status");
                            
                            out.println("<tr>");
                            out.println("<td>" + (cropName != null ? cropName : "-") + "</td>");
                            out.println("<td>Rs " + price + "</td>");
                            out.println("<td>" + (quality != null ? quality : "-") + "</td>");
                            out.println("<td>" + (plantingDate != null ? plantingDate : "-") + "</td>");
                            out.println("<td>" + (transactionStatus != null ? transactionStatus : "Pending") + "</td>");
                            out.println("</tr>");
                        }
                        
                        if (!hasData) {
                            out.println("<tr><td colspan='5' style='text-align: center;'>No sales records found</td></tr>");
                        }
                        
                        out.println("</table>");
                        
                        con.close();
                    } catch (Exception e) {
                        out.println("Error: " + e.getMessage());
                    }
                }
                
                else if (act != null && act.equals("Order Analytics")) {
                    try {
                        Class.forName("com.mysql.cj.jdbc.Driver");
                        Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/crop?useSSL=false&allowPublicKeyRetrieval=true", "root", "windows");
                        
                        // Query to get total money spent by the farmer
                        String totalSpentQuery = "SELECT SUM(total_price) AS total_spent FROM orders WHERE farmer_id=?";
                        PreparedStatement pstTotalSpent = con.prepareStatement(totalSpentQuery);
                        pstTotalSpent.setInt(1, farmerId);
                        ResultSet rsTotalSpent = pstTotalSpent.executeQuery();
                        
                        // Query to get money spent on each product with product_name, brand_name, and order_date
                        String orderDetailsQuery = "SELECT inventory.product_name, inventory.brand_name, orders.total_price, DATE_FORMAT(orders.order_date, '%d-%b-%Y') AS formatted_order_date FROM orders JOIN inventory ON orders.product_id = inventory.inventory_id WHERE orders.farmer_id=?";
                        PreparedStatement pstOrderDetails = con.prepareStatement(orderDetailsQuery);
                        pstOrderDetails.setInt(1, farmerId);
                        ResultSet rsOrderDetails = pstOrderDetails.executeQuery();
                        
                        // Display total money spent
                        if (rsTotalSpent.next()) {
                            double totalSpent = rsTotalSpent.getDouble("total_spent");
                            out.println("<h3><a href='farmeranalytics.html' style='color: green; text-decoration: underline; cursor: pointer;'>Click here to view other options</a></h3>");
                            out.println("<div class='total-spent'><h2>Total Money Spent by the Farmer: Rs " + totalSpent + "</h2></div>");
                        }
                        
                        // Display money spent on each product
                        out.println("<h2>Money Spent on Each Product:</h2>");
                        out.println("<table>");
                        out.println("<tr><th>Brand Name</th><th>Product Name</th><th>Total Price</th><th>Order Date</th></tr>");
                        
                        while (rsOrderDetails.next()) {
                            String brandName = rsOrderDetails.getString("brand_name");
                            String productName = rsOrderDetails.getString("product_name");
                            double totalPrice = rsOrderDetails.getDouble("total_price");
                            String orderDate = rsOrderDetails.getString("formatted_order_date");
                            out.println("<tr><td>" + brandName + "</td><td>" + productName + "</td><td>Rs " + totalPrice + "</td><td>" + orderDate + "</td></tr>");
                        }
                        out.println("</table>");
                        
                        con.close();
                    } catch (Exception e) {
                        out.println("Error: " + e.getMessage());
                    }
                }

                else if (act != null && act.equals("Inspection Analytics")) 
                {
                    try 
                    {
                        Class.forName("com.mysql.cj.jdbc.Driver");
                        Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/crop?useSSL=false&allowPublicKeyRetrieval=true", "root", "windows");
                                
                        // Query to get total number of visits by agronomists to the farmer
                        String totalVisitsQuery = "SELECT COUNT(*) AS total_visits FROM AgronomistVisit WHERE farmer_id=?";
                        PreparedStatement pstTotalVisits = con.prepareStatement(totalVisitsQuery);
                        pstTotalVisits.setInt(1, farmerId);
                        ResultSet rsTotalVisits = pstTotalVisits.executeQuery();
                                
                        // Query to get count of visits with formatted visit_date
                        String visitDetailsQuery = "SELECT COUNT(*) AS visit_count, DATE_FORMAT(visit_date, '%d-%b-%Y') AS formatted_visit_date FROM AgronomistVisit WHERE farmer_id=? GROUP BY visit_date";
                        PreparedStatement pstVisitDetails = con.prepareStatement(visitDetailsQuery);
                        pstVisitDetails.setInt(1, farmerId);
                        ResultSet rsVisitDetails = pstVisitDetails.executeQuery();
                                
                        // Display total number of visits
                        if (rsTotalVisits.next()) 
                        {
                            int totalVisits = rsTotalVisits.getInt("total_visits");
                            out.println("<h3><a href='farmeranalytics.html' style='color: green; text-decoration: underline; cursor: pointer;'>Click here to view other options</a></h3>");
                            out.println("<h2>Total Number of Visits by Agronomists: " + totalVisits + "</h2>");
                        }
                                
                        // Display count of visits with formatted visit_date
                        out.println("<h2>Count of Visits with Visit Dates:</h2>");
                        out.println("<table>");
                        out.println("<tr><th>Visit Count</th><th>Visit Date</th></tr>");
                                
                        while (rsVisitDetails.next()) 
                        {
                            int visitCount = rsVisitDetails.getInt("visit_count");
                            String formattedVisitDate = rsVisitDetails.getString("formatted_visit_date");
                            out.println("<tr><td>" + visitCount + "</td><td>" + formattedVisitDate + "</td></tr>");
                        }
                        out.println("</table>");
                                
                        con.close();     
                    } 
                    catch (Exception e)
                    {
                        out.println("Error: " + e.getMessage());
                    }
                }
            }
        %>
    </div>
</body>
</html>