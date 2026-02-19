package com.finTrace.util;

import java.sql.*;
import java.util.Properties;

import com.finTrace.config.DatabaseConfig;

public class DatabaseConnection {
    private static Connection connection = null;
    
    public static Connection getConnection() throws SQLException, ClassNotFoundException {
        if (connection == null || connection.isClosed()) {
            Class.forName(DatabaseConfig.DRIVER);
            DriverManager.setLoginTimeout(5);
            
            Properties props = new Properties();
            props.setProperty("user", DatabaseConfig.USERNAME);
            props.setProperty("password", DatabaseConfig.PASSWORD);
            props.setProperty("connectTimeout", "5000");
            props.setProperty("socketTimeout", "60000");
            connection = DriverManager.getConnection(
                DatabaseConfig.URL, 
                DatabaseConfig.USERNAME, 
                DatabaseConfig.PASSWORD
            );
        }
        return connection;
    }
    
    public static void closeConnection() {
        try {
            if (connection != null && !connection.isClosed()) {
                connection.close();
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
    
    public static void testConnection() {
        try {
            Connection conn = getConnection();
            System.out.println("Database connected successfully!");
            conn.close();
        } catch (Exception e) {
            System.err.println("Database connection failed: " + e.getMessage());
            e.printStackTrace();
        }
    }
}