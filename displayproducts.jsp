<%@page import="java.sql.*" %>
<%@page import="java.io.*, java.util.*" %>
<%@page import="java.text.SimpleDateFormat" %>

<%
    String searchQuery = request.getParameter("searchQuery");
    String selectedCategory = request.getParameter("product_category");

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/crop?useSSL=false&allowPublicKeyRetrieval=true", "root", "windows");

        // Base query with joins to get inventory and supplier full name
        StringBuilder query = new StringBuilder("SELECT i.*, l.full_name FROM inventory i " +
                                                "JOIN supplier s ON i.supplier_id = s.supplier_id " +
                                                "JOIN login l ON s.user_id = l.user_id ");

        // Adding conditions based on search query and selected category
        List<String> conditions = new ArrayList<>();
        if (searchQuery != null && !searchQuery.isEmpty()) {
            conditions.add("(i.product_name LIKE ? OR i.brand_name LIKE ? OR i.product_category LIKE ? OR l.full_name LIKE ?)");
        }
        if (selectedCategory != null && !selectedCategory.isEmpty()) {
            conditions.add("i.product_category = ?");
        }

        // Append conditions to the base query
        if (!conditions.isEmpty()) {
            query.append("WHERE ").append(String.join(" AND ", conditions));
        } else {
            query.append("ORDER BY RAND() LIMIT 10"); // Default random limit
        }

        PreparedStatement selectStmt = con.prepareStatement(query.toString());

        // Set parameters for search terms if any
        int paramIndex = 1;
        if (searchQuery != null && !searchQuery.isEmpty()) {
            for (int i = 0; i < 4; i++) {
                selectStmt.setString(paramIndex++, "%" + searchQuery + "%");
            }
        }
        if (selectedCategory != null && !selectedCategory.isEmpty()) {
            selectStmt.setString(paramIndex, selectedCategory);
        }

        ResultSet rs = selectStmt.executeQuery();

        SimpleDateFormat inputFormat = new SimpleDateFormat("yyyy-MM-dd");
        SimpleDateFormat outputFormat = new SimpleDateFormat("dd-MMM-yyyy");
%>
<!DOCTYPE html>
<html>
<head>
    <title>Available Products</title>
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
        .product-card {
            border: 1px solid #ccc;
            border-radius: 8px;
            padding: 16px;
            margin: 16px;
            text-align: center;
            box-shadow: 0 4px 8px rgba(0, 0, 0, 0.1);
            transition: transform 0.2s;
        }
        .product-card:hover { transform: translateY(-10px); }
        .product-card h2 { font-size: 1.5em; margin: 0.5em 0; }
        .product-card p { margin: 0.5em 0; color: #333; }
        .product-card a {
            text-decoration: none;
            color: #4CAF50;
            display: inline-block;
            margin-top: 10px;
            font-weight: bold;
        }
        
    input[name="searchQuery"] {
    width: 250px;
    padding: 10px;
    font-size: 16px;
    border: 2px solid #4CAF50;
    border-radius: 15px;
    margin-right: 10px;
    transition: box-shadow 0.3s ease;
    outline: none;
}

input[name="searchQuery"]:focus {
    box-shadow: 0 0 10px rgba(76, 175, 80, 0.5);
    border-color: #45a049;
}
    </style>
</head>
<body>
    <h2>Search Products</h2>

    <!-- Search and Filter Form -->
    <form action="displayproducts.jsp" method="get">
        <!-- Search bar for keywords -->
        <input type="text" name="searchQuery" placeholder="Search for products..." value="<%= searchQuery != null ? searchQuery : "" %>" />

        <!-- Dropdown menu for product categories -->
        <select name="product_category" class="dropdown">
            <option value="">Select Category</option>
            <%
                // Populate dropdown with categories from the database
                String categoryQuery = "SELECT DISTINCT product_category FROM inventory";
                PreparedStatement categoryStmt = con.prepareStatement(categoryQuery);
                ResultSet categoryRs = categoryStmt.executeQuery();
                
                while (categoryRs.next()) {
                    String category = categoryRs.getString("product_category");
                    String selected = category.equals(selectedCategory) ? "selected" : "";
            %>
                    <option value="<%= category %>" <%= selected %>><%= category %></option>
            <%
                }
                categoryRs.close();
            %>
        </select>

        <button type="submit" name="submit" value="search" class="button">Search</button>
    </form>

    <h2 style='color: red;'>Available Products</h2>
    <div class="product-container">
        <% while (rs.next()) { %>
            <div class="product-card">
                <h2><%= rs.getString("product_name") %></h2>
                <p><strong>Brand:</strong> <%= rs.getString("brand_name") %></p>
                <p><strong>Category:</strong> <%= rs.getString("product_category") %></p>
                <p><strong>Price:</strong> <%= rs.getString("unit_price") %> Rs</p>
                <p><strong>Stock Left:</strong> <%= rs.getString("quantity") %></p>
                <p><strong>Manufacturing Date:</strong> <%= outputFormat.format(inputFormat.parse(rs.getString("manufacturing_date"))) %></p>
                <p><strong>Expiry Date:</strong> <%=
                    rs.getString("expiry_date") == null ? "N/A" :
                    outputFormat.format(inputFormat.parse(rs.getString("expiry_date"))) %>
                </p>
                <p><strong>Supplier:</strong> <%= rs.getString("full_name") %></p>
                <a href='description.jsp?inventory_id=<%= rs.getString("inventory_id") %>' target='_blank'>View Description</a><br>
                <a href='buy.jsp?inventory_id=<%= rs.getString("inventory_id") %>' target='_blank'>Buy</a>
            </div>
        <% } %>
    </div>
<%
        rs.close();
        selectStmt.close();
        con.close();
    } catch (Exception e) {
        out.println("Error: " + e.getMessage());
    }
%>
</body>
</html>
