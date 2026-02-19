<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*, com.finTrace.model.*, java.text.DecimalFormat" %>
<%
    // Debug session (single instance)
    Map<String, Account> accounts = (Map<String, Account>) session.getAttribute("accounts");
    List<FraudRing> rings = (List<FraudRing>) session.getAttribute("rings");
    String jsonOutput = (String) session.getAttribute("analysisResult");
    Double processingTime = (Double) session.getAttribute("processingTime");
    
    System.out.println("DASHBOARD: accounts=" + (accounts != null ? accounts.size() : "null"));
    System.out.println("DASHBOARD: rings=" + (rings != null ? rings.size() : "null"));
    System.out.println("DASHBOARD: json length=" + (jsonOutput != null ? jsonOutput.length() : "null"));
    
    if(accounts == null || rings == null) {
        response.sendRedirect("index.jsp?error=Session expired. Please upload again.");
        return;
    }
    
    // Calculate summary stats
    int suspiciousCount = 0;
    int highRiskCount = 0;
    for(Account acc : accounts.values()) {
        if(acc.getSuspicionScore() > 80) highRiskCount++;
        else if(acc.getSuspicionScore() > 50) suspiciousCount++;
    }
    
    // Format processing time
    DecimalFormat df = new DecimalFormat("#.##");
    String procTime = processingTime != null ? df.format(processingTime) : "0.0";
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>FinTrace Dashboard · Analysis Results</title>
    
    <!-- Fonts & Icons -->
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:opsz,wght@14..32,400;14..32,500;14..32,600;14..32,700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css">
    
    <!-- vis.js for graph visualization -->
    <script src="https://cdnjs.cloudflare.com/ajax/libs/vis/4.21.0/vis.min.js"></script>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/vis/4.21.0/vis.min.css">
    
    <style>
        /* ALL YOUR EXISTING CSS STYLES HERE - unchanged */
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: 'Inter', sans-serif;
            background: #f8fafc;
            color: #1e293b;
            line-height: 1.5;
        }

        :root {
            --primary-dark: #0b2b4f;
            --primary: #1e4a6f;
            --primary-light: #e9f0f9;
            --accent: #d4a13e;
            --accent-soft: #fbf3e2;
            --success: #10b981;
            --warning: #f59e0b;
            --danger: #ef4444;
            --gray-50: #f8fafc;
            --gray-100: #f1f5f9;
            --gray-200: #e2e8f0;
            --gray-300: #cbd5e1;
            --gray-600: #475569;
            --gray-800: #1e293b;
            --shadow-sm: 0 1px 2px 0 rgb(0 0 0 / 0.05);
            --shadow: 0 4px 6px -1px rgb(0 0 0 / 0.1);
            --shadow-lg: 0 10px 15px -3px rgb(0 0 0 / 0.1);
        }

        .container {
            max-width: 1600px;
            margin: 0 auto;
            padding: 0 2rem;
        }

        /* Navbar */
        .navbar {
            background: white;
            border-bottom: 1px solid var(--gray-200);
            padding: 1rem 0;
            position: sticky;
            top: 0;
            z-index: 50;
            backdrop-filter: blur(8px);
            background: rgba(255, 255, 255, 0.9);
        }

        .nav-wrapper {
            display: flex;
            align-items: center;
            justify-content: space-between;
        }

        .logo {
            display: flex;
            align-items: center;
            gap: 0.75rem;
            font-size: 1.5rem;
            font-weight: 700;
            color: var(--primary-dark);
        }

        .logo-icon {
            background: var(--accent);
            color: white;
            width: 40px;
            height: 40px;
            border-radius: 12px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 1.3rem;
        }

        .nav-actions {
            display: flex;
            gap: 1rem;
        }

        .btn {
            display: inline-flex;
            align-items: center;
            gap: 0.5rem;
            padding: 0.6rem 1.2rem;
            border-radius: 30px;
            font-weight: 500;
            font-size: 0.95rem;
            cursor: pointer;
            transition: all 0.2s;
            border: 1px solid transparent;
            text-decoration: none;
        }

        .btn-primary {
            background: var(--primary);
            color: white;
        }

        .btn-primary:hover {
            background: var(--primary-dark);
            transform: translateY(-2px);
            box-shadow: var(--shadow);
        }

        .btn-outline {
            background: white;
            border-color: var(--gray-300);
            color: var(--gray-600);
        }

        .btn-outline:hover {
            background: var(--gray-50);
            border-color: var(--primary);
            color: var(--primary);
        }

        .btn-success {
            background: var(--success);
            color: white;
        }

        .btn-success:hover {
            background: #0d9488;
            transform: translateY(-2px);
        }

        /* Summary Cards */
        .summary-grid {
            display: grid;
            grid-template-columns: repeat(4, 1fr);
            gap: 1.5rem;
            margin: 2rem 0;
        }

        .summary-card {
            background: white;
            border-radius: 24px;
            padding: 1.5rem;
            box-shadow: var(--shadow-sm);
            border: 1px solid var(--gray-200);
            transition: all 0.3s;
            display: flex;
            align-items: center;
            gap: 1rem;
        }

        .summary-card:hover {
            transform: translateY(-4px);
            box-shadow: var(--shadow-lg);
            border-color: var(--accent);
        }

        .card-icon {
            width: 60px;
            height: 60px;
            border-radius: 18px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 1.8rem;
        }

        .card-icon.blue { background: var(--primary-light); color: var(--primary); }
        .card-icon.yellow { background: var(--accent-soft); color: var(--accent); }
        .card-icon.red { background: #fee2e2; color: var(--danger); }
        .card-icon.green { background: #d1fae5; color: var(--success); }

        .card-content {
            flex: 1;
        }

        .card-label {
            font-size: 0.9rem;
            color: var(--gray-600);
            margin-bottom: 0.25rem;
        }

        .card-value {
            font-size: 2rem;
            font-weight: 700;
            color: var(--gray-800);
            line-height: 1.2;
        }

        .card-trend {
            font-size: 0.85rem;
            color: var(--success);
            margin-top: 0.25rem;
        }

        /* Graph Section */
        .graph-section {
            background: white;
            border-radius: 24px;
            padding: 1.5rem;
            margin-bottom: 2rem;
            border: 1px solid var(--gray-200);
        }

        .graph-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 1rem;
            flex-wrap: wrap;
            gap: 1rem;
        }

        .graph-title h2 {
            font-size: 1.3rem;
            color: var(--gray-800);
            display: flex;
            align-items: center;
            gap: 0.5rem;
        }

        .graph-legend {
            display: flex;
            gap: 1.5rem;
            flex-wrap: wrap;
        }

        .legend-item {
            display: flex;
            align-items: center;
            gap: 0.5rem;
            font-size: 0.9rem;
        }

        .legend-dot {
            width: 12px;
            height: 12px;
            border-radius: 50%;
        }

        .legend-dot.normal { background: #97c2fc; }
        .legend-dot.suspicious { background: #f59e0b; }
        .legend-dot.high-risk { background: #ef4444; }
        .legend-dot.ring { background: #8b5cf6; }

        #network {
            height: 600px;
            border-radius: 16px;
            border: 1px solid var(--gray-200);
            background: var(--gray-50);
        }

        /* Two Column Layout */
        .two-column {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 2rem;
            margin-bottom: 2rem;
        }

        /* Rings Table */
        .rings-section, .accounts-section {
            background: white;
            border-radius: 24px;
            padding: 1.5rem;
            border: 1px solid var(--gray-200);
        }

        .section-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 1.5rem;
        }

        .section-header h2 {
            font-size: 1.2rem;
            color: var(--gray-800);
            display: flex;
            align-items: center;
            gap: 0.5rem;
        }

        .badge {
            background: var(--gray-100);
            padding: 0.25rem 0.75rem;
            border-radius: 30px;
            font-size: 0.85rem;
            color: var(--gray-600);
        }

        .table-container {
            overflow-x: auto;
            max-height: 400px;
            overflow-y: auto;
            border-radius: 16px;
            border: 1px solid var(--gray-200);
        }

        table {
            width: 100%;
            border-collapse: collapse;
            font-size: 0.9rem;
        }

        th {
            background: var(--gray-50);
            padding: 1rem;
            text-align: left;
            font-weight: 600;
            color: var(--gray-600);
            position: sticky;
            top: 0;
            z-index: 10;
        }

        td {
            padding: 1rem;
            border-bottom: 1px solid var(--gray-200);
        }

        tr:hover {
            background: var(--gray-50);
        }

        .pattern-badge {
            display: inline-block;
            padding: 0.25rem 0.75rem;
            border-radius: 30px;
            font-size: 0.8rem;
            font-weight: 500;
        }

        .pattern-cycle { background: #e0f2fe; color: #0369a1; }
        .pattern-fan_in { background: #fed7aa; color: #9a3412; }
        .pattern-fan_out { background: #d1fae5; color: #065f46; }
        .pattern-shell_chain { background: #f3e8ff; color: #6b21a8; }

        .risk-score {
            display: flex;
            align-items: center;
            gap: 0.5rem;
        }

        .risk-bar {
            width: 60px;
            height: 6px;
            background: var(--gray-200);
            border-radius: 3px;
            overflow: hidden;
        }

        .risk-fill {
            height: 100%;
            background: linear-gradient(90deg, var(--success), var(--warning), var(--danger));
            border-radius: 3px;
        }

        .member-accounts {
            max-width: 250px;
            white-space: nowrap;
            overflow-x: auto;
            padding: 0.25rem 0;
            font-family: 'Monaco', monospace;
            font-size: 0.85rem;
        }

        .btn-icon {
            padding: 0.4rem 0.8rem;
            background: var(--gray-100);
            border: none;
            border-radius: 20px;
            cursor: pointer;
            font-size: 0.85rem;
            transition: all 0.2s;
        }

        .btn-icon:hover {
            background: var(--primary-light);
            color: var(--primary);
        }

        /* Suspicious Accounts Table */
        .score-cell {
            display: flex;
            align-items: center;
            gap: 0.5rem;
        }

        .score-value {
            font-weight: 600;
            min-width: 45px;
        }

        .score-bar-container {
            width: 80px;
            height: 6px;
            background: var(--gray-200);
            border-radius: 3px;
            overflow: hidden;
        }

        .score-bar {
            height: 100%;
            background: linear-gradient(90deg, var(--success), var(--warning), var(--danger));
            border-radius: 3px;
        }

        .pattern-tags {
            display: flex;
            gap: 0.25rem;
            flex-wrap: wrap;
        }

        .pattern-tag {
            padding: 0.15rem 0.5rem;
            background: var(--gray-100);
            border-radius: 30px;
            font-size: 0.75rem;
            color: var(--gray-600);
        }

        .ring-badge {
            padding: 0.15rem 0.5rem;
            background: #f3e8ff;
            border-radius: 30px;
            font-size: 0.75rem;
            color: #6b21a8;
            font-family: monospace;
        }

        /* Loading */
        .loading {
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 3rem;
            color: var(--gray-600);
        }

        .spinner {
            width: 40px;
            height: 40px;
            border: 3px solid var(--gray-200);
            border-top-color: var(--primary);
            border-radius: 50%;
            animation: spin 1s linear infinite;
        }

        @keyframes spin {
            to { transform: rotate(360deg); }
        }

        /* Footer */
        .footer {
            margin-top: 3rem;
            padding: 2rem 0;
            text-align: center;
            color: var(--gray-600);
            border-top: 1px solid var(--gray-200);
        }

        /* Responsive */
        @media (max-width: 1200px) {
            .summary-grid {
                grid-template-columns: repeat(2, 1fr);
            }
            .two-column {
                grid-template-columns: 1fr;
            }
        }

        @media (max-width: 768px) {
            .summary-grid {
                grid-template-columns: 1fr;
            }
            .nav-wrapper {
                flex-direction: column;
                gap: 1rem;
            }
            .graph-header {
                flex-direction: column;
                align-items: flex-start;
            }
        }
    </style>
</head>
<body>
    <!-- Navbar -->
    <nav class="navbar">
        <div class="container nav-wrapper">
            <div class="logo">
                <div class="logo-icon"><i class="fas fa-chart-line"></i></div>
                <div>Fin<span style="color: var(--accent);">Trace</span></div>
            </div>
            <div class="nav-actions">
                <button class="btn btn-outline" onclick="downloadJSON()">
                    <i class="fas fa-download"></i> Download JSON
                </button>
                <a href="index.jsp" class="btn btn-primary">
                    <i class="fas fa-upload"></i> New Analysis
                </a>
            </div>
        </div>
    </nav>

    <main class="container">
        <!-- Summary Cards -->
        <div class="summary-grid">
            <div class="summary-card">
                <div class="card-icon blue">
                    <i class="fas fa-users"></i>
                </div>
                <div class="card-content">
                    <div class="card-label">Total Accounts</div>
                    <div class="card-value"><%= accounts.size() %></div>
                    <div class="card-trend">analyzed</div>
                </div>
            </div>
            
            <div class="summary-card">
                <div class="card-icon yellow">
                    <i class="fas fa-exclamation-triangle"></i>
                </div>
                <div class="card-content">
                    <div class="card-label">Suspicious</div>
                    <div class="card-value"><%= suspiciousCount %></div>
                    <div class="card-trend">score 50-80</div>
                </div>
            </div>
            
            <div class="summary-card">
                <div class="card-icon red">
                    <i class="fas fa-skull-crosswind"></i>
                </div>
                <div class="card-content">
                    <div class="card-label">High Risk</div>
                    <div class="card-value"><%= highRiskCount %></div>
                    <div class="card-trend">score 80+</div>
                </div>
            </div>
            
            <div class="summary-card">
                <div class="card-icon green">
                    <i class="fas fa-ring"></i>
                </div>
                <div class="card-content">
                    <div class="card-label">Fraud Rings</div>
                    <div class="card-value"><%= rings.size() %></div>
                    <div class="card-trend">detected</div>
                </div>
            </div>
        </div>

        <!-- Graph Visualization -->
        <div class="graph-section">
            <div class="graph-header">
            
                <div class="graph-title">
                    <h2><i class="fas fa-project-diagram" style="color: var(--primary);"></i> Transaction Network Graph</h2>
                </div>
                <div class="graph-legend">
                    <span class="legend-item"><span class="legend-dot normal"></span> Normal Account</span>
                    <span class="legend-item"><span class="legend-dot suspicious"></span> Suspicious (50-80)</span>
                    <span class="legend-item"><span class="legend-dot high-risk"></span> High Risk (80+)</span>
                    <span class="legend-item"><span class="legend-dot ring" style="background: #8b5cf6;"></span> Ring Member</span>
                </div>
            </div>
            <div id="network">
                <div class="loading">
                    <div class="spinner"></div>
                    <span style="margin-left: 1rem;">Loading graph...</span>
                </div>
            </div>
        </div>

        <!-- Two Column Layout -->
        <div class="two-column">
            <!-- Fraud Rings Table -->
            <div class="rings-section">
                <div class="section-header">
                    <h2><i class="fas fa-ring" style="color: var(--accent);"></i> Detected Fraud Rings</h2>
                    <span class="badge"><%= rings.size() %> rings</span>
                </div>
                <div class="table-container">
                    <table>
                        <thead>
                            <tr>
                                <th>Ring ID</th>
                                <th>Pattern</th>
                                <th>Members</th>
                                <th>Risk Score</th>
                                <th>Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% 
                            // Sort rings by risk score descending
                            Collections.sort(rings, (a, b) -> Double.compare(b.getRiskScore(), a.getRiskScore()));
                            for(FraudRing ring : rings) { 
                                String patternClass = "";
                                switch(ring.getPatternType()) {
                                    case "cycle": patternClass = "pattern-cycle"; break;
                                    case "fan_in": patternClass = "pattern-fan_in"; break;
                                    case "fan_out": patternClass = "pattern-fan_out"; break;
                                    case "shell_chain": patternClass = "pattern-shell_chain"; break;
                                }
                            %>
                            <tr class="ring-row" data-ring-id="<%= ring.getRingId() %>" data-members="<%= String.join(",", ring.getMemberAccounts()) %>">
                                <td><strong><%= ring.getRingId() %></strong></td>
                                <td>
                                    <span class="pattern-badge <%= patternClass %>">
                                        <%= ring.getPatternType().replace("_", " ") %>
                                    </span>
                                </td>
                                <td class="member-accounts"><%= ring.getMemberCount() %></td>
                                <td>
                                    <div class="risk-score">
                                        <span><%= String.format("%.1f", ring.getRiskScore()) %></span>
                                        <div class="risk-bar">
                                            <div class="risk-fill" style="width: <%= ring.getRiskScore() %>%"></div>
                                        </div>
                                    </div>
                                </td>
                                <td>
                                    <button class="btn-icon" onclick="highlightRing('<%= ring.getRingId() %>')">
                                        <i class="fas fa-eye"></i> Highlight
                                    </button>
                                </td>
                            </tr>
                            <% } %>
                            
                            <% if(rings.isEmpty()) { %>
                            <tr>
                                <td colspan="5" style="text-align: center; padding: 2rem; color: var(--gray-600);">
                                    <i class="fas fa-check-circle" style="color: var(--success); font-size: 2rem; margin-bottom: 1rem;"></i><br>
                                    No fraud rings detected
                                </td>
                            </tr>
                            <% } %>
                        </tbody>
                    </table>
                </div>
            </div>

            <!-- Suspicious Accounts -->
            <div class="accounts-section">
                <div class="section-header">
                    <h2><i class="fas fa-flag" style="color: var(--danger);"></i> Suspicious Accounts</h2>
                    <span class="badge"><%= suspiciousCount + highRiskCount %> flagged</span>
                </div>
                <div class="table-container">
                    <table>
                        <thead>
                            <tr>
                                <th>Account ID</th>
                                <th>Suspicion Score</th>
                                <th>Patterns</th>
                                <th>Ring ID</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% 
                            // Sort accounts by suspicion score descending
                            List<Account> sortedAccounts = new ArrayList<>(accounts.values());
                            sortedAccounts.sort((a, b) -> Double.compare(b.getSuspicionScore(), a.getSuspicionScore()));
                            
                            int displayedCount = 0;
                            for(Account acc : sortedAccounts) { 
                                if(acc.getSuspicionScore() > 50) { 
                                    displayedCount++;
                            %>
                            <tr>
                                <td><code><%= acc.getAccountId() %></code></td>
                                <td>
                                    <div class="score-cell">
                                        <span class="score-value"><%= String.format("%.1f", acc.getSuspicionScore()) %></span>
                                        <div class="score-bar-container">
                                            <div class="score-bar" style="width: <%= acc.getSuspicionScore() %>%"></div>
                                        </div>
                                    </div>
                                </td>
                                <td>
                                    <div class="pattern-tags">
                                        <% for(String pattern : acc.getDetectedPatterns()) { %>
                                            <span class="pattern-tag"><%= pattern %></span>
                                        <% } %>
                                    </div>
                                </td>
                                <td>
                                    <% if(acc.getRingId() != null && !acc.getRingId().isEmpty()) { %>
                                        <span class="ring-badge"><%= acc.getRingId() %></span>
                                    <% } else { %>
                                        <span style="color: var(--gray-400);">—</span>
                                    <% } %>
                                </td>
                            </tr>
                            <% 
                                }
                            } 
                            
                            if(displayedCount == 0) { 
                            %>
                            <tr>
                                <td colspan="4" style="text-align: center; padding: 2rem; color: var(--gray-600);">
                                    <i class="fas fa-check-circle" style="color: var(--success); font-size: 2rem; margin-bottom: 1rem;"></i><br>
                                    No suspicious accounts detected
                                </td>
                            </tr>
                            <% } %>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>

        <!-- Processing Time Info -->
        <div style="text-align: right; color: var(--gray-600); font-size: 0.9rem; margin-top: 1rem;">
            <i class="fas fa-clock"></i> Processing time: <%= procTime %> seconds
        </div>
    </main>

    <!-- Footer -->
    <footer class="footer">
        <div class="container">
            <p>FinTrace · Money Muling Detection Engine · RIFT 2026 Hackathon</p>
        </div>
    </footer>

    <script>
        // Store ring data for highlighting
        var ringMembers = {};
        <% for(FraudRing ring : rings) { %>
            ringMembers['<%= ring.getRingId() %>'] = [
                <% for(int i = 0; i < ring.getMemberAccounts().size(); i++) { %>
                    '<%= ring.getMemberAccounts().get(i) %>'<%= i < ring.getMemberAccounts().size() - 1 ? "," : "" %>
                <% } %>
            ];
        <% } %>

        // Load and render graph
        document.addEventListener('DOMContentLoaded', function() {
            loadGraph();
        });

        function loadGraph() {
            fetch('graphData')
                .then(response => response.json())
                .then(data => {
                    drawGraph(data);
                })
                .catch(error => {
                    console.error('Error loading graph:', error);
                    document.getElementById('network').innerHTML = 
                        '<div style="text-align: center; padding: 3rem; color: var(--danger);">' +
                        '<i class="fas fa-exclamation-triangle" style="font-size: 3rem; margin-bottom: 1rem;"></i><br>' +
                        'Failed to load graph. Please refresh the page.</div>';
                });
        }

        function drawGraph(data) {
            var container = document.getElementById('network');
            container.innerHTML = ''; // Clear loading spinner
            
            var nodes = new vis.DataSet(data.nodes);
            var edges = new vis.DataSet(data.edges);
            
            var options = {
                nodes: {
                    shape: 'dot',
                    size: 25,
                    font: {
                        size: 12,
                        face: 'Inter',
                        color: '#1e293b'
                    },
                    borderWidth: 2,
                    shadow: true,
                    scaling: {
                        min: 20,
                        max: 40
                    }
                },
                edges: {
                    width: 1.5,
                    shadow: true,
                    font: {
                        size: 10,
                        align: 'middle',
                        color: '#64748b'
                    },
                    arrows: {
                        to: { enabled: true, scaleFactor: 0.8 }
                    },
                    smooth: {
                        type: 'continuous',
                        roundness: 0.5
                    },
                    color: {
                        color: '#94a3b8',
                        highlight: '#d4a13e',
                        hover: '#d4a13e'
                    }
                },
                physics: {
                    stabilization: true,
                    barnesHut: {
                        gravitationalConstant: -2000,
                        centralGravity: 0.3,
                        springLength: 150,
                        springConstant: 0.04,
                        damping: 0.09
                    }
                },
                interaction: {
                    hover: true,
                    tooltipDelay: 200,
                    navigationButtons: true,
                    keyboard: true
                },
                layout: {
                    improvedLayout: true,
                    randomSeed: 42
                }
            };
            
            var network = new vis.Network(container, { nodes: nodes, edges: edges }, options);
            
            // Add click handler
            network.on('click', function(params) {
                if (params.nodes.length > 0) {
                    var nodeId = params.nodes[0];
                    showNodeDetails(nodeId);
                }
            });
            
            // Store network instance for highlighting
            window.currentNetwork = network;
            window.currentNodes = nodes;
            window.currentEdges = edges;
        }

        function highlightRing(ringId) {
            if (!window.currentNetwork || !window.currentNodes) {
                alert('Graph still loading. Please wait...');
                return;
            }
            
            var members = ringMembers[ringId];
            if (!members) return;
            
            // Reset all nodes to original colors
            var allNodes = window.currentNodes.get();
            var updatedNodes = [];
            
            allNodes.forEach(node => {
                // Store original color if not stored
                if (!node.originalColor) {
                    node.originalColor = node.color;
                    node.originalSize = node.size;
                }
                
                // Reset to original
                node.color = node.originalColor;
                node.size = node.originalSize;
                node.borderWidth = 1;
                
                // Highlight if in ring
                if (members.includes(node.id)) {
                    node.color = {
                        background: '#8b5cf6',
                        border: '#581c87',
                        highlight: {
                            background: '#7c3aed',
                            border: '#5b21b6'
                        }
                    };
                    node.size = 35;
                    node.borderWidth = 3;
                }
                updatedNodes.push(node);
            });
            
            window.currentNodes.update(updatedNodes);
            
            // Highlight edges within the ring
            if (window.currentEdges) {
                var allEdges = window.currentEdges.get();
                var updatedEdges = [];
                
                allEdges.forEach(edge => {
                    if (members.includes(edge.from) && members.includes(edge.to)) {
                        edge.color = '#8b5cf6';
                        edge.width = 3;
                    } else {
                        edge.color = '#94a3b8';
                        edge.width = 1.5;
                    }
                    updatedEdges.push(edge);
                });
                
                window.currentEdges.update(updatedEdges);
            }
        }

        function showNodeDetails(nodeId) {
            // Find account details from table
            var rows = document.querySelectorAll('.accounts-section tbody tr');
            for (var row of rows) {
                var accountCell = row.cells[0].textContent.trim();
                if (accountCell === nodeId) {
                    var score = row.cells[1].textContent.trim();
                    var patterns = row.cells[2].textContent.trim();
                    var ring = row.cells[3].textContent.trim();
                    
                    alert('📊 Account Details\n\n' +
                          'ID: ' + nodeId + '\n' +
                          'Score: ' + score + '\n' +
                          'Patterns: ' + (patterns || 'none') + '\n' +
                          'Ring: ' + (ring || 'none'));
                    return;
                }
            }
            alert('Account: ' + nodeId + '\nClick on the account in the table for details');
        }

        function downloadJSON() {
            fetch('downloadJson')
                .then(response => {
                    if (!response.ok) throw new Error('Download failed');
                    return response.blob();
                })
                .then(blob => {
                    var url = window.URL.createObjectURL(blob);
                    var a = document.createElement('a');
                    a.href = url;
                    a.download = 'finTrace_analysis_' + new Date().toISOString().slice(0,10) + '.json';
                    document.body.appendChild(a);
                    a.click();
                    window.URL.revokeObjectURL(url);
                    a.remove();
                })
                .catch(error => {
                    alert('Error downloading JSON: ' + error.message);
                });
        }
    </script>
</body>
</html>