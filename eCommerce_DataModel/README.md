** Azure MySQL Database Connectivity **

1.	Create an account on Microsoft Azure.
2.	Create a storage account and a resource group.
3.	Now, go to ‘Azure Database for MySQL flexible servers’ and create a MySQL flexible server.
Assign the following properties:
-> Subscription and resource group (created in step 2)
-> Provide a Server Name (e.g. myserver1)
-> Region (Same as your Databricks workspace)
-> Set Authentication Type as Password
-> Create a Username and Password
-> For Networking, choose Public access
-> Add your local IP address to the firewall rules.
-> Click Create and Review

4. Now go back to your DataGrip software on your machine and create a new MySQL connection with the following properties:
-> Host as ‘<server_name>.mysql.database.azure.com’ 
-> Port as 3306
-> Authentication type as Username and password
-> Provide the username and password as set in Step 3.
-> In the SSL window, click on ‘Use SSL’ and in the Mode select ‘Require’.
-> Test the connection and click on OK.

5. In this newly established connection, create your database, tables and run your relevant DDL and DML scripts.

6. Now go to Azure Databricks.
-> Create a compute cluster.
-> Next create a notebook and connect it to the cluster.
-> In your compute cluster, also add the jar by navigating to Libraries> Maven> ‘mysql:mysql-connector-java:8.0.30’> Install. (This is the MySQL JDBC driver jar which is needed for making a connection to the Azure MySQL on the compute cluster)
-> Write the below connectivity code, to make a connection to the Azure MySQL table and load it into a PySpark dataframe.
jdbc_url = "jdbc:mysql:// <server_name>.mysql.database.azure.com:3306/<database_name>"

connection_properties = {
  "user": "<your username>",
  "password": "<your password>",
  "driver": "com.mysql.cj.jdbc.Driver"
}

df = spark.read.jdbc(url=jdbc_url, table="<table_name>", properties=connection_properties)
df.show()

-> Now execute your transformation queries in PySpark for your usecase.
