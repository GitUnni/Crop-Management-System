<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>

<%
    // Check if the form to update the status has been submitted
    String orderId = request.getParameter("order_id");
    String newStatus = request.getParameter("status");

    if (orderId != null && newStatus != null) {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/crop?useSSL=false&allowPublicKeyRetrieval=true", "root", "windows");
            String updateSql = "UPDATE orders SET status = ? WHERE order_id = ?";
            PreparedStatement pst = con.prepareStatement(updateSql);
            pst.setString(1, newStatus);
            pst.setInt(2, Integer.parseInt(orderId));
            pst.executeUpdate();
            con.close();
        } catch (SQLException e) {
            e.printStackTrace();
            out.println("SQL Error: " + e.getMessage());
        } catch (Exception e) {
            e.printStackTrace();
            out.println("Error: " + e.getMessage());
        }
    }
%>

<!DOCTYPE html>
<html>
<head>
    <title>Order Requests</title>
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
        
        select[name="status"] {
        width: 100%;
        padding: 10px;
        margin-top: 10px;
        font-size: 14px;
        border: 1px solid #ccc;
        border-radius: 5px;
        background-color: #f9f9f9;
        color: #333;
        cursor: pointer;
        transition: border-color 0.3s ease;
    }

    select[name="status"]:hover {
        border-color: #4CAF50;
    }

    /* Style for the Update Status button */
    button[type="submit"] {
        width: 100%;
        padding: 10px;
        background-color: #4CAF50;
        color: white;
        border: none;
        border-radius: 5px;
        font-size: 16px;
        cursor: pointer;
        transition: background-color 0.3s ease;
        margin-top: 10px;
    }

    button[type="submit"]:hover {
        background-color: #45a049;
    }

    button[type="submit"]:active {
        background-color: #3e8e41;
    }
    </style>
</head>
<body>
    <h2>Order Requests</h2>
    <div class="order-container">
<%
    int supplier_id = Integer.parseInt(request.getSession().getAttribute("supplier_id").toString());

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/crop?useSSL=false&allowPublicKeyRetrieval=true", "root", "windows");

        // Modify the query to format the order_date
        String sql = "SELECT o.*, l.phone_number, " +
                     "DATE_FORMAT(o.order_date, '%d-%b-%Y %h:%i:%s %p') AS formatted_order_date " +
                     "FROM orders o " +
                     "JOIN farmer f ON o.farmer_id = f.farmer_id " +
                     "JOIN login l ON f.user_id = l.user_id " +
                     "WHERE o.supplier_id = ?";
        PreparedStatement pst = con.prepareStatement(sql);
        pst.setInt(1, supplier_id);
        ResultSet rs = pst.executeQuery();

        while (rs.next()) {
%>
        <div class="order-card">
            <h3>Order ID: <%= rs.getInt("order_id") %></h3>
            <p><strong>Product ID:</strong> <%= rs.getInt("product_id") %></p>
            <p><strong>Quantity:</strong> <%= rs.getInt("quantity") %></p>
            <p><strong>Total Price:</strong> <%= rs.getDouble("total_price") %></p>
            <p><strong>Address:</strong> <%= rs.getString("address") %></p>
            <p><strong>Order Date:</strong> <%= rs.getString("formatted_order_date") %></p>
            <p><strong>Phone Number:</strong> <%= rs.getString("phone_number") %></p>
            <form action="order.jsp" method="post">
                <input type="hidden" name="order_id" value="<%= rs.getInt("order_id") %>">
                <label for="status">Status:</label>
                <select name="status">
                    <option value="Pending" <%= rs.getString("status").equals("Pending") ? "selected" : "" %>>Pending</option>
                    <option value="Dispatched" <%= rs.getString("status").equals("Dispatched") ? "selected" : "" %>>Dispatched</option>
                    <option value="In Transit" <%= rs.getString("status").equals("In Transit") ? "selected" : "" %>>In Transit</option>
                    <option value="Delivered" <%= rs.getString("status").equals("Delivered") ? "selected" : "" %>>Delivered</option>
                </select>
                <button type="submit">Update Status</button>
            </form>
        </div>
<%
        }
        con.close();
    } catch (SQLException e) {
        e.printStackTrace();
    }
%>
    </div>
</body>
</html>
