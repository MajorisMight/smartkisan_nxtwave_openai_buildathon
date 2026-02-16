# 🌾 Kisan | AI-Powered Precision Agriculture Platform

> **Empowering farmers with intelligent insights for a sustainable and profitable future.**

Kisan is an AI-driven precision agriculture platform that bridges the gap between traditional farming and modern intelligence systems. By leveraging Large Language Models (LLMs), computer vision, weather analytics, and market intelligence, Kisan delivers actionable, real-time insights to help farmers increase yield, reduce waste, and maximize profits.

---

## 🌍 Vision

To democratize agricultural intelligence and make data-driven farming accessible to every farmer — regardless of land size, geography, or technical expertise.

---

## 🚀 Core Features

### 🧪 1. Intelligent Fertilizer Planner

Move beyond generic fertilizer recommendations.

Using a specialized agricultural LLM, Kisan analyzes:
- Crop type
- Soil composition
- Growth stage
- Local weather patterns
- Historical yield data

#### 🔬 What It Delivers:
- **Custom Fertilizer Recipes** — Precise NPK ratios and micronutrient mixes  
- **Application Schedules** — Optimized timing for maximum absorption  
- **Cost Optimization** — Prevents over-application and reduces expenses  
- **Sustainability Guidance** — Encourages balanced soil health  

---

### 🔍 2. Vision-Based Disease Diagnosis

Prevent crop loss before it spreads.

Using high-performance computer vision:

#### 📸 How It Works:
- Farmer uploads a photo of affected crop
- AI detects pests, fungal infections, or nutrient deficiencies
- Generates treatment recommendations instantly

#### 🧠 What You Get:
- **Instant Detection**
- **Organic & Chemical Treatment Options**
- **Root Cause Analysis**
- **Prevention Strategy**

---

### 🏛️ 3. Government Scheme Aggregator

Simplifying access to financial support.

Kisan automatically matches farmer profiles with:

- Regional schemes
- National subsidies
- Crop insurance programs
- Equipment grants

#### 📑 Smart Assistance:
- Eligibility matching
- Required document checklist
- Step-by-step application guidance
- Direct access links

---

### 🌱 4. Intelligent Crop Suggestion Engine

Make smarter planting decisions.

Kisan suggests optimal crops based on:

- Land size  
- Location & soil type  
- Current season  
- Risk appetite  
- Preferred crop category  
- Market demand trends  

This reduces uncertainty and improves profitability.

---

### 🌦️ 5. Weather-Aware Recommendations

Real-time advisory powered by weather intelligence.

Examples:
- 🌧️ Rain expected → Delay irrigation
- 💨 High wind forecast → Avoid fertilizer spraying
- 🌡️ Heatwave warning → Recommend shade or irrigation schedule changes
- ❄️ Frost risk → Suggest protective measures

---

### 🛒 6. Smart Marketplace

A built-in agricultural marketplace connecting:

- Farmers  
- Merchants  
- Buyers  
- Distributors  

#### 📊 Intelligent Insights:
- Real-time price trends
- Supply-demand analysis
- Storage vs. sell recommendations
- Regional crop demand forecasting

---

### 👨‍🌾 7. Community Intelligence Hub

A social space for farmers to:

- Share updates
- Post issues
- Discuss solutions
- Report pest outbreaks

#### 🧠 AI-Powered Monitoring:
Community posts are analyzed to:
- Detect emerging pest threats
- Identify regional crop diseases
- Issue early warnings
- Recommend preventive actions

---

### ⚙️ 8. C.A.R. Engine  
**Crop Action Recommendation Engine**

The heart of Kisan.

The CAR Engine aggregates signals from:

- Fertilizer Planner  
- Disease Detection  
- Marketplace  
- Weather Alerts  
- Community Posts  
- Government Updates  

It generates actionable triggers for farmers.

#### 📢 Example Triggers:
- “Multiple pest reports detected in your region. Inspect crops immediately.”
- “Market oversupply of wheat. Consider holding inventory.”
- “Heavy rainfall predicted. Delay nitrogen application by 3 days.”

---

### Prerequisites
* Flutter SDK installed
* A valid [Gemini API Key](https://aistudio.google.com/)
* or A valid [OpenAI key]

### Step-by-Step Setup
1.  **Clone the Repository:**
    ```bash
    git clone https://github.com/DheerajBishnoi/SmartKisan.git
    ```
2.  **Environment Configuration:**
    Navigate to the root directory and create a `.env` file at:
    `SmartKisan/kisan/.env`
    
    Add your API key inside:
    ```env
    GEMINI_API_KEY=your_actual_key_here
    or 
    GPT_API_KEY=""
    
    Select your desired model using:
    AI_PROVIDER="" (gpt/gemini)
    ```
3.  **Run the Application:**
    ```bash
    flutter pub get
    flutter run
    ```

---

## 📈 Future Roadmap
- [ ] Offline mode for remote areas using quantized local models.
- [ ] Integration with IoT soil sensors for real-time monitoring.
- [ ] Multilingual support (Voice-to-Text) for easier access.

---
*Created for NxtWave x OpenAI Buildathon 2025*