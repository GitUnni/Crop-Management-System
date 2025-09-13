<%@ page contentType="application/pdf" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.io.*" %>

<%
String reportId = request.getParameter("id");
if (reportId != null && !reportId.isEmpty()) {
    try {
        // Load the MySQL driver and establish a connection
        Class.forName("com.mysql.cj.jdbc.Driver");
        Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/crop?useSSL=false&allowPublicKeyRetrieval=true", "root", "windows");

        // Prepare the SQL statement to get the report details
        String query = "SELECT file_name, file_path FROM report WHERE report_id = ?";
        PreparedStatement stmt = con.prepareStatement(query);
        stmt.setInt(1, Integer.parseInt(reportId));
        ResultSet rs = stmt.executeQuery();

        if (rs.next()) {
            String fileName = rs.getString("file_name");
            String filePath = rs.getString("file_path");

            // Check if the file exists at the specified path
            File file = new File(filePath);
            if (file.exists()) {
                // Set headers to trigger file download
                response.setContentType("application/octet-stream");
                response.setHeader("Content-Disposition", "attachment; filename=\"" + fileName + "\"");
                response.setContentLength((int) file.length());

                // Read the file and write it to the response output stream
                FileInputStream fileInputStream = new FileInputStream(file);
                OutputStream outputStream = response.getOutputStream();

                byte[] buffer = new byte[4096];
                int bytesRead;
                while ((bytesRead = fileInputStream.read(buffer)) != -1) {
                    outputStream.write(buffer, 0, bytesRead);
                }

                fileInputStream.close();
                outputStream.flush();
                outputStream.close();
            } else {
                out.println("File not found.");
            }
        } else {
            out.println("Report not found.");
        }

        con.close();
    } catch (Exception e) {
        e.printStackTrace();
        out.println("An error occurred: " + e.getMessage());
    }
} else {
    out.println("Invalid report ID.");
}
%>
