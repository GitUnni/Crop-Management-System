# 🌾 Crop Management System - Installation Guide

The Crop Management System is an innovative platform designed to connect farmers, suppliers and agronomists ensuring seamless communication, efficient operations and informed decision-making. Each user has specific features tailored to their roles, enhancing agricultural productivity and collaboration.

---

## 📦 Prerequisites

Before you begin, make sure you have the following installed:

- **[Apache NetBeans IDE](https://netbeans.apache.org/)**
- **[MySQL Server](https://dev.mysql.com/downloads/mysql/)**
- **[MySQL Connector/J (JDBC Driver)](https://dev.mysql.com/downloads/connector/j/)**  
- **Payara Server** (can be added during project setup in NetBeans)

---

## 🚀 Installation Steps

1. **Clone or Download the Repository**
   - Click the green `Code` button and select `Download ZIP`.
   - Extract the ZIP file to your desired location.

2. **Set Up the MySQL Database**
   - Open MySQL and create a new database named `crop`.
   - Copy the contents of the `DatabaseTables_.txt` file and paste it into the `crop` database.
     ```sql
     -- Command for creating crop database:
     CREATE DATABASE crop;
     USE crop;
     -- Now copy paste the contents of DatabaseTables_.txt
     ```

3. **Set Up the Project in NetBeans**
   - Launch **Apache NetBeans IDE**.
   - Create a **new project**:
     - Choose `Java with Ant` > `Web Application`.
     - Name the project and choose the extracted folder as the source.
     - Select **Payara Server** as the target server (install if not already added).
   - Add the **MySQL Connector/J JAR** file to the project’s libraries:
     - Right-click on the project > `Properties` > `Libraries` > `Add JAR/Folder`.

4. **Build and Run the Project**
   - After ensuring that all JSP and HTML files are in the `web` folder, click the green Run Project button at the top. You should then be able to access the Crop Management System in your browser.

---