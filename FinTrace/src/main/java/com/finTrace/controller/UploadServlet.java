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
@WebServlet("/upload")
@MultipartConfig(
    fileSizeThreshold = 1024 * 1024, // 1 MB
    maxFileSize = 1024 * 1024 * 10,  // 10 MB
    maxRequestSize = 1024 * 1024 * 15 // 15 MB
)
public class UploadServlet extends HttpServlet {
    
    protected void doPost(HttpServletRequest request, 
                          HttpServletResponse response) 
            throws ServletException, IOException {
        
        long startTime = System.currentTimeMillis();
        
        try {
            // Get uploaded file
            Part filePart = request.getPart("csvFile");
            
            if (filePart == null || filePart.getSize() == 0) {
                response.sendRedirect("index.jsp?error=No file uploaded");
                return;
            }
            
            String fileName = filePart.getSubmittedFileName();
            if (!fileName.toLowerCase().endsWith(".csv")) {
                response.sendRedirect("index.jsp?error=Only CSV files are allowed");
                return;
            }
            
            System.out.println("Processing file: " + fileName);
            
            // Process CSV
            InputStream fileContent = filePart.getInputStream();
            CSVProcessor csvProcessor = new CSVProcessor();
            List<Transaction> transactions = csvProcessor.processCSV(fileContent);
            
            if (transactions.isEmpty()) {
                response.sendRedirect("index.jsp?error=No valid transactions found in CSV");
                return;
            }
            
            // Run graph analysis
            GraphAnalyzer analyzer = new GraphAnalyzer();
            Map<String, Account> accounts = analyzer.buildGraph(transactions);
            List<FraudRing> rings = analyzer.detectAllPatterns(accounts, transactions);
            Map<String, Double> scores = analyzer.calculateScores(accounts, rings);
            
            long processingTime = System.currentTimeMillis() - startTime;
            double processingTimeSeconds = processingTime / 1000.0;
            
            System.out.println("Analysis completed in " + processingTime + "ms");
            System.out.println("Found " + rings.size() + " fraud rings");
            System.out.println("Found " + scores.size() + " suspicious accounts");
            
            // Generate JSON output
            JSONGenerator jsonGen = new JSONGenerator();
            String outputJson = jsonGen.generateOutputJSON(accounts, rings, processingTime);
            
            // Store in session
            HttpSession session = request.getSession();
            session.setAttribute("analysisResult", outputJson);
            session.setAttribute("accounts", accounts);
            session.setAttribute("rings", rings);
            session.setAttribute("transactions", transactions);
            session.setAttribute("processingTime", processingTimeSeconds);
            
            // Redirect to dashboard
            response.sendRedirect("dashboard.jsp");
            
        } catch (Exception e) {
            e.printStackTrace();
            String errorMsg = e.getMessage().replaceAll("[^a-zA-Z0-9\\s]", " ");
            response.sendRedirect("error.jsp?message=" + errorMsg);
        }
    }
}
