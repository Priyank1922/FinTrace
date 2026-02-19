package com.finTrace.service;

import com.finTrace.model.Account;
import com.finTrace.model.Transaction;
import com.finTrace.model.FraudRing;
import java.time.LocalDateTime;
import java.time.temporal.ChronoUnit;
import java.util.*;

public class SuspicionScorer {
    
    private static final double SUSPICION_THRESHOLD = 50.0;
    
    public Map<String, Double> calculateScores(Map<String, Account> accounts,
                                                List<FraudRing> rings) {
        Map<String, Double> scores = new HashMap<>();
        
        // First, mark accounts that belong to rings
        markRingMembers(accounts, rings);
        
        for (Account account : accounts.values()) {
            double score = 0.0;
            List<String> patterns = new ArrayList<>();
            
            // 1. Ring membership (highest weight)
            if (account.getRingId() != null) {
                score += 40;
                patterns.add("ring_member");
                
                // Find the ring and add its pattern
                for (FraudRing ring : rings) {
                    if (ring.getRingId().equals(account.getRingId())) {
                        patterns.add(ring.getPatternType());
                        break;
                    }
                }
            }
            
            // 2. Transaction velocity
            double velocityScore = calculateVelocityScore(account);
            score += velocityScore;
            if (velocityScore > 10) {
                patterns.add("high_velocity");
            }
            
            // 3. Amount patterns (round numbers, just below thresholds)
            double amountPatternScore = calculateAmountPatternScore(account);
            score += amountPatternScore;
            if (amountPatternScore > 5) {
                patterns.add("suspicious_amounts");
            }
            
            // 4. Time patterns (odd hours)
            double timePatternScore = calculateTimePatternScore(account);
            score += timePatternScore;
            if (timePatternScore > 5) {
                patterns.add("odd_hours");
            }
            
            // 5. Balance/volume ratio
            double balanceRatioScore = calculateBalanceRatioScore(account);
            score += balanceRatioScore;
            if (balanceRatioScore > 5) {
                patterns.add("low_balance_high_volume");
            }
            
            // 6. Rapid money movement (in-out within short time)
            double rapidMovementScore = calculateRapidMovementScore(account);
            score += rapidMovementScore;
            if (rapidMovementScore > 5) {
                patterns.add("rapid_movement");
            }
            
            // Normalize to 0-100
            score = Math.min(100, score);
            
            // Store patterns and score
            account.getDetectedPatterns().addAll(patterns);
            account.setSuspicionScore(score);
            
            if (score > SUSPICION_THRESHOLD) {
                scores.put(account.getAccountId(), score);
            }
        }
        
        return scores;
    }
    
    private void markRingMembers(Map<String, Account> accounts, List<FraudRing> rings) {
        for (FraudRing ring : rings) {
            for (String memberId : ring.getMemberAccounts()) {
                Account acc = accounts.get(memberId);
                if (acc != null) {
                    acc.setRingId(ring.getRingId());
                }
            }
        }
    }
    
    private double calculateVelocityScore(Account account) {
        int txCount = account.getTransactionCount();
        
        if (txCount > 50) return 20;
        if (txCount > 30) return 15;
        if (txCount > 20) return 10;
        if (txCount > 10) return 5;
        
        return 0;
    }
    
    private double calculateAmountPatternScore(Account account) {
        double score = 0;
        int roundNumberCount = 0;
        int justBelowThresholdCount = 0;
        int totalTx = 0;
        
        // Check outgoing
        for (Transaction t : account.getOutgoingTransactions()) {
            totalTx++;
            double amount = t.getAmount();
            
            // Round numbers (1000, 5000, 10000)
            if (amount % 1000 == 0 || amount % 5000 == 0) {
                roundNumberCount++;
            }
            
            // Just below thresholds (9999, 49999, etc.)
            if (amount > 9000 && amount < 10000 ||
                amount > 49000 && amount < 50000 ||
                amount > 99000 && amount < 100000) {
                justBelowThresholdCount++;
            }
        }
        
        // Check incoming
        for (Transaction t : account.getIncomingTransactions()) {
            totalTx++;
            double amount = t.getAmount();
            
            if (amount % 1000 == 0 || amount % 5000 == 0) {
                roundNumberCount++;
            }
            
            if (amount > 9000 && amount < 10000 ||
                amount > 49000 && amount < 50000 ||
                amount > 99000 && amount < 100000) {
                justBelowThresholdCount++;
            }
        }
        
        if (totalTx > 0) {
            double roundPercentage = (double) roundNumberCount / totalTx;
            double thresholdPercentage = (double) justBelowThresholdCount / totalTx;
            
            if (roundPercentage > 0.5) score += 10;
            if (thresholdPercentage > 0.3) score += 10;
        }
        
        return score;
    }
    
    private double calculateTimePatternScore(Account account) {
        int oddHourCount = 0;
        int weekendCount = 0;
        int totalTx = 0;
        
        // Check outgoing
        for (Transaction t : account.getOutgoingTransactions()) {
            totalTx++;
            LocalDateTime time = t.getTimestamp();
            int hour = time.getHour();
            int dayOfWeek = time.getDayOfWeek().getValue();
            
            // Odd hours (1 AM - 5 AM)
            if (hour >= 1 && hour <= 5) {
                oddHourCount++;
            }
            
            // Weekend (Saturday or Sunday)
            if (dayOfWeek >= 6) {
                weekendCount++;
            }
        }
        
        // Check incoming
        for (Transaction t : account.getIncomingTransactions()) {
            totalTx++;
            LocalDateTime time = t.getTimestamp();
            int hour = time.getHour();
            int dayOfWeek = time.getDayOfWeek().getValue();
            
            if (hour >= 1 && hour <= 5) {
                oddHourCount++;
            }
            
            if (dayOfWeek >= 6) {
                weekendCount++;
            }
        }
        
        double score = 0;
        if (totalTx > 0) {
            double oddPercentage = (double) oddHourCount / totalTx;
            double weekendPercentage = (double) weekendCount / totalTx;
            
            if (oddPercentage > 0.3) score += 10;
            if (weekendPercentage > 0.4) score += 5;
        }
        
        return score;
    }
    
    private double calculateBalanceRatioScore(Account account) {
        double netFlow = account.getTotalReceived() - account.getTotalSent();
        double totalVolume = account.getTotalReceived() + account.getTotalSent();
        
        if (totalVolume > 100000 && netFlow < 1000) {
            return 15;
        } else if (totalVolume > 50000 && netFlow < 500) {
            return 10;
        } else if (totalVolume > 10000 && netFlow < 100) {
            return 5;
        }
        
        return 0;
    }
    
    private double calculateRapidMovementScore(Account account) {
        // Check if money comes in and goes out quickly
        int rapidMovements = 0;
        
        for (Transaction incoming : account.getIncomingTransactions()) {
            LocalDateTime inTime = incoming.getTimestamp();
            
            // Look for outgoing transactions within 1 hour
            for (Transaction outgoing : account.getOutgoingTransactions()) {
                if (outgoing.getTimestamp().isAfter(inTime)) {
                    long minutesBetween = ChronoUnit.MINUTES.between(inTime, outgoing.getTimestamp());
                    if (minutesBetween <= 60) {
                        rapidMovements++;
                        break;
                    }
                }
            }
        }
        
        if (rapidMovements > 5) return 15;
        if (rapidMovements > 3) return 10;
        if (rapidMovements > 1) return 5;
        
        return 0;
    }
}