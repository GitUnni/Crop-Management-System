<%@page import="java.sql.*" %>
<%@page import="java.io.*,java.util.*"%>
<%@ page import="java.text.SimpleDateFormat" %>

<%
    String act = request.getParameter("submit");
    if(act != null && act.equals("Login"))  //Login
    {
        try 
        {
            String name = request.getParameter("textname");
            String psswd = request.getParameter("textpsswd");
            String value = request.getParameter("user");
            Class.forName("com.mysql.cj.jdbc.Driver");
            Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/crop?useSSL=false&allowPublicKeyRetrieval=true", "root", "windows");
            String query = "SELECT * FROM login WHERE username=? AND password=? AND user_role=?";
            PreparedStatement pst = con.prepareStatement(query);
            pst.setString(1, name);
            pst.setString(2, psswd);
            pst.setString(3, value);
            ResultSet rs = pst.executeQuery();

            if (rs.next()) 
            {
                int userId = rs.getInt("user_id");
                String userRoleFromDB = rs.getString("user_role");
                String fullname = rs.getString("full_name");

                if (value.equals("f") && userRoleFromDB.equals("f")) 
                {
                    // Fetch farmer_id from farmer table
                    String farmerQuery = "SELECT farmer_id FROM farmer WHERE user_id=?";
                    PreparedStatement farmerPst = con.prepareStatement(farmerQuery);
                    farmerPst.setInt(1, userId);
                    ResultSet farmerRs = farmerPst.executeQuery();

                    if (farmerRs.next()) 
                    {
                        int farmerId = farmerRs.getInt("farmer_id");
                        session.setAttribute("farmer_id", farmerId);
                        session.setAttribute("user_id", userId);
                        session.setAttribute("username", name);
                        session.setAttribute("full_name", fullname);
                        session.setAttribute("user_role", value);
                        response.sendRedirect("farmers.jsp");
                    } 
                    else 
                        out.println("<h2>Farmer record not found.</h2><a href=\"login.html\"><h3>Click here!</a> to try again</h3>");
                } 
                else if (value.equals("s") && userRoleFromDB.equals("s")) 
                {
                    // Fetch supplier_id from supplier table
                    String supplierQuery = "SELECT supplier_id FROM supplier WHERE user_id=?";
                    PreparedStatement supplierPst = con.prepareStatement(supplierQuery);
                    supplierPst.setInt(1, userId);
                    ResultSet supplierRs = supplierPst.executeQuery();
                    if (supplierRs.next()) 
                    {
                        int supplierId = supplierRs.getInt("supplier_id");
                        session.setAttribute("supplier_id", supplierId);
                        session.setAttribute("user_id", userId);
                        session.setAttribute("username", name);
                        session.setAttribute("full_name", fullname);
                        session.setAttribute("user_role", value);
                        response.sendRedirect("suppliers.jsp");
                    }
                    else 
                        out.println("<h2>Supplier record not found.</h2><a href=\"login.html\"><h3>Click here!</a> to try again</h3>");
                } 
                else if (value.equals("a") && userRoleFromDB.equals("a")) 
                {
                    session.setAttribute("user_id", userId);
                    session.setAttribute("username", name);
                    session.setAttribute("full_name", fullname);
                    session.setAttribute("user_role", value);
                    response.sendRedirect("agronomists.jsp");
                } 
                else
                    out.println("<h2>Wrong user role</h2><a href=\"login.html\"><h3>Click here!</a> to try again</h3>");
            }
            else
                out.println("<h2 style='color: red; text-align: center;'>Wrong username or password</h2><a href='login.html' style='display: block; text-align: center; font-size: 18px; color: blue; text-decoration: none; margin-top: 10px;'><h3>Click here to try again</h3></a>");

            con.close();
        } 
        catch (Exception e) 
        {
            out.println("Error: " + e.getMessage());
        }
    }
 
    else if (act != null && act.equals("SignUp")) //Farmer
    {
        try 
        {
            String value = request.getParameter("user");
            String name = request.getParameter("textname");
            String psswd = request.getParameter("textpsswd");
            String fullname = request.getParameter("fullname");
            String phone = request.getParameter("phone");
            String farmloc = request.getParameter("farmloc");
            String farmsize = request.getParameter("farmsize");

            Class.forName("com.mysql.cj.jdbc.Driver");
            Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/crop?useSSL=false&allowPublicKeyRetrieval=true", "root", "windows");

        // Insert into the login table
            String loginQuery = "INSERT INTO login (username, password, full_name, phone_number, user_role) VALUES (?, ?, UPPER(?), ?, ?)";
            PreparedStatement loginPst = con.prepareStatement(loginQuery, Statement.RETURN_GENERATED_KEYS);
            loginPst.setString(1, name);
            loginPst.setString(2, psswd);
            loginPst.setString(3, fullname);
            loginPst.setString(4, phone);
            loginPst.setString(5, value);
            loginPst.executeUpdate();

            // Get the generated user_id
            ResultSet rs = loginPst.getGeneratedKeys();
            int userId = -1;
            if (rs.next())
                userId = rs.getInt(1);
            if (userId != -1) 
            {
            // Insert into the farmer table
                String farmerQuery = "INSERT INTO farmer (farm_location, farm_size, user_id) VALUES (?, ?, ?)";
                PreparedStatement farmerPst = con.prepareStatement(farmerQuery, Statement.RETURN_GENERATED_KEYS);
                farmerPst.setString(1, farmloc);
                farmerPst.setString(2, farmsize);
                farmerPst.setInt(3, userId);

                int rowsInserted = farmerPst.executeUpdate();
                if (rowsInserted > 0)
                {
                    out.println("<h2 style=\"color:green; font-family: 'Courier New', Courier, monospace; font-size: 30px; text-align:center; font-weight: bold; background-color: #f0f0f0; padding: 20px; border-radius: 10px; box-shadow: 2px 2px 10px rgba(0, 0, 0, 0.1);\">Registered successfully!</h2>");
               %>
               <script>
                    setTimeout(function(){
                        window.location.href = "logout.jsp";
                    }, 2000); // 1000 milliseconds = 1 second
                </script>
            <%
                }
                else
                    out.println("<h2>Error registering user.</h2><a href=\"login.html\"><h3>Click here!</a> to try again!</h3>");
            } 
            else 
                out.println("<h2>Error generating user_id.</h2>");
            con.close();
        } 
        catch (Exception e) 
        {
            out.println("Error: " + e.getMessage());
        }
    }
    
    else if (act != null && act.equals("Sign Up")) //Supplier
    {
        try 
        {
            String value = request.getParameter("user");
            String name = request.getParameter("textname");
            String psswd = request.getParameter("textpsswd");
            String fullname = request.getParameter("fullname");
            String phone = request.getParameter("phone");
            String email = request.getParameter("email");

            Class.forName("com.mysql.cj.jdbc.Driver");
            Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/crop?useSSL=false&allowPublicKeyRetrieval=true", "root", "windows");

        // Insert into the login table
            String loginQuery = "INSERT INTO login (username, password, full_name, phone_number, user_role) VALUES (?, ?, UPPER(?), ?, ?)";
            PreparedStatement loginPst = con.prepareStatement(loginQuery, Statement.RETURN_GENERATED_KEYS);
            loginPst.setString(1, name);
            loginPst.setString(2, psswd);
            loginPst.setString(3, fullname);
            loginPst.setString(4, phone);
            loginPst.setString(5, value);
            loginPst.executeUpdate();

            // Get the generated user_id
            ResultSet rs = loginPst.getGeneratedKeys();
            int userId = -1;
            if (rs.next())
                userId = rs.getInt(1);
            if (userId != -1) 
            {
            // Insert into the supplier table
                String supplierQuery = "INSERT INTO supplier (email, user_id ) VALUES (?, ?)";
                PreparedStatement supplierPst = con.prepareStatement(supplierQuery, Statement.RETURN_GENERATED_KEYS);
                supplierPst.setString(1, email);
                supplierPst.setInt(2, userId);

                int rowsInserted = supplierPst.executeUpdate();
                if (rowsInserted > 0)
                {
                    out.println("<h2 style=\"color:green; font-family: 'Courier New', Courier, monospace; font-size: 30px; text-align:center; font-weight: bold; background-color: #f0f0f0; padding: 20px; border-radius: 10px; box-shadow: 2px 2px 10px rgba(0, 0, 0, 0.1);\">Registered successfully!</h2>");
                    %>
                    <script>
                    setTimeout(function(){
                        window.location.href = "logout.jsp";
                    }, 2000); // 1000 milliseconds = 1 second
                    </script>
                <%
                }
                else
                    out.println("<h2>Error registering user.</h2><a href=\"login.html\"><h3>Click here!</a> to try again!</h3>");
            } 
            else 
                out.println("<h2>Error generating user_id.</h2>");
            con.close();
        } 
        catch (Exception e) 
        {
            out.println("Error: " + e.getMessage());
        }
    }
    
    else if (act != null && act.equals("Sign up")) //Agronomist
    {
        try 
        {
            String value = request.getParameter("user");
            String name = request.getParameter("textname");
            String psswd = request.getParameter("textpsswd");
            String fullname = request.getParameter("fullname");
            String phone = request.getParameter("phone");
            String email = request.getParameter("email");
            String specialization = request.getParameter("specialization");
            String yearsofexp = request.getParameter("yearsofexp");

            Class.forName("com.mysql.cj.jdbc.Driver");
            Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/crop?useSSL=false&allowPublicKeyRetrieval=true", "root", "windows");

        // Insert into the login table
            String loginQuery = "INSERT INTO login (username, password, full_name, phone_number, user_role) VALUES (?, ?, UPPER(?), ?, ?)";
            PreparedStatement loginPst = con.prepareStatement(loginQuery, Statement.RETURN_GENERATED_KEYS);
            loginPst.setString(1, name);
            loginPst.setString(2, psswd);
            loginPst.setString(3, fullname);
            loginPst.setString(4, phone);
            loginPst.setString(5, value);
            loginPst.executeUpdate();

            // Get the generated user_id
            ResultSet rs = loginPst.getGeneratedKeys();
            int userId = -1;
            if (rs.next())
                userId = rs.getInt(1);
            if (userId != -1) 
            {
            // Insert into the agronomist table
                String agronomistQuery = "INSERT INTO agronomist (email, specialization, years_of_exp, user_id) VALUES (?, ?, ?, ?)";
                PreparedStatement agronomistPst = con.prepareStatement(agronomistQuery, Statement.RETURN_GENERATED_KEYS);
                agronomistPst.setString(1, email);
                agronomistPst.setString(2, specialization);
                agronomistPst.setString(3, yearsofexp);
                agronomistPst.setInt(4, userId);

                int rowsInserted = agronomistPst.executeUpdate();
                if (rowsInserted > 0)
                {
                    out.println("<h2 style=\"color:green; font-family: 'Courier New', Courier, monospace; font-size: 30px; text-align:center; font-weight: bold; background-color: #f0f0f0; padding: 20px; border-radius: 10px; box-shadow: 2px 2px 10px rgba(0, 0, 0, 0.1);\">Registered successfully!</h2>");
                    %>
                    <script>
                    setTimeout(function(){
                        window.location.href = "logout.jsp";
                    }, 2000); // 1000 milliseconds = 1 second
                    </script>
                <%
                }
                else
                    out.println("<h2>Error registering user.</h2><a href=\"login.html\"><h3>Click here!</a> to try again!</h3>");
            } 
            else 
                out.println("<h2>Error generating user_id.</h2>");
            con.close();
        } 
        catch (Exception e) 
        {
            out.println("Error: " + e.getMessage());
        }
    }
    
    else if (act != null && act.equals("ChangePassword")) //Change Password
    {
        try 
        {
            String origPsswd = request.getParameter("originalPassword");
            String newPsswd = request.getParameter("newPassword");
            String username = (String) session.getAttribute("username");
            Class.forName("com.mysql.cj.jdbc.Driver");
            Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/crop?useSSL=false&allowPublicKeyRetrieval=true", "root", "windows");

        // Update login table
            String loginQuery = "UPDATE login SET password = ? WHERE username = ? AND password = ?";
            PreparedStatement loginPst = con.prepareStatement(loginQuery);
            loginPst.setString(1, newPsswd);
            loginPst.setString(2, username);
            loginPst.setString(3, origPsswd);
            int rowsUpdated = loginPst.executeUpdate();

            if (rowsUpdated > 0) 
            {
 %>
            <h2 style="color: white; background-color: green; font-size: 24px; font-family: Arial, sans-serif; text-align: center; padding: 20px; border: 2px solid darkgreen; border-radius: 10px; box-shadow: 2px 2px 12px rgba(0, 0, 0, 0.5); margin: 20px;">Password changed successfully!</h2>
            <script>
                setTimeout(function(){
                    window.location.href = "logout.jsp";
                }, 1000); // 1000 milliseconds = 1 second
            </script>
<%
            }
            else
                out.println("<h2>Error changing password. Please try again.</h2>");   
            con.close();
        } 
        catch (Exception e) 
        {
            out.println("Error: " + e.getMessage());
        }
    }
%>