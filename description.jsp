<%@page import="java.sql.*" %>
<%@page import="java.io.*,java.util.*"%>
<%
String inventoryId = request.getParameter("inventory_id");
if (inventoryId != null) 
{
    try 
    {
        Class.forName("com.mysql.cj.jdbc.Driver");
        Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/crop?useSSL=false&allowPublicKeyRetrieval=true", "root", "windows");

        // Create a new PreparedStatement for the SELECT query with the WHERE clause
        String sql = "SELECT product_description, product_name, brand_name FROM inventory WHERE inventory_id = ?";
        PreparedStatement ps = con.prepareStatement(sql);
        ps.setString(1, inventoryId);
        ResultSet rs = ps.executeQuery();

        if (rs.next()) 
        {
            String productDescription = rs.getString("product_description");
            String productName = rs.getString("product_name");
            String brandName = rs.getString("brand_name");
%>
<!DOCTYPE html>
<html>
    <head>
        <title>Product Details</title>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <style>
            @keyframes fadeIn {
                from {
                    opacity: 0;
                    transform: translateY(20px);
                }
                to {
                    opacity: 1;
                    transform: translateY(0);
                }
            }

            body {
                font-family: 'Arial', sans-serif;
                background: linear-gradient(135deg, #0f0f0f, #1a1a1a);
                display: flex;
                justify-content: center;
                align-items: center;
                height: 100vh;
                margin: 0;
                color: #fff;
            }

            .product-details {
                max-width: 600px;
                padding: 25px;
                background: rgba(30, 30, 30, 0.95);
                border-radius: 12px;
                box-shadow: 0px 10px 25px rgba(0, 0, 0, 0.3);
                text-align: center;
                animation: fadeIn 0.8s ease-in-out;
                transition: transform 0.3s ease-in-out, box-shadow 0.3s ease-in-out;
                border: 1px solid rgba(255, 255, 255, 0.1);
                backdrop-filter: blur(10px);
            }

            .product-details:hover {
                transform: scale(1.03);
                box-shadow: 0px 15px 40px rgba(255, 215, 0, 0.3);
            }

            h1 {
                font-size: 26px;
                color: gold;
                margin-bottom: 15px;
                text-transform: uppercase;
                letter-spacing: 1px;
            }

            p {
                font-size: 18px;
                padding: 12px;
                border-radius: 8px;
            }
        </style>
    </head>
    <body>
        <div class="product-details">
            <h1><%= brandName %> - <%= productName %></h1>
            <p><%= productDescription %></p>
        </div>
    </body>
</html>
<%
        } 
        else
            out.println("<p style='color: red; text-align: center;'>No product found with the given ID.</p>");
        con.close();
    } 
    catch (Exception e) 
    {
        out.println("<p style='color: red; text-align: center;'>Error: " + e.getMessage() + "</p>");
    }
}
%>
