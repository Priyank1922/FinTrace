package com.finTrace.config;

public class DatabaseConfig {
    // Read from environment variables (set in Render)
    private static final String DB_HOST = System.getenv("DB_HOST");
    private static final String DB_PORT = System.getenv("DB_PORT");
    private static final String DB_NAME = System.getenv("DB_NAME");
    private static final String DB_USER = System.getenv("DB_USER");
    private static final String DB_PASSWORD = System.getenv("DB_PASSWORD");
    
    // Detect if running on Render
    private static final boolean IS_RENDER = System.getenv("RENDER") != null;
    
    // TiDB Cloud requires SSL
    public static final String URL = buildUrl();
    public static final String USERNAME = buildUsername();
    public static final String PASSWORD = buildPassword();
    public static final String DRIVER = "com.mysql.cj.jdbc.Driver";
    
    private static String buildUrl() {
        // On Render, use environment variables
        if (IS_RENDER && DB_HOST != null && DB_PORT != null && DB_NAME != null) {
            return "jdbc:mysql://" + DB_HOST + ":" + DB_PORT + "/" + DB_NAME + 
                   "?sslMode=VERIFY_IDENTITY&useSSL=true&requireSSL=true&enabledTLSProtocols=TLSv1.2&serverTimezone=UTC";
        }
        
        // Fallback for local development (CHANGE THESE TO YOUR ACTUAL TiDB CREDENTIALS)
        return "jdbc:mysql://gateway01.ap-southeast-1.prod.aws.tidbcloud.com:4000/test" +
               "?sslMode=VERIFY_IDENTITY&useSSL=true&requireSSL=true&enabledTLSProtocols=TLSv1.2&serverTimezone=UTC";
    }
    
    private static String buildUsername() {
        if (IS_RENDER && DB_USER != null) {
            return DB_USER;
        }
        // Your TiDB username for local testing
        return "GfKM8ds5z2m614G.root"; // REPLACE WITH YOUR ACTUAL USERNAME
    }
    
    private static String buildPassword() {
        if (IS_RENDER && DB_PASSWORD != null) {
            return DB_PASSWORD;
        }
        // Your TiDB password for local testing
        return "your-actual-password"; // REPLACE WITH YOUR ACTUAL PASSWORD
    }
}
