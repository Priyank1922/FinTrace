package com.finTrace.controller;

import com.finTrace.model.Account;
import com.finTrace.model.Transaction;
import com.finTrace.model.FraudRing;
import com.google.gson.JsonArray;
import com.google.gson.JsonObject;
import com.google.gson.Gson;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.*;
import java.util.*;

@WebServlet("/graphData")
public class GraphDataServlet extends HttpServlet {
    
    protected void doGet(HttpServletRequest request, 
                         HttpServletResponse response) 
            throws ServletException, IOException {
        
        HttpSession session = request.getSession(false);
        if (session == null) {
            response.setStatus(404);
            response.getWriter().write("{\"error\":\"No session\"}");
            return;
        }
        
        Map<String, Account> accounts = (Map<String, Account>) 
            session.getAttribute("accounts");
        List<Transaction> transactions = (List<Transaction>) 
            session.getAttribute("transactions");
        
        if (accounts == null || transactions == null) {
            response.setStatus(404);
            response.getWriter().write("{\"error\":\"No data\"}");
            return;
        }
        
        // Build graph data
        JsonObject graphData = new JsonObject();
        JsonArray nodes = new JsonArray();
        JsonArray edges = new JsonArray();
        
        // Create nodes
        for (Account acc : accounts.values()) {
            JsonObject node = new JsonObject();
            node.addProperty("id", acc.getAccountId());
            node.addProperty("label", acc.getAccountId());
            
            // Color based on suspicion
            if (acc.getSuspicionScore() > 80) {
                node.addProperty("color", "#ff4444");
                node.addProperty("size", 30);
            } else if (acc.getSuspicionScore() > 50) {
                node.addProperty("color", "#ffaa00");
                node.addProperty("size", 25);
            } else {
                node.addProperty("color", "#97c2fc");
                node.addProperty("size", 20);
            }
            
            // Tooltip
            String title = String.format(
                "Account: %s<br>Score: %.1f<br>Patterns: %s",
                acc.getAccountId(),
                acc.getSuspicionScore(),
                String.join(", ", acc.getDetectedPatterns())
            );
            node.addProperty("title", title);
            
            nodes.add(node);
        }
        
        // Create edges
        for (Transaction t : transactions) {
            JsonObject edge = new JsonObject();
            edge.addProperty("from", t.getSenderId());
            edge.addProperty("to", t.getReceiverId());
            edge.addProperty("label", String.format("$%.0f", t.getAmount()));
            
            String title = String.format(
                "ID: %s<br>Amount: $%.2f<br>Time: %s",
                t.getTransactionId(),
                t.getAmount(),
                t.getTimestamp()
            );
            edge.addProperty("title", title);
            
            edges.add(edge);
        }
        
        graphData.add("nodes", nodes);
        graphData.add("edges", edges);
        
        // Send response
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        
        Gson gson = new Gson();
        gson.toJson(graphData, response.getWriter());
    }
}