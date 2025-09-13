<%@page import="java.sql.*, java.util.*"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <title>Contact Agronomist</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            background-color: #f4f4f9;
            margin: 0;
            padding: 20px;
        }
        button, textarea {
            display: block;
            margin: 10px 0;
            padding: 10px;
            width: 100%;
            max-width: 400px;
            font-size: 16px;
            border-radius: 5px;
            border: 1px solid #ccc;
        }
        button {
            background-color: #007BFF;
            color: white;
            cursor: pointer;
            transition: background-color 0.4s;
        }
        button:hover {
        background-color: #4CAF50;
        }
    </style>
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
    <script>
        function bookInspection() {
            Swal.fire({
                title: 'Are you sure?',
                text: "Do you want to book an inspection?",
                icon: 'warning',
                showCancelButton: true,
                confirmButtonColor: '#007BFF',
                cancelButtonColor: '#d33',
                confirmButtonText: 'Yes, book it!'
            }).then((result) => {
                if (result.isConfirmed)
                    document.getElementById('bookingForm').style.display = 'block';
            });
        }

        function submitBooking() {
            var address = document.getElementById('address').value;
            if (address) {
                $.post('bookInspection.jsp', { address: address }, function(response) {
                    Swal.fire(
                        'Success!',
                        response,
                        'success'
                    );
                });
            } else {
                Swal.fire(
                    'Error',
                    'Please enter your address.',
                    'error'
                );
            }
        }
    </script>
</head>
<body>
    <h2>Contact Agronomist</h2>
    <button onclick="bookInspection()">Book Inspection</button>
    <div id="bookingForm" style="display:none;">
        <textarea id="address" placeholder="Enter your address" required></textarea>
        <button onclick="submitBooking()">Submit for Inspection</button>
    </div>
</body>
</html>
