<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="java.io.*" %>
<%@ page import="java.text.SimpleDateFormat" %>
<!DOCTYPE html>
<html>
<head>
    <title>Uploaded Reports</title>
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
    <h2>Uploaded Reports for You</h2>
    <table>
        <thead>
            <tr>
                <th>Original Filename</th>
                <th>Agronomist Name</th>
                <th>Upload Date</th>
                <th>Action</th>
            </tr>
        </thead>
        <tbody>
            <%
                String farmerUsername = (String) session.getAttribute("username");
                Connection conn = null;
                PreparedStatement pstmt = null;
                ResultSet rs = null;
                SimpleDateFormat readableFormat = new SimpleDateFormat("MMMM d, yyyy 'at' h:mm a");
                try {
                    Class.forName("com.mysql.cj.jdbc.Driver");
                    conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/crop?useSSL=false&allowPublicKeyRetrieval=true", "root", "windows");
                    String sql = "SELECT r.original_filename, r.upload_date, r.unique_filename, l.full_name " +
                                "FROM reports r " +
                                "JOIN login l ON r.agronomist_username = l.username " +
                                "WHERE r.farmer_username = ? " +
                                "ORDER BY r.upload_date DESC";
                    pstmt = conn.prepareStatement(sql);
                    pstmt.setString(1, farmerUsername);
                    rs = pstmt.executeQuery();
                    while (rs.next()) {
                        String originalFilename = rs.getString("original_filename");
                        String agronomistName = rs.getString("full_name");
                        java.sql.Timestamp uploadDate = rs.getTimestamp("upload_date");
                        String formattedUploadDate = readableFormat.format(uploadDate);
                        String uniqueFilename = rs.getString("unique_filename");
            %>
                <tr>
                    <td><%= originalFilename %></td>
                    <td><%= agronomistName %></td>
                    <td><%= formattedUploadDate %></td>
                    <td>
                        <a href="download.jsp?filename=<%= uniqueFilename %>">Download</a>
                    </td>
                </tr>
            <% 
                    }
                } catch (Exception e) {
                    out.println("<tr><td colspan='4'>Error retrieving files: " + e.getMessage() + "</td></tr>");
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