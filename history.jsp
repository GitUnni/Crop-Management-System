<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<!DOCTYPE html>
<html>
<head>
    <title>Sent Reports History</title>
    <style>
        body {
        font-family: Arial, sans-serif;
        background-color: #fafafa;
        padding: 20px;
    }

    h2 {
        color: #333;
        text-align: center;
    }

    table {
        width: 100%;
        border-collapse: collapse;
        margin-top: 20px;
    }

    table, th, td {
        border: 1px solid #ddd;
    }

    th, td {
        padding: 12px;
        text-align: left;
    }

    th {
        background-color: #f2f2f2;
        color: #333;
    }

    td a {
        color: #007bff;
        text-decoration: none;
    }

    td a:hover {
        text-decoration: underline;
    }

    tr:nth-child(even) {
        background-color: #f9f9f9;
    }

    </style>
</head>
<body>
    <h2>Sent Reports History</h2>
    <table>
        <thead>
            <tr>
                <th>Report ID</th>
                <th>Farmer Username</th>
                <th>Farmer Full Name</th>
                <th>Submission Date</th>
                <th>Action</th>
            </tr>
        </thead>
        <tbody>
            <%
                // Get agronomist's username from session
                String agronomistUsername = (String) session.getAttribute("username");

                Connection conn = null;
                PreparedStatement pstmt = null;
                ResultSet rs = null;
                try {
                    Class.forName("com.mysql.cj.jdbc.Driver");
                    conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/crop?useSSL=false&allowPublicKeyRetrieval=true", "root", "windows");

                    // SQL query to fetch report history for the agronomist with farmer's details
                    String sql = "SELECT r.report_id, r.farmer_username, l.full_name, r.upload_date, r.unique_filename " +
                                 "FROM reports r " +
                                 "JOIN login l ON r.farmer_username = l.username " +
                                 "WHERE r.agronomist_username = ? " +
                                 "ORDER BY r.upload_date DESC";
                    
                    pstmt = conn.prepareStatement(sql);
                    pstmt.setString(1, agronomistUsername);
                    rs = pstmt.executeQuery();

                    // Loop through the result set and display each report
                    while (rs.next()) {
                        int reportId = rs.getInt("report_id");
                        String farmerUsername = rs.getString("farmer_username");
                        String farmerFullName = rs.getString("full_name");
                        Timestamp uploadDate = rs.getTimestamp("upload_date");
                        String uniqueFilename = rs.getString("unique_filename");
            %>
                <tr>
                    <td><%= reportId %></td>
                    <td><%= farmerUsername %></td>
                    <td><%= farmerFullName %></td>
                    <td><%= uploadDate %></td>
                    <td>
                        <a href="download.jsp?filename=<%= uniqueFilename %>">Download</a>
                    </td>
                </tr>
            <%
                    }
                } catch (Exception e) {
                    out.println("<tr><td colspan='5'>Error retrieving reports: " + e.getMessage() + "</td></tr>");
                } finally {
                    if (rs != null) rs.close();
                    if (pstmt != null) pstmt.close();
                    if (conn != null) conn.close();
                }
            %>
        </tbody>
    </table>
</body>
</html>
