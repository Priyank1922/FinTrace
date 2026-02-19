package com.finTrace.service;

import com.finTrace.model.Account;
import com.finTrace.model.Transaction;
import com.finTrace.model.FraudRing;
import java.util.*;

public class CycleDetector {
    
    private static final int MIN_CYCLE_LENGTH = 3;
    private static final int MAX_CYCLE_LENGTH = 5;
    private Set<String> processedCycles = new HashSet<>();
    
    
    
    public List<FraudRing> detectCycles(Map<String, Account> accounts, 
                                        List<Transaction> transactions) {
        List<FraudRing> rings = new ArrayList<>();
        processedCycles.clear();
        int cycleCount = 0;
        System.out.println("  CycleDetector: Found " + rings.size() + " cycles");

        // Build adjacency list
        Map<String, List<String>> graph = new HashMap<>();
        for (Transaction t : transactions) {
            graph.computeIfAbsent(t.getSenderId(), k -> new ArrayList<>())
                 .add(t.getReceiverId());
        }
        
        // Detect cycles from each node
        for (String startNode : graph.keySet()) {
            findCycles(startNode, startNode, new ArrayList<>(), graph, rings);
        }
        
        // Remove duplicate cycles
        rings = removeDuplicateRings(rings);
        
        // Assign ring IDs and calculate risk scores
        for (int i = 0; i < rings.size(); i++) {
            FraudRing ring = rings.get(i);
            ring.setRingId("RING_CYCLE_" + (i + 1));
            ring.setRiskScore(calculateCycleRiskScore(ring.getMemberAccounts(), accounts));
        }
        
        return rings;
    }
    
    private void findCycles(String start, String current, List<String> path,
                           Map<String, List<String>> graph, List<FraudRing> rings) {
        
        if (path.size() > MAX_CYCLE_LENGTH) return;
        
        if (path.size() >= MIN_CYCLE_LENGTH && current.equals(start)) {
            // Found a cycle
            List<String> cycle = new ArrayList<>(path);
            String cycleKey = getCycleKey(cycle);
            
            if (!processedCycles.contains(cycleKey)) {
                processedCycles.add(cycleKey);
                
                FraudRing ring = new FraudRing("", "cycle");
                ring.setMemberAccounts(cycle);
                rings.add(ring);
            }
            return;
        }
        
        if (path.contains(current)) return;
        
        path.add(current);
        
        List<String> neighbors = graph.getOrDefault(current, new ArrayList<>());
        for (String neighbor : neighbors) {
            findCycles(start, neighbor, new ArrayList<>(path), graph, rings);
        }
    }
    
    private String getCycleKey(List<String> cycle) {
        // Create a canonical representation of the cycle (sorted)
        List<String> sorted = new ArrayList<>(cycle);
        Collections.sort(sorted);
        return String.join("-", sorted);
    }
    
    private List<FraudRing> removeDuplicateRings(List<FraudRing> rings) {
        Set<String> seen = new HashSet<>();
        List<FraudRing> unique = new ArrayList<>();
        
        for (FraudRing ring : rings) {
            String key = getCycleKey(ring.getMemberAccounts());
            if (!seen.contains(key)) {
                seen.add(key);
                unique.add(ring);
            }
        }
        
        return unique;
    }
    
    private double calculateCycleRiskScore(List<String> members, Map<String, Account> accounts) {
        double baseScore = 70.0;
        
        // Longer cycles are more suspicious
        double lengthBonus = Math.min(20, members.size() * 3);
        
        // Check transaction velocity
        double velocityScore = 0;
        int totalTx = 0;
        
        for (String memberId : members) {
            Account acc = accounts.get(memberId);
            totalTx += acc.getTransactionCount();
        }
        
        if (totalTx > members.size() * 5) {
            velocityScore = 10;
        }
        
        return Math.min(100, baseScore + lengthBonus + velocityScore);
    }
    
    
}