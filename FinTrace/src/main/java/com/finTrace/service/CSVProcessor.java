package com.finTrace.service;

import com.finTrace.model.Transaction;
import com.finTrace.util.DatabaseConnection;
import com.opencsv.CSVReader;
import com.opencsv.exceptions.CsvException;
import com.opencsv.CSVParserBuilder;
import com.opencsv.CSVReaderBuilder;

import java.io.*;
import java.sql.*;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.time.format.DateTimeParseException;
import java.util.*;

public class CSVProcessor {
    
	
	
    private static final DateTimeFormatter DATE_FORMATTER = 
        DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss");
    
    private static final String[] REQUIRED_HEADERS = {
        "transaction_id", "sender_id", "receiver_id", "amount", "timestamp"
    };
    
    /**
     * Process uploaded CSV file and return list of transactions
     */
    public List<Transaction> processCSV(InputStream inputStream) 
            throws IOException, CsvException, SQLException, ClassNotFoundException {
        
        List<Transaction> transactions = new ArrayList<>();
        Connection conn = null;
        int rowNumber = 0;
        
        try {
            conn = DatabaseConnection.getConnection();
            conn.setAutoCommit(false);
            
            // Clear existing data for this session
            clearExistingData(conn);
            
            // Configure CSV parser to handle different formats
            CSVParserBuilder parserBuilder = new CSVParserBuilder()
                .withSeparator(',')  // Default comma separator
                .withIgnoreQuotations(true)
                .withStrictQuotes(false);
            
            // Try to detect delimiter automatically
            CSVReader reader = new CSVReaderBuilder(new InputStreamReader(inputStream))
                .withCSVParser(parserBuilder.build())
                .withSkipLines(0)
                .build();
            
            List<String[]> allRows = reader.readAll();
            
            if (allRows.isEmpty()) {
                throw new IOException("CSV file is empty");
            }
            
            // Validate and process header
            String[] header = allRows.get(0);
            rowNumber = 1;
            
            // Try to detect if delimiter is not comma (e.g., semicolon)
            if (header.length == 1 && header[0].contains(";")) {
                // Re-parse with semicolon delimiter
                reader.close();
                parserBuilder.withSeparator(';');
                reader = new CSVReaderBuilder(new InputStreamReader(inputStream))
                    .withCSVParser(parserBuilder.build())
                    .withSkipLines(0)
                    .build();
                allRows = reader.readAll();
                header = allRows.get(0);
            }
            
            // Validate header
            Map<String, Integer> columnIndexMap = validateHeader(header);
            
            System.out.println("Found columns: " + Arrays.toString(header));
            System.out.println("Processing " + (allRows.size() - 1) + " transactions...");
            
            // Process data rows
            for (int i = 1; i < allRows.size(); i++) {
                String[] row = allRows.get(i);
                rowNumber = i + 1;
                
                // Skip empty rows
                if (isRowEmpty(row)) {
                    System.out.println("Skipping empty row " + rowNumber);
                    continue;
                }
                
                try {
                    Transaction t = parseTransaction(row, columnIndexMap, rowNumber);
                    transactions.add(t);
                    insertTransaction(t, conn);
                    
                    // Progress indicator for large files
                    if (i % 100 == 0) {
                        System.out.println("Processed " + i + " transactions...");
                    }
                    
                    // Commit every 500 rows for performance
                    if (i % 500 == 0) {
                        conn.commit();
                        System.out.println("Committed " + i + " transactions");
                    }
                    
                } catch (Exception e) {
                    System.err.println("Error at row " + rowNumber + ": " + e.getMessage());
                    throw new IOException("Error at row " + rowNumber + ": " + e.getMessage() + 
                                         ". Row data: " + Arrays.toString(row));
                }
            }
            
            conn.commit(); // Final commit
            System.out.println("Successfully processed " + transactions.size() + " transactions");
            reader.close();
            
        } catch (Exception e) {
            if (conn != null) {
                try {
                    conn.rollback(); // Rollback on error
                    System.err.println("Transaction rolled back due to error");
                } catch (SQLException ex) {
                    System.err.println("Error rolling back: " + ex.getMessage());
                }
            }
            throw e;
        } finally {
            if (conn != null) {
                conn.setAutoCommit(true);
                DatabaseConnection.closeConnection();
            }
        }
        
        return transactions;
    }
    
    /**
     * Alternative method that accepts delimiter parameter
     */
    public List<Transaction> processCSV(InputStream inputStream, char delimiter) 
            throws IOException, CsvException, SQLException, ClassNotFoundException {
        
        List<Transaction> transactions = new ArrayList<>();
        Connection conn = null;
        
        try {
            conn = DatabaseConnection.getConnection();
            conn.setAutoCommit(false);
            
            clearExistingData(conn);
            
            CSVParserBuilder parserBuilder = new CSVParserBuilder()
                .withSeparator(delimiter)
                .withIgnoreQuotations(true);
            
            CSVReader reader = new CSVReaderBuilder(new InputStreamReader(inputStream))
                .withCSVParser(parserBuilder.build())
                .withSkipLines(0)
                .build();
            
            List<String[]> allRows = reader.readAll();
            
            if (allRows.isEmpty()) {
                throw new IOException("CSV file is empty");
            }
            
            String[] header = allRows.get(0);
            Map<String, Integer> columnIndexMap = validateHeader(header);
            
            for (int i = 1; i < allRows.size(); i++) {
                String[] row = allRows.get(i);
                
                if (isRowEmpty(row)) continue;
                
                try {
                    Transaction t = parseTransaction(row, columnIndexMap, i + 1);
                    transactions.add(t);
                    insertTransaction(t, conn);
                    
                    if (i % 500 == 0) {
                        conn.commit();
                    }
                } catch (Exception e) {
                    throw new IOException("Error at row " + (i + 1) + ": " + e.getMessage());
                }
            }
            
            conn.commit();
            reader.close();
            
        } catch (Exception e) {
            if (conn != null) conn.rollback();
            throw e;
        } finally {
            if (conn != null) {
                conn.setAutoCommit(true);
                DatabaseConnection.closeConnection();
            }
        }
        
        return transactions;
    }
    
    /**
     * Validate CSV header and return column index mapping
     */
    private Map<String, Integer> validateHeader(String[] header) throws IOException {
        Map<String, Integer> columnIndexMap = new HashMap<>();
        List<String> headerList = Arrays.asList(header);
        
        // Check each required column
        for (String required : REQUIRED_HEADERS) {
            int index = headerList.indexOf(required);
            if (index == -1) {
                // Try case-insensitive match
                for (int i = 0; i < headerList.size(); i++) {
                    if (headerList.get(i).equalsIgnoreCase(required)) {
                        index = i;
                        break;
                    }
                }
            }
            
            if (index == -1) {
                throw new IOException("Missing required column: '" + required + "'." +
                                     " Found columns: " + headerList);
            }
            
            columnIndexMap.put(required, index);
        }
        
        return columnIndexMap;
    }
    
    /**
     * Parse a transaction row using column index mapping
     */
    private Transaction parseTransaction(String[] row, Map<String, Integer> columnIndexMap, int rowNum) 
            throws IOException {
        
        // Check if row has enough columns
        int maxIndex = Collections.max(columnIndexMap.values());
        if (row.length <= maxIndex) {
            throw new IOException("Row has only " + row.length + " columns, need at least " + (maxIndex + 1));
        }
        
        // Get values using column mapping
        String transactionId = getColumnValue(row, columnIndexMap, "transaction_id", rowNum);
        String senderId = getColumnValue(row, columnIndexMap, "sender_id", rowNum);
        String receiverId = getColumnValue(row, columnIndexMap, "receiver_id", rowNum);
        
        // Validate required fields
        if (transactionId.isEmpty()) {
            throw new IOException("Transaction ID is empty");
        }
        if (senderId.isEmpty()) {
            throw new IOException("Sender ID is empty");
        }
        if (receiverId.isEmpty()) {
            throw new IOException("Receiver ID is empty");
        }
        
        // Parse amount
        double amount;
        try {
            String amountStr = getColumnValue(row, columnIndexMap, "amount", rowNum)
                .replace("$", "")
                .replace(",", "")
                .trim();
            amount = Double.parseDouble(amountStr);
            if (amount <= 0) {
                throw new IOException("Amount must be positive: " + amount);
            }
        } catch (NumberFormatException e) {
            throw new IOException("Invalid amount format: " + 
                                 getColumnValue(row, columnIndexMap, "amount", rowNum));
        }
        
        // Parse timestamp
        LocalDateTime timestamp;
        try {
            String timestampStr = getColumnValue(row, columnIndexMap, "timestamp", rowNum).trim();
            timestamp = LocalDateTime.parse(timestampStr, DATE_FORMATTER);
        } catch (DateTimeParseException e) {
            // Try alternative formats
            timestamp = tryParseAlternativeDateFormats(
                getColumnValue(row, columnIndexMap, "timestamp", rowNum));
            if (timestamp == null) {
                throw new IOException("Invalid timestamp format. Expected yyyy-MM-dd HH:mm:ss, got: " +
                                     getColumnValue(row, columnIndexMap, "timestamp", rowNum));
            }
        }
        
        return new Transaction(transactionId, senderId, receiverId, amount, timestamp);
    }
    
    /**
     * Safe method to get column value
     */
    private String getColumnValue(String[] row, Map<String, Integer> columnIndexMap, 
                                  String columnName, int rowNum) throws IOException {
        Integer index = columnIndexMap.get(columnName);
        if (index == null) {
            throw new IOException("Column '" + columnName + "' not found in mapping");
        }
        if (index >= row.length) {
            throw new IOException("Row " + rowNum + " missing column '" + columnName + "'");
        }
        return row[index] != null ? row[index].trim() : "";
    }
    
    /**
     * Try to parse different date formats
     */
    private LocalDateTime tryParseAlternativeDateFormats(String dateStr) {
        DateTimeFormatter[] formatters = {
            DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss"),
            DateTimeFormatter.ofPattern("yyyy/MM/dd HH:mm:ss"),
            DateTimeFormatter.ofPattern("dd-MM-yyyy HH:mm:ss"),
            DateTimeFormatter.ofPattern("MM/dd/yyyy HH:mm:ss"),
            DateTimeFormatter.ofPattern("yyyy-MM-dd'T'HH:mm:ss"),
            DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm"),
            DateTimeFormatter.ofPattern("yyyy/MM/dd HH:mm")
        };
        
        for (DateTimeFormatter formatter : formatters) {
            try {
                return LocalDateTime.parse(dateStr.trim(), formatter);
            } catch (DateTimeParseException e) {
                // Try next format
            }
        }
        return null;
    }
    
    /**
     * Check if a row is empty
     */
    private boolean isRowEmpty(String[] row) {
        if (row == null || row.length == 0) return true;
        for (String cell : row) {
            if (cell != null && !cell.trim().isEmpty()) {
                return false;
            }
        }
        return true;
    }
    
    /**
     * Insert transaction into database
     */
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
    
    /**
     * Clear existing transactions (optional - can be removed if you want to keep data)
     */
    private void clearExistingData(Connection conn) throws SQLException {
        try (Statement stmt = conn.createStatement()) {
            stmt.executeUpdate("DELETE FROM transactions");
            System.out.println("Cleared existing transactions");
        }
    }
    
    /**
     * Validate CSV format without processing
     */
    /**
     * Validate CSV format without processing
     */
    public Map<String, Object> validateCSV(InputStream inputStream) 
            throws IOException, CsvException {
        
        Map<String, Object> validationResult = new HashMap<>();
        List<String> errors = new ArrayList<>();
        List<String> warnings = new ArrayList<>();
        
        try {
            // Mark stream for reset
            if (!inputStream.markSupported()) {
                inputStream = new BufferedInputStream(inputStream);
            }
            inputStream.mark(1024 * 1024 * 10); // Mark 10MB
            
            CSVReader reader = new CSVReader(new InputStreamReader(inputStream));
            List<String[]> allRows = reader.readAll();
            
            if (allRows.isEmpty()) {
                errors.add("CSV file is empty");
            } else {
                // Check header
                String[] header = allRows.get(0);
                
                if (header.length < 5) {
                    errors.add("Header has only " + header.length + " columns, need 5");
                } else {
                    // Check for required columns
                    List<String> headerList = Arrays.asList(header);
                    String[] required = {"transaction_id", "sender_id", "receiver_id", "amount", "timestamp"};
                    
                    for (String req : required) {
                        if (!headerList.contains(req)) {
                            errors.add("Missing required column: " + req);
                        }
                    }
                }
                
                // Check data rows
                for (int i = 1; i < allRows.size(); i++) {
                    String[] row = allRows.get(i);
                    
                    // Skip completely empty rows
                    if (row.length == 1 && row[0].trim().isEmpty()) {
                        warnings.add("Row " + (i + 1) + " is empty");
                        continue;
                    }
                    
                    // Check if row looks like a comment
                    if (row.length == 1 && row[0].trim().matches("^[a-zA-Z].*") && !row[0].contains(",")) {
                        warnings.add("Row " + (i + 1) + " appears to be a comment: '" + row[0] + "'");
                        continue;
                    }
                    
                    // Check column count
                    if (row.length < 5) {
                        errors.add("Row " + (i + 1) + " has only " + row.length + 
                                  " columns, need at least 5. Data: " + Arrays.toString(row));
                    }
                    
                    // Basic format checks on first few rows only
                    if (i <= 5 && row.length >= 5) {
                        try {
                            Double.parseDouble(row[3].trim().replace("$", "").replace(",", ""));
                        } catch (NumberFormatException e) {
                            warnings.add("Row " + (i + 1) + " amount may be invalid: '" + row[3] + "'");
                        }
                    }
                    
                    // Stop after checking first 20 rows for performance
                    if (i > 20) break;
                }
            }
            
            reader.close();
            inputStream.reset(); // Reset for actual processing
            
        } catch (Exception e) {
            errors.add("Error reading CSV: " + e.getMessage());
        }
        
        validationResult.put("valid", errors.isEmpty());
        validationResult.put("errors", errors);
        validationResult.put("warnings", warnings);
        
        return validationResult;
    }
    
    /**
     * Get sample of CSV data (first 5 rows)
     */
    public List<String[]> getSample(InputStream inputStream, int rowCount) 
            throws IOException, CsvException {
        
        List<String[]> sample = new ArrayList<>();
        
        try (CSVReader reader = new CSVReader(new InputStreamReader(inputStream))) {
            List<String[]> allRows = reader.readAll();
            int rowsToTake = Math.min(rowCount, allRows.size());
            for (int i = 0; i < rowsToTake; i++) {
                sample.add(allRows.get(i));
            }
        }
        
        return sample;
    }
}