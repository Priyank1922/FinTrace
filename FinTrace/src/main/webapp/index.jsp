<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>FinTrace · stop money muling</title>
  <!-- standard font: Inter -->
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Inter:opsz,wght@14..32,400;14..32,500;14..32,600;14..32,700&display=swap" rel="stylesheet">
  <!-- Font Awesome 6 -->
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css">
  <style>
    * {
      margin: 0;
      padding: 0;
      box-sizing: border-box;
    }

    body {
      font-family: 'Inter', sans-serif;
      background-color: #ffffff;
      color: #1e293b;
      line-height: 1.5;
      scroll-behavior: smooth;
      overflow-x: hidden;
    }

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

    .container {
      max-width: 1280px;
      margin: 0 auto;
      padding: 0 2rem;
    }

    /* ===== animations ===== */
    @keyframes float {
      0% { transform: translateY(0px); }
      50% { transform: translateY(-6px); }
      100% { transform: translateY(0px); }
    }

    @keyframes pulse-glow {
      0% { box-shadow: 0 0 0 0 rgba(212, 161, 62, 0.3); }
      70% { box-shadow: 0 0 0 10px rgba(212, 161, 62, 0); }
      100% { box-shadow: 0 0 0 0 rgba(212, 161, 62, 0); }
    }

    @keyframes slideIn {
      from {
        opacity: 0;
        transform: translateY(20px);
      }
      to {
        opacity: 1;
        transform: translateY(0);
      }
    }

    .float-animation {
      animation: float 4s ease-in-out infinite;
    }

    /* ===== navbar with logo on right ===== */
    .navbar {
      background: rgba(255,255,255,0.9);
      backdrop-filter: blur(10px);
      box-shadow: 0 2px 20px rgba(255, 190, 231, 0.02);
      padding: 0.8rem 0;
      position: sticky;
      top: 0;
      z-index: 100;
      border-bottom: 1px solid #eef2f6;
    }

    .nav-wrapper {
      display: flex;
      align-items: center;
      justify-content: space-between;
      flex-wrap: wrap;
    }

    /* navigation links on left */
    .nav-links {
      display: flex;
      gap: 2.5rem;
      align-items: center;
      flex-wrap: wrap;
    }

    .nav-links a {
      text-decoration: none;
      font-weight: 500;
      color: var(--neutral-dark);
      transition: color 0.2s;
      font-size: 1.05rem;
      border-bottom: 2px solid transparent;
      padding-bottom: 0.25rem;
    }

    .nav-links a:hover {
      color: var(--primary);
      border-bottom-color: var(--accent);
    }

    /* logo on right */
    .logo {
      display: flex;
      align-items: center;
      gap: 0.5rem;
      font-size: 1.8rem;
      font-weight: 700;
      color: var(--primary-dark);
      letter-spacing: -0.02em;
    }

    .logo-icon {
      background: var(--accent);
      color: white;
      width: 45px;
      height: 45px;
      border-radius: 14px;
      display: flex;
      align-items: center;
      justify-content: center;
      font-size: 1.6rem;
      transform: rotate(0deg);
      transition: transform 0.3s ease;
    }

    .logo:hover .logo-icon {
      transform: rotate(8deg) scale(1.05);
    }

    .logo-text span {
      color: var(--accent);
    }

    /* buttons */
    .btn {
      display: inline-block;
      background-color: transparent;
      border: 2px solid var(--primary);
      padding: 0.7rem 2rem;
      border-radius: 40px;
      font-weight: 600;
      font-size: 1rem;
      cursor: pointer;
      transition: all 0.3s cubic-bezier(0.2, 0.9, 0.3, 1.2);
      text-decoration: none;
      color: var(--primary);
    }

    .btn-primary {
      background-color: var(--primary);
      color: white;
      border: 2px solid var(--primary);
    }

    .btn-primary:hover {
      background-color: var(--primary-dark);
      border-color: var(--primary-dark);
      transform: scale(1.05) translateY(-3px);
      box-shadow: var(--shadow-hover);
    }

    .btn-outline:hover {
      background-color: var(--primary-light);
      border-color: var(--primary-dark);
      color: var(--primary-dark);
      transform: scale(1.02) translateY(-2px);
    }

    .btn-accent {
      background-color: var(--accent);
      color: var(--primary-dark);
      border: 2px solid var(--accent);
      font-weight: 700;
    }

    .btn-accent:hover {
      background-color: #e5b347;
      transform: scale(1.05) translateY(-3px);
      box-shadow: 0 10px 25px -5px rgba(212, 161, 62, 0.4);
      
    }

    /* ===== hero with simple, low‑contrast image ===== */
    .hero {
      padding: 5rem 0 6rem;
      background: linear-gradient(145deg, #ffffff 0%, #f5faff 100%);
      position: relative;
    }

    .hero-grid {
      display: grid;
      grid-template-columns: 1fr 1fr;
      gap: 4rem;
      align-items: center;
    }

    .hero-badge {
      background-color: var(--accent-soft);
      color: var(--accent);
      font-weight: 600;
      font-size: 0.9rem;
      padding: 0.3rem 1.1rem;
      border-radius: 30px;
      display: inline-block;
      margin-bottom: 1.5rem;
      border: 1px solid rgba(212,161,62,0.15);
    }

    .hero h1 {
      font-size: 3.3rem;
      font-weight: 700;
      line-height: 1.2;
      color: var(--primary-dark);
      margin-bottom: 1.5rem;
    }

    .hero h1 span {
      color: var(--accent);
      border-bottom: 3px solid var(--accent-soft);
    }

    .hero p {
      font-size: 1.2rem;
      color: #334155;
      max-width: 90%;
      margin-bottom: 2.5rem;
    }

    .hero-buttons {
      display: flex;
      gap: 1.5rem;
      flex-wrap: wrap;
    }

    /* new simple hero image (classic style) */
    .hero-image {
      background: url('https://images.unsplash.com/photo-1554224155-6726b3ff858f?ixlib=rb-4.0.3&auto=format&fit=crop&w=2067&q=80') center/cover no-repeat;
      min-height: 340px;
      border-radius: 30px;
      box-shadow: 0 10px 25px rgba(0,0,0,0.03);
      transition: all 0.4s ease;
    }

    .hero-image:hover {
      transform: scale(1.01);
      box-shadow: 0 20px 30px -5px rgba(0,0,0,0.1);
    }

    /* ===== upload section (new) ===== */
    .upload-section {
      padding: 4rem 0;
      background: white;
    }

    .upload-card {
      background: white;
      border-radius: 40px;
      padding: 3rem;
      box-shadow: var(--shadow);
      border: 1px solid #eef2f8;
      max-width: 700px;
      margin: 0 auto;
      animation: slideIn 0.6s ease-out;
    }

    .upload-card h3 {
      font-size: 2rem;
      color: var(--primary-dark);
      margin-bottom: 1rem;
      text-align: center;
    }

    .upload-card p {
      text-align: center;
      color: #64748b;
      margin-bottom: 2rem;
    }

    .error-message {
      background: var(--error-light);
      color: var(--error);
      padding: 1rem 1.5rem;
      border-radius: 60px;
      margin-bottom: 2rem;
      display: flex;
      align-items: center;
      gap: 0.8rem;
      font-weight: 500;
      border-left: 4px solid var(--error);
    }

    .error-message i {
      font-size: 1.2rem;
    }

    .upload-form {
      display: flex;
      flex-direction: column;
      gap: 2rem;
    }

    .file-input-container {
      position: relative;
      text-align: center;
    }

    .file-input-container input[type="file"] {
      position: absolute;
      width: 0.1px;
      height: 0.1px;
      opacity: 0;
      overflow: hidden;
      z-index: -1;
    }

    .file-label {
      display: flex;
      align-items: center;
      justify-content: center;
      gap: 1rem;
      padding: 2rem;
      background: var(--primary-light);
      color: var(--primary);
      border: 2px dashed var(--primary);
      border-radius: 30px;
      cursor: pointer;
      font-size: 1.1rem;
      font-weight: 500;
      transition: all 0.3s;
      width: 100%;
    }

    .file-label i {
      font-size: 2rem;
    }

    .file-label:hover {
      background: #d4e0f0;
      border-color: var(--accent);
      transform: translateY(-2px);
    }

    .file-label.selected {
      background: var(--success-light);
      border-color: var(--success);
      color: var(--success);
    }

    .btn-upload {
      background: var(--primary);
      color: white;
      border: none;
      padding: 1.2rem 2rem;
      border-radius: 60px;
      font-size: 1.2rem;
      font-weight: 600;
      cursor: pointer;
      transition: all 0.3s;
      display: flex;
      align-items: center;
      justify-content: center;
      gap: 1rem;
      width: 100%;
    }

    .btn-upload:hover:not(:disabled) {
      background: var(--primary-dark);
      transform: translateY(-3px);
      box-shadow: 0 20px 30px -10px rgba(30, 74, 111, 0.3);
    }

    .btn-upload:disabled {
      opacity: 0.6;
      cursor: not-allowed;
    }

    .btn-upload i {
      font-size: 1.3rem;
    }

    .csv-format {
      margin-top: 2rem;
      padding: 1.5rem;
      background: var(--neutral-light);
      border-radius: 24px;
    }

    .csv-format h4 {
      display: flex;
      align-items: center;
      gap: 0.5rem;
      color: var(--primary-dark);
      margin-bottom: 1rem;
    }

    .csv-format pre {
      background: #1e293b;
      color: #e2e8f0;
      padding: 1rem;
      border-radius: 16px;
      overflow-x: auto;
      font-size: 0.9rem;
      font-family: 'Menlo', 'Monaco', monospace;
    }

    /* ===== metrics with very soft bg ===== */
    .metrics {
      padding: 4rem 0;
      background: #f2f7ff;
    }

    .metrics-grid {
      display: flex;
      justify-content: space-around;
      flex-wrap: wrap;
      gap: 3rem;
      text-align: center;
    }

    .metric-item {
      flex: 1 1 200px;
    }

    .metric-number {
      font-size: 3.5rem;
      font-weight: 700;
      color: var(--primary);
      line-height: 1.2;
      transition: 0.2s;
    }

    .metric-item:hover .metric-number {
      transform: scale(1.05);
      color: var(--accent);
    }

    /* ===== features ===== */
    .features {
      padding: 5rem 0;
      background: white;
    }

    .section-header {
      text-align: center;
      margin-bottom: 3.5rem;
    }

    .section-header h2 {
      font-size: 2.6rem;
      font-weight: 700;
      color: var(--primary-dark);
    }

    .cards-grid {
      display: grid;
      grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
      gap: 2.5rem;
    }

    .card {
      background: white;
      border-radius: 32px;
      padding: 2.5rem 2rem;
      box-shadow: 0 5px 20px rgba(0,0,0,0.02);
      border: 1px solid #f0f4fa;
      transition: all 0.4s cubic-bezier(0.2, 0.9, 0.3, 1.1);
    }

    .card:hover {
      transform: translateY(-8px) scale(1.01);
      border-color: var(--accent);
      box-shadow: 0 30px 40px -20px rgba(212,161,62,0.2);
    }

    .card i {
      font-size: 2.5rem;
      color: var(--primary);
      background: var(--primary-light);
      width: 70px;
      height: 70px;
      border-radius: 20px;
      display: flex;
      align-items: center;
      justify-content: center;
      margin-bottom: 1.8rem;
      transition: 0.3s;
    }

    .card:hover i {
      background: var(--accent);
      color: white;
      transform: rotate(3deg) scale(1.1);
    }

    /* ===== how it works ===== */
    .how-it-works {
      padding: 5rem 0;
      background: #ffffff;
    }

    .steps {
      display: grid;
      grid-template-columns: repeat(3, 1fr);
      gap: 2rem;
      margin-top: 3rem;
    }

    .step {
      text-align: center;
      padding: 2.5rem 1.5rem;
      background: #fafcff;
      border-radius: 40px;
      border: 1px solid #eef2f8;
      transition: all 0.3s;
    }

    .step:hover {
      background: white;
      transform: scale(1.02) translateY(-5px);
      box-shadow: var(--shadow);
    }

    .step-icon {
      background: var(--primary-light);
      color: var(--primary);
      width: 80px;
      height: 80px;
      border-radius: 50%;
      display: flex;
      align-items: center;
      justify-content: center;
      margin: 0 auto 1.5rem;
      font-size: 2rem;
      font-weight: 700;
      transition: 0.4s;
    }

    .step:hover .step-icon {
      background: var(--accent);
      color: white;
      transform: rotate(360deg);
    }

    /* ===== about with simple image ===== */
    .about {
      padding: 5rem 0;
      background: #f9fcff;
    }

    .about-grid {
      display: grid;
      grid-template-columns: 1fr 1fr;
      gap: 4rem;
      align-items: center;
    }

    .about-content h2 {
      font-size: 2.5rem;
      font-weight: 700;
      color: var(--primary-dark);
      margin-bottom: 1.5rem;
    }

    .about-image {
      background: url('https://images.unsplash.com/photo-1521791136064-7986c2920216?ixlib=rb-4.0.3&auto=format&fit=crop&w=2069&q=80') center/cover no-repeat;
      min-height: 320px;
      border-radius: 40px;
      box-shadow: 0 5px 20px rgba(0,0,0,0.02);
      transition: 0.3s;
    }

    .about-image:hover {
      transform: scale(1.01);
      box-shadow: 0 20px 30px -5px rgba(0,0,0,0.05);
    }

    .about-highlight {
      background: var(--accent-soft);
      padding: 1.5rem 2rem;
      border-radius: 24px;
      border-left: 6px solid var(--accent);
      font-weight: 500;
      margin: 2rem 0 0;
    }

    /* ===== why choose FinTrace ===== */
    .why-choose {
      padding: 5rem 0;
      background: white;
    }

    .benefits-grid {
      display: grid;
      grid-template-columns: repeat(3, 1fr);
      gap: 2rem;
      margin-top: 3rem;
    }

    .benefit-item {
      text-align: center;
      padding: 2rem;
    }

    .benefit-item i {
      font-size: 2.8rem;
      color: var(--accent);
      background: var(--accent-soft);
      width: 80px;
      height: 80px;
      border-radius: 30px;
      display: flex;
      align-items: center;
      justify-content: center;
      margin: 0 auto 1.5rem;
      transition: 0.3s;
    }

    .benefit-item:hover i {
      background: var(--accent);
      color: white;
      transform: scale(1.1) rotate(2deg);
    }

    /* ===== FAQ section (new) ===== */
    .faq {
      padding: 5rem 0;
      background: #f9fcff;
    }

    .faq-grid {
      max-width: 900px;
      margin: 0 auto;
    }

    .faq-item {
      background: white;
      border-radius: 30px;
      margin-bottom: 1.2rem;
      border: 1px solid #eef2f8;
      overflow: hidden;
      transition: all 0.3s;
    }

    .faq-item:hover {
      border-color: var(--accent);
      box-shadow: 0 5px 15px rgba(212, 161, 62, 0.1);
    }

    .faq-question {
      padding: 1.5rem 2rem;
      display: flex;
      justify-content: space-between;
      align-items: center;
      cursor: pointer;
      font-weight: 600;
      font-size: 1.2rem;
      color: var(--primary-dark);
    }

    .faq-question i {
      color: var(--accent);
      transition: transform 0.3s;
    }

    .faq-item.active .faq-question i {
      transform: rotate(180deg);
    }

    .faq-answer {
      max-height: 0;
      padding: 0 2rem;
      overflow: hidden;
      transition: max-height 0.4s ease, padding 0.3s ease;
      color: #475569;
      line-height: 1.6;
    }

    .faq-item.active .faq-answer {
      max-height: 300px; /* enough for content */
      padding: 0 2rem 1.8rem 2rem;
    }

    /* ===== CTA ===== */
    .cta {
      padding: 6rem 0;
      background: linear-gradient(120deg, #0b2b4f, #1e4a6f);
      color: white;
      text-align: center;
    }

    .cta h2 {
      font-size: 2.8rem;
      font-weight: 700;
      margin-bottom: 1rem;
    }

    .cta-form {
      display: flex;
      justify-content: center;
      gap: 1rem;
      flex-wrap: wrap;
      max-width: 600px;
      margin: 2rem auto 0;
    }

    .cta-form input {
      flex: 1 1 250px;
      padding: 1rem 1.5rem;
      border: none;
      border-radius: 60px;
      font-family: 'Inter', sans-serif;
      font-size: 1rem;
      background: rgba(255,255,255,0.1);
      backdrop-filter: blur(4px);
      color: white;
      border: 1px solid rgba(255,255,255,0.2);
    }

    .cta-form input:focus {
      outline: none;
      background: rgba(255,255,255,0.2);
      border-color: var(--accent);
    }

    .cta-form .btn {
      background: var(--accent);
      border: none;
      color: #0b2b4f;
      font-weight: 700;
      border-radius: 60px;
      padding: 1rem 2.8rem;
    }

    .cta-form .btn:hover {
      background: #e5b347;
      transform: scale(1.05) translateY(-3px);
    }

    /* ===== footer ===== */
    .footer {
      background: #0f1a2c;
      color: #cbd5e1;
      padding: 3rem 0 2rem;
    }

    .footer-grid {
      display: grid;
      grid-template-columns: 2fr 1fr 1fr 1.5fr;
      gap: 3rem;
      margin-bottom: 3rem;
    }

    .footer-links a {
      display: block;
      color: #a0afc0;
      text-decoration: none;
      margin-bottom: 0.7rem;
      transition: 0.2s;
    }

    .footer-links a:hover {
      color: var(--accent);
      transform: translateX(5px);
    }

    .social-icons i {
      font-size: 1.5rem;
      margin-right: 1.2rem;
      color: #a0afc0;
      transition: 0.2s;
      display: inline-block;
    }

    .social-icons i:hover {
      color: var(--accent);
      transform: scale(1.2);
    }

    /* fade-up animation */
    .fade-up {
      opacity: 0;
      transform: translateY(30px);
      transition: opacity 0.8s ease, transform 0.8s ease;
    }

    .fade-up.visible {
      opacity: 1;
      transform: translateY(0);
    }

    .delay-1 { transition-delay: 0.1s; }
    .delay-2 { transition-delay: 0.2s; }
    .delay-3 { transition-delay: 0.3s; }

    /* loading spinner */
    .spinner {
      display: inline-block;
      width: 20px;
      height: 20px;
      border: 3px solid rgba(255,255,255,.3);
      border-radius: 50%;
      border-top-color: #fff;
      animation: spin 1s ease-in-out infinite;
    }

    @keyframes spin {
      to { transform: rotate(360deg); }
    }

    /* responsive */
    @media (max-width: 768px) {
      .hero-grid,
      .about-grid,
      .footer-grid {
        grid-template-columns: 1fr;
      }
      
      .steps,
      .benefits-grid {
        grid-template-columns: 1fr;
      }
      
      .hero h1 {
        font-size: 2.5rem;
      }
      
      .nav-wrapper {
        flex-direction: column;
        gap: 1rem;
      }
      
      .nav-links {
        justify-content: center;
      }
    }
  </style>
</head>
<body>
  <!-- navbar with logo on right (FAQ link added) -->
  <nav class="navbar">
    <div class="container nav-wrapper">
      <div class="nav-links">
        <a href="#">Home</a>
        <a href="#features">Features</a>
        <a href="#how">How it works</a>
        <a href="#about">About</a>
        <a href="#faq">FAQ</a>  <!-- new FAQ link -->
        <a href="#contact">Contact</a>
        <a href="resource.jsp">Premium Resources</a>
        <a href="#upload" class="btn">Upload CSV</a>
      </div>
      <!-- logo on right -->
      <div class="logo">
        <div class="logo-icon"><i class="fas fa-chart-line"></i></div>
        <div class="logo-text">Fin<span>Trace</span></div>
      </div>
    </div>
  </nav>

  <!-- hero with classic simple image -->
  <section class="hero">
    <div class="container hero-grid">
      <div class="fade-up visible">
        <span class="hero-badge"><i class="fas fa-shield-alt" style="margin-right: 0.5rem;"></i> fresh approach to anti‑muling</span>
        <h1>Detect. Disrupt. <span>Protect.</span> against money muling</h1>
        <p>FinTrace is a brand‑new platform built for financial institutions to identify and stop money muling networks with clarity and speed.</p>
        <div class="hero-buttons">
          <a href="#upload" class="btn btn-primary"><i class="fas fa-rocket" style="margin-right: 0.5rem;"></i> Get started</a>
          <a href="#how" class="btn btn-outline"><i class="fas fa-play" style="margin-right: 0.5rem;"></i> See how</a>
        </div>
      </div>
      <div class="hero-image fade-up visible delay-2 float-animation"></div>
    </div>
  </section>

  <!-- UPLOAD SECTION -->
  <section id="upload" class="upload-section">
    <div class="container">
      <div class="upload-card fade-up visible">
        <h3><i class="fas fa-upload" style="color: var(--accent); margin-right: 0.5rem;"></i> Upload Transaction CSV</h3>
        <p>Upload your transaction data to detect money muling patterns instantly</p>
        
        <% if(request.getParameter("error") != null) { %>
          <div class="error-message">
            <i class="fas fa-exclamation-circle"></i>
            Error: <%= request.getParameter("error") %>
          </div>
        <% } %>
        
        <form action="upload" method="post" enctype="multipart/form-data" class="upload-form" id="uploadForm">
          <div class="file-input-container">
            <input type="file" name="csvFile" id="csvFile" accept=".csv" required>
            <label for="csvFile" class="file-label" id="fileLabel">
              <i class="fas fa-cloud-upload-alt"></i>
              <span>Choose CSV file or drag it here</span>
            </label>
          </div>
          
          <button type="submit" class="btn-upload" id="submitBtn">
            <span class="btn-text"><i class="fas fa-chart-network"></i> Analyze Transactions</span>
            <span class="spinner" style="display: none;"></span>
          </button>
        </form>
        
        <div class="csv-format">
          <h4><i class="fas fa-file-csv"></i> Required CSV Format:</h4>
          <pre>transaction_id,sender_id,receiver_id,amount,timestamp
TXN001,ACC001,ACC002,5000.00,2024-01-15 10:30:00
TXN002,ACC002,ACC003,2500.00,2024-01-15 11:45:00
TXN003,ACC003,ACC001,7500.00,2024-01-15 14:20:00</pre>
        </div>
      </div>
    </div>
  </section>

  <!-- metrics -->
  <section class="metrics">
    <div class="container">
      <div class="metrics-grid">
        <div class="metric-item fade-up">
          <div class="metric-number" data-target="0">0</div>
          <div class="metric-label">institutions onboarded</div>
        </div>
        <div class="metric-item fade-up delay-1">
          <div class="metric-number" data-target="0">0</div>
          <div class="metric-label">accounts analysed</div>
        </div>
        <div class="metric-item fade-up delay-2">
          <div class="metric-number" data-target="100">0<small style="font-size:2rem;">%</small></div>
          <div class="metric-label">fresh & unbiased</div>
        </div>
        <div class="metric-item fade-up delay-3">
          <div class="metric-number" data-target="24">0<small style="font-size:2rem;">/7</small></div>
          <div class="metric-label">real‑time monitoring</div>
        </div>
      </div>
    </div>
  </section>

  <!-- features -->
  <section id="features" class="features">
    <div class="container">
      <div class="section-header fade-up">
        <h2>Built for clarity</h2>
        <p>Simple tools, powerful results.</p>
      </div>
      <div class="cards-grid">
        <div class="card fade-up delay-1">
          <i class="fas fa-eye"></i>
          <h3>Clear visibility</h3>
          <p>Dashboard that highlights unusual patterns without noise.</p>
        </div>
        <div class="card fade-up delay-2">
          <i class="fas fa-bolt"></i>
          <h3>Fast alerts</h3>
          <p>Get notified the moment a mule risk is detected.</p>
        </div>
        <div class="card fade-up delay-3">
          <i class="fas fa-file-alt"></i>
          <h3>Straightforward reporting</h3>
          <p>Generate reports ready for compliance and law enforcement.</p>
        </div>
      </div>
    </div>
  </section>

  <!-- how it works -->
  <section id="how" class="how-it-works">
    <div class="container">
      <div class="section-header fade-up">
        <h2>How FinTrace works</h2>
        <p>Three steps to a safer ecosystem</p>
      </div>
      <div class="steps">
        <div class="step fade-up delay-1">
          <div class="step-icon">1</div>
          <h3>Connect</h3>
          <p>Link your transaction data via secure API – it takes minutes.</p>
        </div>
        <div class="step fade-up delay-2">
          <div class="step-icon">2</div>
          <h3>Analyse</h3>
          <p>Our engine scans for mule behaviour patterns.</p>
        </div>
        <div class="step fade-up delay-3">
          <div class="step-icon">3</div>
          <h3>Act</h3>
          <p>Receive clear alerts and take informed action.</p>
        </div>
      </div>
    </div>
  </section>

  <!-- about with classic image -->
  <section id="about" class="about">
    <div class="container about-grid">
      <div class="about-content fade-up">
        <h2>What is money muling?</h2>
        <p>Money muling happens when criminals move illegal money through innocent people's accounts. Often students or job seekers are tricked into becoming mules.</p>
        <p><strong>FinTrace</strong> helps you spot these accounts early and protect the vulnerable – before the damage is done.</p>
        <div class="about-highlight">
          <i class="fas fa-leaf" style="margin-right: 0.5rem;"></i> We're just getting started – join us in building a safer financial world.
        </div>
      </div>
      <div class="about-image fade-up delay-2"></div>
    </div>
  </section>

  <!-- why choose FinTrace -->
  <section class="why-choose">
    <div class="container">
      <div class="section-header fade-up">
        <h2>Why FinTrace?</h2>
        <p>Fresh perspective, modern design, zero legacy bias.</p>
      </div>
      <div class="benefits-grid">
        <div class="benefit-item fade-up delay-1">
          <i class="fas fa-feather"></i>
          <h3>Light & intuitive</h3>
          <p>No clutter – just the insights you need.</p>
        </div>
        <div class="benefit-item fade-up delay-2">
          <i class="fas fa-lock-open"></i>
          <h3>Transparent by design</h3>
          <p>Clear methodology, explainable alerts.</p>
        </div>
        <div class="benefit-item fade-up delay-3">
          <i class="fas fa-hand-holding-heart"></i>
          <h3>Built with care</h3>
          <p>Focused on protecting people, not just compliance.</p>
        </div>
      </div>
    </div>
  </section>

  <!-- NEW FAQ SECTION -->
  <section id="faq" class="faq">
    <div class="container">
      <div class="section-header fade-up">
        <h2>Frequently Asked Questions</h2>
        <p>Everything you need to know about FinTrace</p>
      </div>
      <div class="faq-grid fade-up delay-1">
        <div class="faq-item">
          <div class="faq-question">
            <h3>What is money muling and how does FinTrace help?</h3>
            <i class="fas fa-chevron-down"></i>
          </div>
          <div class="faq-answer">
            <p>Money muling involves transferring illegal funds through third-party accounts. FinTrace uses advanced analytics to detect patterns indicative of muling activity, helping you flag suspicious accounts early.</p>
          </div>
        </div>
        <div class="faq-item">
          <div class="faq-question">
            <h3>Is my transaction data secure?</h3>
            <i class="fas fa-chevron-down"></i>
          </div>
          <div class="faq-answer">
            <p>Absolutely. All data is encrypted in transit and at rest. We never share your data with third parties. Our platform is built with bank-grade security.</p>
          </div>
        </div>
        <div class="faq-item">
          <div class="faq-question">
            <h3>What CSV format is required for upload?</h3>
            <i class="fas fa-chevron-down"></i>
          </div>
          <div class="faq-answer">
            <p>We require transaction_id, sender_id, receiver_id, amount, timestamp. Check the example in the upload section for reference.</p>
          </div>
        </div>
        <div class="faq-item">
          <div class="faq-question">
            <h3>Can I integrate FinTrace with my existing systems?</h3>
            <i class="fas fa-chevron-down"></i>
          </div>
          <div class="faq-answer">
            <p>Yes, we provide REST APIs and can work with your engineering team for seamless integration.</p>
          </div>
        </div>
      </div>
    </div>
  </section>

  <!-- CTA -->
  <section class="cta">
    <div class="container">
      <h2 class="fade-up">Ready to get started?</h2>
      <p class="fade-up delay-1">Upload your first CSV file and see FinTrace in action.</p>
      <div class="cta-form fade-up delay-2">
        <a href="#upload" class="btn btn-accent" style="font-size: 1.2rem; padding: 1rem 3rem;">
          <i class="fas fa-upload" style="margin-right: 0.5rem;"></i> Upload CSV Now
        </a>
      </div>
    </div>
  </section>

  <!-- footer -->
  <footer id="contact" class="footer">
    <div class="container">
      <div class="footer-grid">
        <div>
          <div style="display: flex; align-items: center; gap: 0.5rem; margin-bottom: 1rem;">
            <div style="background: var(--accent); width: 40px; height: 40px; border-radius: 12px; display: flex; align-items: center; justify-content: center; color: white; font-size: 1.3rem;"><i class="fas fa-chart-line"></i></div>
            <span style="font-size: 1.8rem; font-weight: 700; color: white;">Fin<span style="color: var(--accent);">Trace</span></span>
          </div>
          <p style="color: #a0afc0;">©️ 2026 FinTrace. All rights reserved.<br>Fresh, simple, effective.</p>
        </div>
        <div class="footer-links">
          <h4 style="color:white;">Product</h4>
          <a href="#features">Features</a>
          <a href="#">Pricing</a>
          <a href="#faq">FAQ</a>
        </div>
        <div class="footer-links">
          <h4 style="color:white;">Legal</h4>
          <a href="#">Privacy</a>
          <a href="#">Terms</a>
          <a href="#">Cookies</a>
        </div>
        <div class="footer-links">
          <h4 style="color:white;">Connect</h4>
          <div class="social-icons">
            <i class="fab fa-linkedin-in"></i>
            <i class="fab fa-x-twitter"></i>
            <i class="fab fa-github"></i>
          </div>
        </div>
      </div>
    </div>
  </footer>

  <!-- scroll, counter & FAQ accordion script -->
  <script>
    (function() {
      // Smooth scroll for anchor links
      document.querySelectorAll('a[href^="#"]').forEach(anchor => {
        anchor.addEventListener('click', function (e) {
          const href = this.getAttribute('href');
          if (href === "#") return;
          const target = document.querySelector(href);
          if (target) {
            e.preventDefault();
            target.scrollIntoView({ behavior: 'smooth', block: 'start' });
          }
        });
      });

      // Fade up animations
      const faders = document.querySelectorAll('.fade-up');
      const observer = new IntersectionObserver((entries) => {
        entries.forEach(entry => {
          if (entry.isIntersecting) entry.target.classList.add('visible');
        });
      }, { threshold: 0.2 });
      faders.forEach(fader => observer.observe(fader));

      // Counter animation
      const metricNumbers = document.querySelectorAll('.metric-number');
      const counterObserver = new IntersectionObserver((entries) => {
        entries.forEach(entry => {
          if (entry.isIntersecting) {
            const el = entry.target;
            const target = parseInt(el.getAttribute('data-target'), 10);
            if (target > 0) {
              let current = 0;
              const increment = target / 80;
              const updateCounter = () => {
                current += increment;
                if (current < target) {
                  el.innerText = Math.floor(current);
                  requestAnimationFrame(updateCounter);
                } else {
                  el.innerText = target + (el.querySelector('small') ? '%' : '');
                }
              };
              updateCounter();
            } else {
              el.innerText = '0' + (el.querySelector('small') ? '%' : '');
            }
            counterObserver.unobserve(el);
          }
        });
      }, { threshold: 0.5 });
      metricNumbers.forEach(num => counterObserver.observe(num));

      // File input handling
      const fileInput = document.getElementById('csvFile');
      const fileLabel = document.getElementById('fileLabel');
      const submitBtn = document.getElementById('submitBtn');
      const form = document.getElementById('uploadForm');
      const btnText = submitBtn?.querySelector('.btn-text');
      const spinner = submitBtn?.querySelector('.spinner');

      if (fileInput) {
        fileInput.addEventListener('change', function(e) {
          const fileName = e.target.files[0]?.name;
          const labelSpan = fileLabel.querySelector('span');
          
          if (fileName) {
            labelSpan.textContent = fileName;
            fileLabel.classList.add('selected');
            
            // Check if it's a CSV
            if (!fileName.toLowerCase().endsWith('.csv')) {
              labelSpan.textContent = 'Please select a CSV file';
              fileLabel.classList.remove('selected');
              fileInput.value = '';
              alert('Please select a valid CSV file');
            }
          } else {
            labelSpan.textContent = 'Choose CSV file or drag it here';
            fileLabel.classList.remove('selected');
          }
        });
      }

      if (form) {
        form.addEventListener('submit', function(e) {
          if (fileInput.files.length === 0) {
            e.preventDefault();
            alert('Please select a CSV file first');
            return;
          }
          // Show loading state
          if (btnText && spinner) {
            btnText.style.display = 'none';
            spinner.style.display = 'inline-block';
          }
          submitBtn.disabled = true;
          submitBtn.innerHTML = '<span class="spinner"></span> Processing...';
        });
      }

      // FAQ accordion functionality
      const faqItems = document.querySelectorAll('.faq-item');
      faqItems.forEach(item => {
        const question = item.querySelector('.faq-question');
        question.addEventListener('click', () => {
          // close others? optional, but we allow multiple open; to make accordion style (only one open) uncomment next lines
          // faqItems.forEach(i => {
          //   if (i !== item) i.classList.remove('active');
          // });
          item.classList.toggle('active');
        });
      });

      // Check for error parameter and scroll to upload
      const urlParams = new URLSearchParams(window.location.search);
      if (urlParams.has('error')) {
        document.getElementById('upload').scrollIntoView({ behavior: 'smooth' });
      }
    })();
  </script>
</body>
</html>
