package com.finTrace.util;

import java.sql.*;
import java.util.Properties;
import com.finTrace.config.DatabaseConfig;

public class DatabaseConnection {
    private static Connection connection = null;
    
    public static Connection getConnection() throws SQLException, ClassNotFoundException {
        if (connection == null || connection.isClosed()) {
            Class.forName(DatabaseConfig.DRIVER);
            DriverManager.setLoginTimeout(10);
            
            Properties props = new Properties();
            props.setProperty("user", DatabaseConfig.USERNAME);
            props.setProperty("password", DatabaseConfig.PASSWORD);
            props.setProperty("sslMode", "REQUIRED"); // Match your terminal command
            props.setProperty("useSSL", "true");
            props.setProperty("serverTimezone", "UTC");
            props.setProperty("connectTimeout", "30000");
            props.setProperty("socketTimeout", "60000");
            
            connection = DriverManager.getConnection(DatabaseConfig.URL, props);
            System.out.println("✅ Connected to TiDB Cloud successfully (SSL REQUIRED)");
        }
        return connection;
    }
    
    public static void closeConnection() {
        try {
            if (connection != null && !connection.isClosed()) {
                connection.close();
                System.out.println("📁 Database connection closed");
            }
        } catch (SQLException e) {
            System.err.println("❌ Error closing connection: " + e.getMessage());
        }
    }
    
    public static void testConnection() {
        try (Connection conn = getConnection()) {
            System.out.println("✅ Database connection test successful!");
        } catch (Exception e) {
            System.err.println("❌ Database connection failed: " + e.getMessage());
            e.printStackTrace();
        }
    }
}
