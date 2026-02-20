# FinTrace
FinTrace - Graph-based money muling detection engine for RIFT 2026 Hackathon. Analyzes transaction CSV files to detect fraud patterns: circular routing (cycles), smurfing (fan-in/out), and shell networks. Features interactive graph visualization, suspicion scoring (0-100), and JSON export. Built with Jakarta EE, JSP, MySQL, vis.js.


# Project Title: FinTrace - Graph-Based Financial Crime Detection Engine for RIFT 2026 Hackathon


# Live Demo URL : https://fintrace-1-39q6.onrender.com


# Tech Stack :  Category	Technologies - 
Backend	Java (Jakarta EE 10), Apache Tomcat 10.1
Frontend	JSP, HTML5, CSS3, JavaScript
Database	TiDB Cloud (MySQL-compatible), MySQL 8.0.11
Graph Visualization	vis.js (force-directed graphs)
Libraries	OpenCSV (CSV parsing), Gson (JSON), Commons Lang3
Deployment	Render (Cloud hosting), GitHub (Version Control)
Build Tools	Manual JAR management, Eclipse IDE



# System Architecture : 
text
┌─────────────────┐     ┌──────────────────┐     ┌─────────────┐
│   Browser       │────▶│   Servlets       │────▶│  TiDB Cloud │
│  (JSP/HTML)     │◀────│  (Jakarta EE)    │◀────│  (MySQL)    │
└─────────────────┘     └──────────────────┘     └─────────────┘
                               │
                               ▼
                        ┌──────────────┐
                        │   Graph      │
                        │  Analysis    │
                        │   Engine     │
                        └──────────────┘

Key Components:
Frontend Layer: JSP pages with interactive graph visualization using vis.js
Controller Layer: Servlets handling file upload, data processing, and JSON export
Service Layer: Graph algorithms for fraud pattern detection
Database Layer: TiDB Cloud for persistent transaction storage
Deployment: Containerized with Docker on Render





# Algorithm Approach:
1. Graph Construction
Transactions are modeled as a directed graph G = (V, E) where:

V (nodes) = Bank accounts (sender_id, receiver_id)

E (edges) = Money transfers with amount and timestamp attributes

2. Cycle Detection (Circular Routing)
text
Algorithm: Depth-First Search with path tracking
- Search for cycles of length 3-5
- Time Complexity: O(V * (V+E)) with depth limiting
- Space Complexity: O(V) for recursion stack
Use Case: Detects money rotating through accounts to obscure origin (A→B→C→A)

3. Smurfing Pattern Detection (Fan-in/Fan-out)
text
Algorithm: Temporal grouping + degree counting
- Group transactions in 72-hour windows
- Fan-in: 10+ senders → 1 receiver (structuring)
- Fan-out: 1 sender → 10+ receivers (distribution)
- Time Complexity: O(n log n) for sorting and grouping
Use Case: Identifies structuring to avoid reporting thresholds

4. Shell Network Detection (Layering)
text
Algorithm: Path finding with shell account validation
- Find chains of 3+ hops
- Validate intermediate accounts (≤3 transactions)
- Time Complexity: O(V * E) with pruning
Use Case: Flags money passing through low-activity intermediary accounts

5. Force-Directed Graph Layout (Visualization & Suspicion Highlighting)
Algorithm: Force-Directed Graph (e.g., Fruchterman-Reingold / Spring Layout)
Nodes (accounts) repel each other, edges (transactions) act like springs to maintain structure
Iteratively adjust node positions to minimize energy and improve readability
Can highlight suspicious cycles or clusters by coloring or sizing nodes/edges based on suspicion score
Time Complexity: O(V²) per iteration (can be reduced with optimizations like Barnes-Hut)
Space Complexity: O(V + E) for storing nodes, edges, and position vectors
Use Case: Provides intuitive visualization of complex transaction networks; clusters or tightly connected nodes may indicate money-laundering rings, shell accounts, or circular routing (A→B→C→A).



# Suspicion Score Methodology
Scores are calculated on a 0-100 scale with weighted components:
Component	Weight	Calculation - 
Ring Membership	40%	+40 if account belongs to detected fraud ring
Transaction Velocity	20%	Based on transaction count (5-20 pts)
Amount Patterns	20%	Round numbers, just-below-threshold amounts
Time Patterns	10%	Odd hours (1-5 AM), weekend activity
Balance Ratio	10%	Low balance despite high transaction volume
Final Score Formula:
text
SuspicionScore = MIN(100, 
    (ringMember ? 40 : 0) +
    velocityScore(txCount) +
    amountPatternScore(transactions) +
    timePatternScore(transactions) +
    balanceRatioScore(account)
)




# Installation & Setup:
Java JDK 17 or higher
Apache Tomcat 10.1
MySQL 8.0.11 (or TiDB Cloud account)
Eclipse IDE (Enterprise Edition)
Local Setup Steps
Clone the repository
bash
git clone https://github.com/Priyank1922/FinTrace.git
cd FinTrace
Import into Eclipse
File → Import → Existing Projects into Workspace
Select the cloned directory
Add required JARs to WEB-INF/lib
mysql-connector-java-8.0.11.jar
opencsv-5.7.1.jar
commons-lang3-3.12.0.jar
gson-2.10.1.jar
jakarta.servlet.jsp.jstl-api-3.0.0.jar
jakarta.servlet.jsp.jstl-3.0.1.jar


                        
# Usage Instructions:
1. Upload CSV File
Navigate to home page
Click "Choose CSV File" and select your transaction CSV
Format must be: transaction_id,sender_id,receiver_id,amount,timestamp
Click "Analyze Transactions"

2. Explore Dashboard
Graph Visualization: Interactive network graph with color-coded nodes
Summary Cards: Total accounts, suspicious counts, fraud rings
Fraud Rings Table: Detected rings with patterns and risk scores
Suspicious Accounts: List of flagged accounts with explanations

3. Interactive Features
Hover over nodes: View account details
Click nodes: See detailed suspicion analysis
Highlight rings: Click "Highlight" button to focus on specific rings
Dark mode: Toggle theme for better visibility

4. Export Results
Click "Download JSON" to get analysis report
Format matches hackathon requirements:
json
{
  "suspicious_accounts": [...],
  "fraud_rings": [...],
  "summary": {
    "total_accounts_analyzed": 500,
    "suspicious_accounts_flagged": 15,
    "fraud_rings_detected": 4,
    "processing_time_seconds": 2.3
  }
} 


# Known Limitations:
Limitation	Description	Workaround
File Size	Max 10MB CSV upload	Split large files into smaller chunks
Cycle Length	Only detects cycles of length 3-5	Longer cycles may be missed but rare in practice
Real-time Processing	Batch processing only, no streaming	Acceptable for hackathon scope
False Positives	May flag high-volume merchants	Manual review recommended
Database	Free TiDB tier has 5GB limit	Upgrade for production use
Concurrency	Single-threaded processing	Multiple users may cause delays


# Team Members:
Priyank	Mehta    	   
Harsh Dwivedi	       
Dev Lalawat         	



Additional Notes
Performance Metrics
Processing Time: < 5 seconds for 10K transactions
Precision: > 70% (minimizes false positives)
Recall: > 60% (catches most fraud rings)
