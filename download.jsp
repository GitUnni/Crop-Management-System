<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.io.*, java.sql.*" %>

<%
    String uniqueFilename = request.getParameter("filename");
    
    if (uniqueFilename == null || uniqueFilename.trim().isEmpty()) {
        response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Filename parameter is required.");
        return;
    }

    // Database configuration
    String dbUrl = "jdbc:mysql://localhost:3306/crop?useSSL=false&allowPublicKeyRetrieval=true";
    String dbUser = "root";
    String dbPassword = "windows";
    String filePath = null;

    // Retrieve the full file path from the database
    try (Connection conn = DriverManager.getConnection(dbUrl, dbUser, dbPassword)) {
        String sql = "SELECT file_path FROM reports WHERE unique_filename = ?";
        try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, uniqueFilename);
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    filePath = rs.getString("file_path");
                } else {
                    response.sendError(HttpServletResponse.SC_NOT_FOUND, "File not found");
                    return;
                }
            }
        }
    } catch (Exception e) {
        response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Error retrieving file path");
        return;
    }

    // Proceed with file download if file path is retrieved
    File file = new File(filePath);
    if (!file.exists()) {
        response.sendError(HttpServletResponse.SC_NOT_FOUND, "File not found");
        return;
    }

    response.setContentType("application/octet-stream");
    response.setHeader("Content-Disposition", "attachment;filename=\"" + file.getName() + "\"");
    response.setContentLength((int) file.length());

    try (FileInputStream fis = new FileInputStream(file);
         OutputStream os = response.getOutputStream()) {
        byte[] buffer = new byte[4096];
        int bytesRead;
        while ((bytesRead = fis.read(buffer)) != -1) {
            os.write(buffer, 0, bytesRead);
        }
    } catch (IOException e) {
        response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Error writing file to output stream");
    }
%>
