package com.finTrace.model;

import java.util.*;

public class FraudRing {
    private String ringId;
    private List<String> memberAccounts = new ArrayList<>();
    private String patternType; // "cycle", "fan_in", "fan_out", "shell_chain"
    private double riskScore;
    private int memberCount;
    
    public FraudRing(String ringId, String patternType) {
        this.ringId = ringId;
        this.patternType = patternType;
    }
    
    // Getters and Setters
    public String getRingId() { return ringId; }
    public void setRingId(String ringId) { this.ringId = ringId; }
    
    public List<String> getMemberAccounts() { return memberAccounts; }
    public void setMemberAccounts(List<String> memberAccounts) { 
        this.memberAccounts = memberAccounts;
        this.memberCount = memberAccounts.size();
    }
    
    public String getPatternType() { return patternType; }
    public void setPatternType(String patternType) { this.patternType = patternType; }
    
    public double getRiskScore() { return riskScore; }
    public void setRiskScore(double riskScore) { this.riskScore = riskScore; }
    
    public int getMemberCount() { return memberCount; }
    public void setMemberCount(int memberCount) { this.memberCount = memberCount; }
    
    @Override
    public String toString() {
        return String.format("FraudRing{id='%s', type='%s', members=%d, risk=%.2f}", 
            ringId, patternType, memberCount, riskScore);
    }
}