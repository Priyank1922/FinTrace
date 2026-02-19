package com.finTrace.service;

import com.finTrace.model.Account;
import com.finTrace.model.Transaction;
import com.finTrace.model.FraudRing;
import com.finTrace.util.GraphUtils;
import java.util.*;

public class GraphAnalyzer {
    
    private CycleDetector cycleDetector;
    private SmurfingDetector smurfingDetector;
    private ShellNetworkDetector shellDetector;
    private SuspicionScorer suspicionScorer;
    
    public GraphAnalyzer() {
        this.cycleDetector = new CycleDetector();
        this.smurfingDetector = new SmurfingDetector();
        this.shellDetector = new ShellNetworkDetector();
        this.suspicionScorer = new SuspicionScorer();
    }
    
    public Map<String, Account> buildGraph(List<Transaction> transactions) {
        return GraphUtils.buildGraph(transactions);
    }
    
    public List<FraudRing> detectAllPatterns(Map<String, Account> accounts, 
                                             List<Transaction> transactions) {
        List<FraudRing> allRings = new ArrayList<>();
        
        System.out.println("Starting cycle detection...");
        List<FraudRing> cycleRings = cycleDetector.detectCycles(accounts, transactions);
        System.out.println("Found " + cycleRings.size() + " cycle rings");
        allRings.addAll(cycleRings);
        
        System.out.println("Starting smurfing detection...");
        List<FraudRing> smurfingRings = smurfingDetector.detectSmurfing(accounts, transactions);
        System.out.println("Found " + smurfingRings.size() + " smurfing rings");
        allRings.addAll(smurfingRings);
        
        System.out.println("Starting shell network detection...");
        List<FraudRing> shellRings = shellDetector.detectShellNetworks(accounts, transactions);
        System.out.println("Found " + shellRings.size() + " shell rings");
        allRings.addAll(shellRings);
        
        // Remove duplicate rings
        allRings = removeDuplicates(allRings);
        System.out.println("Total unique rings: " + allRings.size());
        
        return allRings;
    }
    
    public Map<String, Double> calculateScores(Map<String, Account> accounts,
                                               List<FraudRing> rings) {
        return suspicionScorer.calculateScores(accounts, rings);
    }
    
    private List<FraudRing> removeDuplicates(List<FraudRing> rings) {
        Set<String> seen = new HashSet<>();
        List<FraudRing> unique = new ArrayList<>();
        
        for (FraudRing ring : rings) {
            // Create a key based on members and pattern type
            List<String> sortedMembers = new ArrayList<>(ring.getMemberAccounts());
            Collections.sort(sortedMembers);
            String key = ring.getPatternType() + ":" + String.join(",", sortedMembers);
            
            if (!seen.contains(key)) {
                seen.add(key);
                unique.add(ring);
            }
        }
        
        return unique;
    }
    private List<FraudRing> removeDuplicates1(List<FraudRing> rings) {
        Set<String> seen = new HashSet<>();
        List<FraudRing> unique = new ArrayList<>();
        
        // Sort by risk score (keep highest scoring rings)
        rings.sort((a, b) -> Double.compare(b.getRiskScore(), a.getRiskScore()));
        
        for (FraudRing ring : rings) {
            // Create a sorted key of members
            List<String> sortedMembers = new ArrayList<>(ring.getMemberAccounts());
            Collections.sort(sortedMembers);
            String memberKey = String.join("-", sortedMembers);
            
            // Also create a pattern-specific key
            String patternKey = ring.getPatternType() + ":" + memberKey;
            
            if (!seen.contains(patternKey)) {
                seen.add(patternKey);
                unique.add(ring);
            }
        }
        
        return unique;
    }
}