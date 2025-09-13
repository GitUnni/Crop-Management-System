<%
    String userRole = (String) session.getAttribute("user_role");
    if (userRole == null || !userRole.equals("a")) {
        response.sendRedirect("login.html");
        return;
    }
%>
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Agronomist's Dashboard</title>
    <link rel="stylesheet" href="css/greenbutton.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.2/css/all.min.css" /> <!--notification bell-->
    <style>
      body {
        font-family: Arial, sans-serif;
        margin: 0;
        padding: 0;
        background-color: #ddd3ec;
      }
      header {
        background-color: black;
        color: #fff;
        padding: 8px;
        text-align: center;
        animation: slideDown 1s ease-out;
      }
      @keyframes slideDown {
        from {
          transform: translateY(-50px);
          opacity: 0;
        }
        to {
          transform: translateY(0);
          opacity: 1;
        }
      }
      
      @keyframes fadeIn {
        from {
          opacity: 0;
        }
        to {
          opacity: 1;
        }
      }
      nav ul li {
        display: inline;
        margin-right: 20px;
      }
      nav ul li a {
        color: #fff;
        text-decoration: none;
        transition: color 0.3s ease;
      }
      nav ul li a:hover {
        color: #4CAF50;
      }
      .content {
        display: flex;
        padding: 20px;
      }
      a {
        text-decoration: none;
      }
      aside {
        width: 200px;
        background-color: #f0f0f0;
        padding: 10px;
      }
      aside ul {
        list-style-type: none;
        padding: 0;
      }
      aside ul li {
        margin-bottom: 10px;
      }
      aside ul li a {
        color: black;
        text-decoration: none;
        padding: 5px;
        display: block;
        border-radius: 5px;
        transition: background-color 0.3s ease, color 0.3s ease;
      }
      aside ul li a:hover {
        background-color: #4CAF50;
        color: white;
      }
      main {
        padding: 0 20px;
      }
      footer {
        background-color: #1b1b1b;
        color: #fff;
        padding: 2px;
        text-align: center;
        position: fixed;
        bottom: 0;
        width: 100%;
        animation: fadeIn 1s ease-in;
      }

      #profile {
        display: flex;
        align-items: center;
        justify-content: space-between;
      }

      .profile-info {
        display: flex;
        justify-content:space-between;
      }

      .container {
        width: 270px;
        max-width: 280px;
      }

      #photoContainer {
        width: 100%;
        padding-top: 42.5%;
        position: relative;
      }

      #photoContainer img {
        /*border-radius: 50%;    For making photo rounded*/
        position: absolute;
        top: 0;
        height: 100%;
        object-fit: contain;
      }

      input[type="file"] {
        display: none;
      }

      .custom-file-upload {
        display: inline-block;
        padding: 6px 12px;
        cursor: pointer;
        background-color: #4caf50;
        color: #fff;
        border-radius: 4px;
      }
      
      input[type="submit"],
      button[type="submit"],
      button[type="button"],
      input[type="password"]
      {
            border: 1px solid #ccc;
            border-radius: 2px;
            height:30px;
            box-sizing: border-box;
      }
      
      button[type="submit"]:hover
      {
          background-color: #4CAF50;
      }
      
      button[type="submit"]:active 
      {
        background-color: black; 
      }
    </style>
    <script>
      function showSection(sectionId) {
        //sections hiding etc
        var mainSections = document.querySelectorAll("main section");
        mainSections.forEach(function (section) {
          section.style.display = "none";
        });

        var targetSection = document.getElementById(sectionId);
        if (targetSection) targetSection.style.display = "block";
      }

      function showChangePasswordForm() 
      {
        //MyProfile ChangePassword hiding
        var changePasswordForm = document.getElementById("changePasswordForm");
        if (changePasswordForm.style.display === "none" || changePasswordForm.style.display === "")
          changePasswordForm.style.display = "block";
        else 
            changePasswordForm.style.display = "none";
      }

      function logOut() {
        //logout
        window.location.href = "logout.jsp";
      }
    </script>
  </head>
  <body>
    <% 
    response.setHeader("Cache-Control", "no-cache, no-store,must-revalidate"); 
    response.setHeader("Pragma", "no-cache");
    response.setHeader("Expires", "0"); 
    String username = (String)session.getAttribute("username");
    String fullname = (String)session.getAttribute("full_name");
    if (username == null)
        response.sendRedirect("login.html"); // If the session attribute doesn't exist, redirect to the login page 
    %>
    <header>
      <h1>Agronomist Dashboard</h1>
      <nav>
        <ul>
          <li><a href="#" onclick="showSection('weather')">Weather Forecast <i class="fa-solid fa-cloud-sun-rain"></i></a></li>
          <li><a href="#" onclick="showSection('market')">Market Price <i class="fa-solid fa-money-bill-trend-up"></i></a></li>
          <li><a href="#" onclick="showSection('visit')">Visit Scheduling <i class="fa-regular fa-calendar-check"></i></a></li>
          <li><a href="logout.jsp">Log Out <i class="fa-solid fa-arrow-right-from-bracket"></i></a></li>
        </ul>
      </nav>
    </header>
    <div class="content">
      <aside>
        <ul>
          <li><a href="#" onclick="showSection('profile')"><i class="fa-regular fa-user"></i> My Profile</a></li>
          <li><a href="#" onclick="showSection('report')"><i class="fa-solid fa-pen-nib"></i> Report Generation</a></li>
          <li><a href="#" onclick="showSection('history')"><i class="fa-solid fa-clock-rotate-left"></i> History</a></li>
        </ul>
      </aside>
      <main>
        <section id="profile" style="display: none">
          <h2>My Profile</h2>
          <div class="profile-info">
            <div class="shift-right">
              <div id="photoContainer"></div>
              <div class="container">
                <form id="uploadForm">
                  <input type="file" id="fileInput">
                  <label for="fileInput" class="custom-file-upload">Choose an image</label>
                </form>
              </div>

              <script>
                const fileInput = document.getElementById("fileInput");
                const photoContainer = document.getElementById("photoContainer");

                fileInput.addEventListener("change", function (event) {
                  const imgPath = event.target.files[0];
                  const reader = new FileReader();

                  reader.addEventListener(
                    "load",
                    function () {
                      // convert image file to base64 string and save to localStorage
                      localStorage.setItem("image_" + "<%= username %>", reader.result);

                      // display the image
                      const img = document.createElement("img");
                      img.src = reader.result;
                      photoContainer.innerHTML = ""; // Clear previous image
                      photoContainer.appendChild(img);
                    },
                    false
                  );

                  if (imgPath) reader.readAsDataURL(imgPath);
                });

                // Check if there's an image in localStorage and display it
                const savedImage = localStorage.getItem("image_" + "<%= username %>");
                if (savedImage) {
                  const img = document.createElement("img");
                  img.src = savedImage;
                  photoContainer.appendChild(img);
                }
              </script>
            </div>
              
            <div>
                <div style="margin-left: 50px;">Name: <%= fullname %></div>
            <form action="query.jsp" method="post">
              <br><br>
              <button type="button" onclick="showChangePasswordForm()"style=" background-color: rgba(230, 239, 243, 0.6); margin-left: 50px; ">Change Password</button>
              <div id="changePasswordForm" style="display: none; margin-left: 50px;" ><br>
                Original Password:<input type="password" name="originalPassword" style="margin-right: 45px" required/>
                New Password:<input type="password" name="newPassword" required /><br><br>
                <button type="submit" name="submit" value="ChangePassword">Submit</button>
              </div>
              <br><br>
            </form>
            </div>
        </section>

        <section id="weather" style="display: none">
          <object type="text/html" data="weather.html" width="600px" height="500px"></object>
        </section>

        <section id="market" style="display: none">
          <h2>Market Price</h2>
          
          <a href="https://agmarknet.gov.in/" rel="noopener noreferrer">
            <button class="pushable">
            <span class="shadow"></span>
            <span class="edge"></span>
            <span class="front">
             Click here for Market Price!
            </span></button></a>
          
        </section>

        <section id="visit" style="display: none">
          <h2>Visit</h2>
          <iframe src="inspection/agronomistViewRequests.jsp" style="width:900px; height:500px;"></iframe><br> 
        </section>

        <section id="report" style="display: none">
          <h2>Report Generation</h2>
          <iframe src="upload.jsp" style="width:900px; height:500px;"></iframe><br> 
        </section>
            
        <section id="history" style="display: none">
          <h2>History</h2>
          <iframe src="history.jsp" style="width:900px; height:500px;"></iframe><br> 
        </section>
            
        <section>
          <p style="font-family: Cooper; font-size: 45px; color: green;"> Welcome <%= fullname %> !</p>
        </section> 
      </main>
    </div>
    <footer>
      <p>Contact Us: imca-368@scmsgroup.org</p>
    </footer>
  </body>
</html>