<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<!DOCTYPE html>
<html>
<head>
    <title>My Orders</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            background-color: #f4f4f4;
            margin: 0;
            padding: 0;
        }
        h2 {
            text-align: center;
            color: #4CAF50;
            margin-top: 20px;
        }
        .order-container {
            display: flex;
            flex-wrap: wrap;
            justify-content: center;
            margin: 20px;
        }
        .order-card {
            background: white;
            border-radius: 10px;
            box-shadow: 0 4px 8px rgba(0, 0, 0, 0.2);
            margin: 20px;
            padding: 20px;
            width: 300px;
            transition: transform 0.3s;
        }
        .order-card:hover {
            transform: scale(1.05);
        }
        .order-card h3 {
            margin-top: 0;
            color: #333;
        }
        .order-card p {
            color: #777;
            margin: 10px 0;
        }
        .order-card .status {
            font-weight: bold;
            color: #4CAF50;
        }
        .no-orders {
            text-align: center;
            font-size: 18px;
            color: #777;
            margin-top: 50px;
        }
    </style>
</head>
<body>
    <h2>My Orders</h2>
    <div class="order-container">
<%
    int farmer_id = Integer.parseInt(request.getSession().getAttribute("farmer_id").toString());

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/crop?useSSL=false&allowPublicKeyRetrieval=true", "root", "windows");

        String sql = "SELECT o.order_id, o.quantity, o.total_price, o.address, o.status, " +
                     "i.brand_name, i.product_name, l.phone_number, " +
                     "DATE_FORMAT(o.order_date, '%d-%b-%Y %h:%i:%s %p') AS formatted_order_date " +
                     "FROM orders o " +
                     "JOIN inventory i ON o.product_id = i.inventory_id " +
                     "JOIN farmer f ON o.farmer_id = f.farmer_id " +
                     "JOIN login l ON f.user_id = l.user_id " +
                     "WHERE o.farmer_id = ?";
        PreparedStatement pst = con.prepareStatement(sql);
        pst.setInt(1, farmer_id);
        ResultSet rs = pst.executeQuery();

        boolean hasOrders = false;

        while (rs.next()) {
            hasOrders = true;
%>
            <div class="order-card">
                <h3>Order ID: <%= rs.getInt("order_id") %></h3>
                <p><strong>Product Name:</strong> <%= rs.getString("product_name") %></p>
                <p><strong>Brand Name:</strong> <%= rs.getString("brand_name") %></p>
                <p><strong>Quantity:</strong> <%= rs.getInt("quantity") %></p>
                <p><strong>Total Price:</strong> Rs <%= rs.getBigDecimal("total_price") %></p>
                <p><strong>Address:</strong> <%= rs.getString("address") %></p>
                <p><strong>Order Date:</strong> <%= rs.getString("formatted_order_date") %></p>
                <p class="status"><strong>Status:</strong> <%= rs.getString("status") %></p>
            </div>
<%
        }

        if (!hasOrders) {
%>
            <div class="no-orders">No orders till now!</div>
<%
        }
        con.close();
    } catch (SQLException e) {
        e.printStackTrace();
        out.println("SQL Error: " + e.getMessage());
    }
%>
    </div>
</body>
</html>
