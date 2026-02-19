 package com.finTrace.util;

import com.finTrace.model.Account;
import com.finTrace.model.FraudRing;
import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import com.google.gson.JsonObject;
import com.google.gson.JsonArray;
import java.util.*;

public class JSONGenerator {
    
    private final Gson gson;
    
    public JSONGenerator() {
        this.gson = new GsonBuilder().setPrettyPrinting().create();
    }
    
    public String generateOutputJSON(Map<String, Account> accounts,
                                      List<FraudRing> rings,
                                      long processingTimeMs) {
        
        JsonObject output = new JsonObject();
        
        // Suspicious accounts array
        JsonArray suspiciousAccounts = new JsonArray();
        
        // Sort accounts by suspicion score
        List<Account> sortedAccounts = new ArrayList<>(accounts.values());
        sortedAccounts.sort((a, b) -> Double.compare(b.getSuspicionScore(), a.getSuspicionScore()));
        
        for (Account acc : sortedAccounts) {
            if (acc.getSuspicionScore() > 50) { // Only include suspicious
                JsonObject accObj = new JsonObject();
                accObj.addProperty("account_id", acc.getAccountId());
                accObj.addProperty("suspicion_score", 
                    Math.round(acc.getSuspicionScore() * 10) / 10.0);
                
                // Detected patterns array
                JsonArray patterns = new JsonArray();
                for (String pattern : acc.getDetectedPatterns()) {
                    patterns.add(pattern);
                }
                accObj.add("detected_patterns", patterns);
                
                accObj.addProperty("ring_id", 
                    acc.getRingId() != null ? acc.getRingId() : "");
                
                suspiciousAccounts.add(accObj);
            }
        }
        
        output.add("suspicious_accounts", suspiciousAccounts);
        
        // Fraud rings array
        JsonArray fraudRings = new JsonArray();
        for (FraudRing ring : rings) {
            JsonObject ringObj = new JsonObject();
            ringObj.addProperty("ring_id", ring.getRingId());
            
            JsonArray members = new JsonArray();
            for (String member : ring.getMemberAccounts()) {
                members.add(member);
            }
            ringObj.add("member_accounts", members);
            
            ringObj.addProperty("pattern_type", ring.getPatternType());
            ringObj.addProperty("risk_score", 
                Math.round(ring.getRiskScore() * 10) / 10.0);
            
            fraudRings.add(ringObj);
        }
        output.add("fraud_rings", fraudRings);
        
        // Summary object
        JsonObject summary = new JsonObject();
        summary.addProperty("total_accounts_analyzed", accounts.size());
        summary.addProperty("suspicious_accounts_flagged", suspiciousAccounts.size());
        summary.addProperty("fraud_rings_detected", rings.size());
        summary.addProperty("processing_time_seconds", 
            Math.round((processingTimeMs / 1000.0) * 10) / 10.0);
        
        output.add("summary", summary);
        
        return gson.toJson(output);
    }
    
    public String generateSimpleJson(Map<String, Object> data) {
        return gson.toJson(data);
    }
}