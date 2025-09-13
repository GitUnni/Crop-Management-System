<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.sql.*" %>
<!DOCTYPE html>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <title>Farmer Requests</title>
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
    <style>
        body {
            font-family: Arial, sans-serif;
            margin: 20px;
            background-color: #f4f4f9;
        }
        table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 20px;
            background-color: white;
            box-shadow: 0 1px 3px rgba(0,0,0,0.2);
        }
        th, td {
            padding: 12px;
            text-align: left;
            border-bottom: 1px solid #ddd;
        }
        th {
            background-color: #007BFF;
            color: white;
        }
        tr:hover {
            background-color: #f5f5f5;
        }
        .accept-btn {
            background-color: #28a745;
            color: white;
            border: none;
            padding: 8px 16px;
            border-radius: 4px;
            cursor: pointer;
        }
        .accept-btn:hover {
            background-color: #218838;
        }
        .no-requests {
            text-align: center;
            padding: 20px;
            color: #666;
        }
    </style>
</head>
<body>
    <h2>Available Farmer Requests</h2>
    <%
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/crop?useSSL=false&allowPublicKeyRetrieval=true", "root", "windows");
            
            String query = "SELECT r.request_id, l.username, l.full_name, f.farm_location, r.crop_name, " +
                          "r.quantity, r.unit, r.negotiable_price " +
                          "FROM crop_sales_requests r " +
                          "JOIN farmer f ON r.farmer_id = f.farmer_id " +
                          "JOIN login l ON f.user_id = l.user_id " +
                          "WHERE r.status = 'Pending'";
                          
            PreparedStatement pst = con.prepareStatement(query);
            ResultSet rs = pst.executeQuery();

            boolean hasRequests = false;
    %>
    <table>
        <tr>
            <th>Farmer Name</th>
            <th>Username</th>
            <th>Farm Location</th>
            <th>Crop Name</th>
            <th>Quantity</th>
            <th>Unit</th>
            <th>Negotiable Price</th>
            <th>Action</th>
        </tr>
        <% while (rs.next()) { 
            hasRequests = true;
        %>
        <tr>
            <td><%= rs.getString("full_name") %></td>
            <td><%= rs.getString("username") %></td>
            <td><%= rs.getString("farm_location") %></td>
            <td><%= rs.getString("crop_name") %></td>
            <td><%= rs.getBigDecimal("quantity") %></td>
            <td><%= rs.getString("unit") %></td>
            <td>₹<%= rs.getBigDecimal("negotiable_price") %></td>
            <td>
                <button class="accept-btn" onclick="acceptRequest(<%= rs.getInt("request_id") %>)">Accept</button>
            </td>
        </tr>
        <% } %>
    </table>
    <% if (!hasRequests) { %>
        <div class="no-requests">
            <h3>No pending requests available at the moment.</h3>
        </div>
    <% }
        con.close();
    } catch (Exception e) {
        out.println("Error: " + e.getMessage());
    }
    %>

    <script>
    function acceptRequest(requestId) {
        Swal.fire({
            title: 'Enter Pickup Time',
            html: '<input type="datetime-local" id="pickupTime" class="swal2-input">',
            showCancelButton: true,
            confirmButtonText: 'Accept Request',
            preConfirm: () => {
                const pickupTime = document.getElementById('pickupTime').value;
                if (!pickupTime) {
                    Swal.showValidationMessage('Please enter pickup time');
                    return false;
                }
                return pickupTime;
            }
        }).then((result) => {
            if (result.isConfirmed) {
                $.post('acceptRequest.jsp', {
                    requestId: requestId,
                    pickupTime: result.value
                })
                .done(function(response) {
                    if (response.trim().startsWith("Success")) {
                        Swal.fire('Success', response, 'success')
                        .then(() => {
                            location.reload();
                        });
                    } else {
                        Swal.fire('Error', response, 'error');
                    }
                })
                .fail(function() {
                    Swal.fire('Error', 'Failed to process request', 'error');
                });
            }
        });
    }
    </script>
</body>
</html>