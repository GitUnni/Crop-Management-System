<%@ page import="java.sql.*" %>
<%@ page import="java.io.*,java.util.*" %>

<html>
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
    </style>
</head>
<body>
    <div class="container">
        <%
            String action = request.getParameter("action"); 
            Integer supplierId = (Integer) session.getAttribute("supplier_id");

            if (supplierId == null) {
                out.println("<h2>Supplier ID not found in session. Please log in again.</h2>");
            } else {
                String fromDate = request.getParameter("from_date");
                String toDate = request.getParameter("to_date");

                if (action != null && action.equals("Osearch")) {
                    try {
                        Class.forName("com.mysql.cj.jdbc.Driver");
                        Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/crop?useSSL=false&allowPublicKeyRetrieval=true", "root", "windows");
                        
                        // Number of orders between the dates
                        String numOrdersQuery = "SELECT COUNT(*) AS num_orders FROM orders WHERE supplier_id=? AND order_date BETWEEN ? AND ?";
                        PreparedStatement pstNumOrders = con.prepareStatement(numOrdersQuery);
                        pstNumOrders.setInt(1, supplierId);
                        pstNumOrders.setString(2, fromDate);
                        pstNumOrders.setString(3, toDate);
                        ResultSet rsNumOrders = pstNumOrders.executeQuery();

                        // Number of delivered orders between the dates
                        String numDeliveredQuery = "SELECT COUNT(*) AS num_delivered FROM orders WHERE supplier_id=? AND status='Delivered' AND order_date BETWEEN ? AND ?";
                        PreparedStatement pstNumDelivered = con.prepareStatement(numDeliveredQuery);
                        pstNumDelivered.setInt(1, supplierId);
                        pstNumDelivered.setString(2, fromDate);
                        pstNumDelivered.setString(3, toDate);
                        ResultSet rsNumDelivered = pstNumDelivered.executeQuery();

                        // Profit earned from delivered orders between the dates
                        String profitQuery = "SELECT SUM(total_price) AS total_profit FROM orders WHERE supplier_id=? AND status='Delivered' AND order_date BETWEEN ? AND ?";
                        PreparedStatement pstProfit = con.prepareStatement(profitQuery);
                        pstProfit.setInt(1, supplierId);
                        pstProfit.setString(2, fromDate);
                        pstProfit.setString(3, toDate);
                        ResultSet rsProfit = pstProfit.executeQuery();

                        // Display number of orders
                        if (rsNumOrders.next()) {
                            int numOrders = rsNumOrders.getInt("num_orders");
                            out.println("<h3><a href='supplieranalytics.html' style='color: green; text-decoration: underline; cursor: pointer;'>Click here to view other options</a></h3>");
                            out.println("<h2>Number of Orders: " + numOrders + "</h2>");
                        }

                        // Display number of delivered orders
                        if (rsNumDelivered.next()) {
                            int numDelivered = rsNumDelivered.getInt("num_delivered");
                            out.println("<h2>Number of Delivered Orders: " + numDelivered + "</h2>");
                        }

                        // Display profit earned
                        if (rsProfit.next()) {
                            double totalProfit = rsProfit.getDouble("total_profit");
                            out.println("<h2>Total Profit Earned: " + totalProfit + "</h2>");
                        }

                        con.close();
                    } catch (Exception e) {
                        out.println("Error: " + e.getMessage());
                    }
                } else if (action != null && action.equals("Isearch")) {
                    try {
                        Class.forName("com.mysql.cj.jdbc.Driver");
                        Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/crop?useSSL=false&allowPublicKeyRetrieval=true", "root", "windows");
                        
                        // Query to get count of types of products
                        String productTypesQuery = "SELECT COUNT(DISTINCT product_name) AS product_types FROM inventory WHERE supplier_id=? AND manufacturing_date BETWEEN ? AND ?";
                        PreparedStatement pstProductTypes = con.prepareStatement(productTypesQuery);
                        pstProductTypes.setInt(1, supplierId);
                        pstProductTypes.setString(2, fromDate);
                        pstProductTypes.setString(3, toDate);
                        ResultSet rsProductTypes = pstProductTypes.executeQuery();

                        // Query to get brand name, product name, quantity, and unit
                        String productDetailsQuery = "SELECT brand_name, product_name, SUM(quantity) AS total_quantity, unit FROM inventory WHERE supplier_id=? AND manufacturing_date BETWEEN ? AND ? GROUP BY brand_name, product_name, unit";
                        PreparedStatement pstProductDetails = con.prepareStatement(productDetailsQuery);
                        pstProductDetails.setInt(1, supplierId);
                        pstProductDetails.setString(2, fromDate);
                        pstProductDetails.setString(3, toDate);
                        ResultSet rsProductDetails = pstProductDetails.executeQuery();

                        // Query to get expired/wasted goods with units
                        String expiredGoodsQuery = "SELECT brand_name, product_name, SUM(quantity) AS total_quantity, unit FROM inventory WHERE supplier_id=? AND expiry_date <= ? GROUP BY brand_name, product_name, unit";
                        PreparedStatement pstExpiredGoods = con.prepareStatement(expiredGoodsQuery);
                        pstExpiredGoods.setInt(1, supplierId);
                        pstExpiredGoods.setString(2, toDate);
                        ResultSet rsExpiredGoods = pstExpiredGoods.executeQuery();

                        // Display count of types of products
                        if (rsProductTypes.next()) {
                            int productTypes = rsProductTypes.getInt("product_types");
                            out.println("<h3><a href='supplieranalytics.html' style='color: green; text-decoration: underline; cursor: pointer;'>Click here to view other options</a></h3>");
                            out.println("<h2>Count of Types of Products: " + productTypes + "</h2>");
                        }

                        // Display brand name, product name, quantity, and unit in table format
                        out.println("<h2>Brand Name, Product Name, Quantity, Unit:</h2>");
                        out.println("<table>");
                        out.println("<tr><th>Brand Name</th><th>Product Name</th><th>Quantity</th><th>Unit</th></tr>");

                        while (rsProductDetails.next()) {
                            String brandName = rsProductDetails.getString("brand_name");
                            String productName = rsProductDetails.getString("product_name");
                            int quantity = rsProductDetails.getInt("total_quantity");
                            String unit = rsProductDetails.getString("unit");
                            out.println("<tr><td>" + brandName + "</td><td>" + productName + "</td><td>" + quantity + "</td><td>" + unit + "</td></tr>");
                        }
                        out.println("</table>");

                        // Display expired/wasted goods in table format
                        out.println("<h2>Expired/Wasted Goods:</h2>");
                        out.println("<table>");
                        out.println("<tr><th>Brand Name</th><th>Product Name</th><th>Quantity</th><th>Unit</th></tr>");

                        while (rsExpiredGoods.next()) {
                            String brandName = rsExpiredGoods.getString("brand_name");
                            String productName = rsExpiredGoods.getString("product_name");
                            int quantity = rsExpiredGoods.getInt("total_quantity");
                            String unit = rsExpiredGoods.getString("unit");
                            out.println("<tr><td>" + brandName + "</td><td>" + productName + "</td><td>" + quantity + "</td><td>" + unit + "</td></tr>");
                        }
                        out.println("</table>");

                        con.close();
                    } catch (Exception e) {
                        out.println("Error: " + e.getMessage());
                    }
                }
            }
        %>
    </div>
</body>
</html>
