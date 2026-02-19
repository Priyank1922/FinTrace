package com.finTrace.util;

import com.finTrace.model.Account;
import com.finTrace.model.Transaction;
import java.util.*;

public class GraphUtils {
    
    public static Map<String, Account> buildGraph(List<Transaction> transactions) {
        Map<String, Account> accountMap = new HashMap<>();
        
        for (Transaction t : transactions) {
            // Get or create sender account
            Account sender = accountMap.computeIfAbsent(
                t.getSenderId(), k -> new Account(t.getSenderId()));
            
            // Get or create receiver account
            Account receiver = accountMap.computeIfAbsent(
                t.getReceiverId(), k -> new Account(t.getReceiverId()));
            
            // Add transactions
            sender.addOutgoingTransaction(t);
            receiver.addIncomingTransaction(t);
        }
        
        return accountMap;
    }
    
    public static Map<String, List<String>> buildAdjacencyList(List<Transaction> transactions) {
        Map<String, List<String>> graph = new HashMap<>();
        
        for (Transaction t : transactions) {
            graph.computeIfAbsent(t.getSenderId(), k -> new ArrayList<>())
                 .add(t.getReceiverId());
        }
        
        return graph;
    }
    
    public static Map<String, List<String>> buildReverseAdjacencyList(List<Transaction> transactions) {
        Map<String, List<String>> reverseGraph = new HashMap<>();
        
        for (Transaction t : transactions) {
            reverseGraph.computeIfAbsent(t.getReceiverId(), k -> new ArrayList<>())
                       .add(t.getSenderId());
        }
        
        return reverseGraph;
    }
    
    public static Set<String> getAllAccounts(List<Transaction> transactions) {
        Set<String> accounts = new HashSet<>();
        
        for (Transaction t : transactions) {
            accounts.add(t.getSenderId());
            accounts.add(t.getReceiverId());
        }
        
        return accounts;
    }
    
    public static Map<String, Integer> calculateDegrees(Map<String, List<String>> graph) {
        Map<String, Integer> degrees = new HashMap<>();
        
        for (Map.Entry<String, List<String>> entry : graph.entrySet()) {
            degrees.put(entry.getKey(), entry.getValue().size());
        }
        
        return degrees;
    }
}