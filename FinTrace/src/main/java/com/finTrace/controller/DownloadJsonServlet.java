package com.finTrace.controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.*;

@WebServlet("/downloadJson")
public class DownloadJsonServlet extends HttpServlet {
    
    protected void doGet(HttpServletRequest request, 
                         HttpServletResponse response) 
            throws ServletException, IOException {
        
        HttpSession session = request.getSession(false);
        if (session == null) {
            response.sendRedirect("index.jsp?error=Session expired");
            return;
        }
        
        String jsonOutput = (String) session.getAttribute("analysisResult");
        if (jsonOutput == null) {
            response.sendRedirect("index.jsp?error=No analysis found");
            return;
        }
        
        // Set response headers
        response.setContentType("application/json");
        response.setHeader("Content-Disposition", 
            "attachment; filename=\"finTrace_analysis.json\"");
        
        // Write JSON
        try (PrintWriter out = response.getWriter()) {
            out.print(jsonOutput);
            out.flush();
        }
    }
}