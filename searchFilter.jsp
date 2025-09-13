<%@page import="java.sql.*" %>
<!DOCTYPE html>
<html>
<head>
    <title>Display Products</title>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <style>
        .button {
            display: inline-block;
            padding: 10px 20px;
            font-size: 16px;
            cursor: pointer;
            text-align: center;
            color: #fff;
            background-color: #4CAF50;
            border: none;
            border-radius: 15px;
            box-shadow: 0 9px #999;
        }
        .button:hover { background-color: #3e8e41; }
        .button:active { transform: translateY(4px); }
        .dropdown {
            padding: 10px;
            font-size: 16px;
        }
    </style>
</head>
<body>
    <h2>Search Products</h2>

    <form action="displayproducts.jsp" method="get">
        <!-- Dropdown menu for product categories -->
        <select name="product_category" class="dropdown">
            <option value="">Select Category</option>
            <%
                try {
                    Class.forName("com.mysql.cj.jdbc.Driver");
                    Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/crop?useSSL=false&allowPublicKeyRetrieval=true", "root", "windows");
                    String query = "SELECT DISTINCT product_category FROM inventory";
                    PreparedStatement stmt = con.prepareStatement(query);
                    ResultSet rs = stmt.executeQuery();
                    
                    while (rs.next()) {
                        String category = rs.getString("product_category");
            %>
                        <option value="<%= category %>"><%= category %></option>
            <%
                    }
                    con.close();
                } catch (Exception e) {
                    out.println("Error: " + e.getMessage());
                }
            %>
        </select>
        
        <button type="submit" name="submit" value="searchByCategory" class="button">Search</button>
    </form>
</body>
</html>
