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
            
            // Check if we're connecting to TiDB Cloud (detect by port or host)
            boolean isTiDB = DatabaseConfig.URL.contains("tidbcloud.com") || 
                             DatabaseConfig.URL.contains(":4000");
            
            Properties props = new Properties();
            props.setProperty("user", DatabaseConfig.USERNAME);
            props.setProperty("password", DatabaseConfig.PASSWORD);
            props.setProperty("connectTimeout", "30000"); // Increased for TiDB
            props.setProperty("socketTimeout", "60000");
            
            // TiDB Cloud requires SSL and specific settings
            if (isTiDB) {
                System.out.println("🔌 Connecting to TiDB Cloud with SSL...");
                props.setProperty("sslMode", "VERIFY_IDENTITY");
                props.setProperty("useSSL", "true");
                props.setProperty("requireSSL", "true");
                props.setProperty("enabledTLSProtocols", "TLSv1.2,TLSv1.3");
                props.setProperty("serverTimezone", "UTC");
                props.setProperty("allowPublicKeyRetrieval", "true");
            } else {
                // Local MySQL settings
                props.setProperty("useSSL", "false");
                props.setProperty("allowPublicKeyRetrieval", "true");
                props.setProperty("serverTimezone", "UTC");
            }
            
            // Create connection with properties
            connection = DriverManager.getConnection(DatabaseConfig.URL, props);
            
            // Test the connection
            testConnection(connection);
        }
        return connection;
    }
    
    private static void testConnection(Connection conn) {
        try (Statement stmt = conn.createStatement()) {
            ResultSet rs = stmt.executeQuery("SELECT 1 as test");
            if (rs.next()) {
                System.out.println("✅ Database connection verified");
            }
        } catch (SQLException e) {
            System.err.println("⚠️ Connection test failed: " + e.getMessage());
        }
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
        Connection conn = null;
        try {
            conn = getConnection();
            System.out.println("✅ Database connection test successful!");
            System.out.println("   URL: " + DatabaseConfig.URL);
            System.out.println("   User: " + DatabaseConfig.USERNAME);
            
            // Get database info
            DatabaseMetaData metaData = conn.getMetaData();
            System.out.println("   Database: " + metaData.getDatabaseProductName());
            System.out.println("   Version: " + metaData.getDatabaseProductVersion());
            
        } catch (Exception e) {
            System.err.println("❌ Database connection failed: " + e.getMessage());
            e.printStackTrace();
        } finally {
            if (conn != null) {
                try {
                    conn.close();
                } catch (SQLException e) {
                    // Ignore
                }
            }
        }
    }
    
    /**
     * Execute a simple query to test connection is alive
     */
    public static boolean isConnectionValid() {
        if (connection == null) {
            return false;
        }
        
        try (Statement stmt = connection.createStatement()) {
            stmt.executeQuery("SELECT 1");
            return true;
        } catch (SQLException e) {
            return false;
        }
    }
    
    /**
     * Get connection status
     */
    public static String getConnectionStatus() {
        if (connection == null) {
            return "🔴 Not connected";
        }
        
        try {
            if (connection.isClosed()) {
                return "🔴 Connection closed";
            }
            
            if (isConnectionValid()) {
                return "🟢 Connected and valid";
            } else {
                return "🟡 Connection stale";
            }
        } catch (SQLException e) {
            return "🔴 Error: " + e.getMessage();
        }
    }
}
