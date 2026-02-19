package com.finTrace.service;

import com.finTrace.model.Transaction;
import com.finTrace.util.DatabaseConnection;
import com.opencsv.CSVReader;
import com.opencsv.exceptions.CsvException;
import java.io.*;
import java.sql.*;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.time.format.DateTimeParseException;
import java.util.*;

public class CSVProcessor {
    
    private static final DateTimeFormatter DATE_FORMATTER = 
        DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss");
    
    public List<Transaction> processCSV(InputStream inputStream) 
            throws IOException, CsvException, SQLException, ClassNotFoundException {
        
        List<Transaction> transactions = new ArrayList<>();
        Connection conn = null;
        
        try {
            conn = DatabaseConnection.getConnection();
            conn.setAutoCommit(false); // For better performance
            
            // Clear existing data (optional - comment out if you want to keep data)
            clearExistingData(conn);
            
            try (CSVReader reader = new CSVReader(new InputStreamReader(inputStream))) {
                List<String[]> rows = reader.readAll();
                
                if (rows.size() < 2) {
                    throw new IOException("CSV file must contain header and at least one data row");
                }
                
                // Validate header
                String[] header = rows.get(0);
                validateHeader(header);
                
                // Process data rows
                System.out.println("Processing " + (rows.size() - 1) + " transactions...");
                
                for (int i = 1; i < rows.size(); i++) {
                    String[] row = rows.get(i);
                    
                    try {
                        Transaction t = parseTransaction(row, i);
                        transactions.add(t);
                        insertTransaction(t, conn);
                    } catch (Exception e) {
                        System.err.println("Error parsing row " + (i + 1) + ": " + e.getMessage());
                        throw new IOException("Error at row " + (i + 1) + ": " + e.getMessage());
                    }
                    
                    // Commit every 1000 rows
                    if (i % 1000 == 0) {
                        conn.commit();
                        System.out.println("Committed " + i + " transactions");
                    }
                }
                
                conn.commit(); // Final commit
                System.out.println("Successfully processed " + transactions.size() + " transactions");
            }
            
        } catch (Exception e) {
            if (conn != null) {
                conn.rollback(); // Rollback on error
            }
            throw e;
        } finally {
            if (conn != null) {
                conn.setAutoCommit(true);
            }
        }
        
        return transactions;
    }
    
    private void validateHeader(String[] header) throws IOException {
        String[] expectedHeader = {"transaction_id", "sender_id", "receiver_id", "amount", "timestamp"};
        
        if (header.length != expectedHeader.length) {
            throw new IOException("Invalid CSV format. Expected " + expectedHeader.length + 
                                 " columns but found " + header.length);
        }
        
        for (int i = 0; i < expectedHeader.length; i++) {
            if (!header[i].trim().equalsIgnoreCase(expectedHeader[i])) {
                throw new IOException("Invalid header at column " + (i+1) + 
                                     ". Expected '" + expectedHeader[i] + 
                                     "' but found '" + header[i] + "'");
            }
        }
    }
    
    /**
     * Converts a timestamp string like "2024-01-21 3:01:00" to "2024-01-21 03:01:00"
     * by padding the hour to two digits.
     */
    private String normalizeTimestamp(String rawTimestamp) {
        String[] parts = rawTimestamp.trim().split(" ");
        if (parts.length != 2) {
            return rawTimestamp; // unexpected format, let the original parser handle it
        }
        String datePart = parts[0];
        String timePart = parts[1];
        
        String[] timeComponents = timePart.split(":");
        if (timeComponents.length == 3) {
            String hour = timeComponents[0];
            String minute = timeComponents[1];
            String second = timeComponents[2];
            // Pad hour with leading zero if needed
            if (hour.length() == 1) {
                hour = "0" + hour;
            }
            return datePart + " " + hour + ":" + minute + ":" + second;
        }
        return rawTimestamp; // fallback
    }
    
    private Transaction parseTransaction(String[] row, int rowNum) throws IOException {
        if (row.length < 5) {
            throw new IOException("Row " + rowNum + " has only " + row.length + " columns (need 5)");
        }
        
        String transactionId = row[0].trim();
        String senderId = row[1].trim();
        String receiverId = row[2].trim();
        
        if (transactionId.isEmpty() || senderId.isEmpty() || receiverId.isEmpty()) {
            throw new IOException("Empty required field at row " + rowNum);
        }
        
        double amount;
        try {
            amount = Double.parseDouble(row[3].trim());
            if (amount <= 0) {
                throw new IOException("Amount must be positive at row " + rowNum);
            }
        } catch (NumberFormatException e) {
            throw new IOException("Invalid amount format at row " + rowNum + ": " + row[3]);
        }
        
        // Normalize the timestamp before parsing
        String rawTimestamp = row[4].trim();
        String normalizedTimestamp = normalizeTimestamp(rawTimestamp);
        
        LocalDateTime timestamp;
        try {
            timestamp = LocalDateTime.parse(normalizedTimestamp, DATE_FORMATTER);
        } catch (DateTimeParseException e) {
            throw new IOException("Invalid timestamp format at row " + rowNum + 
                                 ". Expected yyyy-MM-dd HH:mm:ss, got: " + rawTimestamp);
        }
        
        return new Transaction(transactionId, senderId, receiverId, amount, timestamp);
    }
    
    private void insertTransaction(Transaction t, Connection conn) throws SQLException {
        String sql = "INSERT INTO transactions (transaction_id, sender_id, " +
                    "receiver_id, amount, transaction_time) VALUES (?, ?, ?, ?, ?)";
        
        try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, t.getTransactionId());
            pstmt.setString(2, t.getSenderId());
            pstmt.setString(3, t.getReceiverId());
            pstmt.setDouble(4, t.getAmount());
            pstmt.setTimestamp(5, Timestamp.valueOf(t.getTimestamp()));
            pstmt.executeUpdate();
        }
    }
    
    private void clearExistingData(Connection conn) throws SQLException {
        try (Statement stmt = conn.createStatement()) {
            stmt.executeUpdate("DELETE FROM transactions");
            System.out.println("Cleared existing transactions");
        }
    }
}
