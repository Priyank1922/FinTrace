package com.finTrace.config;

public class DatabaseConfig {
    // Read from environment variables (set in Render)
    private static final String DB_HOST = System.getenv("DB_HOST");
    private static final String DB_PORT = System.getenv("DB_PORT");
    private static final String DB_NAME = System.getenv("DB_NAME");
    private static final String DB_USER = System.getenv("DB_USER");
    private static final String DB_PASSWORD = System.getenv("DB_PASSWORD");
    
    // TiDB Cloud JDBC URL with REQUIRED SSL parameters [citation:3][citation:4]
    public static final String URL = "jdbc:mysql://" + DB_HOST + ":" + DB_PORT + "/" + DB_NAME + 
        "?sslMode=VERIFY_IDENTITY&useSSL=true&requireSSL=true&enabledTLSProtocols=TLSv1.2&serverTimezone=UTC";
    
    public static final String USERNAME = DB_USER;
    public staticAL String PASSWORD = DB_PASSWORD;
    public static final String DRIVER = "com.mysql.cj.jdbc.Driver";
    
    // Fallback for local development (temporary)
    static {
        if (DB_HOST == null) {
            System.err.println("WARNING: Using fallback database configuration for local testing");
            // You can temporarily hardcode for testing, but never commit this!
            // URL = "jdbc:mysql://gateway01.ap-southeast-1.prod.aws.tidbcloud.com:4000/test?...";
        }
    }
}
