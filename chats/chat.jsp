<%@page import="java.sql.*, java.util.*"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <title>Chat</title>
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <style>
        body {
            font-family: Arial, sans-serif;
            background-color: #f4f4f9;
            margin: 0;
            padding: 18px;
        }

        h2 {
            color: #333;
        }

        select, textarea, button {
            display: block;
            margin: 10px 0;
            padding: 10px;
            width: 100%;
            max-width: 400px;
            font-size: 16px;
            border-radius: 5px;
            border: 1px solid #ccc;
        }

        select:focus, textarea:focus, button:focus {
            outline: none;
            border-color: #007BFF;
        }

        button {
            background-color: #1eb7e6;
            color: white;
            cursor: pointer;
        }

        button:hover {
            background-color: #14f344;
            transition: background-color 0.4s;
        }

        #messageView {
            border: 1px solid #ccc;
            height: 300px;
            overflow-y: scroll;
            background-color: white;
            padding: 10px;
            margin-bottom: 10px;
            max-width: 600px;
        }

        .message {
            margin: 5px 0;
            padding: 10px;
            border-radius: 5px;
            background-color: #e9e9eb;
        }

        .message.sender {
            background-color: #d1e7dd;
        }

        .message.receiver {
            background-color: #f8d7da;
        }
    </style>
    <script>
        $(document).ready(function() {
            $('#userSelect').change(function() {
                var selectedUser = $(this).val();
                if (selectedUser) {
                    loadMessages(selectedUser);
                }
            });

            $('#sendMessageBtn').click(function() {
                var selectedUser = $('#userSelect').val();
                var message = $('#messageInput').val();
                if (selectedUser && message) {
                    sendMessage(selectedUser, message);
                }
            });
        });

        function loadMessages(selectedUser) {
            $.ajax({
                url: 'fetchMessages.jsp',
                type: 'GET',
                data: { receiver: selectedUser },
                success: function(data) {
                    $('#messageView').html(data);
                }
            });
        }

        function sendMessage(receiver, message) {
            $.ajax({
                url: 'sendMessage.jsp',
                type: 'POST',
                data: { receiver: receiver, message: message },
                success: function() {
                    $('#messageInput').val('');
                    loadMessages(receiver);
                }
            });
        }
    </script>
</head>
<body>
    <h2>Chat</h2>
    <select id="userSelect">
        <option value="">Select Unique UserID</option>
        <%
            String currentUser = (String) session.getAttribute("username");
            String userRole = (String) session.getAttribute("user_role"); // Assuming user_role is stored in session

            String query;
            if ("f".equals(userRole)) {
                query = "SELECT username FROM login WHERE user_role = 's'";
            } else if ("s".equals(userRole)) {
                query = "SELECT username FROM login WHERE user_role = 'f'";
            } else {
                query = "";
            }

            if (!query.isEmpty()) {
                try {
                    Class.forName("com.mysql.cj.jdbc.Driver");
                    Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/crop?useSSL=false&allowPublicKeyRetrieval=true", "root", "windows");
                    Statement stmt = con.createStatement();
                    ResultSet rs = stmt.executeQuery(query);

                    while (rs.next()) {
                        String username = rs.getString("username");
        %>
                        <option value="<%= username %>"><%= username %></option>
        <%
                    }
                    con.close();
                } catch (Exception e) {
                    e.printStackTrace();
                }
            }
        %>
    </select>

    <div id="messageView">
        <!-- Messages will be loaded here -->
    </div>

    <textarea id="messageInput" placeholder="Type your message..."></textarea>
    <button id="sendMessageBtn">Send</button>
</body>
</html>
