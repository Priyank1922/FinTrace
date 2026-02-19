package com.finTrace.model;

import java.util.*;

public class Account {
    private String accountId;
    private List<Transaction> outgoingTransactions = new ArrayList<>();
    private List<Transaction> incomingTransactions = new ArrayList<>();
    private double totalSent;
    private double totalReceived;
    private int transactionCount;
    private double suspicionScore;
    private String ringId;
    private Set<String> detectedPatterns = new HashSet<>();
    
    public Account(String accountId) {
        this.accountId = accountId;
    }
    
    // Getters and Setters
    public String getAccountId() { return accountId; }
    public void setAccountId(String accountId) { this.accountId = accountId; }
    
    public List<Transaction> getOutgoingTransactions() { return outgoingTransactions; }
    public void setOutgoingTransactions(List<Transaction> outgoingTransactions) { 
        this.outgoingTransactions = outgoingTransactions; 
    }
    
    public List<Transaction> getIncomingTransactions() { return incomingTransactions; }
    public void setIncomingTransactions(List<Transaction> incomingTransactions) { 
        this.incomingTransactions = incomingTransactions; 
    }
    
    public double getTotalSent() { return totalSent; }
    public void setTotalSent(double totalSent) { this.totalSent = totalSent; }
    
    public double getTotalReceived() { return totalReceived; }
    public void setTotalReceived(double totalReceived) { this.totalReceived = totalReceived; }
    
    public int getTransactionCount() { return transactionCount; }
    public void setTransactionCount(int transactionCount) { this.transactionCount = transactionCount; }
    
    public double getSuspicionScore() { return suspicionScore; }
    public void setSuspicionScore(double suspicionScore) { this.suspicionScore = suspicionScore; }
    
    public String getRingId() { return ringId; }
    public void setRingId(String ringId) { this.ringId = ringId; }
    
    public Set<String> getDetectedPatterns() { return detectedPatterns; }
    public void setDetectedPatterns(Set<String> detectedPatterns) { 
        this.detectedPatterns = detectedPatterns; 
    }
    
    public void addOutgoingTransaction(Transaction t) {
        outgoingTransactions.add(t);
        totalSent += t.getAmount();
        transactionCount++;
    }
    
    public void addIncomingTransaction(Transaction t) {
        incomingTransactions.add(t);
        totalReceived += t.getAmount();
        transactionCount++;
    }
    
    @Override
    public String toString() {
        return String.format("Account{id='%s', txCount=%d, score=%.2f, ring='%s'}", 
            accountId, transactionCount, suspicionScore, ringId);
    }
}