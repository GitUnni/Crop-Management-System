<%@page import="java.sql.*" %>
<%@page import="java.io.*,java.util.*"%>

<%
    String action = request.getParameter("action");
    if(action != null && action.equals("add")) //Add Stock button (inventory mgmt)
    {
        try 
        {
            String brand_name = request.getParameter("brand_name");
            String product_name = request.getParameter("product_name");
            String product_description = request.getParameter("product_description");
            String product_category = request.getParameter("product_category");
            String unit_price = request.getParameter("unit_price");
            String quantity = request.getParameter("quantity");
            String unit = request.getParameter("unit");
            String manufacturing_date = request.getParameter("manufacturing_date");
            String expiry_date = request.getParameter("expiry_date");
            
            if (expiry_date == null || expiry_date.isEmpty())
                expiry_date = null;

            Class.forName("com.mysql.cj.jdbc.Driver");
            Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/crop?useSSL=false&allowPublicKeyRetrieval=true", "root", "windows");

            // Get the username from the session
            String username = (String) session.getAttribute("username");

            // Get the supplier_id from the supplier table based on the username
            String getSupplierIdQuery = "SELECT supplier_id FROM supplier, login WHERE username = ? AND supplier.user_id = login.user_id;";
            PreparedStatement getSupplierIdStmt = con.prepareStatement(getSupplierIdQuery);
            getSupplierIdStmt.setString(1, username);
            ResultSet supplierRS = getSupplierIdStmt.executeQuery();

            int supplier_id = -1;
            if (supplierRS.next())
                supplier_id = supplierRS.getInt("supplier_id");

            // Insert into the inventory table
            String inventoryQuery = "INSERT INTO inventory (brand_name, product_name, product_description, product_category, unit_price, quantity, unit, manufacturing_date, expiry_date, supplier_id) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
            PreparedStatement inventoryPst = con.prepareStatement(inventoryQuery, Statement.RETURN_GENERATED_KEYS);
            inventoryPst.setString(1, brand_name);
            inventoryPst.setString(2, product_name);
            inventoryPst.setString(3, product_description);
            inventoryPst.setString(4, product_category);
            inventoryPst.setString(5, unit_price);
            inventoryPst.setString(6, quantity);
            inventoryPst.setString(7, unit);
            inventoryPst.setString(8, manufacturing_date);
            inventoryPst.setString(9, expiry_date);
            inventoryPst.setInt(10, supplier_id);
            int rowsInserted = inventoryPst.executeUpdate();

            if (rowsInserted > 0)
            {
                out.println("<h2>Product added successfully!</h2><h2>Please wait!</h2>");
%>              
            <script>
                setTimeout(function(){
                    location.replace("inventoryOperations.html");
                }, 1000); // 1000 milliseconds = 1 second
            </script>  
<%
            }
            else
                out.println("<h2>Error adding product.</h2>");

            con.close();
        } 
        catch (Exception e) 
        {
            out.println("Error: " + e.getMessage());
        }
    }
    
else if (action != null && action.equals("update")) {
    try {
        // Get the username from the session
        String username = (String) session.getAttribute("username");

        Class.forName("com.mysql.cj.jdbc.Driver");
        Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/crop?useSSL=false&allowPublicKeyRetrieval=true", "root", "windows");

        // Get the supplier_id from the supplier table based on the username
        String getSupplierIdQuery = "SELECT supplier_id FROM supplier, login WHERE username = ? AND supplier.user_id = login.user_id;";
        PreparedStatement getSupplierIdStmt = con.prepareStatement(getSupplierIdQuery);
        getSupplierIdStmt.setString(1, username);
        ResultSet supplierRS = getSupplierIdStmt.executeQuery();

        int supplier_id = -1;
        if (supplierRS.next())
            supplier_id = supplierRS.getInt("supplier_id");

        // Get the inventory_id from the request parameter
        String inventory_id = request.getParameter("inventory_id");

        // Get the existing record from the database
        String selectQuery = "SELECT brand_name, product_name, product_description, product_category, unit_price, quantity, unit, manufacturing_date, expiry_date FROM inventory WHERE inventory_id = ? AND supplier_id = ?";
        PreparedStatement selectStmt = con.prepareStatement(selectQuery);
        selectStmt.setInt(1, Integer.parseInt(inventory_id));
        selectStmt.setInt(2, supplier_id);
        ResultSet existingRecord = selectStmt.executeQuery();

        // Update the inventory table
        String updateQuery = "UPDATE inventory SET brand_name = ?, product_name = ?, product_description = ?, product_category = ?, unit_price = ?, quantity = ?, unit = ?, manufacturing_date = ?, expiry_date = ? WHERE inventory_id = ? AND supplier_id = ?";
        PreparedStatement updateStmt = con.prepareStatement(updateQuery);

        // Set the parameter values, keeping existing values if input is empty
        if (existingRecord.next()) {
            updateStmt.setString(1, request.getParameter("brand_name") != null && !request.getParameter("brand_name").isEmpty() ? request.getParameter("brand_name") : existingRecord.getString("brand_name"));
            updateStmt.setString(2, request.getParameter("product_name") != null && !request.getParameter("product_name").isEmpty() ? request.getParameter("product_name") : existingRecord.getString("product_name"));
            updateStmt.setString(3, request.getParameter("product_description") != null && !request.getParameter("product_description").isEmpty() ? request.getParameter("product_description") : existingRecord.getString("product_description"));
            updateStmt.setString(4, request.getParameter("product_category") != null && !request.getParameter("product_category").isEmpty() ? request.getParameter("product_category") : existingRecord.getString("product_category"));
            updateStmt.setString(5, request.getParameter("unit_price") != null && !request.getParameter("unit_price").isEmpty() ? request.getParameter("unit_price") : existingRecord.getString("unit_price"));
            updateStmt.setString(6, request.getParameter("quantity") != null && !request.getParameter("quantity").isEmpty() ? request.getParameter("quantity") : existingRecord.getString("quantity"));
            updateStmt.setString(7, request.getParameter("unit") != null && !request.getParameter("unit").isEmpty() ? request.getParameter("unit") : existingRecord.getString("unit"));

            // Handle manufacturing_date
            String manufacturingDateParam = request.getParameter("manufacturing_date");
            if (manufacturingDateParam != null && !manufacturingDateParam.isEmpty())
                updateStmt.setDate(8, java.sql.Date.valueOf(manufacturingDateParam));
            else
                updateStmt.setDate(8, existingRecord.getDate("manufacturing_date"));

            // Handle expiry_date
            String expiryDateParam = request.getParameter("expiry_date");
            if (expiryDateParam != null && !expiryDateParam.isEmpty())
                updateStmt.setDate(9, java.sql.Date.valueOf(expiryDateParam));
            else
                updateStmt.setDate(9, existingRecord.getDate("expiry_date"));

            updateStmt.setInt(10, Integer.parseInt(inventory_id));
            updateStmt.setInt(11, supplier_id);

            int rowsUpdated = updateStmt.executeUpdate();
            if (rowsUpdated > 0) {
                out.println("<h2>Product updated successfully!</h2><h2>Please wait!</h2>");
%>              
                <script>
                    setTimeout(function(){
                        location.replace("inventoryOperations.html");
                    }, 1000); // 1000 milliseconds = 1 second
                </script>  
<%
            } else {
                out.println("<h2>Error updating product.</h2>");
            }
        } else {
            out.println("<h2>Error: Record not found.</h2>");
        }

    } catch (Exception e) {
        out.println("Error: " + e.getMessage());
    }
}

    else if(action != null && action.equals("delete")) //Delete Stock button (inventory mgmt)
    {
        try 
        {
            String inventory_id = request.getParameter("inventory_id");

            Class.forName("com.mysql.cj.jdbc.Driver");
            Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/crop?useSSL=false&allowPublicKeyRetrieval=true", "root", "windows");

            // Get the username from the session
            String username = (String) session.getAttribute("username");

            // Get the supplier_id from the supplier table based on the username
            String getSupplierIdQuery = "SELECT supplier_id FROM supplier, login WHERE username = ? AND supplier.user_id = login.user_id;";
            PreparedStatement getSupplierIdStmt = con.prepareStatement(getSupplierIdQuery);
            getSupplierIdStmt.setString(1, username);
            ResultSet supplierRS = getSupplierIdStmt.executeQuery();

            int supplier_id = -1;
            if (supplierRS.next())
                supplier_id = supplierRS.getInt("supplier_id");

            // DELETE from the inventory table
            String inventoryQuery = "DELETE FROM inventory WHERE inventory_id =? AND supplier_id =?";
            PreparedStatement inventoryPst = con.prepareStatement(inventoryQuery, Statement.RETURN_GENERATED_KEYS);
            inventoryPst.setString(1, inventory_id);
            inventoryPst.setInt(2, supplier_id);
            int rowsDeleted = inventoryPst.executeUpdate();

            if (rowsDeleted > 0)
            {
                out.println("<h2>Deleted successfully!</h2><h2>Please wait!</h2>");
%>              
            <script>
                setTimeout(function(){
                    location.replace("inventoryOperations.html");
                }, 1000); // 1000 milliseconds = 1 second
            </script>  
<%
            }
            else
                out.println("<h2>Error deleting the product.</h2>");

            con.close();
        } 
        catch (Exception e) 
        {
            out.println("Error: " + e.getMessage());
        }
    }
    
    else if (action != null && action.equals("display"))  //Display Stock button(inventory mgmt)
    {
        try 
        {
            // Get the username from the session
            String username = (String) session.getAttribute("username");
            Class.forName("com.mysql.cj.jdbc.Driver");
            Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/crop?useSSL=false&allowPublicKeyRetrieval=true", "root", "windows");
            
            // Get the supplier_id from the supplier table based on the username
            String getSupplierIdQuery = "SELECT supplier_id FROM supplier, login WHERE username = ? AND supplier.user_id = login.user_id;";
            PreparedStatement getSupplierIdStmt = con.prepareStatement(getSupplierIdQuery);
            getSupplierIdStmt.setString(1, username);
            ResultSet supplierRS = getSupplierIdStmt.executeQuery();
            int supplier_id = -1;
            if (supplierRS.next())
                supplier_id = supplierRS.getInt("supplier_id");
            
            // Create a new PreparedStatement for the SELECT query with the WHERE clause and formatted dates
            String query = "SELECT inventory_id, brand_name, product_name, product_category, unit_price, quantity, unit, " +
                           "DATE_FORMAT(manufacturing_date, '%d-%b-%Y') AS formatted_manufacturing_date, " +
                           "DATE_FORMAT(expiry_date, '%d-%b-%Y') AS formatted_expiry_date " +
                           "FROM inventory WHERE supplier_id = ?";
            PreparedStatement selectStmt = con.prepareStatement(query);
            selectStmt.setInt(1, supplier_id);
            ResultSet rs = selectStmt.executeQuery();
    %>
        <style>
        table {
            width: 750px;
            max-width: 750px;
            border-collapse: collapse;
            border-radius: 8px;
            overflow: hidden;
            background: #222;
            color: #ddd;
            box-shadow: 0px 4px 10px rgba(0, 0, 0, 0.3);
        }
        th, td {
            font-size: 14.5px; 
            border: 1px solid #ccc;
            padding: 10px;
            text-align: left;
            text-transform: uppercase;
        }
        th {
            border-bottom: 1px solid rgba(255, 255, 255, 0.1);
            color: white;
        }
 
        tr:hover  {
            background: black;
            transition: background 0.3s ease-in-out;
        }

        </style>
    <%
            // Print the result set in an HTML table
            out.println("<h3><a href='displayInventory.html' style='color: green; text-decoration: underline; cursor: pointer;'>Click here to view other options</a></h3>");
            out.println("<table border='1'>");
            out.println("<tr>");
            out.println("<th>Id</th>");
            out.println("<th>Brand Name</th>");
            out.println("<th>Product Name</th>");
            out.println("<th>Product Category</th>");
            out.println("<th>Unit Price</th>");
            out.println("<th>Quantity</th>");
            out.println("<th>Manufacturing Date</th>");
            out.println("<th>Expiry Date</th>");
            out.println("</tr>");
            while (rs.next()) 
            {
                out.println("<tr>");
                out.println("<td>" + rs.getString("inventory_id") + "</td>");
                out.println("<td>" + rs.getString("brand_name") + "</td>");
                out.println("<td>" + rs.getString("product_name") + "</td>");
                out.println("<td>" + rs.getString("product_category") + "</td>");
                out.println("<td>&#8377;" + rs.getString("unit_price") + "</td>");
                out.println("<td>" + rs.getString("quantity"));
                out.println(rs.getString("unit") + "</td>");
                out.println("<td>" + rs.getString("formatted_manufacturing_date") + "</td>");
                out.println("<td>" + rs.getString("formatted_expiry_date") + "</td>");
                out.println("</tr>");
            }
            out.println("</table>");
            con.close();
        } 
        catch (Exception e) 
        {
            out.println("Error: " + e.getMessage());
        }
    }
    
    else if(action != null && action.equals("Bsearch")) //Brand Name Search button (inventory mgmt)
    {
        try 
        {
            String brand_name = request.getParameter("brand_name");
            // Get the username from the session
            String username = (String) session.getAttribute("username");

            Class.forName("com.mysql.cj.jdbc.Driver");
            Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/crop?useSSL=false&allowPublicKeyRetrieval=true", "root", "windows");

            // Get the supplier_id from the supplier table based on the username
            String getSupplierIdQuery = "SELECT supplier_id FROM supplier, login WHERE username = ? AND supplier.user_id = login.user_id;";
            PreparedStatement getSupplierIdStmt = con.prepareStatement(getSupplierIdQuery);
            getSupplierIdStmt.setString(1, username);
            ResultSet supplierRS = getSupplierIdStmt.executeQuery();

            int supplier_id = -1;
            if (supplierRS.next())
                supplier_id = supplierRS.getInt("supplier_id");

            // Create a new PreparedStatement for the SELECT query with the WHERE clause
            String query = "SELECT inventory_id, brand_name, product_name, product_category, unit_price, quantity, unit,"+
                           "DATE_FORMAT(manufacturing_date, '%d-%b-%Y') AS formatted_manufacturing_date,"+
                           "DATE_FORMAT(expiry_date, '%d-%b-%Y') AS formatted_expiry_date FROM inventory WHERE brand_name= ? and supplier_id = ?";
            PreparedStatement selectStmt = con.prepareStatement(query);
            selectStmt.setString(1, brand_name);
            selectStmt.setInt(2, supplier_id);
            ResultSet rs = selectStmt.executeQuery();

            // Print the result set in a card format
            out.println("<style>");
            out.println(".card { border: 1px solid #ddd; border-radius: 8px; padding: 16px; margin: 16px 0; box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1); background-color: #fff; transition: transform 0.3s ease;}");
            out.println(".card:hover { transform: scale(1.05); }");
            out.println(".card h4 { margin: 0 0 8px; }");
            out.println(".card p { margin: 4px 0; }");
            out.println("</style>");

            out.println("<h3><a href='displayInventory.html' style='color: green; text-decoration: underline; cursor: pointer;'>Click here to view other options</a></h3>");

            while (rs.next()) 
            {
                out.println("<div class='card'>");
                out.println("<h4>Product ID: " + rs.getString("inventory_id") + "</h4>");
                out.println("<p><strong>Brand Name:</strong> " + rs.getString("brand_name") + "</p>");
                out.println("<p><strong>Product Name:</strong> " + rs.getString("product_name") + "</p>");
                out.println("<p><strong>Product Category:</strong> " + rs.getString("product_category") + "</p>");
                out.println("<p><strong>Unit Price:</strong> " + rs.getString("unit_price") + "</p>");
                out.println("<p><strong>Quantity:</strong> " + rs.getString("quantity") + " " + rs.getString("unit") + "</p>");
                out.println("<p><strong>Manufacturing Date:</strong> " + rs.getString("formatted_manufacturing_date") + "</p>");
                out.println("<p><strong>Expiry Date:</strong> " + rs.getString("formatted_expiry_date") + "</p>");
                out.println("</div>");
            }

            con.close();
        } 
        catch (Exception e) 
        {
            out.println("Error: " + e.getMessage());
        }
    }

    else if(action != null && action.equals("Psearch")) //Product Name Search button (inventory mgmt)
    {
        try 
        {
            String product_name = request.getParameter("product_name"); 
            // Get the username from the session
            String username = (String) session.getAttribute("username");

            Class.forName("com.mysql.cj.jdbc.Driver");
            Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/crop?useSSL=false&allowPublicKeyRetrieval=true", "root", "windows");

            // Get the supplier_id from the supplier table based on the username
            String getSupplierIdQuery = "SELECT supplier_id FROM supplier, login WHERE username = ? AND supplier.user_id = login.user_id;";
            PreparedStatement getSupplierIdStmt = con.prepareStatement(getSupplierIdQuery);
            getSupplierIdStmt.setString(1, username);
            ResultSet supplierRS = getSupplierIdStmt.executeQuery();

            int supplier_id = -1;
            if (supplierRS.next())
                supplier_id = supplierRS.getInt("supplier_id");

            // Create a new PreparedStatement for the SELECT query with the WHERE clause
            String query = "SELECT inventory_id, brand_name, product_name, product_category, unit_price, quantity, unit, " +
                           "DATE_FORMAT(manufacturing_date, '%d-%b-%Y') AS formatted_manufacturing_date, " +
                           "DATE_FORMAT(expiry_date, '%d-%b-%Y') AS formatted_expiry_date " +
                           "FROM inventory WHERE product_name = ? AND supplier_id = ?";
            PreparedStatement selectStmt = con.prepareStatement(query);
            selectStmt.setString(1, product_name);
            selectStmt.setInt(2, supplier_id);
            ResultSet rs = selectStmt.executeQuery();

            // Print the result set in a card format
            out.println("<style>");
            out.println(".card { border: 1px solid #ddd; border-radius: 5px; padding: 16px; margin: 16px 0; box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1); background-color: #fff; transition: transform 0.3s ease; }");
            out.println(".card:hover { transform: scale(1.05); }");
            out.println(".card h4 { margin: 0 0 8px; }");
            out.println(".card p { margin: 4px 0; }");
            out.println("</style>");

            out.println("<h3><a href='displayInventory.html' style='color: green; text-decoration: underline; cursor: pointer;'>Click here to view other options</a></h3>");

            while (rs.next()) 
            {
                out.println("<div class='card'>");
                out.println("<h4>Product ID: " + rs.getString("inventory_id") + "</h4>");
                out.println("<p><strong>Brand Name:</strong> " + rs.getString("brand_name") + "</p>");
                out.println("<p><strong>Product Name:</strong> " + rs.getString("product_name") + "</p>");
                out.println("<p><strong>Product Category:</strong> " + rs.getString("product_category") + "</p>");
                out.println("<p><strong>Unit Price:</strong> " + rs.getString("unit_price") + "</p>");
                out.println("<p><strong>Quantity:</strong> " + rs.getString("quantity") + " " + rs.getString("unit") + "</p>");
                out.println("<p><strong>Manufacturing Date:</strong> " + rs.getString("formatted_manufacturing_date") + "</p>");
                out.println("<p><strong>Expiry Date:</strong> " + rs.getString("formatted_expiry_date") + "</p>");
                out.println("</div>");
            }

            con.close();
        } 
        catch (Exception e) 
        {
            out.println("Error: " + e.getMessage());
        }
    }


    else if(action != null && action.equals("count")) //Count button (inventory mgmt)
    {
        try 
        {
            // Get the username from the session
            String username = (String) session.getAttribute("username");

            Class.forName("com.mysql.cj.jdbc.Driver");
            Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/crop?useSSL=false&allowPublicKeyRetrieval=true", "root", "windows");

            // Get the supplier_id from the supplier table based on the username
            String getSupplierIdQuery = "SELECT supplier_id FROM supplier, login WHERE username = ? AND supplier.user_id = login.user_id;";
            PreparedStatement getSupplierIdStmt = con.prepareStatement(getSupplierIdQuery);
            getSupplierIdStmt.setString(1, username);
            ResultSet supplierRS = getSupplierIdStmt.executeQuery();

            int supplier_id = -1;
            if (supplierRS.next())
                supplier_id = supplierRS.getInt("supplier_id");

            // Create a new PreparedStatement for the SELECT query with the WHERE clause
            String query = "SELECT COUNT(inventory_id) FROM inventory WHERE supplier_id = ?";
            PreparedStatement selectStmt = con.prepareStatement(query);
            selectStmt.setInt(1, supplier_id);
            ResultSet rs = selectStmt.executeQuery();
            
           // Print the result set
            out.println("<h3><a href='displayInventory.html' style='color: green; text-decoration: underline; cursor: pointer;'>Click here to view other options</a></h3>");

            while (rs.next()) 
                out.println("<strong>Total Items = " + rs.getString("COUNT(inventory_id)")+"</strong>");

            con.close();
        } 
        catch (Exception e) 
        {
            out.println("Error: " + e.getMessage());
        }
    }
    
    else if(action != null && action.equals("cropinfo")) // Add Crop Information(Harvest & Yield mgmt)
    {
        try 
        {
            String crop_name = request.getParameter("crop_name");
            String planting_date = request.getParameter("planting_date");
            String soil_type = request.getParameter("soil_type");

            Class.forName("com.mysql.cj.jdbc.Driver");
            Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/crop?useSSL=false&allowPublicKeyRetrieval=true", "root", "windows");

            // Get the username from the session
            String username = (String) session.getAttribute("username");

            // Get the farmer_id from the farmer table based on the username
            String getFarmerIdQuery = "SELECT farmer_id FROM farmer, login WHERE username = ? AND farmer.user_id = login.user_id;";
            PreparedStatement getFarmerIdStmt = con.prepareStatement(getFarmerIdQuery);
            getFarmerIdStmt.setString(1, username);
            ResultSet farmerRS = getFarmerIdStmt.executeQuery();

            int farmer_id = -1;
            if (farmerRS.next())
                farmer_id = farmerRS.getInt("farmer_id");

            // Insert into the cropInfo table
            String cropInfoQuery = "INSERT INTO cropInfo (crop_name, planting_date, soil_type, farmer_id) VALUES (?, ?, ?, ?)";
            PreparedStatement cropInfoPst = con.prepareStatement(cropInfoQuery);
            cropInfoPst.setString(1, crop_name);
            cropInfoPst.setString(2, planting_date);
            cropInfoPst.setString(3, soil_type);
            cropInfoPst.setInt(4, farmer_id);
            int rowsInserted = cropInfoPst.executeUpdate();

            if (rowsInserted > 0)
            {
                out.println("<h2>Crop details added successfully!</h2><h2>Please wait!</h2>");
%>              
            <script>
                setTimeout(function(){
                    location.replace("harvest.html");
                }, 1000); // 1000 milliseconds = 1 second
            </script>  
<%
            }
            else
                out.println("<h2>Error adding data.</h2>");

            con.close();
        } 
        catch (Exception e) 
        {
            out.println("Error: " + e.getMessage());
        }
    }
    
    else if(action != null && action.equals("yield")) // Harvest & Yield button (Harvest & Yield mgmt)
    {
        try 
        {
            String crop_id = request.getParameter("crop_id");
            String harvest_date = request.getParameter("harvest_date");
            String yield_quantity = request.getParameter("yield_quantity");
            String yield_unit = request.getParameter("yield_unit");
            String quality = request.getParameter("quality");

            Class.forName("com.mysql.cj.jdbc.Driver");
            Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/crop?useSSL=false&allowPublicKeyRetrieval=true", "root", "windows");

            // Get the username from the session
            String username = (String) session.getAttribute("username");

            // Get the farmer_id from the farmer table based on the username
            String getFarmerIdQuery = "SELECT farmer_id FROM farmer, login WHERE username = ? AND farmer.user_id = login.user_id;";
            PreparedStatement getFarmerIdStmt = con.prepareStatement(getFarmerIdQuery);
            getFarmerIdStmt.setString(1, username);
            ResultSet farmerRS = getFarmerIdStmt.executeQuery();

            int farmer_id = -1;
            if (farmerRS.next())
                farmer_id = farmerRS.getInt("farmer_id");

            // Insert into the cropInfo table
            String harvestQuery = "UPDATE cropInfo SET harvest_date = ?, yield_quantity = ?, yield_unit = ?, quality = ? WHERE crop_id = ? AND farmer_id = ?";
            PreparedStatement harvestPst = con.prepareStatement(harvestQuery);
            harvestPst.setString(1, harvest_date);
            harvestPst.setString(2, yield_quantity);
            harvestPst.setString(3, yield_unit);
            harvestPst.setString(4, quality);
            harvestPst.setString(5, crop_id);
            harvestPst.setInt(6, farmer_id);
            int rowsInserted = harvestPst.executeUpdate();

            if (rowsInserted > 0)
            {
                out.println("<h2>Harvest & Yield data added successfully!</h2><h2>Please wait!</h2>");
%>              
            <script>
                setTimeout(function(){
                    location.replace("harvest.html");
                }, 1000); // 1000 milliseconds = 1 second
            </script>  
<%
            }       
            else
                out.println("<h2>Error adding Harvest & Yield data.</h2>");
            con.close();
        } 
        catch (Exception e) 
        {
            out.println("Error: " + e.getMessage());
        }
    }
    
    else if(action != null && action.equals("show")) // Display button (Harvest & Yield mgmt)
    {
        try 
        {
            // Add SimpleDateFormat import
            java.text.SimpleDateFormat dbFormat = new java.text.SimpleDateFormat("yyyy-MM-dd");
            java.text.SimpleDateFormat readableFormat = new java.text.SimpleDateFormat("MMMM d, yyyy");

            Class.forName("com.mysql.cj.jdbc.Driver");
            Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/crop?useSSL=false&allowPublicKeyRetrieval=true", "root", "windows");
            // Get the username from the session
            String username = (String) session.getAttribute("username");
            // Get the farmer_id from the farmer table based on the username
            String getFarmerIdQuery = "SELECT farmer_id FROM farmer, login WHERE username = ? AND farmer.user_id = login.user_id;";
            PreparedStatement getFarmerIdStmt = con.prepareStatement(getFarmerIdQuery);
            getFarmerIdStmt.setString(1, username);
            ResultSet farmerRS = getFarmerIdStmt.executeQuery();
            int farmer_id = -1;
            if (farmerRS.next())
                farmer_id = farmerRS.getInt("farmer_id");           
            // Create a new PreparedStatement for the SELECT query with the WHERE clause
            String query = "SELECT * FROM cropInfo where farmer_id =?";
            PreparedStatement selectStmt = con.prepareStatement(query);
            selectStmt.setInt(1, farmer_id);
            ResultSet rs = selectStmt.executeQuery();
           // Print the result set in an HTML table
            out.println("<style>");
            out.println("table { width: 100%; border-collapse: collapse; }");
            out.println("table, th, td { border: 1px solid #ddd; }");
            out.println("th, td { padding: 12px; text-align: left; }");
            out.println("th { background-color: #f2f2f2; }");
            out.println("tr { background-color: #f2f2f2; }");
            out.println("tr:hover { background-color: #58d184; }");
            out.println("</style>");
            out.println("<h3><a href='harvest.html' style='color: green; text-decoration: underline; cursor: pointer;'>Click here to view other options</a></h3>");
            out.println("<table>");
            out.println("<tr>");
            out.println("<th>Id</th>");
            out.println("<th>Crop Name</th>");
            out.println("<th>Planting Date</th>");
            out.println("<th>Harvest Date</th>");
            out.println("<th>Soil Type</th>");
            out.println("<th>Yield Quantity</th>");
            out.println("<th>Yield Unit</th>");
            out.println("<th>Quality</th>");
            out.println("</tr>");
            while (rs.next()) 
            {
                // Format dates to be more readable
                String plantingDate = rs.getString("planting_date");
                String harvestDate = rs.getString("harvest_date");
                String formattedPlantingDate = plantingDate != null ? readableFormat.format(dbFormat.parse(plantingDate)) : "N/A";
                String formattedHarvestDate = harvestDate != null ? readableFormat.format(dbFormat.parse(harvestDate)) : "N/A";

                out.println("<tr>");
                out.println("<td>" + rs.getString("crop_id") + "</td>");
                out.println("<td>" + rs.getString("crop_name") + "</td>");
                out.println("<td>" + formattedPlantingDate + "</td>");
                out.println("<td>" + formattedHarvestDate + "</td>");
                out.println("<td>" + rs.getString("soil_type") + "</td>");
                out.println("<td>" + rs.getString("yield_quantity") + "</td>");
                out.println("<td>" + rs.getString("yield_unit") + "</td>");
                out.println("<td>" + rs.getString("quality") + "</td>");
                out.println("</tr>");
            }
            out.println("</table>");
            con.close();
        } 
        catch (Exception e) 
        {
            out.println("Error: " + e.getMessage());
        }
    }

    else if(action != null && action.equals("searchProducts")) //Search Products button (Order mgmt)
    {
        try 
        {
            String brand_name = request.getParameter("brand_name");
            // Get the username from the session
            String username = (String) session.getAttribute("username");

            Class.forName("com.mysql.cj.jdbc.Driver");
            Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/crop?useSSL=false&allowPublicKeyRetrieval=true", "root", "windows");

            // Get the supplier_id from the supplier table based on the username
            String getSupplierIdQuery = "SELECT supplier_id FROM supplier, login WHERE username = ? AND supplier.user_id = login.user_id;";
            PreparedStatement getSupplierIdStmt = con.prepareStatement(getSupplierIdQuery);
            getSupplierIdStmt.setString(1, username);
            ResultSet supplierRS = getSupplierIdStmt.executeQuery();

            int supplier_id = -1;
            if (supplierRS.next())
                supplier_id = supplierRS.getInt("supplier_id");

            // Create a new PreparedStatement for the SELECT query with the WHERE clause
            String query = "SELECT inventory_id, brand_name, product_name, product_category, unit_price, quantity, manufacturing_date, expiry_date FROM inventory WHERE brand_name= ? and supplier_id = ?";
            PreparedStatement selectStmt = con.prepareStatement(query);
            selectStmt.setString(1, brand_name);
            selectStmt.setInt(2, supplier_id);
            ResultSet rs = selectStmt.executeQuery();

           // Print the result set in an HTML table
            out.println("<style>");
            out.println("table { width: 100%; border-collapse: collapse; }");
            out.println("table, th, td { border: 1px solid #ddd; }");
            out.println("th, td { padding: 12px; text-align: left; }");
            out.println("th { background-color: #f2f2f2; }");
            out.println("tr:nth-child(even) { background-color: #f9f9f9; }");
            out.println("tr:hover { background-color: #f1f1f1; }");
            out.println("</style>");

            out.println("<h3><a href='displayproducts.html' style='color: green; text-decoration: underline; cursor: pointer;'>Click here to view other options</a></h3>");
            out.println("<table>");
            out.println("<tr>");
            out.println("<th>Id</th>");
            out.println("<th>Brand Name</th>");
            out.println("<th>Product Name</th>");
            out.println("<th>Product Category</th>");
            out.println("<th>Unit Price</th>");
            out.println("<th>Quantity</th>");
            out.println("<th>Manufacturing Date</th>");
            out.println("<th>Expiry Date</th>");
            out.println("</tr>");

            while (rs.next()) 
            {
                out.println("<tr>");
                out.println("<td>" + rs.getString("inventory_id") + "</td>");
                out.println("<td>" + rs.getString("brand_name") + "</td>");
                out.println("<td>" + rs.getString("product_name") + "</td>");
                out.println("<td>" + rs.getString("product_category") + "</td>");
                out.println("<td>" + rs.getString("unit_price") + "</td>");
                out.println("<td>" + rs.getString("quantity") + "</td>");
                out.println("<td>" + rs.getString("manufacturing_date") + "</td>");
                out.println("<td>" + rs.getString("expiry_date") + "</td>");
                out.println("</tr>");
            }

            out.println("</table>");

            con.close();
        } 
        catch (Exception e) 
        {
            out.println("Error: " + e.getMessage());
        }
    }
%>
