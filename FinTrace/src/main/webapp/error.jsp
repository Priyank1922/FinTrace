<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" isErrorPage="true"%>
<%@ page import="java.net.URLDecoder, java.io.PrintWriter, java.io.StringWriter, java.util.*" %>
<%
    // This ONE file handles BOTH:
    // 1. Redirected errors (with parameters)
    // 2. Direct JSP exceptions (with isErrorPage="true")
    
    String errorMessage = request.getParameter("message");
    String errorDetails = request.getParameter("details");
    String errorType = request.getParameter("type");
    
    // If exception exists (from isErrorPage="true")
    if (exception != null) {
        errorMessage = exception.getMessage();
        StringWriter sw = new StringWriter();
        PrintWriter pw = new PrintWriter(sw);
        exception.printStackTrace(pw);
        errorDetails = sw.toString();
        errorType = "exception";
    }
    
    // Set defaults
    if (errorMessage == null || errorMessage.isEmpty()) {
        errorMessage = "An unexpected error occurred";
    }
    if (errorDetails == null) errorDetails = "";
    if (errorType == null) errorType = "general";
    
    // Decode URL encoded characters
    try {
        errorMessage = URLDecoder.decode(errorMessage, "UTF-8");
        errorDetails = URLDecoder.decode(errorDetails, "UTF-8");
    } catch (Exception e) {
        // Keep as is if decoding fails
    }
    
    // Clean up error message for display
    errorMessage = errorMessage.replaceAll("[<>]", ""); // Remove HTML tags
    
    // Get error category for smart suggestions
    String errorCategory = "general";
    if (errorMessage.contains("columns") || errorMessage.contains("Column") || errorMessage.contains("fields")) {
        errorCategory = "columns";
    } else if (errorMessage.contains("Missing required column") || errorMessage.contains("header")) {
        errorCategory = "header";
    } else if (errorMessage.contains("amount") || errorMessage.contains("Amount") || errorMessage.contains("number")) {
        errorCategory = "amount";
    } else if (errorMessage.contains("timestamp") || errorMessage.contains("Timestamp") || errorMessage.contains("date") || errorMessage.contains("time")) {
        errorCategory = "timestamp";
    } else if (errorMessage.contains("empty") || errorMessage.contains("Empty") || errorMessage.contains("no data")) {
        errorCategory = "empty";
    } else if (errorMessage.contains("MySQL") || errorMessage.contains("database") || errorMessage.contains("DB") || errorMessage.contains("Connection")) {
        errorCategory = "database";
    } else if (errorMessage.contains("file") || errorMessage.contains("File") || errorMessage.contains("upload")) {
        errorCategory = "file";
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>FinTrace · Error</title>
    
    <!-- FinTrace fonts & icons -->
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:opsz,wght@14..32,400;14..32,500;14..32,600;14..32,700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css">
    
    <style>
        /* ----- FinTrace theme variables (from index.jsp) ----- */
        :root {
            --primary-dark: #0b2b4f;
            --primary: #1e4a6f;
            --primary-light: #e9f0f9;
            --accent: #d4a13e;
            --accent-soft: #fbf3e2;
            --neutral-light: #f8fafc;
            --neutral-dark: #1e293b;
            --shadow: 0 20px 30px -10px rgba(0, 20, 40, 0.08);
            --shadow-hover: 0 30px 50px -15px rgba(0, 20, 40, 0.15);
            --error: #ef4444;
            --error-light: #fee2e2;
            --success: #10b981;
            --success-light: #d1fae5;
        }

        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: 'Inter', sans-serif;
            background-color: var(--neutral-light);
            color: var(--neutral-dark);
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 2rem 1rem;
            line-height: 1.5;
        }

        .error-container {
            width: 100%;
            max-width: 900px;
            margin: 0 auto;
            animation: slideIn 0.6s ease-out;
        }

        @keyframes slideIn {
            from { opacity: 0; transform: translateY(20px); }
            to { opacity: 1; transform: translateY(0); }
        }

        /* main card – same as upload-card in index */
        .error-card {
            background: white;
            border-radius: 40px;
            padding: 3rem;
            box-shadow: var(--shadow);
            border: 1px solid #eef2f8;
        }

        .error-icon {
            width: 100px;
            height: 100px;
            background: var(--error-light);
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            margin: 0 auto 2rem;
            font-size: 3rem;
            color: var(--error);
            animation: pulse 2s infinite;
        }

        @keyframes pulse {
            0% { transform: scale(1); }
            50% { transform: scale(1.05); }
            100% { transform: scale(1); }
        }

        h1 {
            font-size: 2.5rem;
            font-weight: 700;
            color: var(--primary-dark);
            text-align: center;
            margin-bottom: 1rem;
        }

        .error-type {
            display: inline-block;
            padding: 0.5rem 1.5rem;
            background: var(--primary-light);
            border-radius: 30px;
            font-size: 0.9rem;
            color: var(--primary);
            margin: 0 auto 2rem;
            text-align: center;
            width: fit-content;
            text-transform: uppercase;
            letter-spacing: 0.5px;
            font-weight: 600;
        }

        /* error message box – matches upload section style */
        .error-message-box {
            background: var(--error-light);
            border-left: 4px solid var(--error);
            border-radius: 60px;
            padding: 1rem 1.5rem;
            margin: 2rem 0;
            display: flex;
            align-items: center;
            gap: 0.8rem;
        }

        .error-message-box h3 {
            color: var(--error);
            font-size: 1rem;
            font-weight: 600;
            display: flex;
            align-items: center;
            gap: 0.5rem;
            white-space: nowrap;
        }

        .error-message-box p {
            color: var(--neutral-dark);
            font-size: 1rem;
            word-break: break-word;
            flex: 1;
            background: rgba(255,255,255,0.5);
            padding: 0.5rem 1rem;
            border-radius: 40px;
            font-family: 'Monaco', monospace;
        }

        /* technical details – collapsible, dark theme */
        .error-details {
            background: #1e293b;
            border-radius: 24px;
            padding: 1.5rem;
            margin: 1.5rem 0;
            position: relative;
        }

        .error-details summary {
            color: #e2e8f0;
            cursor: pointer;
            margin-bottom: 1rem;
            font-weight: 500;
            list-style: none;
            display: flex;
            align-items: center;
            gap: 0.5rem;
        }

        .error-details summary::-webkit-details-marker {
            display: none;
        }

        .error-details pre {
            color: #e2e8f0;
            font-family: 'Monaco', monospace;
            font-size: 0.85rem;
            white-space: pre-wrap;
            word-wrap: break-word;
            max-height: 300px;
            overflow-y: auto;
            background: #0f172a;
            padding: 1rem;
            border-radius: 16px;
        }

        .copy-btn {
            position: absolute;
            top: 1rem;
            right: 1rem;
            background: #475569;
            color: white;
            border: none;
            padding: 0.4rem 1rem;
            border-radius: 30px;
            font-size: 0.8rem;
            cursor: pointer;
            display: flex;
            align-items: center;
            gap: 0.25rem;
            transition: all 0.2s;
        }

        .copy-btn:hover {
            background: #64748b;
        }

        /* suggestions box – same as .csv-format in index */
        .error-suggestions {
            background: var(--neutral-light);
            border-radius: 24px;
            padding: 2rem;
            margin: 2rem 0;
        }

        .error-suggestions h4 {
            color: var(--primary-dark);
            margin-bottom: 1.5rem;
            display: flex;
            align-items: center;
            gap: 0.5rem;
            font-size: 1.2rem;
        }

        .suggestion-list {
            list-style: none;
        }

        .suggestion-list li {
            padding: 0.75rem 0;
            display: flex;
            align-items: center;
            gap: 1rem;
            border-bottom: 1px solid #e2e8f0;
        }

        .suggestion-list li:last-child {
            border-bottom: none;
        }

        .suggestion-icon {
            width: 30px;
            height: 30px;
            background: var(--primary-light);
            border-radius: 10px;
            display: flex;
            align-items: center;
            justify-content: center;
            color: var(--primary);
            flex-shrink: 0;
        }

        .suggestion-text {
            flex: 1;
        }

        .suggestion-text code {
            background: #e2e8f0;
            padding: 0.2rem 0.4rem;
            border-radius: 4px;
            font-size: 0.85rem;
        }

        /* CSV preview / format examples */
        .csv-preview {
            background: white;
            border: 2px dashed #cbd5e1;
            border-radius: 24px;
            padding: 1.5rem;
            margin: 2rem 0;
        }

        .csv-preview h4 {
            margin-bottom: 1rem;
            color: var(--primary-dark);
            display: flex;
            align-items: center;
            gap: 0.5rem;
        }

        .csv-sample {
            background: var(--neutral-light);
            padding: 1rem;
            border-radius: 16px;
            font-family: 'Monaco', monospace;
            font-size: 0.85rem;
            color: var(--neutral-dark);
            border: 1px solid #e2e8f0;
            overflow-x: auto;
            white-space: pre;
        }

        .format-grid {
        
        justify-content:center;
            display: grid;
            grid-template-columns: repeat(2, 1fr);
            gap: 1.5rem;
            margin-top: 1.5rem;
        }

        .format-card {
            background: white;
            padding: 1.5rem;
            border-radius: 20px;
            border: 1px solid #e2e8f0;
            height: 100%;
            display: flex;
            flex-direction: column;
        }

        .format-card.good {
            border-left: 4px solid var(--success);
        }

        .format-card.bad {
            border-left: 4px solid var(--error);
        }

        .format-card h5 {
            margin-bottom: 1rem;
            display: flex;
            align-items: center;
            gap: 0.5rem;
            font-size: 1rem;
        }

        .format-card code {
            background: var(--neutral-light);
            padding: 0.75rem;
            border-radius: 12px;
            display: block;
            font-size: 0.85rem;
            color: var(--neutral-dark);
            overflow-x: auto;
            font-family: 'Monaco', monospace;
            margin-bottom: 0.5rem;
        }

        .format-card p {
            margin-top: 0;
            font-size: 0.85rem;
            color: #64748b;
        }

        /* action buttons – same as index */
        .action-buttons {
            display: flex;
            gap: 1rem;
            justify-content: center;
            margin: 2rem 0 1.5rem;
            flex-wrap: wrap;
        }

        .btn {
            display: inline-flex;
            align-items: center;
            gap: 0.5rem;
            padding: 1rem 2rem;
            border-radius: 40px;
            font-weight: 600;
            font-size: 1rem;
            cursor: pointer;
            transition: all 0.3s cubic-bezier(0.2, 0.9, 0.3, 1.2);
            text-decoration: none;
            border: none;
        }

        .btn-primary {
            background: var(--primary);
            color: white;
            border: 2px solid var(--primary);
        }

        .btn-primary:hover {
            background: var(--primary-dark);
            border-color: var(--primary-dark);
            transform: scale(1.05) translateY(-3px);
            box-shadow: var(--shadow-hover);
        }

        .btn-outline {
            background: white;
            border: 2px solid var(--primary);
            color: var(--primary);
        }

        .btn-outline:hover {
            background: var(--primary-light);
            border-color: var(--primary-dark);
            color: var(--primary-dark);
            transform: scale(1.02) translateY(-2px);
        }

        .btn-success {
            background: var(--success);
            color: white;
            border: 2px solid var(--success);
        }

        .btn-success:hover {
            background: #059669;
            border-color: #059669;
            transform: scale(1.05) translateY(-3px);
            box-shadow: 0 10px 25px -5px rgba(16, 185, 129, 0.4);
        }

        .error-footer {
            text-align: center;
            margin-top: 2rem;
            color: #94a3b8;
            font-size: 0.9rem;
        }

        .error-footer a {
            color: var(--primary);
            text-decoration: none;
        }

        .error-footer a:hover {
            text-decoration: underline;
        }

        /* responsive */
        @media (max-width: 768px) {
            .error-card {
                padding: 2rem 1.5rem;
            }
            
            h1 {
                font-size: 2rem;
            }
            
            .error-message-box {
                flex-direction: column;
                align-items: flex-start;
                border-radius: 30px;
            }
            
            .format-grid {
                grid-template-columns: 1fr;
            }
            
            .action-buttons {
                flex-direction: column;
            }
            
            .btn {
                width: 100%;
                justify-content: center;
            }
        }
    </style>
</head>
<body>
    <div class="error-container">
        <div class="error-card">
            <div class="error-icon">
                <i class="fas fa-exclamation-triangle"></i>
            </div>
            
            <h1>Oops! Something Went Wrong</h1>
            
            <div class="error-type">
                <i class="fas fa-tag"></i> 
                <%= errorType.replace("_", " ").toUpperCase() %>
            </div>
            
            <div class="error-message-box">
                <h3>
                    <i class="fas fa-times-circle"></i>
                    Error
                </h3>
                <p><%= errorMessage %></p>
            </div>
            
            <% if (!errorDetails.isEmpty() && !errorDetails.equals(errorMessage)) { %>
            <div class="error-details">
                <details>
                    <summary>
                        <i class="fas fa-code"></i> Technical Details (click to expand)
                    </summary>
                    <pre id="errorDetailsPre"><%= errorDetails %></pre>
                </details>
                <button class="copy-btn" onclick="copyErrorDetails()">
                    <i class="fas fa-copy"></i> Copy
                </button>
            </div>
            <% } %>
            
            <div class="error-suggestions">
                <h4>
                    <i class="fas fa-lightbulb" style="color: var(--accent);"></i>
                    How to Fix This
                </h4>
                
                <ul class="suggestion-list">
                    <% if (errorCategory.equals("columns")) { %>
                        <li>
                            <span class="suggestion-icon"><i class="fas fa-columns"></i></span>
                            <span class="suggestion-text">Your CSV has the wrong number of columns. Expected exactly <strong>5 columns</strong>:</span>
                        </li>
                        <li>
                            <span class="suggestion-icon"><i class="fas fa-check-circle" style="color: var(--success);"></i></span>
                            <span class="suggestion-text"><code>transaction_id, sender_id, receiver_id, amount, timestamp</code></span>
                        </li>
                        <li>
                            <span class="suggestion-icon"><i class="fas fa-times-circle" style="color: var(--error);"></i></span>
                            <span class="suggestion-text">Remove any extra columns or add missing ones</span>
                        </li>
                    <% } else if (errorCategory.equals("header")) { %>
                        <li>
                            <span class="suggestion-icon"><i class="fas fa-heading"></i></span>
                            <span class="suggestion-text">Your CSV header is missing required columns. The first row must be exactly:</span>
                        </li>
                        <li>
                            <span class="suggestion-icon"><i class="fas fa-check-circle" style="color: var(--success);"></i></span>
                            <span class="suggestion-text"><code>transaction_id,sender_id,receiver_id,amount,timestamp</code></span>
                        </li>
                    <% } else if (errorCategory.equals("amount")) { %>
                        <li>
                            <span class="suggestion-icon"><i class="fas fa-dollar-sign"></i></span>
                            <span class="suggestion-text">Amount must be a valid number with 2 decimal places</span>
                        </li>
                        <li>
                            <span class="suggestion-icon"><i class="fas fa-check-circle" style="color: var(--success);"></i></span>
                            <span class="suggestion-text">Correct: <code>5000.00</code> (not $5000 or 5,000)</span>
                        </li>
                    <% } else if (errorCategory.equals("timestamp")) { %>
                        <li>
                            <span class="suggestion-icon"><i class="fas fa-calendar"></i></span>
                            <span class="suggestion-text">Timestamp must be in format: <code>YYYY-MM-DD HH:MM:SS</code></span>
                        </li>
                        <li>
                            <span class="suggestion-icon"><i class="fas fa-check-circle" style="color: var(--success);"></i></span>
                            <span class="suggestion-text">Example: <code>2024-02-20 01:00:00</code></span>
                        </li>
                    <% } else if (errorCategory.equals("empty")) { %>
                        <li>
                            <span class="suggestion-icon"><i class="fas fa-file-excel"></i></span>
                            <span class="suggestion-text">The CSV file appears to be empty or contains no valid transaction data.</span>
                        </li>
                        <li>
                            <span class="suggestion-icon"><i class="fas fa-download"></i></span>
                            <span class="suggestion-text">Download the sample CSV below and try again</span>
                        </li>
                    <% } else if (errorCategory.equals("database")) { %>
                        <li>
                            <span class="suggestion-icon"><i class="fas fa-database"></i></span>
                            <span class="suggestion-text">Database connection error. Please check if MySQL is running:</span>
                        </li>
                        <li>
                            <span class="suggestion-icon"><i class="fas fa-terminal"></i></span>
                            <span class="suggestion-text"><code>sudo /usr/local/mysql/support-files/mysql.server start</code></span>
                        </li>
                    <% } else if (errorCategory.equals("file")) { %>
                        <li>
                            <span class="suggestion-icon"><i class="fas fa-file-csv"></i></span>
                            <span class="suggestion-text">File upload error. Please check:</span>
                        </li>
                        <li>
                            <span class="suggestion-icon"><i class="fas fa-check-circle" style="color: var(--success);"></i></span>
                            <span class="suggestion-text">File must be .csv format</span>
                        </li>
                        <li>
                            <span class="suggestion-icon"><i class="fas fa-check-circle" style="color: var(--success);"></i></span>
                            <span class="suggestion-text">File size must be less than 10MB</span>
                        </li>
                    <% } else { %>
                        <li>
                            <span class="suggestion-icon"><i class="fas fa-file-csv"></i></span>
                            <span class="suggestion-text">Make sure your CSV file:</span>
                        </li>
                        <li>
                            <span class="suggestion-icon"><i class="fas fa-check-circle" style="color: var(--success);"></i></span>
                            <span class="suggestion-text">Has the correct header row with 5 columns</span>
                        </li>
                        <li>
                            <span class="suggestion-icon"><i class="fas fa-check-circle" style="color: var(--success);"></i></span>
                            <span class="suggestion-text">Uses commas (,) as separators, not semicolons (;)</span>
                        </li>
                        <li>
                            <span class="suggestion-icon"><i class="fas fa-check-circle" style="color: var(--success);"></i></span>
                            <span class="suggestion-text">Has no comments, descriptive text, or empty lines</span>
                        </li>
                    <% } %>
                </ul>
            </div>
            
            <!-- CSV Format Examples -->
            <div class="csv-preview">
                <h4>
                    <i class="fas fa-check-circle" style="color: var(--success);"></i>
                    Correct CSV Format
                </h4>
                <div class="csv-sample">transaction_id,sender_id,receiver_id,amount,timestamp
T001,ACC001,ACC002,5000.00,2024-01-15 10:30:00
T002,ACC002,ACC003,2500.00,2024-01-15 11:45:00</div>
                
                <div style="margin-top: 2rem;">
                    <h4 style="color: var(--error);">
                        <i class="fas fa-times-circle"></i>
                        Common Mistakes
                    </h4>
                    
                    <div class="format-grid">
                        <div class="format-card bad">
                            <h5><i class="fas fa-times" style="color: var(--error);"></i> Wrong Separator</h5>
                            <code>transaction_id;sender_id;receiver_id;
                            amount;timestamp</code>
                            <p>Use commas (,) not semicolons (;)</p>
                        </div>
                        
                        <div class="format-card bad">
                            <h5><i class="fas fa-times" style="color: var(--error);"></i> Missing Columns</h5>
                            <code>T001,ACC001,5000.00</code>
                            <p>Need 5 values per row</p>
                        </div>
                        
                        <div class="format-card bad">
                            <h5><i class="fas fa-times" style="color: var(--error);"></i> Text Comments</h5>
                            <code># This is a comment</code>
                            <p>Remove all comments</p>
                        </div>
                        
                        <div class="format-card bad">
                            <h5><i class="fas fa-times" style="color: var(--error);"></i> Wrong Date Format</h5>
                            <code>T001,ACC001,ACC002,5000.00,15-01-2024</code>
                            <p>Use YYYY-MM-DD HH:MM:SS</p>
                        </div>
                    </div>
                </div>
            </div>
            
            <div class="action-buttons">
                <a href="index.jsp#upload" class="btn btn-primary">
                    <i class="fas fa-upload"></i> Try Upload Again
                </a>
                
                <button onclick="window.history.back()" class="btn btn-outline">
                    <i class="fas fa-arrow-left"></i> Go Back
                </button>
                
                <a href="downloadSample" class="btn btn-success">
                    <i class="fas fa-download"></i> Download Sample CSV
                </a>
            </div>
            
            <div class="error-footer">
                <p>Need help? Contact <a href="mailto:support@fintrace.com">support@fintrace.com</a></p>
                <p style="margin-top: 0.5rem; font-size: 0.8rem;">FinTrace · RIFT 2026 Hackathon</p>
            </div>
        </div>
    </div>
    
    <script>
        // Copy error details to clipboard
        function copyErrorDetails() {
            const errorDetails = document.getElementById('errorDetailsPre');
            if (errorDetails) {
                navigator.clipboard.writeText(errorDetails.textContent).then(() => {
                    const copyBtn = document.querySelector('.copy-btn');
                    const originalText = copyBtn.innerHTML;
                    copyBtn.innerHTML = '<i class="fas fa-check"></i> Copied!';
                    setTimeout(() => {
                        copyBtn.innerHTML = originalText;
                    }, 2000);
                });
            }
        }
        
        // Auto-format error message for better readability (optional)
        document.addEventListener('DOMContentLoaded', function() {
            const errorMsg = document.querySelector('.error-message-box p');
            if (errorMsg) {
                let text = errorMsg.innerHTML;
                // Highlight important parts
                text = text.replace(/Row \d+/g, '<strong>$&</strong>');
                text = text.replace(/columns?/gi, '<strong>$&</strong>');
                text = text.replace(/Error at row/g, '<span style="color: #991b1b;">$&</span>');
                errorMsg.innerHTML = text;
            }
        });
    </script>
</body>
</html>