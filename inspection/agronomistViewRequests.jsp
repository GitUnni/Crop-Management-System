<%@page import="java.sql.*, java.util.*"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
   <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.2/css/all.min.css" />  <!-- tick icon-->
    <title>Agronomist - View Requests</title>
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
        input[type="datetime-local"], button {
            display: block;
            margin: 10px 0;
            padding: 10px;
            width: 90%;
            max-width: 200px;
            font-size: 16px;
            border-radius: 5px;
            border: 1px solid #ccc;
        }
        button {
            background-color: #007BFF;
            color: white;
            cursor: pointer;
            transition: background-color 0.4s;
        }
        button:hover {
            background-color: #4CAF50;
        }
    </style>
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <script>
        function updateVisitDate(visitId) {
            var visitDate = document.getElementById('visitDate_' + visitId).value;
            if (visitDate) {
                $.post('updateVisitDate.jsp', { id: visitId, visitDate: visitDate }, function(response) {
                    alert(response);
                    location.reload();
                });
            } else
                alert('Please select a visit date.');
        }
    </script>
</head>
<body>
    <h2>Agronomist - View Requests</h2>
    <table>
        <tr>
            <th>Farmer ID</th>
            <th>Username</th>
            <th>Full Name</th>
            <th>Address</th>
            <th>Booking Date</th>
            <th>Visit Date</th>
            <th>Action</th>
        </tr>
        <%
            try {
                Class.forName("com.mysql.cj.jdbc.Driver");
                Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/crop?useSSL=false&allowPublicKeyRetrieval=true", "root", "windows");

                // SQL query to join AgronomistVisit, farmer, and login tables
                String query = "SELECT av.id, f.farmer_id, l.username, av.full_name, av.address, " +
                               "DATE_FORMAT(av.booking_date, '%d-%b-%Y') AS formatted_booking_date, " +
                               "DATE_FORMAT(av.visit_date, '%d-%b-%Y') AS formatted_visit_date " +
                               "FROM AgronomistVisit av " +
                               "JOIN farmer f ON av.farmer_id = f.farmer_id " +
                               "JOIN login l ON f.user_id = l.user_id";

                Statement stmt = con.createStatement();
                ResultSet rs = stmt.executeQuery(query);

                while (rs.next()) {
                    int id = rs.getInt("id");
                    String farmerId = rs.getString("farmer_id");
                    String username = rs.getString("username");
                    String fullName = rs.getString("full_name");
                    String address = rs.getString("address");
                    String bookingDate = rs.getString("formatted_booking_date");
                    String visitDate = rs.getString("formatted_visit_date");
        %>
        <tr>
            <td><%= farmerId %></td>
            <td><%= username %></td>
            <td><%= fullName %></td>
            <td><%= address %></td>
            <td><%= bookingDate %></td>
            <td><%= visitDate != null ? visitDate : "Pending" %></td>
            <td>
                <% if (visitDate == null) { %>
                <input type="datetime-local" required id="visitDate_<%= id %>">
                <button onclick="updateVisitDate(<%= id %>)">Confirm</button>
                <% } else { %>
                <i class="fa-solid fa-check"></i>
                <% } %>
            </td>
        </tr>
        <%
                }
                con.close();
            } catch (Exception e) {
                e.printStackTrace();
            }
        %>
    </table>
</body>
</html>
