<%@ page import="java.sql.*, java.text.SimpleDateFormat" %>
<%
    Integer supplierId = (Integer) session.getAttribute("supplier_id");
    if (supplierId != null) {
%>
    <style>
        table {
            width: 100%;
            border-collapse: collapse;
            font-family: Arial, sans-serif;
            margin: 20px 0;
            box-shadow: 0 0 15px rgba(0, 0, 0, 0.1);
        }
        th, td {
            padding: 12px 15px;
            text-align: left;
        }
        th {
            background-color: #4CAF50;
            color: white;
        }
        tr:nth-child(even) {
            background-color: #f2f2f2;
        }
        tr:nth-child(odd) {
            background-color: #ffffff;
        }
        tr:hover {
            background-color: aliceblue;
        }
        .table-title {
            font-size: 24px;
            font-weight: bold;
            color: #333;
            margin-bottom: 10px;
            text-align: center;
        }
    </style>

    <div class="table-title">Accepted Crop Sale Requests</div>
    <table>
        <tr>
            <th>Farmer Username</th>
            <th>Farmer Name</th>
            <th>Negotiable Price</th>
            <th>Sold Price</th>
            <th>Request Date</th>
            <th>Time of Pickup</th>
            <th>Quantity</th>
            <th>Unit</th>
        </tr>
<%
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/crop?useSSL=false&allowPublicKeyRetrieval=true", "root", "windows");

            String query = "SELECT login.username AS farmer_username, login.full_name AS farmer_full_name, " +
                           "crop_sales_requests.negotiable_price, crop_sales_requests.sold_price, crop_sales_requests.request_date, " +
                           "crop_sales_requests.time_of_pickup, crop_sales_requests.quantity, crop_sales_requests.unit " +
                           "FROM crop_sales_requests " +
                           "JOIN farmer ON crop_sales_requests.farmer_id = farmer.farmer_id " +
                           "JOIN login ON farmer.user_id = login.user_id " +
                           "WHERE crop_sales_requests.supplier_id = ? AND crop_sales_requests.status = 'Accepted'";

            PreparedStatement pst = con.prepareStatement(query);
            pst.setInt(1, supplierId);
            ResultSet rs = pst.executeQuery();

            SimpleDateFormat dateFormat = new SimpleDateFormat("dd MMM yyyy, hh:mm a");

            while (rs.next()) {
                String farmerUsername = rs.getString("farmer_username");
                String farmerFullName = rs.getString("farmer_full_name");
                double negotiablePrice = rs.getDouble("negotiable_price");
                double soldPrice = rs.getDouble("sold_price");
                Timestamp requestDate = rs.getTimestamp("request_date");
                Timestamp timeOfPickup = rs.getTimestamp("time_of_pickup");
                double quantity = rs.getDouble("quantity");
                String unit = rs.getString("unit");

                String formattedRequestDate = requestDate != null ? dateFormat.format(requestDate) : "N/A";
                String formattedPickupTime = timeOfPickup != null ? dateFormat.format(timeOfPickup) : "N/A";
%>
        <tr>
            <td><%= farmerUsername %></td>
            <td><%= farmerFullName %></td>
            <td>Rs <%= negotiablePrice %></td>
            <td>Rs <%= soldPrice %></td>
            <td><%= formattedRequestDate %></td>
            <td><%= formattedPickupTime %></td>
            <td><%= quantity %></td>
            <td><%= unit %></td>
        </tr>
<%
            }
            con.close();
        } catch (Exception e) {
            out.println("Error: " + e.getMessage());
        }
    } else {
        out.println("Supplier not logged in.");
    }
%>
    </table>
