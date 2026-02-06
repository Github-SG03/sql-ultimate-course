---



# What is SQL Server

SQL Server is a relational database management system (RDBMS) developed and marketed by Microsoft.

Similar to other RDBMS software, SQL Server is built on top of [SQL](https://www.sqltutorial.org/), a standard programming language for interacting with relational databases. SQL Server is tied to Transact-SQL, or T-SQL, Microsoft’s implementation of SQL, which includes a set of proprietary programming constructs.

SQL Server has been exclusively available on the Windows environment for over 20 years. In 2016, Microsoft made it available on Linux. SQL Server 2017 became generally available in October 2016 and was compatible with both Windows and Linux.

## SQL Server Architecture

The following diagram illustrates the architecture of the SQL Server:

![What is SQL Server - SQL Server Architecture ](https://www.sqlservertutorial.net/wp-content/uploads/What-is-SQL-Server-SQL-Server-Architecture.png)

SQL Server consists of two main components:

* Database Engine
* SQLOS

### Database Engine

The core component of the SQL Server is the Database Engine, which comprises a relational engine that processes queries and a storage engine that manages database files, pages, indexes, etc.

Additionally, the database engine creates database objects such as [stored procedures](https://www.sqlservertutorial.net/sql-server-stored-procedures/basic-sql-server-stored-procedures/), [views](https://www.sqlservertutorial.net/sql-server-views/), and [triggers](https://www.sqlservertutorial.net/sql-server-triggers/).

#### Relational Engine

The Relational Engine contains the components that determine the optimal method for executing a query. It is also known as the query processor.

The relational engine requests data from the storage engine based on the input query and processes the results.

Some tasks of the relational engine include querying processing, memory management, thread and task management, buffer management, and distributed query processing.

#### Storage Engine

The storage engine is responsible for storing and retrieving data from the storage systems such as disks and SAN.

### SQLOS

Under the relational engine and storage engine lies the SQL Server Operating System, or SQLOS.

SQLOS provides various operating system services such as memory and I/O management, as well as exception handling and synchronization services.

## SQL Server Services and Tools

Microsoft offers both data management and business intelligence (BI) tools and services alongside SQL Server.

For data management, SQL Server includes SQL Server Integration Services (SSIS), SQL Server Data Quality Service, and SQL Server Master Data Services.

For database development, SQL Server provides SQL Server Data tools; and for managing, deploying, and monitoring databases, SQL Server has the SQL Server Management Studio (SSMS).

For data analysis, SQL Server offers SQL Server Analysis Services (SSAS). SQL Server Reporting Services (SSRS) provides reports and data visualization. The Machine Learning Services technology first appeared first in SQL Server 2016, originally known as the R Services.

## SQL Server Editions

SQL Server has four primary editions, each offering different bundled services and tools. Two editions are available free of charge:

**SQL Server Developer Edition** is intended for database development and testing purposes.

**SQL Server Express Edition** is suitable for small databases with a storage capacity of up to 10 GB.

For larger and more critical applications, SQL Server offers the  **Enterprise edition** , which includes all SQL Server’s features.

**SQL Server Standard Edition** has a subset of features available in the Enterprise Edition and imposes limitations on the server, including restrictions on the number of processor cores and memory configurations.

**SQL Server Web Edition** is a good option for web hosting companies due to its low total cost of ownership.

For detailed information on the SQL Server Editions, check out the available [Server Server 2022 Editions](https://learn.microsoft.com/en-us/sql/sql-server/editions-and-components-of-sql-server-2022?view=sql-server-ver16#sql-server-editions).

## Summary

* SQL server architecture includes a database engine and SQL server operation system (SQLOS)
* SQL server offers a set of tools for working with data effectively.
* SQL server has different editions including developer edition, expression, enterprise, and standard.

---

# Install SQL Server

 **Summary** : in this tutorial, you will learn to install SQL Server 2022 Developer Edition and SQL Server Management Studio (SSMS).

## Install SQL Server 2022 Developer Edition

### Download SQL Server 2022

To download SQL Server 2022, click the link below:

[Download the SQL Server](https://www.microsoft.com/en-us/sql-server/sql-server-downloads)

Microsoft offers some editions of SQL Server. For learning purposes, you can download the Developer edition.

Step 1. The downloader will ask you to select the installation type. Choose the Download Media option, which allows you to download the setup files first and install the SQL Server later:

![](https://www.sqlservertutorial.net/wp-content/uploads/Download-SQL-Server-Installer-1.png)

Step 2. Choose the folder to store the installation files, then click the **Download** button:

![](https://www.sqlservertutorial.net/wp-content/uploads/Download-SQL-Server-Installer-2.png)

Step 3. The downloader will start downloading the installation files. This process may take some minutes, depending on your internet speed.

![](https://www.sqlservertutorial.net/wp-content/uploads/Download-SQL-Server-Installer-3.png)

Step 4. Once the download is complete, open the folder where the downloaded file is stored:

Step 5. Open the **SQLServer2022-DEV-x64-ENU** file to launch the installation. It will extract the files to a directory and start the installation process.

### Install SQL Server 2022 developer edition

Step 1. After launching the installer, the SQL Server Installation Center window appears; select the **Installation** option on the left:

![](https://www.sqlservertutorial.net/wp-content/uploads/1-Install-SQL-Server-Server-Installation-Center.png)

Step 2. Select the Developer edition to install and click the Next button:

![](https://www.sqlservertutorial.net/wp-content/uploads/2-SQL-Server-2022-Setup.png)

Step 3. Check the “I accept the license terms.” and click the Next button:

![](https://www.sqlservertutorial.net/wp-content/uploads/3-SQL-Server-2022-Setup.png)

Step 4. If you don’t want to get the updates for the SQL Server, uncheck the “Use Microsoft Update to check for updates (recommended)” option, and then click the **Next** button:

![](https://www.sqlservertutorial.net/wp-content/uploads/4-SQL-Server-2022-Setup.png)

Step 5. The installation will check for prerequisites before proceeding. If no error occurs, click the Next button:

![](https://www.sqlservertutorial.net/wp-content/uploads/5-SQL-Server-2022-Setup.png)

Step 6. Uncheck the Aruze extension for SQL Server:

![](https://www.sqlservertutorial.net/wp-content/uploads/6-SQL-Server-2022-Setup.png)

Step 7. Select the features you want to install. For learning purposes, you need the Database Engine Services, and click the Next button to continue:

![](https://www.sqlservertutorial.net/wp-content/uploads/7-SQL-Server-2022-Setup.png)

Step 8. Enter the instance ID of the SQL Server and click the Next button. The instance ID defaults to `MSSQLServer`:

![](https://www.sqlservertutorial.net/wp-content/uploads/8-SQL-Server-2022-Setup.png)

Step 9.  Specify the service accounts and collation configuration. Use the default settings and click the Next button:

![](https://www.sqlservertutorial.net/wp-content/uploads/9-SQL-Server-2022-Setup.png)

Step 10.  Specify database engine authentication security mode. Select the **Mixed Mode** (1), and enter the password for system administration (`sa`) account (2& 3), and add the current user as a SQL Server Administrator (4):

![](https://www.sqlservertutorial.net/wp-content/uploads/10-SQL-Server-2022-Setup.png)

Make sure to store this password in a secure place, as you’ll need it to connect to the SQL Server later.

Step 11. Verify that the SQL Server 2022 features are installed.

![](https://www.sqlservertutorial.net/wp-content/uploads/11-SQL-Server-2022-Setup.png)

![](https://www.sqlservertutorial.net/wp-content/uploads/12-SQL-Server-2022-Setup.png)

Step 12. Click the **Close** button to complete the installation.

Congratulation!  you have successfully installed SQL Server 2022 Developer Edition.

## Microsoft SQL Server Management Studio (SSMS)

To interact with SQL Server, you can use a SQL Server client tool such as SQL Server Management Studio (SSMS) provided by Microsoft.

The SQL Server Management Studio is software for querying, designing, and managing SQL Server on your local computer, a remote server, or in the cloud. It provides you with tools to configure, monitor, and administer SQL Server instances.

### Download SQL Server Management Studio

First, download the SSMS from the Microsoft website via the following link:

[Download SQL Server Management Studio](https://learn.microsoft.com/en-us/sql/ssms/download-sql-server-management-studio-ssms)

Second, double-click the installation file **SSMS-Setup-ENU.exe** to launch the installer. The installation process of SMSS is straightforward. you need to follow the screen sequence.

### Install SQL Server Management Studio

Step 1. Click the **Install** button:

![](https://www.sqlservertutorial.net/wp-content/uploads/Install-SSMS-1.png)

Step 2. Wait for a few minutes while the installer setting up the software:

![](https://www.sqlservertutorial.net/wp-content/uploads/Install-SSMS-2.png)

Step 3. Once setup is completed, click the **Close** button:

![](https://www.sqlservertutorial.net/wp-content/uploads/Install-SSMS-3.png)

Now, you should have SQL Server 2022 and SQL Server Management Studio installed on your computer. Next, you will learn how to [connect to the SQL Server from the SQL Server Management Studio](https://www.sqlservertutorial.net/connect-to-the-sql-server/).

---



# Connect to the SQL Server

 **Summary** : in this tutorial, you will learn how to connect to SQL Server from the SQL Server Management Studio and execute a query.

## Connect to the SQL Server using SSMS

To connect to the SQL Server using the Microsoft SQL Server Management Studio, follow these steps:

Step 1. Launch the Microsoft SQL Server Management Studio:

![](https://www.sqlservertutorial.net/wp-content/uploads/SSMS-connect-to-SQL-Server.png)

Step 2. Choose the  **Database Engine** …  from the **Connect** menu under the  **Object Explorer** :

![](https://www.sqlservertutorial.net/wp-content/uploads/Open-the-Connection-Dialog-300x213.png)

Step 3. Enter the following information:

1. Server Type: **Database Engine**
2. Server name: **localhost**
3. Authentication: **SQL Server Authentication**
4. Login: **sa**
5. Password: (The one you entered during the [installation](https://www.sqlservertutorial.net/install-sql-server/).)
6. Check the  **Remember Password** .
7. Encryption: **Optional**

Click the **Connect** button to connect to the SQL Server:

![Connect to Local Server Server](https://www.sqlservertutorial.net/wp-content/uploads/Connect-to-Local-Server-Server.png)

If the connection is successful, you will see the following **Object Explorer** panel:

![Connect Microsoft SQL Server Management Studio](https://www.sqlservertutorial.net/wp-content/uploads/Connect-Microsoft-SQL-Server-Management-Studio.png)

## Execute a query

To execute a query you follow these steps:

First, right-click on the **localhost (SQL Server …)** node and choose the **New Query** menu item:

![](https://www.sqlservertutorial.net/wp-content/uploads/New-Query.png)

Second, enter the following query in the Editor

```
select @@version;Code language: SQL (Structured Query Language) (sql)
```

This query returns the version of the SQL Server.

Third, click the **Execute** button:

![](https://www.sqlservertutorial.net/wp-content/uploads/SSMS-Execute-a-Query.png)

The **Results** window shows the version of the SQL Server as shown in the above screenshot. A quick way to execute a query is to press the **F5** keyboard shortcut.

Now, you should know how to connect to an SQL Server and execute a query from the SSMS.
