package com.finTrace.controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.*;

@WebServlet("/downloadSample")  // This maps to /downloadSample URL
public class DownloadSampleServlet extends HttpServlet {
    
    protected void doGet(HttpServletRequest request, 
                         HttpServletResponse response) 
            throws ServletException, IOException {
        
        System.out.println("DownloadSampleServlet called"); // Debug log
        
        // Get path to the sample file
        String filePath = getServletContext().getRealPath("/") + "sample_transactions.csv";
        System.out.println("Looking for file at: " + filePath); // Debug log
        
        File file = new File(filePath);
        
        if (file.exists()) {
            System.out.println("File found, sending to client..."); // Debug log
            
            response.setContentType("text/csv");
            response.setHeader("Content-Disposition", 
                "attachment; filename=\"sample_transactions.csv\"");
            response.setContentLengthLong(file.length());
            
            // Send file to browser
            try (FileInputStream fis = new FileInputStream(file);
                 OutputStream os = response.getOutputStream()) {
                byte[] buffer = new byte[4096];
                int bytesRead;
                while ((bytesRead = fis.read(buffer)) != -1) {
                    os.write(buffer, 0, bytesRead);
                }
                os.flush();
            }
            System.out.println("File sent successfully"); // Debug log
        } else {
            System.out.println("File NOT found!"); // Debug log
            response.sendError(404, "Sample file not found. Please ensure sample_transactions.csv exists in the WebContent folder.");
        }
    }
}