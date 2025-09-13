<%@page import="java.sql.*, java.util.*"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <title>View Booking Status</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            background-color: #f4f4f9;
            margin: 0;
            padding: 20px;
        }
        table {
            width: 100%;
            max-width: 600px;
            border-collapse: collapse;
            margin: 20px 0;
        }
        th, td {
            border: 1px solid #ccc;
            padding: 10px;
            text-align: left;
        }
        th {
            background-color: #007BFF;
            color: white;
        }
    </style>
</head>
<body>
    <h2>Booking Status</h2>
    <table>
        <tr>
            <th>Farmer ID</th>
            <th>Address</th>
            <th>Booking Date</th>
            <th>Visit Date</th>
        </tr>
        <%
            String username = (String) session.getAttribute("username");
            System.out.println("Username from session: " + username);
            try {
                Class.forName("com.mysql.cj.jdbc.Driver");
                Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/crop?useSSL=false&allowPublicKeyRetrieval=true", "root", "windows");

                // Get user_id from login table using username
                String queryUserId = "SELECT user_id FROM login WHERE username = ?";
                PreparedStatement psUserId = con.prepareStatement(queryUserId);
                psUserId.setString(1, username);
                ResultSet rsUserId = psUserId.executeQuery();
                int userId = -1;
                if (rsUserId.next())
                    userId = rsUserId.getInt("user_id");

                System.out.println("User ID: " + userId);

                if (userId != -1) {
                    // Get farmer_id from farmer table using user_id
                    String queryFarmerId = "SELECT farmer_id FROM farmer WHERE user_id = ?";
                    PreparedStatement psFarmerId = con.prepareStatement(queryFarmerId);
                    psFarmerId.setInt(1, userId);
                    ResultSet rsFarmerId = psFarmerId.executeQuery();
                    int farmerId = -1;
                    if (rsFarmerId.next())
                        farmerId = rsFarmerId.getInt("farmer_id");

                    System.out.println("Farmer ID: " + farmerId);

                    if (farmerId != -1) {
                        // Query the AgronomistVisit table using farmer_id with formatted dates
                        String query = "SELECT farmer_id, address, " +
                                       "DATE_FORMAT(booking_date, '%d-%b-%Y') AS formatted_booking_date, " +
                                       "DATE_FORMAT(visit_date, '%d-%b-%Y') AS formatted_visit_date " +
                                       "FROM AgronomistVisit WHERE farmer_id = ?";
                        PreparedStatement ps = con.prepareStatement(query);
                        ps.setInt(1, farmerId);
                        ResultSet rs = ps.executeQuery();

                        boolean hasResults = false;
                        while (rs.next()) {
                            hasResults = true;
                            String id = rs.getString("farmer_id");
                            String address = rs.getString("address");
                            String bookingDate = rs.getString("formatted_booking_date");
                            String visitDate = rs.getString("formatted_visit_date");
        %>
        <tr>
            <td><%= id %></td>
            <td><%= address %></td>
            <td><%= bookingDate %></td>
            <td><%= visitDate != null ? visitDate : "Pending" %></td>
        </tr>
        <%
                        }
                        if (!hasResults)
                            out.print("<tr><td colspan='4'>No bookings found for this farmer.</td></tr>");

                    } else
                        out.print("<tr><td colspan='4'>Farmer ID not found. Please log in again.</td></tr>");

                } 
                else
                    out.print("<tr><td colspan='4'>User ID not found. Please log in again.</td></tr>");

                con.close();
            } 
            catch (Exception e) 
            {
                e.printStackTrace();
                out.print("<tr><td colspan='4'>Error occurred while retrieving booking status. Please try again.</td></tr>");
            }
        %>
    </table>
</body>
</html>