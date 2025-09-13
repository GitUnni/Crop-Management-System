<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.io.*" %>
<%@ page import="java.util.UUID" %>
<%@ page import="java.sql.*" %>
<%@ page import="jakarta.servlet.http.Part" %>
<!DOCTYPE html>
<html>
<head>
    <title>Upload Report for Farmer</title>
    <style>
        body {
        font-family: Arial, sans-serif;
        background-color: #f0f8ff;
        display: flex;
        justify-content: center;
        align-items: center;
        height: 100vh;
        margin: 0;
    }

    .upload-container {
        background-color: #ffffff;
        padding: 20px;
        border-radius: 8px;
        box-shadow: 0 4px 8px rgba(0, 0, 0, 0.2);
        width: 300px;
        text-align: center;
    }

    h2 {
        color: #333;
        margin-bottom: 15px;
    }

    label {
        font-weight: bold;
        color: #555;
    }

    input[type="text"], input[type="file"], input[type="submit"] {
        width: 100%;
        margin-top: 10px;
        padding: 8px;
        border: 1px solid #ccc;
        border-radius: 4px;
    }

    input[type="submit"] {
        background-color: #4CAF50;
        color: white;
        cursor: pointer;
    }

    input[type="submit"]:hover {
        background-color: #45a049;
    }

    .success {
        color: green;
        margin-top: 10px;
    }

    .error {
        color: red;
        margin-top: 10px;
    }

    </style>
</head>
<body>
    <div class="upload-container">
        <h2>Upload Report for Farmer</h2>
        <form action="upload.jsp" method="post" enctype="multipart/form-data">
            <label>Farmer Username:</label>
            <input type="text" name="farmerUsername" placeholder="Enter username" required>
            <input type="file" name="file" required>
            <input type="submit" value="Upload Report">
        </form>
        <%
            if (request.getContentType() != null && request.getContentType().toLowerCase().contains("multipart/form-data")) {
                String farmerUsername = request.getParameter("farmerUsername");
                try {
                    // Get agronomist's information from session
                    String agronomistUsername = (String) session.getAttribute("username");
                    
                    // Upload path setup
                    String projectRoot = new File(application.getRealPath("/")).getParent();
                    String uploadPath = projectRoot + File.separator + "uploads";
                    File uploadDir = new File(uploadPath);
                    if (!uploadDir.exists()) uploadDir.mkdirs();
                    
                    // File handling
                    Part filePart = request.getPart("file");
                    String fileName = filePart.getSubmittedFileName();
                    String uniqueFileName = UUID.randomUUID().toString() + "_" + fileName;
                    File targetFile = new File(uploadDir, uniqueFileName);
                    String filePath = targetFile.getAbsolutePath();
                    
                    // Save the file
                    try (InputStream input = filePart.getInputStream();
                         FileOutputStream output = new FileOutputStream(targetFile)) {
                        byte[] buffer = new byte[8192];
                        int length;
                        while ((length = input.read(buffer)) > 0) {
                            output.write(buffer, 0, length);
                        }
                    }
                    
                    // Database insertion
                    String dbUrl = "jdbc:mysql://localhost:3306/crop?useSSL=false&allowPublicKeyRetrieval=true";
                    String dbUser = "root";
                    String dbPassword = "windows";
                    
                    Class.forName("com.mysql.cj.jdbc.Driver");
                    try (Connection conn = DriverManager.getConnection(dbUrl, dbUser, dbPassword)) {
                        // Changed to use the reports table instead of report
                        String sql = "INSERT INTO reports (agronomist_username, farmer_username, original_filename, unique_filename, file_path) VALUES (?, ?, ?, ?, ?)";
                        try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
                            pstmt.setString(1, agronomistUsername);
                            pstmt.setString(2, farmerUsername);
                            pstmt.setString(3, fileName);
                            pstmt.setString(4, uniqueFileName);
                            pstmt.setString(5, filePath);
                            pstmt.executeUpdate();
                        }
                    }
                    %>
                    <p class="success">File uploaded successfully!</p>
                    <%
                } catch (Exception e) {
                    %>
                    <p class="error">Error: <%= e.getMessage() %></p>
                    <%
                }
            }
        %>
        
    </div>
</body>
</html>