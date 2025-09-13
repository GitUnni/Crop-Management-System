<%@ page import="java.sql.*" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.io.*" %>
<%
    // Set up logging to a file
    String logPath = application.getRealPath("/") + "debug.log";
    PrintWriter logWriter = new PrintWriter(new FileWriter(logPath, true));
    
    Connection con = null;
    PreparedStatement pst = null;
    PreparedStatement cropPst = null;
    ResultSet rs = null;
    ResultSet cropRs = null;
    
    try {
        logWriter.println("\n--- New Request " + new java.util.Date() + " ---");
        
        // Debug session information
        logWriter.println("Checking session...");
        if(session == null) {
            logWriter.println("Session is null!");
            response.sendRedirect("login.jsp");
            return;
        }
        
        Object farmerIdObj = session.getAttribute("farmer_id");
        logWriter.println("Session farmer_id: " + farmerIdObj);
        
        // Check if user is logged in
        if (farmerIdObj == null) {
            logWriter.println("No farmer_id in session - redirecting to login");
            response.sendRedirect("login.jsp");
            return;
        }
        
        // Print all session attributes
        logWriter.println("All session attributes:");
        java.util.Enumeration<String> sessionAttributes = session.getAttributeNames();
        while(sessionAttributes.hasMoreElements()) {
            String attributeName = sessionAttributes.nextElement();
            logWriter.println(attributeName + ": " + session.getAttribute(attributeName));
        }
        
        // Database connection
        String dbURL = "jdbc:mysql://localhost:3306/crop?useSSL=false&allowPublicKeyRetrieval=true";
        String dbUser = "root";
        String dbPass = "windows";
        
        int farmerId = (int) farmerIdObj;
        logWriter.println("Connecting to database for farmer_id: " + farmerId);
        
        Class.forName("com.mysql.cj.jdbc.Driver");
        con = DriverManager.getConnection(dbURL, dbUser, dbPass);
        logWriter.println("Database connected successfully");
        
        // First, let's check what crops this farmer has
        String debugQuery = "SELECT * FROM cropInfo WHERE farmer_id = ?";
        PreparedStatement debugPst = con.prepareStatement(debugQuery);
        debugPst.setInt(1, farmerId);
        ResultSet debugRs = debugPst.executeQuery();
        
        logWriter.println("\nDebug - Raw crop data for farmer " + farmerId + ":");
        boolean hasCrops = false;
        while(debugRs.next()) {
            hasCrops = true;
            logWriter.println(String.format("Crop: %s, Yield: %.2f %s", 
                debugRs.getString("crop_name"),
                debugRs.getDouble("yield_quantity"),
                debugRs.getString("yield_unit")));
        }
        if(!hasCrops) {
            logWriter.println("No crops found in initial debug query");
        }
        
        // Now get the accepted requests
        String requestQuery = "SELECT csr.request_id, " +
                     "l.username AS supplier_username, " +
                     "l.full_name AS supplier_fullname, " +
                     "l.phone_number, " +
                     "csr.crop_name, " +
                     "csr.negotiable_price, " +
                     "csr.sold_price, " +
                     "csr.quantity, " +
                     "csr.unit, " +
                     "csr.time_of_pickup, " +
                     "csr.transaction_status, " +
                     "csr.transaction_notes " +
                     "FROM crop_sales_requests csr " +
                     "JOIN supplier s ON csr.supplier_id = s.supplier_id " +
                     "JOIN login l ON s.user_id = l.user_id " +
                     "WHERE csr.farmer_id = ? AND csr.status = 'Accepted'";
        
        pst = con.prepareStatement(requestQuery);
        pst.setInt(1, farmerId);
        rs = pst.executeQuery();
        
        // Finally, get available crops for sale
        String cropQuery = "SELECT DISTINCT ci.crop_name, " +
               "SUM(ci.yield_quantity) as total_quantity, " +
               "ci.yield_unit, ci.farmer_id " +
               "FROM cropInfo ci " +
               "WHERE ci.farmer_id = ? AND ci.yield_quantity > 0 " +
               "GROUP BY ci.crop_name, ci.yield_unit, ci.farmer_id";
        
        logWriter.println("\nExecuting crop query: " + cropQuery);
        logWriter.println("For farmer_id: " + farmerId);
        
        cropPst = con.prepareStatement(cropQuery, 
                                   ResultSet.TYPE_SCROLL_INSENSITIVE,
                                   ResultSet.CONCUR_READ_ONLY);
        cropPst.setInt(1, farmerId);
        cropRs = cropPst.executeQuery();
        
        if (!cropRs.isBeforeFirst()) {
            logWriter.println("No available crops found for sale");
        } else {
            logWriter.println("Found crops available for sale:");
            while(cropRs.next()) {
                logWriter.println(String.format("Available: %s - %.2f %s",
                    cropRs.getString("crop_name"),
                    cropRs.getDouble("total_quantity"),
                    cropRs.getString("yield_unit")));
            }
            cropRs.beforeFirst(); // Reset for HTML generation
        }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Crop Management</title>
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
    <style>
        body {
            font-family: Arial, sans-serif;
            background-color: #f5f5f5;
            color: #333;
            padding: 20px;
        }
        
        .container {
            max-width: 1200px;
            margin: 0 auto;
        }
        
        .header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 20px;
        }
        
        .page-title {
            color: #4CAF50;
            margin: 0;
        }
        
        .sell-button {
            background-color: #007BFF;
            color: white;
            border: none;
            padding: 10px 20px;
            border-radius: 5px;
            cursor: pointer;
            font-size: 16px;
            transition: background-color 0.3s;
        }
        
        .sell-button:hover {
            background-color: #0056b3;
        }
        
        .table-container {
            background-color: white;
            border-radius: 8px;
            box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
            overflow: hidden;
        }
        
        table {
            width: 100%;
            border-collapse: collapse;
        }
        
        th {
            background-color: #4CAF50;
            color: white;
            padding: 10px;
            text-align: left;
            font-weight: bold;
        }
        
        td {
            padding: 9px;
            border-bottom: 1px solid #ddd;
        }
        
        tr:nth-child(even) {
            background-color: aliceblue;
        }
        
        tr:hover {
            background-color: lightgreen;
        }
        
        .no-data {
            text-align: center;
            padding: 20px;
            font-size: 16px;
            color: #666;
        }
        
        .status-pending {
            color: #f39c12;
            font-weight: bold;
        }
        .status-completed {
            color: #27ae60;
            font-weight: bold;
        }
        .status-failed {
            color: #e74c3c;
            font-weight: bold;
        }
        .btn-complete, .btn-fail {
            padding: 8px 16px;
            border: none;
            border-radius: 4px;
            cursor: pointer;
            color: white;
            margin: 0 5px;
        }
        .btn-complete {
            background-color: #27ae60;
        }
        .btn-fail {
            background-color: #e74c3c;
        }
        
        .form-group {
            margin-bottom: 20px;
            text-align: left;
        }
        .form-group label {
           display: block;
           margin-bottom: 5px;
           font-weight: bold;
       }

        .swal2-select {
            display: block !important;
            width: 100% !important;
            padding: 8px;
            margin: 10px 0;
            border: 1px solid #ddd;
            border-radius: 4px;
            background-color: white;
        }

        .swal2-container {
            z-index: 1000000 !important;
        }

        .swal2-select option {
            padding: 8px;
        }
        
        .swal2-input {
            margin-top: 5px !important;
        }
        
        /* Hide any extra SweetAlert2 select elements */
        .swal2-select:not(#modalCropSelect) {
            display: none !important;
        }
        
        .custom-select-container {
            width: 100%;
            margin-bottom: 1rem;
        }
        
        .custom-select {
            width: 100%;
            padding: 8px;
            border: 1px solid #ddd;
            border-radius: 4px;
            background-color: white;
            margin-top: 5px;
        }
        
        .price-input {
            width: 100px;
            padding: 5px;
            border: 1px solid #ddd;
            border-radius: 4px;
            text-align: right;
        }

        .price-input:focus {
            border-color: #4CAF50;
            outline: none;
            box-shadow: 0 0 5px rgba(76, 175, 80, 0.3);
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h2 class="page-title">Accepted Crop Sale Requests</h2>
            <button class="sell-button" onclick="confirmSale()">Sell Crop</button>
        </div>
    <div class="table-container">
        <table>
            <tr>
                <th>Supplier Username</th>
                <th>Full Name</th>
                <th>Phone Number</th>
                <th>Crop Name</th>
                <th>Negotiable Price</th>
                <th>Sold Price</th>
                <th>Quantity</th>
                <th>Unit</th>
                <th>Time of Pickup</th>
                <th>Transaction Status</th>
                <th>Reason (if Failed)</th>
                <th>Action</th>
            </tr>
            <%
            if (!rs.isBeforeFirst()) {
                %>
                <tr>
                    <td colspan="12" class="no-data">No accepted requests found.</td>
                </tr>
                <%
            } else {
                SimpleDateFormat dateFormat = new SimpleDateFormat("dd-MM-yyyy HH:mm");
                while (rs.next()) {
                    String status = rs.getString("transaction_status");
                    String statusClass = status.equals("Pending") ? "status-pending" : 
                                     status.equals("Completed") ? "status-completed" : "status-failed";
            %>
            <tr>
                <td><%= rs.getString("supplier_username") %></td>
                <td><%= rs.getString("supplier_fullname") %></td>
                <td><%= rs.getString("phone_number") %></td>
                <td><%= rs.getString("crop_name") %></td>
                <td>&#8377;<%= String.format("%.2f", rs.getDouble("negotiable_price")) %></td>
                <td>
                    <% if (status.equals("Pending")) { %>
                        <input type="number" 
                               step="0.01" 
                               class="price-input" 
                               value="<%= rs.getObject("sold_price") != null ? String.format("%.2f", rs.getDouble("sold_price")) : String.format("%.2f", rs.getDouble("negotiable_price")) %>"
                               onchange="updateSoldPrice(<%= rs.getInt("request_id") %>, this.value)"
                        >
                    <% } else { %>
                        Rs <%= rs.getObject("sold_price") != null ? String.format("%.2f", rs.getDouble("sold_price")) : String.format("%.2f", rs.getDouble("negotiable_price")) %>
                    <% } %>
                </td>
                <td><%= String.format("%.2f", rs.getDouble("quantity")) %></td>
                <td><%= rs.getString("unit") %></td>
                <td><%= rs.getTimestamp("time_of_pickup") != null ? dateFormat.format(rs.getTimestamp("time_of_pickup")) : "N/A" %></td>
                <td class="<%= statusClass %>"><%= status %></td>
                <td><%= rs.getString("transaction_notes") != null ? rs.getString("transaction_notes") : "" %></td>
                <td>
                    <% if (status.equals("Pending")) { %>
                        <button class="btn-complete" onclick="updateStatus(<%= rs.getInt("request_id") %>, 'Completed')">Mark Complete</button>
                        <button class="btn-fail" onclick="updateStatus(<%= rs.getInt("request_id") %>, 'Failed')">Mark Failed</button>
                    <% } %>
                </td>
            </tr>
            <%
                }
            }
            %>
        </table>
    </div>
    </div>
    <!--</div>-->

    <script>
        function debugLog(message) {
            console.log('[DEBUG ' + new Date().toISOString() + '] ' + message);
        }
        
        function updateStatus(requestId, status) {
            debugLog(`Updating status: ${status} for request: ${requestId}`);

            if (status === 'Failed') {
                // Use a simple modal dialog instead of redirecting to another page
                Swal.fire({
                    title: 'Provide Reason for Failed Transaction',
                    input: 'textarea',
                    inputLabel: 'Please explain why the transaction failed:',
                    inputPlaceholder: 'Enter your reason here...',
                    inputAttributes: {
                        'aria-label': 'Type your reason here',
                        'rows': '5'
                    },
                    showCancelButton: true,
                    confirmButtonText: 'Submit',
                    showLoaderOnConfirm: true,
                    preConfirm: (reason) => {
                        if (!reason || reason.trim() === '') {
                            Swal.showValidationMessage('Please provide a reason for the failure');
                            return false;
                        }

                        // Send the AJAX request directly from here
                        return $.post('updateTransactionStatus.jsp', {
                            requestId: requestId,
                            status: status,
                            notes: reason
                        })
                        .then(response => {
                            debugLog(`Status update response: ${response}`);
                            if (!response.trim().startsWith("Success")) {
                                throw new Error(response);
                            }
                            return response;
                        })
                        .catch(error => {
                            Swal.showValidationMessage(`Request failed: ${error}`);
                        });
                    },
                    allowOutsideClick: () => !Swal.isLoading()
                }).then((result) => {
                    if (result.isConfirmed) {
                        Swal.fire({
                            icon: 'success',
                            title: 'Success',
                            text: 'Transaction marked as failed!'
                        }).then(() => {
                            location.reload();
                        });
                    }
                });
            } else {
                // Handle "Mark Complete" same as before
                Swal.fire({
                    title: 'Processing...',
                    text: 'Updating transaction status',
                    allowOutsideClick: false,
                    didOpen: () => {
                        Swal.showLoading();
                    }
                });

                $.post('updateTransactionStatus.jsp', {
                    requestId: requestId,
                    status: status
                })
                .done(function(response) {
                    debugLog(`Status update response: ${response}`);
                    if (response.trim().startsWith("Success")) {
                        Swal.fire({
                            icon: 'success',
                            title: 'Success',
                            text: 'Transaction marked as completed!'
                        }).then(() => {
                            location.reload();
                        });
                    } else {
                        Swal.fire({
                            icon: 'error',
                            title: 'Error',
                            text: response
                        });
                    }
                })
                .fail(function(jqXHR, textStatus, errorThrown) {
                    debugLog(`Error: ${textStatus}, ${errorThrown}`);
                    Swal.fire({
                        icon: 'error',
                        title: 'Error',
                        text: 'Failed to update transaction status. Please try again.'
                    });
                });
            }
        }

        function updateSoldPrice(requestId, price) {
            debugLog(`Updating sold price: ${price} for request: ${requestId}`);
            
            $.post('updateSoldPrice.jsp', {
                requestId: requestId,
                soldPrice: price
            })
            .done(function(response) {
                debugLog(`Price update response: ${response}`);
                if (response.trim().startsWith("Success")) {
                    const Toast = Swal.mixin({
                        toast: true,
                        position: 'top-end',
                        showConfirmButton: false,
                        timer: 3000,
                        timerProgressBar: true
                    });
                    
                    Toast.fire({
                        icon: 'success',
                        title: 'Price updated successfully'
                    });
                } else {
                    Swal.fire({
                        icon: 'error',
                        title: 'Error',
                        text: response
                    });
                }
            })
            .fail(function(jqXHR, textStatus, errorThrown) {
                debugLog(`Error: ${textStatus}, ${errorThrown}`);
                Swal.fire({
                    icon: 'error',
                    title: 'Error',
                    text: 'Failed to update price. Please try again.'
                });
            });
        }

        function confirmSale() {
            debugLog('Opening sale confirmation dialog');
            <% if (!cropRs.isBeforeFirst()) { %>
                debugLog('No crops available - showing error');
                Swal.fire('Error', 'No crops available for sale', 'error');
                return;
            <% } %>
            
            Swal.fire({
                title: 'Enter Crop Details',
                html: `
                    <div class="form-group">
                        <label for="cropSelect">Select Crop</label>
                        <select id="modalCropSelect" class="swal2-select">
                            <option value="">Select Crop</option>
                            <% 
                            while(cropRs.next()) { 
                                String cropName = cropRs.getString("crop_name");
                                double totalQuantity = cropRs.getDouble("total_quantity");
                                String yieldUnit = cropRs.getString("yield_unit");
                            %>
                                <option value="<%= cropName %>" 
                                        data-quantity="<%= totalQuantity %>"
                                        data-unit="<%= yieldUnit %>">
                                    <%= cropName %> (Available: <%= String.format("%.2f", totalQuantity) %> <%= yieldUnit %>)
                                </option>
                            <% } %>
                        </select>
                    </div>
                    <div class="form-group">
                        <label for="quantity">Quantity</label>
                        <input id="quantity" type="number" step="0.01" class="swal2-input" placeholder="Enter quantity">
                    </div>
                    <div class="form-group">
                        <label for="price">Price</label>
                        <input id="price" type="number" class="swal2-input" placeholder="Enter negotiable price">
                    </div>
                `,
                showCancelButton: true,
                confirmButtonText: 'Submit',
                preConfirm: () => {
                    const modalCropSelect = document.getElementById('modalCropSelect');
                    const quantity = document.getElementById('quantity').value;
                    const price = document.getElementById('price').value;
                    const selectedOption = modalCropSelect.options[modalCropSelect.selectedIndex];

                    if (!modalCropSelect.value || !quantity || !price) {
                        Swal.showValidationMessage('Please fill in all fields');
                        return false;
                    }

                    const availableQuantity = parseFloat(selectedOption.dataset.quantity);
                    if (parseFloat(quantity) > availableQuantity) {
                        Swal.showValidationMessage(`Cannot sell more than available quantity (${availableQuantity})`);
                        return false;
                    }

                    if (price <= 0) {
                        Swal.showValidationMessage('Price must be greater than 0');
                        return false;
                    }

                    return {
                        cropName: selectedOption.value,
                        quantity: quantity,
                        unit: selectedOption.dataset.unit,
                        price: price
                    };
                }
            }).then((result) => {
                if (result.isConfirmed) {
                    debugLog(`Sale confirmed with values: ${JSON.stringify(result.value)}`);
                    submitSaleRequest(result.value);
                }
            });
        }

        function submitSaleRequest(data) {
            debugLog(`Submitting sale request: ${JSON.stringify(data)}`);
            $.ajax({
                url: 'submitSaleRequest.jsp',
                type: 'POST',
                data: data,
                success: function(response) {
                    debugLog(`Sale request response: ${response}`);
                    if (response.trim() === 'success') {
                        Swal.fire('Success', 'Sale request submitted successfully!', 'success')
                        .then(() => {
                            location.reload();
                        });
                    } else {
                        Swal.fire('Error', response.replace('error:', ''), 'error');
                    }
                },
                error: function(xhr, status, error) {
                    debugLog(`Sale request error - Status: ${status}, Error: ${error}`);
                    debugLog(`Response: ${xhr.responseText}`);
                    Swal.fire('Error', `Failed to submit sale request: ${error}`, 'error');
                }
            });
        }
    </script>
</body>
</html>
<%
    } catch (Exception e) {
        logWriter.println("Error in cropSell.jsp: " + e.getMessage());
        e.printStackTrace(new PrintWriter(logWriter));
        out.println("An error occurred: " + e.getMessage());
    } finally {
        try {
            if (rs != null) rs.close();
            if (cropRs != null) cropRs.close();
            if (pst != null) pst.close();
            if (cropPst != null) cropPst.close();
            if (con != null) con.close();
            if (logWriter != null) logWriter.close();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
%>