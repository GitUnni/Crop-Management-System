<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%
    String inventoryId = request.getParameter("inventory_id");
    double unitPrice = 0.0;
    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/crop?useSSL=false&allowPublicKeyRetrieval=true", "root", "windows");
        String sql = "SELECT unit_price FROM inventory WHERE inventory_id = ?";
        PreparedStatement pst = con.prepareStatement(sql);
        pst.setString(1, inventoryId);
        ResultSet rs = pst.executeQuery();
        if (rs.next()) {
            unitPrice = rs.getDouble("unit_price");
        }
    } catch (SQLException e) {
        e.printStackTrace();
    }
%>
<!DOCTYPE html>
<html>
<head>
    <title>Buy Product</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            background-color: #f0f0f0;
            margin: 0;
            padding: 0;
            justify-content: center;
            align-items: center;
            height: 100vh;
        }
        h2 {
            color: #333;
            text-align: center;
        }
        form {
            background: #fff;
            padding: 20px;
            border-radius: 8px;
            box-shadow: 0 0 10px rgba(0, 0, 0, 0.1);
            max-width: 400px;
            width: 100%;
            margin: 20px auto;
            transition: transform 0.3s ease-in-out;
        }
        form:hover {
            transform: scale(1.02);
        }
        input[type="number"], input[type="text"], input[type="submit"], input[placeholder] {
            width: calc(100% - 22px);
            padding: 10px;
            margin: 10px 0;
            border: 1px solid #ccc;
            border-radius: 4px;
            transition: border-color 0.3s;
        }
        input[type="number"]:focus, input[type="text"]:focus, input[placeholder]:focus {
            border-color: #007bff;
        }
        input[type="submit"] {
            background-color: #007bff;
            color: #fff;
            border: none;
            cursor: pointer;
            transition: background-color 0.3s ease;
        }
        input[type="submit"]:hover {
            background-color: #0056b3;
        }
        p {
            font-size: 18px;
            color: #333;
            text-align: center;
        }
    </style>
    <script>
        function updatePrice() {
            var unitPrice = parseFloat(document.getElementById("unitPrice").value);
            var quantity = parseInt(document.getElementById("quantity").value);
            var totalPrice = unitPrice * quantity;
            document.getElementById("totalPrice").innerText = "Total Price: Rs " + totalPrice.toFixed(2);
            document.getElementById("totalPriceInput").value = totalPrice.toFixed(2);
        }
    </script>
</head>
<body>
    <h2>Buy Product</h2>
    <form action="ProcessOrder.jsp?action=Submit" method="post">
        <input type="hidden" id="unitPrice" value="<%= unitPrice %>">
        Quantity: <input type="number" id="quantity" name="quantity" required oninput="updatePrice()" min="1" value="1"><br>
        Address: <input type="text" name="address" required><br>
        Card Number: <input placeholder="Enter 16-digit card number" required><br>
        CVV: <input placeholder="Enter 3-digit CVV" required><br>
        <input type="hidden" name="inventory_id" value="<%= inventoryId %>">
        <input type="hidden" name="farmer_id" value="<%= session.getAttribute("farmer_id") %>">
        <input type="hidden" id="totalPriceInput" name="total_price" value="<%= unitPrice %>">
        <p id="totalPrice">Total Price: Rs <%= unitPrice %></p>
        <input type="submit">
    </form>
</body>
</html>
