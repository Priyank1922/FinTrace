package com.finTrace.service;

import com.finTrace.model.Account;
import com.finTrace.model.Transaction;
import com.finTrace.model.FraudRing;
import java.time.LocalDateTime;
import java.time.temporal.ChronoUnit;
import java.util.*;
import java.util.stream.Collectors;

public class SmurfingDetector {
    
    private static final int FAN_IN_THRESHOLD = 10;
    private static final int FAN_OUT_THRESHOLD = 10;
    private static final int TIME_WINDOW_HOURS = 72;
    private static final double SMALL_AMOUNT_THRESHOLD = 10000;
    
    public List<FraudRing> detectSmurfing(Map<String, Account> accounts, 
                                          List<Transaction> transactions) {
        List<FraudRing> rings = new ArrayList<>();
        
        // Group transactions by time windows (72-hour periods)
        Map<LocalDateTime, List<Transaction>> timeWindows = groupByTimeWindow(transactions);
        
        for (Map.Entry<LocalDateTime, List<Transaction>> entry : timeWindows.entrySet()) {
            LocalDateTime windowStart = entry.getKey();
            List<Transaction> windowTxs = entry.getValue();
            
            System.out.println("Analyzing time window: " + windowStart + 
                             " with " + windowTxs.size() + " transactions");
            
            // Detect fan-in patterns
            List<FraudRing> fanInRings = detectFanIn(windowTxs, windowStart);
            rings.addAll(fanInRings);
            
            // Detect fan-out patterns
            List<FraudRing> fanOutRings = detectFanOut(windowTxs, windowStart);
            rings.addAll(fanOutRings);
        }
        
        // Assign ring IDs
        for (int i = 0; i < rings.size(); i++) {
            FraudRing ring = rings.get(i);
            String prefix = ring.getPatternType().equals("fan_in") ? "FANIN" : "FANOUT";
            ring.setRingId("RING_" + prefix + "_" + (i + 1));
        }
        System.out.println("  SmurfingDetector: Analyzing " + transactions.size() + " transactions");        // ...  code ...
        System.out.println("  SmurfingDetector: Found " + rings.size() + " smurfing rings");
        
        return rings;
    }
    
    private Map<LocalDateTime, List<Transaction>> groupByTimeWindow(List<Transaction> transactions) {
        Map<LocalDateTime, List<Transaction>> windows = new HashMap<>();
        
        for (Transaction t : transactions) {
            // Round down to the start of the 72-hour window
            LocalDateTime windowStart = t.getTimestamp()
                .truncatedTo(ChronoUnit.HOURS)
                .withHour(0)
                .withMinute(0)
                .withSecond(0)
                .withNano(0);
            
            windows.computeIfAbsent(windowStart, k -> new ArrayList<>()).add(t);
        }
        
        return windows;
    }
    
    private List<FraudRing> detectFanIn(List<Transaction> transactions, LocalDateTime windowStart) {
        List<FraudRing> rings = new ArrayList<>();
        
        // Group by receiver
        Map<String, List<Transaction>> byReceiver = transactions.stream()
            .collect(Collectors.groupingBy(Transaction::getReceiverId));
        
        for (Map.Entry<String, List<Transaction>> entry : byReceiver.entrySet()) {
            String receiverId = entry.getKey();
            List<Transaction> txs = entry.getValue();
            
            // Count unique senders
            Set<String> uniqueSenders = txs.stream()
                .map(Transaction::getSenderId)
                .collect(Collectors.toSet());
            
            if (uniqueSenders.size() >= FAN_IN_THRESHOLD) {
                // Check if amounts are small (smurfing characteristic)
                boolean allSmallAmounts = txs.stream()
                    .allMatch(t -> t.getAmount() < SMALL_AMOUNT_THRESHOLD);
                
                // Check if transactions are rapid (within hours)
                boolean rapidTransactions = areRapidTransactions(txs);
                
                if (allSmallAmounts && rapidTransactions) {
                    FraudRing ring = new FraudRing("", "fan_in");
                    List<String> members = new ArrayList<>(uniqueSenders);
                    members.add(receiverId);
                    ring.setMemberAccounts(members);
                    ring.setRiskScore(calculateFanInRiskScore(uniqueSenders.size(), txs.size()));
                    rings.add(ring);
                    
                    System.out.println("Detected fan-in ring: " + receiverId + 
                                     " with " + uniqueSenders.size() + " senders");
                }
            }
        }
        
        return rings;
    }
    
    private List<FraudRing> detectFanOut(List<Transaction> transactions, LocalDateTime windowStart) {
        List<FraudRing> rings = new ArrayList<>();
        
        // Group by sender
        Map<String, List<Transaction>> bySender = transactions.stream()
            .collect(Collectors.groupingBy(Transaction::getSenderId));
        
        for (Map.Entry<String, List<Transaction>> entry : bySender.entrySet()) {
            String senderId = entry.getKey();
            List<Transaction> txs = entry.getValue();
            
            // Count unique receivers
            Set<String> uniqueReceivers = txs.stream()
                .map(Transaction::getReceiverId)
                .collect(Collectors.toSet());
            
            if (uniqueReceivers.size() >= FAN_OUT_THRESHOLD) {
                // Check if amounts are small
                boolean allSmallAmounts = txs.stream()
                    .allMatch(t -> t.getAmount() < SMALL_AMOUNT_THRESHOLD);
                
                // Check if transactions are rapid
                boolean rapidTransactions = areRapidTransactions(txs);
                
                if (allSmallAmounts && rapidTransactions) {
                    FraudRing ring = new FraudRing("", "fan_out");
                    List<String> members = new ArrayList<>(uniqueReceivers);
                    members.add(senderId);
                    ring.setMemberAccounts(members);
                    ring.setRiskScore(calculateFanOutRiskScore(uniqueReceivers.size(), txs.size()));
                    rings.add(ring);
                    
                    System.out.println("Detected fan-out ring: " + senderId + 
                                     " with " + uniqueReceivers.size() + " receivers");
                }
            }
        }
        
        return rings;
    }
    
    private boolean areRapidTransactions(List<Transaction> transactions) {
        if (transactions.size() < 2) return false;
        
        // Sort by timestamp
        List<Transaction> sorted = new ArrayList<>(transactions);
        sorted.sort(Comparator.comparing(Transaction::getTimestamp));
        
        // Check if all transactions within 24 hours
        LocalDateTime first = sorted.get(0).getTimestamp();
        LocalDateTime last = sorted.get(sorted.size() - 1).getTimestamp();
        
        long hoursBetween = ChronoUnit.HOURS.between(first, last);
        return hoursBetween <= 24;
    }
    
    private double calculateFanInRiskScore(int senderCount, int txCount) {
        double baseScore = 75.0;
        double senderBonus = Math.min(15, senderCount - FAN_IN_THRESHOLD);
        double txBonus = Math.min(10, txCount / 10.0);
        return Math.min(100, baseScore + senderBonus + txBonus);
    }
    
    private double calculateFanOutRiskScore(int receiverCount, int txCount) {
        double baseScore = 70.0;
        double receiverBonus = Math.min(15, receiverCount - FAN_OUT_THRESHOLD);
        double txBonus = Math.min(10, txCount / 10.0);
        return Math.min(100, baseScore + receiverBonus + txBonus);
    }
}