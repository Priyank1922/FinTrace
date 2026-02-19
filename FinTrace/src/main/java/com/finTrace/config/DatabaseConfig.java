package com.finTrace.config;

public class DatabaseConfig {
    // Read from environment variables (set in Render)
    private static final String DB_HOST = System.getenv("DB_HOST");
    private static final String DB_PORT = System.getenv("DB_PORT");
    private static final String DB_NAME = System.getenv("DB_NAME");
    private static final String DB_USER = System.getenv("DB_USER");
    private static final String DB_PASSWORD = System.getenv("DB_PASSWORD");
    
    // Default values if env vars not set (for local testing)
    private static final String DEFAULT_HOST = "gateway01.ap-southeast-1.prod.aws.tidbcloud.com";
    private static final String DEFAULT_PORT = "4000";
    private static final String DEFAULT_NAME = "test";
    private static final String DEFAULT_USER = "2h8YKj5jHjTyWvr.root";
    private static final String DEFAULT_PASSWORD = "your-password-here";
    
    // Determine if we're in production (Render) or local
    private static final boolean IS_PRODUCTION = System.getenv("RENDER") != null;
    
    public static final String URL = buildUrl();
    public static final String USERNAME = buildUsername();
    public static final String PASSWORD = buildPassword();
    public static final String DRIVER = "com.mysql.cj.jdbc.Driver";
    
    private static String buildUrl() {
        String host = IS_PRODUCTION ? DB_HOST : DEFAULT_HOST;
        String port = IS_PRODUCTION ? DB_PORT : DEFAULT_PORT;
        String dbName = IS_PRODUCTION ? DB_NAME : DEFAULT_NAME;
        
        if (host == null || port == null || dbName == null) {
            // Fallback for local testing without env vars
            return "jdbc:mysql://" + DEFAULT_HOST + ":" + DEFAULT_PORT + "/" + DEFAULT_NAME;
        }
        
        return "jdbc:mysql://" + host + ":" + port + "/" + dbName;
    }
    
    private static String buildUsername() {
        return IS_PRODUCTION ? DB_USER : DEFAULT_USER;
    }
    
    private static String buildPassword() {
        return IS_PRODUCTION ? DB_PASSWORD : DEFAULT_PASSWORD;
    }
    
    // Helper method to check if using TiDB
    public static boolean isTiDB() {
        return URL.contains("tidbcloud.com") || URL.contains(":4000");
    }
}
