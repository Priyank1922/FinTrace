package com.finTrace.controller;

import com.finTrace.service.CSVProcessor;
import com.finTrace.service.GraphAnalyzer;
import com.finTrace.util.JSONGenerator;
import com.finTrace.util.DatabaseConnection;
import com.finTrace.model.*;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.*;
import java.util.*;
import java.net.URLEncoder;
import java.sql.Connection;

@WebServlet("/upload")
@MultipartConfig(
    fileSizeThreshold = 1024 * 1024 * 2, // 2MB
    maxFileSize = 1024 * 1024 * 50,      // 50MB
    maxRequestSize = 1024 * 1024 * 60    // 60MB
)
public class UploadServlet extends HttpServlet {
    
    protected void doPost(HttpServletRequest request, 
                          HttpServletResponse response) 
            throws ServletException, IOException {
        
        PrintWriter out = response.getWriter();
        
        try {
            // STEP 1: Test database connection first
            System.out.println("🔍 Testing database connection...");
            try {
                Class.forName("com.mysql.cj.jdbc.Driver");
                Properties props = new Properties();
                
                // Get database config from environment
                String dbHost = System.getenv("DB_HOST");
                String dbPort = System.getenv("DB_PORT");
                String dbName = System.getenv("DB_NAME");
                String dbUser = System.getenv("DB_USER");
                String dbPassword = System.getenv("DB_PASSWORD");
                
                // Check if running on Render
                boolean isRender = System.getenv("RENDER") != null;
                
                if (isRender && (dbHost == null || dbPort == null || dbName == null)) {
                    System.err.println("❌ Missing database environment variables on Render");
                    System.err.println("DB_HOST: " + dbHost);
                    System.err.println("DB_PORT: " + dbPort); 
                    System.err.println("DB_NAME: " + dbName);
                    System.err.println("DB_USER: " + (dbUser != null ? "✓ Set" : "✗ Missing"));
                    System.err.println("DB_PASSWORD: " + (dbPassword != null ? "✓ Set" : "✗ Missing"));
                    
                    redirectError(response, "Database configuration error", 
                        "Missing database environment variables. Please check Render dashboard.", 
                        "db_config_error");
                    return;
                }
                
                // Build connection URL
                String dbUrl;
                if (isRender && dbHost != null) {
                    dbUrl = "jdbc:mysql://" + dbHost + ":" + dbPort + "/" + dbName;
                } else {
                    // Local development fallback - UPDATE WITH YOUR TIDB CREDENTIALS
                    dbUrl = "jdbc:mysql://gateway01.ap-southeast-1.prod.aws.tidbcloud.com:4000/test";
                    dbUser = "YOUR_TIDB_USERNAME.root"; // Replace with your actual username
                    dbPassword = "YOUR_TIDB_PASSWORD"; // Replace with your actual password
                }
                
                // Add SSL parameters for TiDB Cloud
                String dbUrlWithSSL = dbUrl + "?sslMode=VERIFY_IDENTITY&useSSL=true&requireSSL=true&enabledTLSProtocols=TLSv1.2&serverTimezone=UTC";
                
                props.setProperty("user", dbUser);
                props.setProperty("password", dbPassword);
                props.setProperty("sslMode", "VERIFY_IDENTITY");
                props.setProperty("useSSL", "true");
                props.setProperty("requireSSL", "true");
                props.setProperty("enabledTLSProtocols", "TLSv1.2");
                props.setProperty("serverTimezone", "UTC");
                props.setProperty("connectTimeout", "30000");
                props.setProperty("socketTimeout", "60000");
                
                Connection testConn = java.sql.DriverManager.getConnection(dbUrlWithSSL, props);
                System.out.println("✅ Database connection successful!");
                System.out.println("   Connected to: " + dbHost);
                testConn.close();
                
            } catch (Exception e) {
                System.err.println("❌ Database connection failed: " + e.getMessage());
                e.printStackTrace();
                
                String errorDetail = "Database connection error. ";
                if (e.getMessage().contains("Access denied")) {
                    errorDetail += "Invalid username or password.";
                } else if (e.getMessage().contains("Connection refused")) {
                    errorDetail += "Cannot reach database host. Check host and port.";
                } else if (e.getMessage().contains("SSL")) {
                    errorDetail += "SSL configuration error.";
                } else {
                    errorDetail += e.getMessage();
                }
                
                redirectError(response, "Database connection failed", 
                    errorDetail, "db_connection_error");
                return;
            }
            
            // STEP 2: Get uploaded file
            System.out.println("📁 Processing file upload...");
            Part filePart = request.getPart("csvFile");
            
            // Check if file exists
            if (filePart == null || filePart.getSize() == 0) {
                redirectError(response, "No file uploaded", 
                    "Please select a CSV file to upload.", "file_missing");
                return;
            }
            
            String fileName = filePart.getSubmittedFileName();
            long fileSize = filePart.getSize();
            System.out.println("   File: " + fileName + " (" + fileSize + " bytes)");
            
            // Check file extension
            if (!fileName.toLowerCase().endsWith(".csv")) {
                redirectError(response, "Invalid file type", 
                    "File must be a CSV. You uploaded: " + fileName, "invalid_type");
                return;
            }
            
            // Check file size (max 10MB)
            if (fileSize > 10 * 1024 * 1024) {
                redirectError(response, "File too large", 
                    "File size: " + (fileSize / 1024 / 1024) + "MB. Max allowed: 10MB", "file_too_large");
                return;
            }
            
            // Set start time for processing measurement
            long startTime = System.currentTimeMillis();
            
            // STEP 3: Process CSV
            System.out.println("📊 Processing CSV file...");
            InputStream fileContent = filePart.getInputStream();
            CSVProcessor csvProcessor = new CSVProcessor();
            
            // First validate CSV format
            Map<String, Object> validation = csvProcessor.validateCSV(fileContent);
            fileContent.reset(); // Reset stream after validation
            
            if (!(boolean)validation.get("valid")) {
                List<String> errors = (List<String>)validation.get("errors");
                List<String> warnings = (List<String>)validation.get("warnings");
                
                String errorMsg = String.join(". ", errors);
                String details = "Errors: " + errors + "\nWarnings: " + warnings;
                
                redirectError(response, errorMsg, details, "validation_failed");
                return;
            }
            
            // Process the CSV
            List<Transaction> transactions = csvProcessor.processCSV(fileContent);
            
            if (transactions == null || transactions.isEmpty()) {
                redirectError(response, "No transactions found", 
                    "The CSV file contains no valid transaction data.", "empty_file");
                return;
            }
            
            System.out.println("✅ Loaded " + transactions.size() + " transactions");
            
            // STEP 4: Run graph analysis
            System.out.println("🔍 Running graph analysis...");
            GraphAnalyzer analyzer = new GraphAnalyzer();
            Map<String, Account> accounts = analyzer.buildGraph(transactions);
            List<FraudRing> rings = analyzer.detectAllPatterns(accounts, transactions);
            Map<String, Double> scores = analyzer.calculateScores(accounts, rings);
            
            System.out.println("✅ Analysis complete:");
            System.out.println("   - Accounts: " + accounts.size());
            System.out.println("   - Fraud rings: " + rings.size());
            System.out.println("   - Suspicious accounts: " + scores.size());
            
            // Calculate processing time
            long processingTime = System.currentTimeMillis() - startTime;
            System.out.println("⏱️ Processing time: " + processingTime + "ms");
            
            // STEP 5: Generate JSON output
            JSONGenerator jsonGen = new JSONGenerator();
            String outputJson = jsonGen.generateOutputJSON(accounts, rings, processingTime);
            
            // STEP 6: Store in session
            HttpSession session = request.getSession();
            session.setAttribute("analysisResult", outputJson);
            session.setAttribute("accounts", accounts);
            session.setAttribute("rings", rings);
            session.setAttribute("transactions", transactions);
            session.setAttribute("processingTime", processingTime / 1000.0);
            session.setAttribute("fileName", fileName);
            
            System.out.println("🚀 Redirecting to dashboard...");
            
            // Redirect to dashboard
            response.sendRedirect("dashboard.jsp");
            
        } catch (Exception e) {
            System.err.println("❌ Fatal error in UploadServlet: " + e.getMessage());
            e.printStackTrace();
            
            String errorMsg = e.getMessage();
            String details = getStackTraceAsString(e);
            
            // Clean up error message for display
            if (errorMsg == null || errorMsg.isEmpty()) {
                errorMsg = "Unknown error occurred while processing the CSV file.";
            }
            
            // Truncate if too long
            if (errorMsg.length() > 200) {
                errorMsg = errorMsg.substring(0, 200) + "...";
            }
            
            redirectError(response, errorMsg, details, "exception");
        }
    }
    
    private void redirectError(HttpServletResponse response, String message, 
                               String details, String type) throws IOException {
        String encodedMessage = URLEncoder.encode(message, "UTF-8");
        String encodedDetails = URLEncoder.encode(details, "UTF-8");
        String encodedType = URLEncoder.encode(type, "UTF-8");
        
        response.sendRedirect("error.jsp?message=" + encodedMessage + 
                             "&details=" + encodedDetails + 
                             "&type=" + encodedType);
    }
    
    private String getStackTraceAsString(Exception e) {
        StringWriter sw = new StringWriter();
        PrintWriter pw = new PrintWriter(sw);
        e.printStackTrace(pw);
        return sw.toString();
    }
}
