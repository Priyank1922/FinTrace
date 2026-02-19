package com.finTrace.controller;

import com.finTrace.service.CSVProcessor;
import com.finTrace.service.GraphAnalyzer;
import com.finTrace.util.JSONGenerator;
import com.finTrace.model.*;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.*;
import java.util.*;
import java.net.URLEncoder;

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
        
        try {
            // Get uploaded file
            Part filePart = request.getPart("csvFile");
            
            // Check if file exists
            if (filePart == null || filePart.getSize() == 0) {
                redirectError(response, "No file uploaded", 
                    "Please select a CSV file to upload.", "file_missing");
                return;
            }
            
            String fileName = filePart.getSubmittedFileName();
            long fileSize = filePart.getSize();
            
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
            
            // Process CSV
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
            
            // Run graph analysis
            GraphAnalyzer analyzer = new GraphAnalyzer();
            Map<String, Account> accounts = analyzer.buildGraph(transactions);
            List<FraudRing> rings = analyzer.detectAllPatterns(accounts, transactions);
            Map<String, Double> scores = analyzer.calculateScores(accounts, rings);
            
            // 🔧 FIXED: Calculate processing time properly
            long processingTime = System.currentTimeMillis() - startTime;
            
            // Generate JSON output
            JSONGenerator jsonGen = new JSONGenerator();
            String outputJson = jsonGen.generateOutputJSON(accounts, rings, processingTime);
            
            // Store in session
            HttpSession session = request.getSession();
            session.setAttribute("analysisResult", outputJson);
            session.setAttribute("accounts", accounts);
            session.setAttribute("rings", rings);
            session.setAttribute("transactions", transactions);
            session.setAttribute("processingTime", processingTime / 1000.0);
            session.setAttribute("fileName", fileName);
            
            // Redirect to dashboard
            response.sendRedirect("dashboard.jsp");
            
        } catch (Exception e) {
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
