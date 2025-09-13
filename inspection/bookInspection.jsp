<%@page import="java.sql.*, java.util.*"%>
<%@page contentType="text/plain" pageEncoding="UTF-8"%>
<%
    String address = request.getParameter("address");
    String username = (String) session.getAttribute("username");
    String fullName = (String) session.getAttribute("full_name");

    if (username == null || fullName == null)
        out.print("Session attributes are missing. Please log in again.");
    else if (address != null && !address.trim().isEmpty()) 
    {
        try 
        {
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

            if (userId != -1) 
            {
                // Get farmer_id from farmer table using user_id
                String queryFarmerId = "SELECT farmer_id FROM farmer WHERE user_id = ?";
                PreparedStatement psFarmerId = con.prepareStatement(queryFarmerId);
                psFarmerId.setInt(1, userId);
                ResultSet rsFarmerId = psFarmerId.executeQuery();
                int farmerId = -1;
                if (rsFarmerId.next())
                    farmerId = rsFarmerId.getInt("farmer_id");

                if (farmerId != -1) 
                {
                    // Insert booking details into AgronomistVisit table
                    String query = "INSERT INTO AgronomistVisit (farmer_id, full_name, address) VALUES (?, ?, ?)";
                    PreparedStatement ps = con.prepareStatement(query);
                    ps.setInt(1, farmerId);
                    ps.setString(2, fullName);
                    ps.setString(3, address);
                    ps.executeUpdate();
                    out.print("Booking successful! Visiting date will be notified shortly! Please refresh after clicking ok");
                } 
                else
                    out.print("Farmer ID not found. Please try again.");
            } 
            else
                out.print("User ID not found. Please try again.");

            con.close();
        } 
        catch (SQLException e) 
        {
            e.printStackTrace();
            out.print("Error occurred while booking. Please try again. " + e.getMessage());
        } 
        catch (ClassNotFoundException e) 
        {
            e.printStackTrace();
            out.print("Database driver not found. Please contact support.");
        }
    } 
    else 
    {
        out.print("Address cannot be empty.");
    }
%>
