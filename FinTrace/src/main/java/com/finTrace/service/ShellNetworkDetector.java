package com.finTrace.service;

import com.finTrace.model.Account;
import com.finTrace.model.Transaction;
import com.finTrace.model.FraudRing;
import java.util.*;

public class ShellNetworkDetector {
    
    private static final int MIN_CHAIN_LENGTH = 3;
    private static final int MAX_SHELL_TX_COUNT = 3;
    private Set<String> processedChains = new HashSet<>();
    

    private boolean isAlreadyInCycle(List<String> chain, List<FraudRing> existingRings) {
        for (FraudRing ring : existingRings) {
            if (ring.getPatternType().equals("cycle")) {
                // Check if this chain is a subset of a cycle
                Set<String> cycleMembers = new HashSet<>(ring.getMemberAccounts());
                Set<String> chainMembers = new HashSet<>(chain);
                
                // If chain is part of a cycle, skip it
                if (cycleMembers.containsAll(chainMembers) && chainMembers.size() >= 3) {
                    return true;
                }
            }
        }
        return false;
    }
    
    public List<FraudRing> detectShellNetworks(Map<String, Account> accounts, 
                                                List<Transaction> transactions) {
        List<FraudRing> rings = new ArrayList<>();
        processedChains.clear();
        
        // Build transaction graph
        Map<String, List<String>> graph = new HashMap<>();
        for (Transaction t : transactions) {
            graph.computeIfAbsent(t.getSenderId(), k -> new ArrayList<>())
                 .add(t.getReceiverId());
        }
        
        // Find chains from each starting point
        for (String startNode : graph.keySet()) {
            findChains(startNode, new ArrayList<>(), graph, accounts, rings);
        }
        
        // Remove duplicates
        rings = removeDuplicateChains(rings);
        
        // Assign ring IDs and calculate risk scores
        for (int i = 0; i < rings.size(); i++) {
            FraudRing ring = rings.get(i);
            ring.setRingId("RING_SHELL_" + (i + 1));
            ring.setRiskScore(calculateShellRiskScore(ring.getMemberAccounts(), accounts));
        }
        System.out.println("  ShellDetector: Looking for chains...");
        System.out.println("  ShellDetector: Found " + rings.size() + " shell chains");
        
        return rings;
    }
    
    private void findChains(String current, List<String> path,
                           Map<String, List<String>> graph,
                           Map<String, Account> accounts,
                           List<FraudRing> rings) {
        
        if (path.contains(current)) return; // Avoid cycles
        
        path.add(current);
        
        // Check if we have a valid chain
        if (path.size() >= MIN_CHAIN_LENGTH) {
            if (isShellChain(path, accounts)) {
                String chainKey = getChainKey(path);
                if (!processedChains.contains(chainKey)) {
                    processedChains.add(chainKey);
                    
                    FraudRing ring = new FraudRing("", "shell_chain");
                    ring.setMemberAccounts(new ArrayList<>(path));
                    rings.add(ring);
                }
            }
        }
        
        // Continue exploring
        List<String> neighbors = graph.getOrDefault(current, new ArrayList<>());
        for (String neighbor : neighbors) {
            if (!path.contains(neighbor)) {
                findChains(neighbor, new ArrayList<>(path), graph, accounts, rings);
            }
        }
    }
    
    private boolean isShellChain(List<String> path, Map<String, Account> accounts) {
        // Check intermediate accounts (excluding first and last)
        for (int i = 1; i < path.size() - 1; i++) {
            Account acc = accounts.get(path.get(i));
            if (acc.getTransactionCount() > MAX_SHELL_TX_COUNT) {
                return false; // Not a shell account (too many transactions)
            }
            
            // Check if account has both incoming and outgoing (typical for shell)
            if (acc.getIncomingTransactions().isEmpty() || 
                acc.getOutgoingTransactions().isEmpty()) {
                return false;
            }
        }
        
        return true;
    }
    
    private String getChainKey(List<String> chain) {
        return String.join("->", chain);
    }
    
    private List<FraudRing> removeDuplicateChains(List<FraudRing> rings) {
        Set<String> seen = new HashSet<>();
        List<FraudRing> unique = new ArrayList<>();
        
        for (FraudRing ring : rings) {
            String key = getChainKey(ring.getMemberAccounts());
            if (!seen.contains(key)) {
                seen.add(key);
                unique.add(ring);
            }
        }
        
        return unique;
    }
    
    private double calculateShellRiskScore(List<String> members, Map<String, Account> accounts) {
        double baseScore = 65.0;
        
        // Longer chains are more suspicious
        double lengthBonus = Math.min(20, (members.size() - 2) * 5);
        
        // Check if amounts are increasing (layering)
        boolean increasingAmounts = checkIncreasingAmounts(members, accounts);
        if (increasingAmounts) {
            baseScore += 15;
        }
        
        return Math.min(100, baseScore + lengthBonus);
    }
    
    private boolean checkIncreasingAmounts(List<String> members, Map<String, Account> accounts) {
        for (int i = 0; i < members.size() - 1; i++) {
            String from = members.get(i);
            String to = members.get(i + 1);
            
            Account fromAcc = accounts.get(from);
            
            // Find transaction from 'from' to 'to'
            double amount = 0;
            for (Transaction t : fromAcc.getOutgoingTransactions()) {
                if (t.getReceiverId().equals(to)) {
                    amount = t.getAmount();
                    break;
                }
            }
            
            if (i > 0) {
                // Compare with previous amount
                String prevFrom = members.get(i - 1);
                Account prevAcc = accounts.get(prevFrom);
                double prevAmount = 0;
                
                for (Transaction t : prevAcc.getOutgoingTransactions()) {
                    if (t.getReceiverId().equals(from)) {
                        prevAmount = t.getAmount();
                        break;
                    }
                }
                
                if (amount <= prevAmount) {
                    return false; // Amounts should increase for typical layering
                }
            }
        }
        
        return true;
    }
}