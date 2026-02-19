<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>FinTrace Resources · premium features</title>
  <!-- Inter font -->
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
    }

    .container {
      max-width: 1280px;
      margin: 0 auto;
      padding: 0 2rem;
    }

    /* navbar (simplified) */
    .navbar {
      background: rgba(255,255,255,0.9);
      backdrop-filter: blur(10px);
      box-shadow: 0 2px 20px rgba(0,0,0,0.02);
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

    .logo {
      display: flex;
      align-items: center;
      gap: 0.5rem;
      font-size: 1.8rem;
      font-weight: 700;
      color: var(--primary-dark);
      letter-spacing: -0.02em;
      text-decoration: none;
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
      transition: transform 0.3s ease;
    }

    .logo:hover .logo-icon {
      transform: rotate(8deg) scale(1.05);
    }

    .logo-text span {
      color: var(--accent);
    }

    .nav-links a {
      text-decoration: none;
      font-weight: 500;
      color: var(--neutral-dark);
      margin-left: 2rem;
      transition: color 0.2s;
      border-bottom: 2px solid transparent;
      padding-bottom: 0.25rem;
    }

    .nav-links a:hover {
      color: var(--primary);
      border-bottom-color: var(--accent);
    }

    /* header */
    .page-header {
      padding: 3rem 0 1rem;
      text-align: center;
    }

    .page-header h1 {
      font-size: 2.8rem;
      font-weight: 700;
      color: var(--primary-dark);
      margin-bottom: 0.5rem;
    }

    .page-header p {
      font-size: 1.2rem;
      color: #475569;
      max-width: 700px;
      margin: 0 auto;
    }

    /* subscription card / pricing teaser */
    .subscription-banner {
      background: var(--accent-soft);
      border-radius: 40px;
      padding: 2rem;
      margin: 2rem 0 3rem;
      display: flex;
      align-items: center;
      justify-content: space-between;
      flex-wrap: wrap;
      gap: 2rem;
      border: 1px solid rgba(212,161,62,0.2);
    }

    .banner-text h2 {
      font-size: 1.8rem;
      color: var(--primary-dark);
      margin-bottom: 0.5rem;
    }

    .banner-text p {
      color: #334155;
    }

    .btn {
      display: inline-block;
      background-color: transparent;
      border: 2px solid var(--primary);
      padding: 0.8rem 2.5rem;
      border-radius: 40px;
      font-weight: 600;
      font-size: 1.1rem;
      cursor: pointer;
      transition: all 0.3s;
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

    /* features grid */
    .features-grid {
      display: grid;
      grid-template-columns: repeat(3, 1fr);
      gap: 2rem;
      margin: 3rem 0 4rem;
    }

    .feature-card {
      background: white;
      border-radius: 32px;
      padding: 2.5rem 2rem;
      box-shadow: var(--shadow);
      border: 1px solid #eef2f8;
      transition: all 0.4s;
      position: relative;
      overflow: hidden;
    }

    .feature-card:hover {
      transform: translateY(-8px);
      border-color: var(--accent);
      box-shadow: var(--shadow-hover);
    }

    .feature-icon {
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

    .feature-card:hover .feature-icon {
      background: var(--accent);
      color: white;
      transform: rotate(3deg) scale(1.1);
    }

    .feature-card h3 {
      font-size: 1.6rem;
      margin-bottom: 1rem;
      color: var(--primary-dark);
    }

    .feature-card p {
      color: #475569;
      margin-bottom: 1.5rem;
    }

    /* locked overlay */
    .locked-overlay {
      position: absolute;
      top: 0; left: 0; right: 0; bottom: 0;
      background: rgba(255,255,255,0.85);
      backdrop-filter: blur(4px);
      display: flex;
      flex-direction: column;
      align-items: center;
      justify-content: center;
      border-radius: 32px;
      z-index: 10;
      transition: opacity 0.3s;
    }

    .locked-overlay i {
      font-size: 3rem;
      color: var(--accent);
      margin-bottom: 1rem;
    }

    .locked-overlay p {
      font-weight: 600;
      color: var(--primary-dark);
    }

    .feature-card.unlocked .locked-overlay {
      display: none;
    }

    /* extra demo content for unlocked state */
    .demo-placeholder {
      background: var(--neutral-light);
      border-radius: 16px;
      padding: 1rem;
      margin-top: 1.5rem;
      font-size: 0.9rem;
      border: 1px dashed var(--primary-light);
      color: var(--primary);
    }

    .csv-fixer-demo {
      display: flex;
      gap: 0.5rem;
      align-items: center;
      flex-wrap: wrap;
    }

    .csv-fixer-demo input {
      flex: 1;
      padding: 0.6rem 1rem;
      border: 1px solid #d1d9e6;
      border-radius: 40px;
      font-family: 'Inter', sans-serif;
    }

    .csv-fixer-demo button {
      background: var(--primary);
      color: white;
      border: none;
      padding: 0.6rem 1.5rem;
      border-radius: 40px;
      cursor: pointer;
      font-weight: 500;
    }

    .risk-viz-placeholder {
      display: flex;
      align-items: flex-end;
      justify-content: center;
      gap: 0.5rem;
      height: 100px;
      margin-top: 1rem;
    }

    .risk-bar {
      width: 30px;
      background: var(--accent);
      border-radius: 10px 10px 0 0;
      transition: height 0.3s;
    }

    /* unlock message */
    .unlock-status {
      text-align: center;
      margin: 2rem 0;
      padding: 1rem;
      background: #e6f7e6;
      border-radius: 60px;
      color: #2e7d32;
      font-weight: 500;
      display: none;
    }

    .unlock-status.visible {
      display: block;
    }

    /* footer */
    .footer {
      background: #0f1a2c;
      color: #cbd5e1;
      padding: 2rem 0;
      margin-top: 3rem;
      text-align: center;
    }

    .footer a {
      color: var(--accent);
      text-decoration: none;
    }

    /* responsive */
    @media (max-width: 900px) {
      .features-grid {
        grid-template-columns: repeat(2, 1fr);
      }
    }

    @media (max-width: 600px) {
      .features-grid {
        grid-template-columns: 1fr;
      }
      .subscription-banner {
        flex-direction: column;
        text-align: center;
      }
    }

    /* animations */
    .fade-up {
      opacity: 0;
      transform: translateY(20px);
      animation: fadeUp 0.8s forwards;
    }

    @keyframes fadeUp {
      to { opacity: 1; transform: translateY(0); }
    }
  </style>
</head>
<body>
  <!-- simple navbar -->
  <nav class="navbar">
    <div class="container nav-wrapper">
      <a href="index.jsp" class="logo">
        <div class="logo-icon"><i class="fas fa-chart-line"></i></div>
        <div class="logo-text">Fin<span>Trace</span></div>
      </a>
      <div class="nav-links">
        <a href="index.jsp">Home</a>
        <a href="index.jsp#features">Features</a>
        <a href="index.jsp#about">About</a>
        <a href="#resources" style="border-bottom-color: var(--accent);">Resources</a>
      </div>
    </div>
  </nav>

  <div class="container">
    <!-- page header -->
    <div class="page-header fade-up">
      <h1>Premium resource hub</h1>
      <p>Unlock advanced tools for money muling detection. Subscribe to get full access.</p>
    </div>

    <!-- subscription status & unlock button -->
    <div class="subscription-banner fade-up" id="subscriptionBanner">
      <div class="banner-text">
        <h2><i class="fas fa-crown" style="color: var(--accent);"></i> Unlock all features</h2>
        <p>Behaviour monitoring · risk visualization · smart CSV validation & fixing</p>
      </div>
      <div>
        <button class="btn btn-accent" id="unlockButton">
          <i class="fas fa-lock-open"></i> <span id="buttonText">Subscribe now</span>
        </button>
      </div>
    </div>

    <!-- unlocked confirmation message -->
    <div class="unlock-status" id="unlockMessage">
      <i class="fas fa-check-circle"></i> You have access to all premium features. Thank you for subscribing!
    </div>

    <!-- features grid (3 cards) -->
    <div class="features-grid">
      <!-- Card 1: Behaviour Monitoring -->
      <div class="feature-card fade-up" id="card1">
        <div class="locked-overlay" id="overlay1">
          <i class="fas fa-lock"></i>
          <p>Locked · subscribe to unlock</p>
        </div>
        <div class="feature-icon"><i class="fas fa-eye"></i></div>
        <h3>Behaviour monitoring</h3>
        <p>Track suspicious patterns over time. Get alerts on unusual transaction behaviours linked to muling.</p>
        <div class="demo-placeholder" style="display: none;" id="demo1">
          <i class="fas fa-chart-line" style="color: var(--accent);"></i> Real-time behaviour analysis active. 
          <span style="display: block; background: #d4e0f0; height: 4px; width: 100%; margin-top: 8px; border-radius: 2px;"></span>
        </div>
      </div>

      <!-- Card 2: Risk Visualization -->
      <div class="feature-card fade-up" id="card2">
        <div class="locked-overlay" id="overlay2">
          <i class="fas fa-lock"></i>
          <p>Locked · subscribe to unlock</p>
        </div>
        <div class="feature-icon"><i class="fas fa-chart-pie"></i></div>
        <h3>Risk visualization</h3>
        <p>Interactive dashboards to visualise risk scores, network connections, and mule rings.</p>
        <div class="demo-placeholder" style="display: none;" id="demo2">
          <div class="risk-viz-placeholder">
            <div class="risk-bar" style="height: 60px;"></div>
            <div class="risk-bar" style="height: 90px;"></div>
            <div class="risk-bar" style="height: 40px;"></div>
            <div class="risk-bar" style="height: 70px;"></div>
          </div>
          <p style="font-size:0.8rem; margin-top:0.5rem;">risk distribution (sample)</p>
        </div>
      </div>

      <!-- Card 3: Smart CSV validation + fixer -->
      <div class="feature-card fade-up" id="card3">
        <div class="locked-overlay" id="overlay3">
          <i class="fas fa-lock"></i>
          <p>Locked · subscribe to unlock</p>
        </div>
        <div class="feature-icon"><i class="fas fa-file-csv"></i></div>
        <h3>Smart CSV validation + fixer</h3>
        <p>Automatically validate and repair common CSV formatting errors before analysis.</p>
        <div class="demo-placeholder" style="display: none;" id="demo3">
          <div class="csv-fixer-demo">
            <input type="text" placeholder="Upload or paste CSV..." disabled value="sample.csv">
            <button disabled><i class="fas fa-wrench"></i> Fix & validate</button>
          </div>
          <p style="font-size:0.8rem; margin-top:0.5rem;">(demo) Automatic delimiter detection, missing value imputation</p>
        </div>
      </div>
    </div>

    <!-- additional info (always visible) -->
    <div style="text-align: center; margin: 3rem 0; color: #475569;">
      <p><i class="fas fa-shield-alt" style="color: var(--accent);"></i> All premium features are part of the subscription plan. Unlock with a single payment.</p>
    </div>
  </div>

  <!-- footer -->
  <footer class="footer">
    <div class="container">
      <p>©️ 2026 FinTrace · <a href="#">Terms</a> · <a href="#">Privacy</a></p>
      <p style="margin-top: 0.5rem;">This is a demo subscription simulation.</p>
    </div>
  </footer>

  <script>
    (function() {
      // check localStorage for unlocked status
      let unlocked = localStorage.getItem('fintrace_premium') === 'true';

      const overlay1 = document.getElementById('overlay1');
      const overlay2 = document.getElementById('overlay2');
      const overlay3 = document.getElementById('overlay3');
      const demo1 = document.getElementById('demo1');
      const demo2 = document.getElementById('demo2');
      const demo3 = document.getElementById('demo3');
      const unlockMessage = document.getElementById('unlockMessage');
      const unlockButton = document.getElementById('unlockButton');
      const buttonText = document.getElementById('buttonText');

      // cards
      const card1 = document.getElementById('card1');
      const card2 = document.getElementById('card2');
      const card3 = document.getElementById('card3');

      function applyUnlock(shouldUnlock) {
        if (shouldUnlock) {
          // hide overlays, show demos
          overlay1.style.display = 'none';
          overlay2.style.display = 'none';
          overlay3.style.display = 'none';
          demo1.style.display = 'block';
          demo2.style.display = 'block';
          demo3.style.display = 'block';
          unlockMessage.classList.add('visible');
          buttonText.innerText = 'Subscribed';
          unlockButton.disabled = true;
          unlockButton.style.opacity = '0.7';
          unlockButton.style.cursor = 'default';
          // optional: remove lock class
          card1.classList.add('unlocked');
          card2.classList.add('unlocked');
          card3.classList.add('unlocked');
        } else {
          overlay1.style.display = 'flex';
          overlay2.style.display = 'flex';
          overlay3.style.display = 'flex';
          demo1.style.display = 'none';
          demo2.style.display = 'none';
          demo3.style.display = 'none';
          unlockMessage.classList.remove('visible');
          buttonText.innerText = 'Subscribe now';
          unlockButton.disabled = false;
          unlockButton.style.opacity = '1';
          unlockButton.style.cursor = 'pointer';
          card1.classList.remove('unlocked');
          card2.classList.remove('unlocked');
          card3.classList.remove('unlocked');
        }
      }

      // initial apply
      applyUnlock(unlocked);

      // unlock button click (simulate payment)
      unlockButton.addEventListener('click', function(e) {
        if (unlocked) return; // already unlocked

        // simulate payment processing
        unlockButton.innerHTML = '<i class="fas fa-spinner fa-pulse"></i> Processing...';
        unlockButton.disabled = true;

        setTimeout(() => {
          // after "payment" success
          localStorage.setItem('fintrace_premium', 'true');
          unlocked = true;
          applyUnlock(true);
          unlockButton.innerHTML = '<i class="fas fa-lock-open"></i> <span>Subscribed</span>';
        }, 1500);
      });

      // optional: reset for demo (can be triggered by url param or hidden button, but we keep it simple)
      // you can add a hidden reset link in footer if needed.
    })();
  </script>
</body>
</html>