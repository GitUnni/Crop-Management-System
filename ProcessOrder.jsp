<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<!DOCTYPE html>
<html>
<head>
    <title>Order Processing</title>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/animejs/3.2.1/anime.min.js"></script>
    <style>
        body { 
            display: flex; 
            flex-direction: column;
            justify-content: center; 
            align-items: center; 
            height: 100vh; 
            margin: 0; 
            overflow: hidden; 
            background: green; 
        }
        #box { 
            width: 100px; 
            height: 100px; 
            background: linear-gradient(
                45deg, 
                #ff0000, #00ff00, #0000ff, 
                #ffff00, #ffa500, #800080,
                #ff0000, #00ff00, #0000ff
            );
            background-size: 400% 400%;
            animation: gradientBG 10s ease infinite;
            box-shadow: 
                0 0 20px rgba(255,255,255,0.8),
                0 0 30px rgba(255,0,0,0.6),
                0 0 40px rgba(0,255,0,0.6),
                0 0 50px rgba(0,0,255,0.6);
        }
        @keyframes gradientBG {
            0% { background-position: 0% 50%; }
            50% { background-position: 100% 50%; }
            100% { background-position: 0% 50%; }
        }
        #message {
            display: none;
            color: white;
            font-size: 24px;
            margin-top: 20px;
            text-align: center;
        }
    </style>
</head>
<body>
    <div id="box"></div>
    <div id="message">
        <%
        String inventoryId = request.getParameter("inventory_id");
        String quantity = request.getParameter("quantity");
        String address = request.getParameter("address");
        String farmerId = request.getParameter("farmer_id");
        String totalPrice = request.getParameter("total_price");
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/crop?useSSL=false&allowPublicKeyRetrieval=true", "root", "windows");
            con.setAutoCommit(false);
            // Getting the supplier_id using the correct SQL query
            String supplierSql = "SELECT supplier_id FROM inventory WHERE inventory_id = ?";
            PreparedStatement supplierPst = con.prepareStatement(supplierSql);
            supplierPst.setString(1, inventoryId);
            ResultSet rs = supplierPst.executeQuery();
            rs.next(); // Move to the first row
            String supplier_id = rs.getString("supplier_id");
            // Insert the order details into the orders table
            String orderSql = "INSERT INTO orders (product_id, quantity, total_price, address, supplier_id, order_date, farmer_id) VALUES (?, ?, ?, ?, ?, NOW(), ?)";
            PreparedStatement orderPst = con.prepareStatement(orderSql);
            orderPst.setString(1, inventoryId);
            orderPst.setString(2, quantity);
            orderPst.setString(3, totalPrice);
            orderPst.setString(4, address);
            orderPst.setString(5, supplier_id);
            orderPst.setString(6, farmerId);
            orderPst.executeUpdate();
            // Update the inventory quantity
            String updateSql = "UPDATE inventory SET quantity = quantity - ? WHERE inventory_id = ?";
            PreparedStatement updatePst = con.prepareStatement(updateSql);
            updatePst.setString(1, quantity);
            updatePst.setString(2, inventoryId);
            updatePst.executeUpdate();
            con.commit();
            // Success message for farmer
            out.println("<h2>Ordered successfully! Order will arrive within a week or before. Please refresh your Order Management Dashboard for checking the latest orders you placed</h2>");
        } catch (SQLException e) {
            e.printStackTrace();
            out.println("SQL Error: " + e.getMessage());
        } catch (Exception e) {
            e.printStackTrace();
            out.println("Error: " + e.getMessage());
        }
        %>
    </div>
    <script>
        window.onload = function() {
            const box = document.getElementById('box');
            const message = document.getElementById('message');
            
            const maxDimension = Math.max(window.innerWidth, window.innerHeight);
            const scale = maxDimension / 100 * 1.5;
            
            anime({
                targets: '#box',
                rotate: '10turn',
                scale: [0, scale],
                duration: 3000,
                easing: 'easeInOutQuad',
                complete: function() {
                    box.style.display = 'none';
                    message.style.display = 'block';
                }
            });
        };
    </script>
</body>
</html>