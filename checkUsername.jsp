<%@ page import="java.sql.*" %>
<%
String username = request.getParameter("username");
if (username != null && !username.isEmpty()) 
{
    try 
    {
        Class.forName("com.mysql.cj.jdbc.Driver");
        Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/crop?useSSL=false&allowPublicKeyRetrieval=true", "root", "windows");
        String usernameCheckQuery = "SELECT * FROM login WHERE username=?";
        PreparedStatement usernameCheckStmt = con.prepareStatement(usernameCheckQuery);
        usernameCheckStmt.setString(1, username);
        ResultSet usernameCheckResult = usernameCheckStmt.executeQuery();

        if (usernameCheckResult.next())
            out.println("Username already taken");

        usernameCheckResult.close();
        usernameCheckStmt.close();
        con.close();
    } 
    catch (Exception e) 
    {
        out.println("Error: " + e.getMessage());
    }
} 
%>